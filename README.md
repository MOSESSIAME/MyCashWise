# MyCashWise

**MyCashWise** is a modern mobile personal finance management app built with Flutter. It helps users track income, expenses, budgets, and accounts in a clean, easy-to-use interface. MyCashWise is designed to make financial tracking simple, visual, and insightful for users in Zambia and beyond.

---

![MyCashWise Dashboard Screenshot](assets/dashboard_screenshot.png)

## Features

- **Dashboard Overview**: Quick summary of current income, expenses, and recent transactions.
- **Transactions**: Add, view, and filter transactions. Supports categorization (Food, Transport, Shopping, Bills, etc.), notes, and account selection.
- **Budgets**: Create monthly budgets for different categories and monitor your spending against budget limits.
- **Accounts**: Manage multiple accounts (cash, mobile money, bank accounts) and view their balances.
- **Notifications**: Get notified about important financial events (budget limits, reminders).
- **Clean UI**: Modern, responsive interface with a visually appealing dashboard and summary cards.
- **Local Storage**: Uses Hive for secure, efficient, offline data storage.
- **Secure**: Your financial data is kept private on your device.

---

## Screenshots

![Dashboard](assets/dashboard_screenshot.png)
![Transactions](assets/transactions_screenshot.png)
![Budgets](assets/budgets_screenshot.png)
![Accounts](assets/accounts_screenshot.png)

---

## Getting Started

### 1. **Clone the Repository**

```sh
git clone https://github.com/yourusername/mycashwise.git
cd mycashwise
```

### 2. **Install Dependencies**

```sh
flutter pub get
```

### 3. **Run the App**

```sh
flutter run
```

### 4. **Build for Release**

```sh
flutter build apk
```

---

## Configuration

- **Assets**: Place your background images and screenshots in the `assets/` folder. Update `pubspec.yaml` to include them.
- **Hive Boxes**: Data is stored locally using Hive. No setup required; the app manages everything for you.
- **Providers**: State management is handled using Provider.

---

## Folder Structure

```
lib/
  providers/
    account_provider.dart
    transaction_provider.dart
    budget_provider.dart
  presentation/
    screens/
      home/
        home_screen.dart
      accounts/
        accounts_screen.dart
      transactions/
        transactions_screen.dart
      budgets/
        budgets_screen.dart
      ...
    widgets/
      ...
  main.dart
assets/
  bg_cashwise.jpg
  dashboard_screenshot.png
  ...
```

---

## Technologies Used

- [Flutter](https://flutter.dev/)
- [Hive](https://pub.dev/packages/hive)
- [Provider](https://pub.dev/packages/provider)
- [Material Icons](https://fonts.google.com/icons)

---

## Customization

- **Background Image**: Replace `assets/bg_cashwise.jpg` with your preferred background.
- **Currency**: Default is ZMW (Zambian Kwacha); you can change this in `home_screen.dart`.
- **Categories & Accounts**: Add/edit categories and account types in respective Provider files.

---

## Contributing

Pull requests and suggestions are welcome! Please open an issue or submit a PR.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

---

## License

[MIT](LICENSE)

---

## Contact

For feedback, support, or business inquiries:

- Email: (msiame1997@email.com)
- GitHub:(https://github.com/MOSESSIAME)

---

## Acknowledgments

- Built with Flutter and the awesome open-source community.
- Special thanks to contributors and testers.

---

> **MyCashWise - Take control of your finances!**
