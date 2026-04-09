// Import the Firebase config
importScripts(
    'firebase-config.js',
    "https://www.gstatic.com/firebasejs/12.10.0/firebase-app-compat.js",
    "https://www.gstatic.com/firebasejs/12.10.0/firebase-messaging-compat.js"
);

//Using singleton breaks instantiating messaging()
// App firebase = FirebaseWeb.instance.app;
if (firebase.messaging.isSupported()) {
    firebase.initializeApp(globalThis.firebaseConfig);
      const messaging = firebase.messaging();
      messaging.onBackgroundMessage(function (payload) {
          // W-3/H-01: Extract notification title and body from the FCM payload.
          // Search in notification payload first, then fall back to data payload.
          const notificationTitle = payload.notification?.title || payload.data?.title || 'New Message';
          const notificationOptions = {
              body: payload.notification?.body || payload.data?.body || 'You have received a new message.',
              icon: '/favicon.png', // Fallback to app favicon
              data: payload.data // Store payload so it's available on click
          };

          return registration.showNotification(notificationTitle, notificationOptions);
      });

      // W-3/H-01: Listen for notification clicks to focus the app tab.
      // Without this, clicking a native banner does nothing on the web.
      self.addEventListener('notificationclick', function (event) {
          event.notification.close();

          // Focus the window/tab if it's already open
          event.waitUntil(
              clients.matchAll({
                  type: 'window',
                  includeUncontrolled: true
              }).then(function (windowClients) {
                  for (const client of windowClients) {
                      if ('focus' in client) {
                          return client.focus();
                      }
                  }
                  if (clients.openWindow) {
                      return clients.openWindow('/');
                  }
              })
          );
      });
}


