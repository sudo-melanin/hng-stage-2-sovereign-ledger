# Sovereign Ledger — Functional Specification

## 1. Project Overview

Sovereign Ledger is a local-first Flutter expense tracker designed to help users manage personal finances by tracking transactions, setting budgets, managing recurring entries, and visualizing financial data through charts.

The application emphasizes structured data modeling, efficient state management, local persistence, and secure access to sensitive financial information using facial liveness verification.

---

## 2. Product Goals

The app should allow users to:

- Record income and expense transactions
- Categorize financial activities
- Monitor category-based budgets
- Manage recurring transactions
- View financial summaries and analytics
- Persist all data locally on-device
- Restrict access to sensitive views using liveness verification

---

## 3. Success Criteria

The app is considered complete if:

- Users can add transactions and see real-time updates
- Budgets reflect accurate spending progress
- Recurring transactions generate correctly without duplication
- Charts reflect actual financial data
- Data persists after app restart
- Sensitive screens require successful liveness verification
- UI aligns closely with provided Figma designs

---

## 4. Platform Scope

- Platform: Android
- Framework: Flutter
- Data Storage: Local only (no backend)

---

## 5. Core Features

### 5.1 Overview / Dashboard

Displays a financial summary including:

- Total balance
- Total income
- Total expenses
- Spending preview
- Recent transactions
- Quick access to add transactions

> 🔒 Protected by liveness verification

---

### 5.2 Transaction Management

Users can:

- Add income or expense
- Enter amount
- Select category
- Choose date
- Add notes
- Enable recurring transactions

System behavior:

- Transactions are stored locally
- Balance updates immediately
- Data reflects across budgets and analytics

---

### 5.3 Budget Management

Users can:

- Create category-based budgets
- Define amount limits
- Set time periods (weekly/monthly/custom)
- Track spending against budget

System behavior:

- Budget usage is calculated from related expense transactions
- Visual indicators show progress and over-limit states

---

### 5.4 Recurring Transactions

Users can:

- Create recurring income or expenses
- Choose frequency (daily, weekly, monthly)
- Enable/disable rules

System behavior:

- App checks for due transactions on launch
- Generates transactions when due
- Updates next execution date
- Prevents duplicate generation

---

### 5.5 Financial Insights / Analytics

Includes:

- Category-based spending distribution
- Time-based spending trends
- Summary insight cards (e.g., monthly burn, top category)

> 🔒 Protected by liveness verification

---

### 5.6 Local Persistence

All data must persist locally:

- Transactions
- Categories
- Budgets
- Recurring rules
- App settings

Data must remain after app restart.

---

### 5.7 Security — Liveness Verification

Purpose:

Restrict access to sensitive financial data.

Protected areas:

- Overview / Dashboard
- Insights / Analytics

Flow:

- Trigger verification before access
- Allow access on success
- Deny and allow retry on failure

---

### 5.8 Settings

Includes:

- Security preferences/status
- Currency formatting option
- Export option (CSV)
- App information

---

## 6. Bonus Features

### 6.1 CSV Export

Users can export transaction data as a CSV file.

---

### 6.2 Currency Formatting

Support clean display of currency values using proper formatting.

---

## 7. Out of Scope

- Backend or cloud sync
- User authentication
- Bank integrations
- Push notifications
- Multi-user support
- Advanced analytics beyond basic charts
- OCR or receipt scanning

---

## 8. Screens

- Splash / Entry Screen
- Overview Screen (Protected)
- Add Transaction Screen
- Budgets Screen
- Add Budget Screen
- Insights Screen (Protected)
- Settings Screen
- Liveness Verification Screen

---

## 9. User Flows

### Add Transaction
1. Open add screen
2. Enter details
3. Save
4. Data updates across app

### Create Budget
1. Open budgets
2. Add budget
3. Save
4. Track progress

### Recurring Transaction
1. Enable recurring
2. Choose frequency
3. Save
4. System generates entries when due

### Access Protected Screen
1. Navigate to screen
2. Trigger liveness check
3. Grant or deny access

---

## 10. Data Models

### Transaction
- id
- title
- amount
- type (income/expense)
- categoryId
- date
- note
- isRecurring
- recurringRuleId
- createdAt
- updatedAt

---

### Category
- id
- name
- iconKey
- colorValue
- categoryType

---

### Budget
- id
- categoryId
- amountLimit
- periodType
- startDate
- endDate
- createdAt

---

### RecurringRule
- id
- title
- amount
- type
- categoryId
- frequency
- startDate
- endDate
- nextDueDate
- isActive

---

### AppSettings
- currencyCode
- currencySymbol
- securityEnabled
- lastLivenessVerifiedAt

---

## 11. Business Rules

- Balance = total income − total expenses
- Budgets track only expense transactions
- Transactions must fall within budget period to count
- Recurring transactions must not duplicate
- Protected screens require liveness verification
- Data must persist after restart
- Updates reflect immediately across all modules

---

## 12. Edge Case Handling

- Prevent zero-value transactions
- Prevent incomplete inputs
- Handle empty analytics state
- Handle liveness failure gracefully
- Prevent duplicate recurring entries

---

## 13. Non-Functional Requirements

- Responsive UI
- Clean layout
- Smooth navigation
- Offline-first
- Stable performance
- Consistent design implementation

---

## 14. Acceptance Criteria

### Transactions
- Can create and persist
- Updates reflect instantly

### Budgets
- Progress updates correctly
- Over-limit detection works

### Recurring
- Generates correctly
- No duplicates

### Insights
- Charts reflect real data

### Security
- Protected routes require verification

### Storage
- Data persists after restart

### Bonus
- CSV export works
- Currency formatting is correct