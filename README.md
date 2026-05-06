# 🪄 Magic Notes

A premium, state-of-the-art Flutter mobile application powered by **Firebase** and **Riverpod 3.x**. Designed with stunning glassmorphic aesthetics, glowing neon-themed UI elements, smooth micro-animations, and real-time cloud data synchronization.

---

## ✨ Features

### 🔐 1. Next-Gen Authentication Suite
*   **Google Sign-In (v7.x)**: Completely seamless auth flow using the modern authorization client structure.
*   **Secure Phone Auth (SMS OTP)**: Dynamic SMS verification, real-time OTP confirmation, and beautiful interactive fields.
*   **Email & Password Auth**: Clean registration and login interfaces with comprehensive error handling.

### 📝 2. Firestore-Backed Notes
*   **Real-time Synchronization**: Instant synchronization across devices powered by Cloud Firestore.
*   **Secure Partitioning**: Secured by granular Firestore Security Rules under `/users/{userId}/notes/{noteId}`.

### 💬 3. Real-Time Paginated Chat
*   **Ultra-Low Latency Streaming**: Instantly broadcasts and receives messages powered by a WebSocket connection to **Firebase Realtime Database**.
*   **Anchor-Based Pagination**: Employs efficient server-side pagination (`.endBefore().limitToLast()`) that automatically triggers when scrolling near the top of the chat, keeping memory footprint low.
*   **Dynamic Identity Resolution**: Automatically resolves sender names, defaulting to their custom display name, falling back to email prefixes (`username@domain` -> `username`), or defaulting safely to `User`.
*   **No-Jump Scroll Anchoring**: Intelligent scroll physics preserve reading position when older messages are loaded into the viewport.

### 👤 4. Premium Glassmorphic Profile
*   **Dynamic Avatar & Bio**: Editable Display Name and Bio fields.
*   **Cloud Synchronization**: Custom fields like **Bio** and **Location** are stored and streamed live from **Firebase Realtime Database**.
*   **Real-Time Analytics**:
    *   **Active Notes Stats**: Tracks and counts your active notes live via Riverpod.
    *   **Member Since**: Extracts and displays your account registration age.
*   **One-Tap UID Copy**: Quick account identification copy-to-clipboard shortcut.

### 🔔 5. Firebase Push Notifications (FCM)
*   **Multi-State Message Handling**:
    *   **Foreground Messages (`onMessage`)**: Receives real-time cloud notifications seamlessly while interacting inside the app.
    *   **Background Messages (`onBackgroundMessage`)**: High-resiliency static service worker handlers process push payloads while the app is closed or running in the background.
    *   **Click-to-Open Routing (`onMessageOpenedApp`)**: Automatically detects notification clicks to route users instantly to specific content.
*   **Secure Permissions**: Elegant opt-in dialogs request notification alerts, badges, and sound permissions safely from the operating system.

### 🧠 6. On-Device AI/ML Intelligence Suite (Google ML Kit)
*   **Optical Character Recognition (OCR)**: Real-time, fully on-device text recognition capable of instantly extracting Latin script texts from images.
*   **Smart Barcode & QR Scanner**: Scans, reads, and processes barcodes and QR codes dynamically from loaded images.
*   **Advanced Face Detection**: Highly accurate face detector that counts faces, traces facial contours, and processes facial expressions completely on-device without any cloud overhead.

---

## 🎨 Design Aesthetics
*   **Theme**: Deep Dark Mode with futuristic Neon Indigo (`#6C63FF`) and glowing Mint/Teal (`#00D4AA`) accents.
*   **Visual Enhancements**: Glassmorphic panels (`BackdropFilter` blur), smooth gradients, custom neon app icons, custom splash screens, and subtle micro-animations.

---

## 🛠️ Architecture & Tech Stack
*   **Framework**: [Flutter](https://flutter.dev) (iOS / Android)
*   **State Management**: [Riverpod 3.x](https://riverpod.dev) using modern `Notifier` and `NotifierProvider` classes for perfect responsiveness and separation of concerns.
*   **Routing**: [GoRouter](https://pub.dev/packages/go_router) for clean, declarative, and robust navigation routing.
*   **Database**: 
    *   [Cloud Firestore](https://firebase.google.com/docs/firestore) (Structured Notes)
    *   [Firebase Realtime Database](https://firebase.google.com/docs/database) (Custom User Profiles & Live Chats)

---

## 🚀 Getting Started

### 📋 Prerequisites
*   Flutter SDK installed (v3.22.3+ recommended).
*   Active Firebase Account.

### ⚙️ Installation & Setup

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/bilash-biswas/flutter-firebase.git
    cd flutter-firebase
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Configure Firebase**:
    *   Create a project in the [Firebase Console](https://console.firebase.google.com/).
    *   Register your Android (`com.example.flutter_firebase`) and iOS apps.
    *   Add your **SHA-1** and **SHA-256** fingerprints in Firebase Console -> Project Settings.
    *   Download `google-services.json` and place it in `android/app/google-services.json`.

4.  **Set Up Realtime Database Rules**:
    Go to Firebase Console -> Realtime Database -> Rules, and paste the following secure rules:
    ```json
    {
      "rules": {
        "messages": {
          ".read": "auth != null",
          ".write": "auth != null"
        },
        "users": {
          "$uid": {
            ".read": "auth != null && auth.uid == $uid",
            ".write": "auth != null && auth.uid == $uid"
          }
        }
      }
    }
    ```

5.  **Set Up Cloud Firestore Rules**:
    Go to Firebase Console -> Firestore Database -> Rules, and paste the following security rules to protect user notes partition:
    ```javascript
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        match /users/{userId}/notes/{noteId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
    ```

6.  **Run the Application**:
    ```bash
    flutter run
    ```

---

## 🔒 Security & Privacy
This repository is configured with secure development guardrails in [`.gitignore`](.gitignore) to ensure private signing keys (`*.keystore`, `*.jks`), password properties files (`*.properties`), and local environment variables (`.env*`) are automatically blocked from ever being committed to GitHub.

---

## 🌟 License
Distributed under the MIT License. See `LICENSE` for more information.
