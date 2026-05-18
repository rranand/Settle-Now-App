# SettleNow

A production-grade social expense management and settlement platform built with Flutter.

SettleNow helps users manage shared expenses, split bills, maintain personal ledgers, track balances, and collaborate financially through groups and rooms — all within a fast, scalable, and modern mobile experience.

The application is designed with a strong focus on scalability, modular architecture, performance optimization, and smooth user workflows.

---

# ✨ Features

## 👤 Authentication & User Management

- Secure authentication system
- Google Sign-In integration
- Persistent user sessions
- JWT-based authentication handling
- Device-aware session management

---

## 💸 Expense Management

- Create and manage shared expenses
- Split expenses among friends or groups
- Equal and custom splitting workflows
- Real-time balance calculations
- Expense history tracking
- Settlement workflows
- Shared activity timeline

---

## 👥 Group & Room System

- Create collaborative expense rooms
- Add multiple participants
- Track room-wise balances
- Shared expense management
- Group activity tracking
- Room-based settlement handling

---

## 📒 LenDen (Personal Ledger System)

A dedicated mutual ledger system between two users for tracking informal borrow/lend transactions.

### Features

- Shared ledger between users
- Running balance calculations
- Chat-style transaction history
- Track gave/owe transactions
- Editable transactions for creators
- Mutual financial tracking

---

## 🔔 Smart Notification System

- Firebase Cloud Messaging integration
- Local notifications support
- Background notification handling
- Financial activity alerts
- Group and settlement notifications
- Engagement-focused reminder workflows

---

## 📊 Analytics & Insights

- Expense analytics dashboards
- Spending summaries
- Financial trend visualization
- Interactive charts
- Timeline-based activity tracking

---

## 🚀 User Experience Enhancements

- Smooth declarative navigation
- Optimized image caching
- Responsive UI layouts
- Sticky headers and advanced scrolling
- Shimmer loading effects
- Floating quick action workflows
- Adaptive typography support

---

## 📱 Modern Mobile Capabilities

- In-app update support
- In-app review prompts
- Share and invite workflows
- External URL handling
- Cached media optimization
- App version management

---

# 🏗️ Architecture

The application follows a modular and scalable architecture focused on maintainability and performance.

## Architecture Highlights

- Feature-driven folder structure
- Separation of concerns
- Modular business logic
- Centralized routing system
- Reusable UI components
- Optimized async handling
- Clean API integration layer

---

# ⚙️ State Management

The application uses a hybrid state management approach:

- **Provider** → lightweight reactive state handling
- **Flutter Bloc / Bloc** → scalable business logic and predictable state flows

This combination enables efficient UI updates while keeping complex workflows maintainable.

---

# 🔥 Firebase Integrations

- Firebase Core
- Firebase Cloud Messaging
- Firebase Analytics
- Firebase Crashlytics
- Firebase Remote Config

### Used For

- Push notifications
- Analytics tracking
- Crash reporting
- Runtime feature management
- User engagement monitoring

---

# 📂 Project Structure

```bash
lib/
├── bloc
├── constant
├── core.dart
├── cubit
├── data
├── firebase
├── internationalization
├── main.dart
├── model
├── notification
├── provider
├── router
├── screen
├── theme
└── util
```

---

# ⚡ Performance Optimizations

- Cached network image handling
- Lazy-loaded workflows
- Reduced unnecessary widget rebuilds
- Optimized async operations
- Lightweight routing architecture
- Efficient API handling
- Smooth animation rendering

---

# 📈 Engineering Highlights

- Production-grade Flutter application
- Solely designed and developed
- Built with scalability and maintainability in mind
- Modular architecture for long-term growth
- Optimized for smooth mobile experience
- Designed to support evolving feature workflows

---

# 🛠️ Tech Stack

## Mobile Development

- Flutter
- Dart

## State Management

- Provider
- Flutter Bloc
- Bloc

## Backend & Services

- Node.js + Express.js (REST API)
- Go (async processing, notification workflows)
- AWS Lambda (serverless deployment)
- AWS SQS (message queue)
- Redis (caching layer)
- MongoDB (primary database)

## Analytics & Monitoring

- Firebase Analytics
- Firebase Crashlytics
- Firebase Remote Config

---

# 🚀 Getting Started

## Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio / VS Code
- Firebase Project Setup

---

## Installation

### Clone Repository

```bash
git clone https://github.com/rranand/Settle-Now-App.git
cd Settle-Now-App
```

### Install Dependencies

```bash
flutter pub get
```

---

## Run Application

```bash
flutter run
```

---

# 🔧 Build APK

```bash
flutter build apk --release
```

---

# 🔮 Future Improvements

- Advanced analytics dashboards
- Smart recurring expense workflows
- Enhanced real-time synchronization
- AI-assisted expense categorization
- Expanded collaboration features
- Multi-platform support

---

# 📱 Project Highlights

- 🚀 5K+ Downloads
- 📱 Production-deployed application
- 👨‍💻 Sole developer and maintainer
- ⚡ Performance-focused architecture
- 🔄 Continuously evolving ecosystem

---

# 👨‍💻 Author

Built and maintained by [Rohit Anand](https://github.com/rranand).