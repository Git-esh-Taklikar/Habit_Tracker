# HabitPulse 

A high-performance, real-time habit tracking web application built with Flutter Web and powered by Firebase. Designed to help users establish consistency, track daily streaks, visualize progress with GitHub-style contribution heatmaps, and maintain dedicated focus sprints.

**Live Demo:** [https://git-esh-taklikar.github.io/Habit_Tracker/](https://git-esh-taklikar.github.io/Habit_Tracker/)

---

## Project Overview

HabitPulse solves the problem of scattered daily routines by giving users a persistent, distraction-free environment to manage their personal goals. The application connects directly to a cloud database, allowing users to authenticate from any device, synchronize daily logs instantly, and evaluate long-term consistency through visual activity grids.

---

## Technical Stack & Architecture

* **Framework:** Flutter Web (Dart)
* **Backend as a Service:** Firebase Authentication & Cloud Firestore
* **Hosting & CI/CD:** GitHub Pages & Git Version Control
* **State Management:** Reactive UI via Streams and Futures

---


## Core Features

* **Cloud Sync Across Devices:** Firebase Authentication pairs user accounts with dedicated Firestore document paths, enabling updates on one device to reflect everywhere in real time.
* **GitHub-Style Contribution Heatmap:** Visualizes monthly frequency and habit execution volume via an aggregated color-coded activity grid.
* **Per-Habit Activity Matrices:** Deep-dive into individual tasks to see specific dates completed during the current month.
* **Integrated Pomodoro Focus Engine:** A dedicated 5-minute interval timer implemented using Dart streams to encourage immediate execution of tracked goals.
* **Clean State Initialization:** Starts empty on first sign-up with no dummy or mock records.

---

## Local Development Setup

### Prerequisites
* Flutter SDK (Version 3.47+ recommended)
* Google Chrome or any modern browser
* Git

### Installation

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/Git-esh-Taklikar/Habit_Tracker.git](https://github.com/Git-esh-Taklikar/Habit_Tracker.git)
   cd Habit_Tracker
2. **Install dependencies:**
   ```bash
   flutter pub get
3. **Run Locally:**
   ```bash
   flutter run -d chrome
## Web Build & Deployment

1. **Compile production bundle with repo prefix:**
   ```bash
   flutter build web --release --base-href "/Habit_Tracker/"
2. **Deploy bundle to the gh-pages branch:**
   ```bash
   cd build/web
   git add .
   git commit -m "Deploy production release"
   git push origin gh-pages
   cd ../..

3. **Commit source code to main**
   ```bash
   git add .
   git commit -m "Update project codebase"
   git push origin main



## Understanding How it works

## System Architecture & How It Works

HabitPulse is a cross-platform habit tracking application built with Flutter, designed to synchronize state in real time across Web and Android clients via Firebase.

---

### 1. Authentication Flow & Session Management

* **Firebase Authentication:** Handles user identity via Email/Password authentication.
* **Persistent Sessions:** User auth state is monitored via `FirebaseAuth.instance.authStateChanges()`. Upon initial login, Firebase securely persists authentication tokens locally (IndexedDB on Web, EncryptedSharedPreferences on Android).
* **Seamless App Launches:** The application root listens to this auth stream. If a valid session token exists, the user bypasses the login screen and lands directly on the Cloud Dashboard; if unauthenticated, the app displays the login/registration view.
* **Secure Logout:** Triggering the logout action invalidates the local session tokens and resets the stream to direct back to the authentication screen.

---

### 2. Database Design & Real-Time Sync (Cloud Firestore)

* **User Data Isolation:** Every authenticated user is assigned a unique UID. All user data is partitioned under an isolated Firestore collection path:
  ```text
  users/{userId}/habits/{habitId}
* **Real-Time Data Streams:** Dashboard views utilize Firestore `snapshots()` streams. When a habit is added, edited, or marked complete on one device, Firestore pushes updates over WebSockets/gRPC to all active clients within milliseconds.
* **Offline Caching:** Changes made while disconnected are queued locally and automatically synced when network connectivity is re-established.

---

### 3. Activity Map & Heatmap Computation

* **Daily Completion Tracking:** Each habit completion is logged with a timestamp formatted as `YYYY-MM-DD`.
* **Dynamic Grid Rendering:** The top activity map aggregates daily habit completion counts across the current month. The intensity/color of each block scales dynamically depending on consistency and total completed tasks for that specific day.

---

### 4. CI/CD & Android Release Pipeline (GitHub Actions)

* **Automated Cloud Builds:** Releases are managed via `.github/workflows/build_apk.yml` running on Ubuntu runners (`ubuntu-latest`).
* **Toolchain Alignment:** Configured with Java 17, Flutter stable, Kotlin Gradle Plugin 2.1.0, and Android Gradle Plugin 8.7.0 to guarantee reproducible, dependency-validated builds.
* **Direct Binary Distribution:** On pushing to the `main` branch (or releasing version tags), GitHub Actions compiles `assembleRelease`, generates `app-release.apk`, and publishes a GitHub Release asset with an automated direct download endpoint.


[Demo Vid.zip](https://github.com/user-attachments/files/32006577/Demo.Vid.zip)
