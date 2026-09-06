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
