// importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js");
// importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js");

// firebase.initializeApp({
//     apiKey: "AIzaSyBKSvpbS-nvL9DEYgNTGNkkK76mXgggbHE",
//     authDomain: "cca-flutter-app.firebaseapp.com",
//     projectId: "cca-flutter-app",
//     storageBucket: "cca-flutter-app.firebasestorage.app",
//     messagingSenderId: "116396092394",
//     appId: "1:116396092394:web:377b25d2e8d73527d16093"
// });

// const messaging = firebase.messaging();

importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyBKSvpbS-nvL9DEYgNTGNkkK76mXgggbHE",
  authDomain: "cca-flutter-app.firebaseapp.com",
  projectId: "cca-flutter-app",
  storageBucket: "cca-flutter-app.firebasestorage.app",
  messagingSenderId: "116396092394",
  appId: "1:116396092394:web:95809f64e81fa484d16093"
});

const messaging = firebase.messaging();

// Handle Background Messages
messaging.onBackgroundMessage((payload) => {
  console.log('🌐 Background message:', payload);
  const title = payload.notification?.title || 'PictoCreds';
  const options = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png', // Ensure this path matches your icons
    data: payload.data // Keeps the redirect info
  };
  return self.registration.showNotification(title, options);
});

self.addEventListener('notificationclick', function(event) {
  console.log('Notification clicked!');
  event.notification.close(); // Close the notification immediately

  // 1. Get the data passed from the backend
  const data = event.notification.data;
  
  // 2. Construct the Absolute URL (Full Address)
  // self.location.origin gives "https://your-app.vercel.app"
  const urlToOpen = new URL(self.location.origin);
  
  // Add the redirect parameter based on data type
  if (data && (data.type === 'TASK_CREATED' || data.type === 'TASK_UPDATED' || data.type === 'SUBTASK_UPDATED')) {
    urlToOpen.searchParams.append('redirect', 'tasks');
  } else if (data && (data.type === 'MEETING_CREATED' || data.type === 'MEETING_UPDATED')) {
    urlToOpen.searchParams.append('redirect', 'meetings');
  }

  // 3. Convert to string (e.g., "https://cca.vercel.app/?redirect=tasks")
  const fullUrl = urlToOpen.toString();

  // 4. Open/Focus Logic
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(clientList) {
      // A. If a tab is already open, focus it and navigate
      for (var i = 0; i < clientList.length; i++) {
        var client = clientList[i];
        // Check if the tab belongs to our site
        if (client.url.indexOf(self.location.origin) >= 0 && 'focus' in client) {
          return client.focus().then(() => client.navigate(fullUrl));
        }
      }
      
      // B. If no tab is open, force open a new window
      if (clients.openWindow) {
        return clients.openWindow(fullUrl);
      }
    })
  );
});