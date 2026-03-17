// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Shree Giriraj Engineering';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get home => 'Home';

  @override
  String get sites => 'Sites';

  @override
  String get transactions => 'Transactions';

  @override
  String get users => 'Users';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String get gujarati => 'Gujarati';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get amount => 'Amount';

  @override
  String get description => 'Description';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cash => 'Cash';

  @override
  String get upi => 'UPI';

  @override
  String get bank => 'Bank Transfer';

  @override
  String get other => 'Other';

  @override
  String get welcomeBackDashboard => 'Welcome back to your dashboard';

  @override
  String get todayIncome => 'Today Income';

  @override
  String get todayExpense => 'Today Expense';

  @override
  String get totalTransactions => 'TOTAL TRANSACTIONS';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get tapToAddFirstTransaction => 'Tap + to add your first transaction';

  @override
  String get addYourFirstTransaction => 'Add your first transaction';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get hello => 'Hello';

  @override
  String get all => 'All';

  @override
  String get partners => 'Partners';

  @override
  String get searchPartners => 'Search partners by name or ID';

  @override
  String allPartnersCount(Object count) {
    return 'All Partners ($count)';
  }

  @override
  String get noPartnersFound => 'No partners found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get noPartnersRegistered => 'No partners registered yet';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String lastSeenDate(Object date) {
    return 'Last seen $date';
  }

  @override
  String get noLocationData => 'No location data';

  @override
  String get viewAssignedSites => 'View assigned sites';

  @override
  String get viewDetails => 'View Details';

  @override
  String get constructionSites => 'Construction Sites';

  @override
  String get searchSites => 'Search by name, city or status...';

  @override
  String get allProjects => 'All Projects';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get noSitesFound => 'No sites found';

  @override
  String get tapToAddSite => 'Tap + to add a new site';

  @override
  String get onHold => 'On Hold';

  @override
  String get siteIdUppercase => 'SITE ID';

  @override
  String get manage => 'Manage';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get nothingToShowFilter => 'Nothing to show for this filter';

  @override
  String byUser(Object name) {
    return 'By: $name';
  }

  @override
  String get netBalance => 'NET BALANCE';

  @override
  String totalTransactionsCount(Object count) {
    return '$count total transactions';
  }

  @override
  String itemsCount(Object count) {
    return '$count items';
  }

  @override
  String get activeSites => 'Active Sites';

  @override
  String locationsCount(Object count) {
    return '$count locations';
  }

  @override
  String get date => 'Date';

  @override
  String get site => 'Site';

  @override
  String get selectSite => 'Select Site';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get noSites => 'No sites found';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Something went wrong';

  @override
  String get retry => 'Try Again';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get role => 'Role';

  @override
  String get superAdmin => 'Super Admin';

  @override
  String get admin => 'Admin';

  @override
  String get partner => 'Partner';

  @override
  String get required => 'This field is required';

  @override
  String get invalidAmount => 'Please enter a valid amount';

  @override
  String get email => 'Email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get notProvided => 'Not provided';

  @override
  String get lastLocationUpdated => 'Last Location Updated';

  @override
  String get notYetCaptured => 'Not yet captured';

  @override
  String get organization => 'Organization';

  @override
  String get memberSince => 'Member Since';

  @override
  String get numbersInEnglishNote =>
      'Numbers always display in English (1, 2, 3…)';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get signOut => 'Sign Out';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get activate => 'Activate';

  @override
  String get errorPrefix => 'Error: ';

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String get pleaseSelectSite => 'Please select a site';

  @override
  String get errorSavingTransaction => 'Error saving transaction: ';

  @override
  String get titleSiteList => 'Site List';

  @override
  String get addIncome => 'Add Income';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get amountIsRequired => 'Amount is required';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get siteLocation => 'Site / Location';

  @override
  String get remarksOptional => 'Remarks (Optional)';

  @override
  String get whatWasThisFor => 'What was this for?';

  @override
  String get saveTransaction => 'Save Transaction';

  @override
  String get siteDetails => 'Site Details';

  @override
  String get editSite => 'Edit Site';

  @override
  String get partnerDetails => 'Partner Details';
}
