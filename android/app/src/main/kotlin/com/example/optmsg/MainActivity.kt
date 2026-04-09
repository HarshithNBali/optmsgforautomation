package com.optmsg.mail

import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity: FlutterFragmentActivity() {

    // AN-7: Use TextureView instead of the default SurfaceView. SurfaceView
    // renders in a separate hardware compositor layer with special z-ordering.
    // When an opaque native View (privacy overlay) is added on top via
    // addContentView() and then removed, the SurfaceView's compositor layer
    // may not re-engage, causing a permanent black screen. This is triggered
    // by the BiometricPrompt dialog's onPause/onResume lifecycle churn.
    // TextureView participates in the normal View drawing pipeline, so
    // adding/removing overlays works correctly. The ~1 frame of extra latency
    // is imperceptible for a non-gaming app.
    override fun getRenderMode(): RenderMode = RenderMode.texture
    private val CHANNEL = "com.optmsg/intent"
    private val PRIVACY_CHANNEL = "com.optmsg.mail/privacy"
    // Default to true so the very first onPause (before Flutter has a chance
    // to communicate via method channel) shows the overlay. Flutter will
    // explicitly set this to false when the user is not authenticated or has
    // biometric disabled.
    private var privacyEnabled = true

    // The native View sitting on top of the window when the app is backgrounded.
    // Removed only when Flutter explicitly calls hidePrivacyOverlay — NOT on
    // onResume, which would re-introduce the content flash on return from background.
    private var privacyOverlayView: View? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Set FLAG_SECURE immediately — before Flutter starts, before any
        // app-switcher screenshot can be taken. This blanks the app in the
        // recent apps view. Flutter will clear this flag via the method
        // channel if the user is not authenticated or has biometric disabled.
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        Log.d("MainActivity", "onCreate: action=${intent.action}, data=${intent.data}, extras=${intent.extras}")

        // ── PASSKEY DEBUG — print signing fingerprints & asset links host ──
        debugPasskeyInfo()
    }

    /**
     * TEMPORARY: Prints the app's SHA-256 signing certificate fingerprint(s),
     * package name, and the host URLs where Android looks for assetlinks.json.
     * Remove after passkey debugging is complete.
     */
    private fun debugPasskeyInfo() {
        val tag = "PASSKEY-DEBUG"
        Log.w(tag, "╔═══════════════════════════════════════════════════")
        Log.w(tag, "║ PASSKEY DEBUG INFO")
        Log.w(tag, "╠═══════════════════════════════════════════════════")

        // 1. Package name (must match assetlinks.json "package_name")
        Log.w(tag, "║ Package name: $packageName")

        // 2. Signing certificate SHA-256 fingerprint(s)
        try {
            val signingInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val signingInfo = packageManager.getPackageInfo(
                    packageName, PackageManager.GET_SIGNING_CERTIFICATES
                ).signingInfo
                if (signingInfo?.hasMultipleSigners() == true) {
                    signingInfo.apkContentsSigners
                } else {
                    signingInfo?.signingCertificateHistory
                }
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(
                    packageName, PackageManager.GET_SIGNATURES
                ).signatures
            }

            signingInfos?.forEachIndexed { index, sig ->
                val md = MessageDigest.getInstance("SHA-256")
                md.update(sig.toByteArray())
                val fingerprint = md.digest().joinToString(":") { "%02X".format(it) }
                Log.w(tag, "║ Signing cert #$index SHA-256: $fingerprint")
            }
        } catch (e: Exception) {
            Log.e(tag, "║ Failed to read signing certificates: $e")
        }

        // 3. Domain verification status + asset links URLs (API 31+)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val dvm = getSystemService(
                    android.content.pm.verify.domain.DomainVerificationManager::class.java
                )
                val userState = dvm.getDomainVerificationUserState(packageName)
                userState?.hostToStateMap?.forEach { (host, state) ->
                    val stateStr = when (state) {
                        android.content.pm.verify.domain.DomainVerificationUserState.DOMAIN_STATE_VERIFIED -> "VERIFIED"
                        android.content.pm.verify.domain.DomainVerificationUserState.DOMAIN_STATE_SELECTED -> "SELECTED"
                        android.content.pm.verify.domain.DomainVerificationUserState.DOMAIN_STATE_NONE -> "NONE (NOT VERIFIED)"
                        else -> "UNKNOWN($state)"
                    }
                    Log.w(tag, "║ Domain: $host → $stateStr")
                    Log.w(tag, "║   → https://$host/.well-known/assetlinks.json")
                }
            } else {
                Log.w(tag, "║ API < 31 — run: adb shell pm get-app-links $packageName")
            }
        } catch (e: Exception) {
            Log.e(tag, "║ Failed to read domain verification: $e")
        }

        Log.w(tag, "╚═══════════════════════════════════════════════════")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Intent / mailto channel (existing)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInitialEmail") {
                val email = getInitialEmail(intent)
                result.success(email)
            } else {
                result.notImplemented()
            }
        }

        // Privacy screen channel — mirrors iOS AppDelegate behaviour.
        // setPrivacyScreenEnabled(bool): enables/disables FLAG_SECURE and the overlay feature.
        // hidePrivacyOverlay: removes the current overlay when Flutter is ready to show content.
        // setBiometricInProgress(bool): suppresses overlay during biometric dialog lifecycle.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PRIVACY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setPrivacyScreenEnabled" -> {
                        val enabled = call.arguments as? Boolean ?: false
                        privacyEnabled = enabled
                        if (enabled) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            // Feature disabled while overlay may be showing — hide it now.
                            hidePrivacyOverlay()
                        }
                        result.success(true)
                    }
                    "hidePrivacyOverlay" -> {
                        // Flutter has rendered its frame and is ready to show content.
                        hidePrivacyOverlay()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

    }

    // Add overlay when the app is backgrounded (equivalent to iOS applicationWillResignActive).
    // This ensures the OS Recent Apps thumbnail never captures app content.
    // The 2-second grace period in the Flutter controller prevents the biometric
    // dialog's lifecycle churn from causing re-lock, so no biometricInProgress
    // check is needed here.
    override fun onPause() {
        super.onPause()
        if (privacyEnabled) showPrivacyOverlay()
    }

    // Do NOT auto-hide in onResume — Flutter controls removal via hidePrivacyOverlay.
    // Auto-hiding here would re-introduce the content flash because the overlay
    // would be removed before Flutter has rendered its privacy frame.

    private fun showPrivacyOverlay() {
        if (privacyOverlayView != null) return
        val overlay = View(this)
        overlay.setBackgroundColor(Color.parseColor("#194FA5")) // brand blue — matches iOS
        window.addContentView(
            overlay,
            ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        )
        privacyOverlayView = overlay
    }

    private fun hidePrivacyOverlay() {
        privacyOverlayView?.let { overlay ->
            (overlay.parent as? ViewGroup)?.let { parent ->
                parent.removeView(overlay)
                // Force the parent ViewGroup to re-layout. On some Android
                // devices, removing a full-screen opaque view that was covering
                // the FlutterSurfaceView doesn't automatically trigger
                // recomposition of the hardware surface underneath, leaving a
                // permanent black screen. requestLayout + invalidate forces
                // the compositor to redraw.
                parent.requestLayout()
                parent.invalidate()
            }
            privacyOverlayView = null
        }
        // Also invalidate the window's decor view as a fallback to ensure
        // the Flutter rendering surface is re-composited.
        window?.decorView?.let { decor ->
            decor.requestLayout()
            decor.invalidate()
        }
    }

    override fun onNewIntent(newIntent: Intent) {
        super.onNewIntent(newIntent)
        setIntent(newIntent)
        Log.d("MainActivity", "onNewIntent: action=${newIntent.action}, data=${newIntent.data}, extras=${newIntent.extras}")
        val email = getInitialEmail(newIntent)
        val engine = flutterEngine
        if (engine != null) {
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("newIntent", email)
        } else {
            Log.d("MainActivity", "FlutterEngine is null in onNewIntent")
        }
    }

    private fun getInitialEmail(intent: Intent): String? {
        // 1. Try to get the email from the data URI (works for VIEW)
        intent.data?.let { uri ->
            if (uri.scheme == "mailto") {
                return uri.schemeSpecificPart
            }
        }
        // 2. For SENDTO intents, check if extras contain the email.
        if (intent.action == Intent.ACTION_SENDTO) {
            val extras = intent.extras
            extras?.let {
                val emails = it.getStringArray(Intent.EXTRA_EMAIL)
                if (emails != null && emails.isNotEmpty()) {
                    return emails[0]
                }
            }
        }
        return null
    }
}
