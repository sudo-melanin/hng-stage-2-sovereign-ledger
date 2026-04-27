# Sovereign Ledger — Functional Specification

## 1. Project Overview

Sovereign Ledger is a local-first Flutter-based finance tracking application designed to help users manage personal finances through structured transaction tracking, budgeting, recurring entries, and visual financial insights.

The application emphasizes clean architecture, efficient state management, offline persistence, and controlled access to sensitive financial data using session-based facial liveness verification.

---

## 2. Product Goals

The application enables users to:

- Record and manage income and expense transactions
- Categorize financial activities
- Define and monitor budgets
- Automate recurring transactions
- Visualize financial data through charts
- Persist all data locally on-device
- Restrict access to sensitive financial views

---

## 3. Success Criteria

The application is considered complete when:

- Transactions can be created and reflected immediately
- Budgets accurately track spending progress
- Recurring transactions generate correctly without duplication
- Insights reflect actual stored data
- Data persists after app restart
- Sensitive views are protected by liveness verification
- UI aligns closely with the provided Figma design

---

## 4. Platform Scope

- Platform: Android
- Framework: Flutter
- Data Storage: Local (Hive)
- Backend: Not required

---

## 5. Core Features

### 5.1 Overview / Dashboard

Displays financial summary including:

- Total balance
- Total income
- Total expenses
- Recent transactions
- Quick actions for adding transactions

Behavior:

- Values are dynamically calculated from stored transactions
- Negative balance is supported and visually indicated

🔒 Protected via session-based liveness verification

---

### 5.2 Transaction Management

Users can:

- Add income or expense transactions
- Input amount (validated numeric input)
- Select category
- Choose transaction date
- Add optional notes
- Enable recurring transactions

System behavior:

- Transactions are stored locally
- Balance updates immediately
- Data propagates to budgets and insights

---

### 5.3 Budget Management

Users can:

- Create budgets per category
- Set spending limits
- Choose period:
  - Weekly
  - Monthly
  - Custom date range

System behavior:

- Only expense transactions count toward budgets
- Spending progress is calculated dynamically
- Visual feedback shows:
  - Safe range
  - Near limit
  - Over budget

---

### 5.4 Recurring Transactions

Users can:

- Enable recurring transactions
- Select frequency:
  - Weekly
  - Monthly

System behavior:

- Recurring rules are stored separately
- App checks for due transactions on load
- Transactions are generated when due
- Next due date is automatically updated
- Duplicate generation is prevented

---

### 5.5 Financial Insights / Analytics

Includes:

- Category-based spending distribution (pie chart)
- Summary metrics:
  - Total income
  - Total expenses
  - Savings ratio

System behavior:

- Data is derived from stored transactions
- Chart includes color mapping and category legend

🔒 Protected via session-based liveness verification

---

### 5.6 Local Persistence

All data is stored locally using Hive:

- Transactions
- Categories
- Budgets
- Recurring rules
- App settings

Behavior:

- Data persists across app restarts
- No network dependency

---

### 5.7 Security — Liveness Verification

Purpose:

Protect access to sensitive financial information.

Protected areas:

- Overview / Dashboard
- Insights / Analytics
- Data export

Flow:

1. User attempts to access protected content
2. Liveness verification is triggered
3. On success:
   - Session is unlocked
   - Access granted for current session
4. On failure:
   - Access denied
   - Retry allowed

Behavior:

- Verification is required once per session
- Session resets on app restart

---

### 5.8 Settings

Includes:

- Currency selection
- CSV export functionality
- Security information

---

## 6. Bonus Features

### 6.1 CSV Export

Users can export transaction data as CSV.

Behavior:

- Export triggers liveness verification if session is locked
- File is generated locally
- File is shared using system share sheet

---

### 6.2 Currency Formatting

Supports multiple currencies:

- NGN (₦)
- USD ($)
- GBP (£)
- EUR (€)

Behavior:

- Selected currency applies across entire app
- Uses locale-aware formatting

---

## 7. Out of Scope

- Backend services or cloud sync
- User authentication accounts
- Bank integrations
- Push notifications
- Multi-user support
- Advanced forecasting analytics
- Receipt scanning or OCR

---

## 8. Screens

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
1. Open add transaction screen
2. Enter details
3. Save
4. Data updates instantly

---

### Create Budget
1. Navigate to budgets
2. Add budget
3. Save
4. Monitor spending progress

---

### Recurring Transaction
1. Enable recurring option
2. Select frequency
3. Save
4. System generates transactions when due

---

### Access Protected Content
1. Navigate to protected section
2. Trigger liveness verification
3. Access granted or denied

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

---

### RecurringRule
- id
- title
- amount
- type
- categoryId
- frequency (weekly/monthly)
- nextDueDate
- isActive

---

### AppSettings
- currencyCode

---

## 11. Business Rules

- Balance = total income − total expenses
- Only expenses affect budgets
- Budget calculations respect date range
- Recurring transactions must not duplicate
- Sensitive views require verification
- Data persists locally
- Updates reflect immediately

---

## 12. Edge Case Handling

- Prevent invalid or empty inputs
- Prevent zero-value transactions
- Handle empty states (no data)
- Handle liveness verification failure
- Ensure recurring transactions do not duplicate

---

## 13. Non-Functional Requirements

- Responsive UI
- Smooth navigation
- Offline-first functionality
- Efficient state updates
- Clean and consistent design

---

## 14. Acceptance Criteria

### Transactions
- Can be created and persist
- Updates reflect immediately

### Budgets
- Track spending correctly
- Show over-limit states

### Recurring
- Generates correctly
- No duplication

### Insights
- Charts reflect stored data

### Security
- Protected screens require verification

### Storage
- Data persists after restart

### Bonus
- CSV export works correctly
- Currency formatting updates globally