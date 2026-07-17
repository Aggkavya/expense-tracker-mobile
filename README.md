# Finance Tracker — Flutter Mobile App

A complete Flutter mobile app mirroring the React web frontend and connecting to the same Spring Boot backend hosted on Render.

## 🚀 Quick Setup

### 1. Set your Backend URL

Open [`lib/core/api_config.dart`](lib/core/api_config.dart) and update:

```dart
const String kApiBaseUrl = 'https://your-app.onrender.com'; // ← change this
```

### 2. Install Flutter

Download from https://flutter.dev/docs/get-started/install/windows

After installing:
```powershell
flutter --version   # should print Flutter 3.x
flutter doctor      # check all deps are OK
```

### 3. Get Dependencies

```powershell
cd d:\ft\expense_tracker_mobile
flutter pub get
```

### 4. Run the App

```powershell
# On a connected Android device or emulator:
flutter run

# To pick a specific device:
flutter devices
flutter run -d <device-id>

# Build APK:
flutter build apk --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point + MultiProvider
├── core/
│   ├── api_config.dart          # ⭐ BASE URL — edit this!
│   ├── api_client.dart          # HTTP client (mirrors api.js)
│   ├── storage_service.dart     # SharedPreferences (mirrors localStorage)
│   ├── format_utils.dart        # INR currency & date formatting
│   ├── app_theme.dart           # Dark/light theme + AppColors extension
│   └── router.dart              # GoRouter with auth guard
├── providers/
│   ├── auth_provider.dart       # JWT auth + ThemeProvider
│   ├── theme_provider.dart      # Dark/light toggle
│   └── finance_provider.dart   # All finance state (mirrors FinanceContext)
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── main_shell.dart          # AppBar + Drawer + BottomNav
│   ├── overview_screen.dart
│   ├── balances_screen.dart
│   ├── expense/
│   │   ├── new_expense_screen.dart
│   │   └── expense_history_screen.dart
│   ├── income/
│   │   ├── new_income_screen.dart
│   │   └── income_history_screen.dart
│   ├── debt/
│   │   ├── new_debt_screen.dart
│   │   └── debt_history_screen.dart
│   ├── receivable/
│   │   ├── new_receivable_screen.dart
│   │   └── receivable_history_screen.dart
│   └── friends/
│       └── friends_screen.dart
└── widgets/
    └── common_widgets.dart      # StatTile, SectionCard, StatusBanner, etc.
```

---

## 🎨 Design

- **Dark theme default** (matches web app) — toggle via AppBar icon
- **Brand colors**: `#2563EB` light / `#00C2FF` dark (cyan)
- **INR (₹) currency** formatting matching the web
- **Bottom navigation**: Overview, Expenses, Income, Debts, Friends
- **Side drawer**: All 11 navigation destinations

## 🔐 API Auth

JWT token stored in `SharedPreferences`. Every authenticated request sends:
```
Authorization: Bearer <token>
```

## 📱 Features

| Screen | Features |
|---|---|
| Login / Signup | JWT auth, validation |
| Overview | Stats, bar chart, recent transactions, pull-to-refresh |
| Balances | View & update cash/bank balances |
| Expense History | Filter, sort, delete |
| New Expense | Category, payment mode, amount, description |
| Income History | View, delete |
| New Income | Amount, mode, description |
| Debt History | Expandable cards, pay debt, delete, payment history |
| New Debt | Personal + linked transaction request |
| Receivable History | Expandable cards, collect, delete, history |
| New Receivable | Personal receivable form |
| Friends | Pending/Sent/Friends/Shared tabs, linked payments |
| Notifications | Bell in AppBar, bottom sheet panel, mark read |
