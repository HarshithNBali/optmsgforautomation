import UIKit
import Flutter
import QuickLook
import FirebaseCore
import FirebaseMessaging
import app_links

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, MessagingDelegate, UIDocumentInteractionControllerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate {

    // Declare the document interaction controller as a class property (used for "Open In" fallback)
    private var documentInteractionController: UIDocumentInteractionController?
    // Holds the Flutter result callback until the viewer is fully dismissed,
    // so the Dart side only resolves (and deletes the temp file) after the
    // user has closed QuickLook or the "Open In" sheet.
    private var pendingFileResult: FlutterResult?
    // File URL for QLPreviewController data source
    private var previewFileURL: URL?

    // MARK: - Privacy Screen (biometric app lock)
    private var privacyView: UIView?
    // Default to true so the very first applicationWillResignActive (before
    // Flutter has a chance to communicate via method channel) shows the overlay.
    // Flutter will explicitly set this to false when the user is not
    // authenticated or has biometric disabled.
    private var privacyEnabled: Bool = true

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // I-F: Dynamically load flavor-specific Firebase configuration based on Bundle ID.
        let provider = Bundle.main.bundleIdentifier ?? "com.optmsg.mail"
        var configPath: String?

        if provider.contains("dev") {
            configPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist", inDirectory: "Firebase/dev")
        } else if provider.contains("stag") {
            // "stage" flavor uses "com.optmsg.stag" bundle ID
            configPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist", inDirectory: "Firebase/stage")
        } else {
            // Default to production
            configPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist", inDirectory: "Firebase/prod")
        }

        if let path = configPath, let options = FirebaseOptions(contentsOfFile: path) {
            FirebaseApp.configure(options: options)
        } else {
            // Fallback for standard location or root level
            FirebaseApp.configure()
        }

        Messaging.messaging().delegate = self

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

        application.registerForRemoteNotifications()

        // I-2: Do NOT call requestAuthorization() here.
        // The Flutter Firebase Messaging SDK (firebaseMessaging.requestPermission()
        // in Dart) is the sole owner of the permission dialog. Calling it here
        // as well caused a duplicate system prompt on first launch.

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("AppDelegate: Firebase registration token: \(String(describing: fcmToken))")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }

    // MARK: - UNUserNotificationCenterDelegate
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                          willPresent notification: UNNotification,
                                          withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("AppDelegate: userNotificationCenter willPresent: \(userInfo)")
        
        // Pass to Flutter
        super.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }

    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                          didReceive response: UNNotificationResponse,
                                          withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("AppDelegate: userNotificationCenter didReceive: \(userInfo)")
        
        // Pass to Flutter
        super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }

    // MARK: - FlutterImplicitEngineDelegate
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        setupFileOpenChannel(with: engineBridge.pluginRegistry)
        setupPrivacyChannel(with: engineBridge.pluginRegistry)
    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("🚀 [APNS_TOKEN] -> \(token)")
        
        Messaging.messaging().apnsToken = deviceToken
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    // MARK: - File Opening Setup
    private func setupFileOpenChannel(with registry: FlutterPluginRegistry) {
        guard let registrar = registry.registrar(forPlugin: "com.optmsg.mail.FileOpener") else {
            print("Unable to get plugin registrar for FileOpener")
            return
        }

        let fileChannel = FlutterMethodChannel(
            name: "com.optmsg.mail/file_opener",
            binaryMessenger: registrar.messenger()
        )

        fileChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "openFile" {
                guard let args = call.arguments as? [String: Any],
                      let filePath = args["filePath"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "File path is required",
                                      details: nil))
                    return
                }

                self?.openFile(filePath: filePath, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: - Open File Method
    private func openFile(filePath: String, result: @escaping FlutterResult) {
        let fileURL = URL(fileURLWithPath: filePath)

        // Check if file exists
        guard FileManager.default.fileExists(atPath: filePath) else {
            result(FlutterError(code: "FILE_NOT_FOUND",
                              message: "File not found at path: \(filePath)",
                              details: nil))
            return
        }

        // Get the root view controller from the active scene
        guard let rootViewController = keyRootViewController() else {
            result(FlutterError(code: "NO_VIEW_CONTROLLER",
                              message: "Unable to get root view controller",
                              details: nil))
            return
        }

        // Walk the presentation chain to find the topmost VC that can present.
        // If FlutterViewController is already presenting something (e.g. a
        // platform view overlay), presenting on it directly would fail.
        var topVC = rootViewController
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        self.pendingFileResult = result
        self.previewFileURL = fileURL

        // Present on main thread — use QLPreviewController directly instead of
        // UIDocumentInteractionController.presentPreview(). The latter relies on
        // a delegate callback to obtain the presenting VC, which can return an
        // invalid controller in release/TestFlight builds with the scene-based
        // lifecycle, causing presentPreview() to silently return false.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(FlutterError(code: "CONTROLLER_ERROR",
                                  message: "AppDelegate deallocated",
                                  details: nil))
                return
            }

            // Try QuickLook first — handles PDFs, images, Office docs, etc.
            if QLPreviewController.canPreview(fileURL as QLPreviewItem) {
                let qlController = QLPreviewController()
                qlController.dataSource = self
                qlController.delegate = self
                topVC.present(qlController, animated: true)
                // pendingFileResult resolved by previewControllerDidDismiss
            } else {
                // QuickLook can't handle this type — fall back to "Open In" sheet
                let docController = UIDocumentInteractionController(url: fileURL)
                docController.delegate = self
                self.documentInteractionController = docController

                let presented = docController.presentOpenInMenu(
                    from: .zero,
                    in: topVC.view,
                    animated: true
                )
                if !presented {
                    self.pendingFileResult = nil
                    self.previewFileURL = nil
                    result(FlutterError(code: "CANNOT_OPEN",
                                      message: "Cannot open this file type. No compatible app found.",
                                      details: nil))
                }
                // If presented, pendingFileResult resolved by
                // documentInteractionControllerDidDismissOpenInMenu
            }
        }
    }

    // MARK: - QLPreviewControllerDataSource
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewFileURL != nil ? 1 : 0
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewFileURL! as QLPreviewItem
    }

    // MARK: - QLPreviewControllerDelegate
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        // QuickLook closed — file is no longer in use, safe to delete immediately.
        pendingFileResult?(true)
        pendingFileResult = nil
        previewFileURL = nil
    }

    // MARK: - UIDocumentInteractionControllerDelegate (Open In fallback)
    // Called when the "Open In" sheet is dismissed (user picked an app or cancelled).
    // Returns false (not true) so the Dart side knows to delay file deletion —
    // iOS still needs the source file to complete the copy to the chosen app.
    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        pendingFileResult?(false)
        pendingFileResult = nil
        self.documentInteractionController = nil
    }

    // MARK: - Privacy Screen Lifecycle
    override func applicationWillResignActive(_ application: UIApplication) {
        super.applicationWillResignActive(application)
        guard privacyEnabled else { return }
        showPrivacyScreen()
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        // Do NOT auto-hide the privacy overlay here. Flutter will call
        // hidePrivacyOverlay via the method channel once it has rendered its
        // own privacy frame and is ready to show content. Auto-hiding here
        // caused a content flash because the native UIView was removed before
        // Flutter's ValueListenableBuilder had committed the privacy frame.
    }

    private func showPrivacyScreen() {
        guard privacyView == nil else { return }
        // Try keyWindow first, fall back to any window (covers edge cases
        // where keyWindow isn't set yet during app startup transitions).
        let allWindows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        guard let window = allWindows.first(where: { $0.isKeyWindow })
                ?? allWindows.first else { return }

        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor(red: 0.098, green: 0.325, blue: 0.647, alpha: 1.0) // #194FA5 brand blue
        overlay.tag = 999

        // Use LaunchScreen storyboard if available, otherwise plain blue
        if let launchSb = UIStoryboard(name: "LaunchScreen", bundle: nil)
            .instantiateInitialViewController()?.view {
            launchSb.frame = overlay.bounds
            launchSb.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlay.addSubview(launchSb)
        }

        window.addSubview(overlay)
        privacyView = overlay
    }

    private func hidePrivacyScreen() {
        privacyView?.removeFromSuperview()
        privacyView = nil
    }

    // MARK: - Privacy Method Channel
    private func setupPrivacyChannel(with registry: FlutterPluginRegistry) {
        guard let registrar = registry.registrar(forPlugin: "com.optmsg.mail.Privacy") else {
            print("Unable to get plugin registrar for Privacy")
            return
        }

        let channel = FlutterMethodChannel(
            name: "com.optmsg.mail/privacy",
            binaryMessenger: registrar.messenger()
        )

        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "setPrivacyScreenEnabled" {
                if let enabled = call.arguments as? Bool {
                    self?.privacyEnabled = enabled
                    // If the feature is being disabled while an overlay is
                    // showing (e.g. user turned off biometric in settings),
                    // hide it immediately.
                    if !enabled { self?.hidePrivacyScreen() }
                    result(true)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                       message: "Expected Bool argument",
                                       details: nil))
                }
            } else if call.method == "hidePrivacyOverlay" {
                // Flutter has rendered its frame and is ready to show content.
                // Remove the native UIView overlay regardless of privacyEnabled —
                // the flag still controls whether the overlay appears next time
                // the app is backgrounded.
                self?.hidePrivacyScreen()
                result(true)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: - Helpers
    private func keyRootViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
