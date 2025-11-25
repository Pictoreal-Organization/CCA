importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyBKSvpbS-nvL9DEYgNTGNkkK76mXgggbHE",
    authDomain: "cca-flutter-app.firebaseapp.com",
    projectId: "cca-flutter-app",
    storageBucket: "cca-flutter-app.firebasestorage.app",
    messagingSenderId: "116396092394",
    appId: "1:116396092394:web:377b25d2e8d73527d16093"
});

const messaging = firebase.messaging();