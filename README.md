# Sovereign Ledger

## Overview

Sovereign Ledger is a finance tracking mobile application built with Flutter. It enables users to manage their income and expenses, set budgets, track recurring transactions, and visualize spending patterns — all in a fully offline, secure environment.

The app was developed as part of the HNG Mobile Track Stage 2 task, with a strong focus on clean architecture, performance, and real-world usability.

---

## Features

### Transaction Management
- Add income and expense transactions
- Categorize transactions (Food, Transport, Salary, etc.)
- Input validation to prevent invalid entries

### Budgeting System
- Set budgets by category
- Supports:
  - Weekly budgets
  - Monthly budgets
  - Custom date range budgets
- Real-time tracking of spending vs budget

### Recurring Transactions
- Supports weekly and monthly recurrence
- Automatically generates transactions when due
- Rule-based system (no background jobs required)

### Financial Overview
- Real-time balance calculation
- Income, expense, and net summaries
- Handles negative balances gracefully

### Insights Dashboard
- Visual breakdown of spending using pie charts
- Category-based analytics
- Lightweight chart legend for clarity

### Currency Formatting (Bonus)
- Supports multiple currencies:
  - NGN (₦)
  - USD ($)
  - GBP (£)
  - EUR (€)
- Dynamic formatting across the app

### Data Persistence
- Fully offline-first using Hive
- Fast, lightweight local database

### Security (Liveness Verification)
- Sensitive screens protected using facial liveness verification
- Session-based unlocking:
  - One successful verification unlocks access
  - Resets on app restart
- Protects:
  - Dashboard
  - Insights
  - Data export

### Data Export (Bonus)
- Export transactions as CSV
- Uses share functionality for cross-device access

---

## Architecture

The app follows a modular and scalable architecture:

### State Management
- Provider + Selector pattern
- Minimizes unnecessary UI rebuilds
- Keeps UI and logic clearly separated

### Data Layer
- Repository pattern for data access
- Hive used as local database

### Structure

lib/
├── core/
│ ├── constants/
│ ├── enums/
│ ├── services/
│ └── utils/
├── data/
│ ├── models/
│ └── repositories/
├── features/
│ ├── overview/
│ ├── transactions/
│ ├── budgets/
│ ├── insights/
│ ├── settings/
│ └── security/
├── providers/
└── main.dart

---

## Design Approach

The UI was built based on a provided Figma design.

Key considerations:
- Clean financial dashboard layout
- Clear hierarchy of information
- Consistent color usage:
  - Income → Green
  - Expense → Red
- Minimal clutter and strong readability

---

## Security Approach

Instead of locking the entire app, liveness verification is applied only to sensitive features.

### Why this approach?
- Maintains usability for basic actions
- Protects critical financial data
- Avoids unnecessary friction for users

---

## How to Run

```bash
flutter pub get
flutter run