// Firebase configuration for local development (defaults to staging).
// This file is ignored by git and replaced during CI/CD from S3.
// RULE: firebase-config.js must always point to the same project as
// lib/firebase_options.dart (web) and the backend's Firebase Admin SDK.
self.firebaseConfig = {
    apiKey: "AIzaSyAOn7udVV71xCFutIQxmisE54ip27bjbf4",
    authDomain: "optmsg-staging.firebaseapp.com",
    projectId: "optmsg-staging",
    storageBucket: "optmsg-staging.firebasestorage.app",
    messagingSenderId: "1004260439071",
    appId: "1:1004260439071:web:17ae34a9ca726eb91f112a"
};
