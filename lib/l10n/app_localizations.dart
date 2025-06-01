import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Enum để xác định các ngôn ngữ được hỗ trợ
enum SupportedLanguage {
  english('en', 'US'),
  vietnamese('vi', 'VN');

  final String languageCode;
  final String countryCode;

  const SupportedLanguage(this.languageCode, this.countryCode);

  Locale get locale => Locale(languageCode, countryCode);
}

// Delegate cho localization
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return SupportedLanguage.values.any((lang) => lang.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

// Class chính để quản lý bản địa hóa
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Delegate tĩnh để sử dụng trong ứng dụng
  static const AppLocalizationsDelegate delegate = AppLocalizationsDelegate();

  // Danh sách ngôn ngữ được hỗ trợ
  static final List<Locale> supportedLocales = SupportedLanguage.values.map((e) => e.locale).toList();

  // Lấy instance AppLocalizations từ context
  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (localizations == null) {
      throw Exception('AppLocalizations not found. Ensure MaterialApp is configured with AppLocalizations.delegate.');
    }
    return localizations;
  }

  // Bảng bản địa hóa
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'CrystaPay',
      'home': 'Home',
      'send': 'Send',
      'receive': 'Receive',
      'wallets': 'Wallets',
      'profile': 'Profile',
      'total_balance': 'Total Balance',
      'view_all': 'View All',
      'services': 'Services',
      'recent_transactions': 'Recent Transactions',
      'send_crypto': 'Send {cryptoType}',
      'receive_crypto': 'Receive {cryptoType}',
      'view_all_transactions': 'View All Transactions',
      'wallet_address': 'Wallet Address',
      'copy_address': 'Copy Address',
      'share_address': 'Share Address',
      'select_wallet': 'Select Wallet',
      'settings': 'Settings',
      'logout': 'Logout',
      'confirm_logout': 'Confirm Logout',
      'logout_confirmation': 'Are you sure you want to log out?',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'amount': 'Amount',
      'network': 'Network',
      'gas_fee': 'Gas Fee',
      'total_fee': 'Total Fee',
      'send_money': 'Send Money',
      'sending': 'Sending...',
      'success': 'Success',
      'error': 'Error',
      'invalid_address': 'Invalid {cryptoType} address',
      'invalid_amount': 'Invalid amount',
      'insufficient_balance': 'Insufficient balance',
      'copied': 'Copied to clipboard',
      'copy_link': 'Copy Link',
      'copy_qr': 'Copy QR Code',
      'status': 'Status',
      'active': 'Active',
      'locked': 'Locked',
      'pending': 'Pending',
      'type': 'Type',
      'balance': 'Balance',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'search': 'Search',
      'add_wallet': 'Add Wallet',
      'wallet_name': 'Wallet Name',
      'edit_wallet': 'Edit Wallet',
      'delete_wallet': 'Delete Wallet',
      'delete_wallet_confirmation': 'Are you sure you want to delete this wallet? This action cannot be undone.',
      'wallet_exists': 'Wallet already exists',
      'edit_profile': 'Edit Profile',
      'name': 'Name',
      'email': 'Email',
      'phone': 'Phone',
      'security': 'Security',
      'notifications': 'Notifications',
      'language': 'Language',
      'theme': 'Theme',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'system_mode': 'System',
      'help_support': 'Help & Support',
      'about': 'About',
      'version': 'Version',
      'login': 'Log In',
      'register': 'Sign Up',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'no_account': 'No account yet?',
      'have_account': 'Have an account?',
      'create_account': 'Create Account',
      'welcome_back': 'Welcome Back',
      'sign_in_to_continue': 'Sign in to continue',
      'get_started': 'Get Started',
      'next': 'Next',
      'skip': 'Skip',
      // DApp-specific translations
      'select_crypto_type': 'Select Cryptocurrency',
      'transaction_details': 'Transaction Details',
      'transaction_title': 'Title',
      'recipient_address': 'Recipient Address',
      'amount_crypto': 'Amount ({cryptoType})',
      'transaction_fee': 'Fee',
      'estimate': 'Estimate',
      'minimum_fee': 'Min Fee: {minFee} {cryptoType}',
      'enter_transaction_description': 'Enter description',
      'enter_wallet_address': 'Enter {cryptoType} address',
      'max': 'MAX',
      'processing': 'Processing...',
      'qr_scanner_placeholder': 'QR Scanner (Coming Soon)',
      'please_enter_title': 'Enter a title',
      'please_enter_wallet_address': 'Enter wallet address',
      'please_enter_amount': 'Enter amount',
      'amount_must_be_greater_than_zero': 'Amount must be > 0',
      'please_enter_transaction_fee': 'Enter transaction fee',
      'confirm_transaction': 'Confirm Transaction',
      'transaction_warning': 'Verify details carefully. This transaction is irreversible.',
      'sent_amount': 'Sent {amount} {cryptoType}',
      'transaction_successful': 'Transaction Successful',
      'view_transaction': 'View Details',
      'advanced_options': 'Advanced',
      'fee_and_settings': 'Fee & Settings',
      'blockchain_error': 'Blockchain error: {message}',
      'network_unavailable': 'Network unavailable',
      // TransactionBloc-specific errors
      'load_transactions_failed': 'Failed to load transaction history: {message}',
      'load_recent_transactions_failed': 'Failed to load recent transactions: {message}',
      'create_transaction_failed': 'Failed to create transaction: {message}',
    },
    'vi': {
      'app_name': 'CrystaPay',
      'home': 'Trang Chủ',
      'send': 'Gửi',
      'receive': 'Nhận',
      'wallets': 'Ví',
      'profile': 'Hồ Sơ',
      'total_balance': 'Tổng Số Dư',
      'view_all': 'Xem Tất Cả',
      'services': 'Dịch Vụ',
      'recent_transactions': 'Giao Dịch Gần Đây',
      'send_crypto': 'Gửi {cryptoType}',
      'receive_crypto': 'Nhận {cryptoType}',
      'view_all_transactions': 'Xem Tất Cả Giao Dịch',
      'wallet_address': 'Địa Chỉ Ví',
      'copy_address': 'Sao Chép Địa Chỉ',
      'share_address': 'Chia Sẻ Địa Chỉ',
      'select_wallet': 'Chọn Ví',
      'settings': 'Cài Đặt',
      'logout': 'Đăng Xuất',
      'confirm_logout': 'Xác Nhận Đăng Xuất',
      'logout_confirmation': 'Bạn có chắc muốn đăng xuất?',
      'cancel': 'Hủy',
      'confirm': 'Xác Nhận',
      'amount': 'Số Lượng',
      'network': 'Mạng Lưới',
      'gas_fee': 'Phí Gas',
      'total_fee': 'Tổng Phí',
      'send_money': 'Gửi Tiền',
      'sending': 'Đang Gửi...',
      'success': 'Thành Công',
      'error': 'Lỗi',
      'invalid_address': 'Địa chỉ {cryptoType} không hợp lệ',
      'invalid_amount': 'Số lượng không hợp lệ',
      'insufficient_balance': 'Số dư không đủ',
      'copied': 'Đã sao chép',
      'copy_link': 'Sao Chép Liên Kết',
      'copy_qr': 'Sao Chép Mã QR',
      'status': 'Trạng Thái',
      'active': 'Hoạt Động',
      'locked': 'Khóa',
      'pending': 'Chờ Xác Nhận',
      'type': 'Loại',
      'balance': 'Số Dư',
      'save': 'Lưu',
      'edit': 'Sửa',
      'delete': 'Xóa',
      'search': 'Tìm Kiếm',
      'add_wallet': 'Thêm Ví',
      'wallet_name': 'Tên Ví',
      'edit_wallet': 'Sửa Ví',
      'delete_wallet': 'Xóa Ví',
      'delete_wallet_confirmation': 'Bạn có chắc muốn xóa ví này? Hành động này không thể hoàn tác.',
      'wallet_exists': 'Ví đã tồn tại',
      'edit_profile': 'Sửa Hồ Sơ',
      'name': 'Tên',
      'email': 'Email',
      'phone': 'Điện Thoại',
      'security': 'Bảo Mật',
      'notifications': 'Thông Báo',
      'language': 'Ngôn Ngữ',
      'theme': 'Giao Diện',
      'dark_mode': 'Chế Độ Tối',
      'light_mode': 'Chế Độ Sáng',
      'system_mode': 'Hệ Thống',
      'help_support': 'Hỗ Trợ',
      'about': 'Giới Thiệu',
      'version': 'Phiên Bản',
      'login': 'Đăng Nhập',
      'register': 'Đăng Ký',
      'password': 'Mật Khẩu',
      'confirm_password': 'Xác Nhận Mật Khẩu',
      'forgot_password': 'Quên Mật Khẩu?',
      'no_account': 'Chưa có tài khoản?',
      'have_account': 'Đã có tài khoản?',
      'create_account': 'Tạo Tài Khoản',
      'welcome_back': 'Chào Mừng Trở Lại',
      'sign_in_to_continue': 'Đăng nhập để tiếp tục',
      'get_started': 'Bắt Đầu',
      'next': 'Tiếp Theo',
      'skip': 'Bỏ Qua',
      // DApp-specific translations
      'select_crypto_type': 'Chọn Tiền Điện Tử',
      'transaction_details': 'Chi Tiết Giao Dịch',
      'transaction_title': 'Tiêu Đề',
      'recipient_address': 'Địa Chỉ Nhận',
      'amount_crypto': 'Số Lượng ({cryptoType})',
      'transaction_fee': 'Phí',
      'estimate': 'Ước Tính',
      'minimum_fee': 'Phí Tối Thiểu: {minFee} {cryptoType}',
      'enter_transaction_description': 'Nhập mô tả',
      'enter_wallet_address': 'Nhập địa chỉ {cryptoType}',
      'max': 'TỐI ĐA',
      'processing': 'Đang Xử Lý...',
      'qr_scanner_placeholder': 'Quét QR (Sắp Ra Mắt)',
      'please_enter_title': 'Nhập tiêu đề',
      'please_enter_wallet_address': 'Nhập địa chỉ ví',
      'please_enter_amount': 'Nhập số lượng',
      'amount_must_be_greater_than_zero': 'Số lượng phải > 0',
      'please_enter_transaction_fee': 'Nhập phí giao dịch',
      'confirm_transaction': 'Xác Nhận Giao Dịch',
      'transaction_warning': 'Kiểm tra kỹ thông tin. Giao dịch này không thể hoàn tác.',
      'sent_amount': 'Đã gửi {amount} {cryptoType}',
      'transaction_successful': 'Giao Dịch Thành Công',
      'view_transaction': 'Xem Chi Tiết',
      'advanced_options': 'Nâng Cao',
      'fee_and_settings': 'Phí & Cài Đặt',
      'blockchain_error': 'Lỗi blockchain: {message}',
      'network_unavailable': 'Mạng không khả dụng',
      // TransactionBloc-specific errors
      'load_transactions_failed': 'Không thể tải lịch sử giao dịch: {message}',
      'load_recent_transactions_failed': 'Không thể tải giao dịch gần đây: {message}',
      'create_transaction_failed': 'Không thể tạo giao dịch: {message}',
    },
  };

  /// Dịch chuỗi với tham số động
  String translate(String key, [Map<String, dynamic>? params]) {
    final translations = _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
    String value = translations[key] ?? _localizedValues['en']![key] ?? key;

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue.toString());
      });
    }

    return value;
  }

  /// Định dạng số lượng tiền điện tử
  String formatCryptoAmount(double amount, {int decimalDigits = 8}) {
    final format = NumberFormat('#,##0.${'0' * decimalDigits}', locale.toString());
    return format.format(amount).trim();
  }

  /// Định dạng tiền tệ fiat
  String formatFiatCurrency(double amount, {String symbol = '\$'}) {
    final format = NumberFormat.currency(
      locale: locale.toString(),
      symbol: symbol,
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  /// Định dạng ngày giờ
  String formatDateTime(DateTime date, {bool includeTime = true}) {
    final dateFormat = includeTime
        ? DateFormat.yMMMd(locale.toString()).add_Hm()
        : DateFormat.yMMMd(locale.toString());
    return dateFormat.format(date);
  }

  // DApp-specific translations
  String sendCrypto(String cryptoType) => translate('send_crypto', {'cryptoType': cryptoType});
  String receiveCrypto(String cryptoType) => translate('receive_crypto', {'cryptoType': cryptoType});
  String invalidAddress(String cryptoType) => translate('invalid_address', {'cryptoType': cryptoType});
  String minimumFee(double minFee, String cryptoType) =>
      translate('minimum_fee', {'minFee': formatCryptoAmount(minFee), 'cryptoType': cryptoType});
  String enterWalletAddress(String cryptoType) => translate('enter_wallet_address', {'cryptoType': cryptoType});
  String amountCrypto(String cryptoType) => translate('amount_crypto', {'cryptoType': cryptoType});
  String sentAmount(String amount, String cryptoType) => translate('sent_amount', {
        'amount': formatCryptoAmount(double.tryParse(amount) ?? 0),
        'cryptoType': cryptoType,
      });
  String blockchainError(String message) => translate('blockchain_error', {'message': message});
  String transactionError(String key, String message) => translate(key, {'message': message});
}