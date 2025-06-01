import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _feeAmountController = TextEditingController();

  String _cryptoType = 'ETH';
  bool _isFormValid = false;
  bool _showAdvancedOptions = false;
  bool _isSubmitting = false;
  String? _errorMessage; // To store error message if transaction fails

  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // Crypto configurations synchronized with WalletsScreen
  final Map<String, Map<String, dynamic>> _cryptoConfigs = {
    'ETH': {
      'name': 'Ethereum',
      'color': const Color(0xFF627EEA),
      'lightColor': const Color(0xFFE8ECFF),
      'icon': Icons.diamond,
      'symbol': 'Ξ',
      'minFee': 0.001,
      'addressPattern': r'^0x[a-fA-F0-9]{40}$',
      'balance': 2.5,
    },
    'BTC': {
      'name': 'Bitcoin',
      'color': const Color(0xFFF7931A),
      'lightColor': const Color(0xFFFFF3E0),
      'icon': Icons.currency_bitcoin,
      'symbol': '₿',
      'minFee': 0.0001,
      'addressPattern': r'^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$|^bc1[a-z0-9]{39,59}$',
      'balance': 0.15,
    },
    'USDT': {
      'name': 'Tether USD',
      'color': const Color(0xFF26A17B),
      'lightColor': const Color(0xFFE8F5F0),
      'icon': Icons.attach_money,
      'symbol': '₮',
      'minFee': 0.0001,
      'addressPattern': r'^0x[a-fA-F0-9]{40}$',
      'balance': 1250.0,
    },
    'SOL': {
      'name': 'Solana',
      'color': const Color(0xFF9945FF),
      'lightColor': const Color(0xFFF2E8FF),
      'icon': Icons.flash_on,
      'symbol': '◎',
      'minFee': 0.00005,
      'addressPattern': r'^[1-9A-HJ-NP-Za-km-z]{32,44}$',
      'balance': 10.0,
    },
    'BNB': {
      'name': 'BNB',
      'color': const Color(0xFFF3BA2F),
      'lightColor': const Color(0xFFFFF6E0),
      'icon': Icons.token,
      'symbol': 'BNB',
      'minFee': 0.0002,
      'addressPattern': r'^0x[a-fA-F0-9]{40}$',
      'balance': 5.0,
    },
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupListeners();
    _startAnimations();
  }

  void _initAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));
  }

  void _setupListeners() {
    _titleController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
    _amountController.addListener(_validateForm);
    _feeAmountController.addListener(_validateForm);
  }

  void _startAnimations() {
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _titleController.dispose();
    _addressController.dispose();
    _amountController.dispose();
    _feeAmountController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _isFormValid = isValid;
    });
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập địa chỉ ví';
    }
    final pattern = _cryptoConfigs[_cryptoType]!['addressPattern'] as String;
    if (!RegExp(pattern).hasMatch(value)) {
      return 'Địa chỉ ví $_cryptoType không hợp lệ';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số lượng';
    }
    final amount = double.tryParse(value);
    final balance = _cryptoConfigs[_cryptoType]!['balance'] as double;
    if (amount == null || amount <= 0) {
      return 'Số lượng phải lớn hơn 0';
    }
    if (amount > balance) {
      return 'Số dư không đủ';
    }
    return null;
  }

  String? _validateFee(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập phí giao dịch';
    }
    final fee = double.tryParse(value);
    final minFee = _cryptoConfigs[_cryptoType]!['minFee'] as double;
    if (fee == null || fee < minFee) {
      return 'Phí tối thiểu là $minFee $_cryptoType';
    }
    return null;
  }

  Future<void> _submitTransaction() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      setState(() {
        _isSubmitting = true;
        _errorMessage = null;
      });

      try {
        // Giả lập gọi API để gửi giao dịch
        await Future.delayed(const Duration(seconds: 2)); // Giả lập độ trễ mạng

        // Kiểm tra nếu mounted trước khi cập nhật trạng thái
        if (!mounted) return;

        // Hiển thị thông báo thành công
        _showSuccessSnackBar(_amountController.text, _cryptoType);

        // Đóng màn hình sau 1 giây
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } catch (e) {
        // Xử lý lỗi
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _errorMessage = 'Giao dịch thất bại: $e';
          });
          _showErrorSnackBar('Giao dịch thất bại: $e');
        }
      }
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _showSuccessSnackBar(String amount, String cryptoType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _cryptoConfigs[cryptoType]!['color'].withOpacity(0.8),
                      _cryptoConfigs[cryptoType]!['color'].withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Giao dịch thành công',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Đã gửi $amount $cryptoType',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: _cryptoConfigs[cryptoType]!['color'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Xem giao dịch',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to transaction details
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _scanQRCode() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 200,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 48,
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Chức năng quét QR sẽ sớm được triển khai',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setMaxAmount() {
    HapticFeedback.selectionClick();
    final balance = _cryptoConfigs[_cryptoType]!['balance'] as double;
    _amountController.text = balance.toStringAsFixed(8);
    _validateForm();
  }

  void _estimateFee() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null) {
      final minFee = _cryptoConfigs[_cryptoType]!['minFee'] as double;
      final estimatedFee = (amount * 0.001).clamp(minFee, double.infinity);
      _feeAmountController.text = estimatedFee.toStringAsFixed(8);
      _validateForm();
      HapticFeedback.selectionClick();
    }
  }

  Widget _buildCryptoSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Chọn loại tiền mã hóa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: _cryptoConfigs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final crypto = _cryptoConfigs.keys.elementAt(index);
                final config = _cryptoConfigs[crypto]!;
                final isSelected = crypto == _cryptoType;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _cryptoType = crypto;
                      _amountController.clear();
                      _feeAmountController.clear();
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: 120,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                config['color'].withOpacity(0.8),
                                config['color'].withOpacity(0.6),
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? config['color']
                            : Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                config['color'].withOpacity(0.2),
                                config['lightColor'],
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            config['icon'],
                            color: isSelected ? Colors.white : config['color'],
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          crypto,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? hint,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _cryptoConfigs[_cryptoType]!['color'].withOpacity(0.8),
                  _cryptoConfigs[_cryptoType]!['color'].withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: _cryptoConfigs[_cryptoType]!['color'],
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
          errorStyle: const TextStyle(color: Colors.red),
        ),
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
      ),
    );
  }

  Widget _buildConfirmDialog() {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Xác nhận giao dịch',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết giao dịch',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Tiêu đề giao dịch',
              _titleController.text,
            ),
            _buildDetailRow(
              'Địa chỉ nhận',
              '${_addressController.text.substring(0, 10)}...${_addressController.text.substring(_addressController.text.length - 8)}',
            ),
            _buildDetailRow(
              'Số lượng',
              '${_amountController.text} $_cryptoType',
            ),
            _buildDetailRow(
              'Phí giao dịch',
              '${_feeAmountController.text} $_cryptoType',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vui lòng kiểm tra kỹ thông tin trước khi xác nhận. Giao dịch không thể hoàn tác.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Hủy',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _cryptoConfigs[_cryptoType]!['color'],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            _submitTransaction();
          },
          child: const Text(
            'Xác nhận',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cryptoConfig = _cryptoConfigs[_cryptoType]!;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF121212),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Gửi $_cryptoType',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        _buildCryptoSelector(),
                        const SizedBox(height: 16),

                        // Main Form Card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Chi tiết giao dịch',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              _buildModernTextField(
                                controller: _titleController,
                                label: 'Tiêu đề giao dịch',
                                icon: Icons.title,
                                hint: 'Nhập mô tả giao dịch',
                                validator: (value) => value!.isEmpty
                                    ? 'Vui lòng nhập tiêu đề'
                                    : null,
                              ),

                              _buildModernTextField(
                                controller: _addressController,
                                label: 'Địa chỉ nhận',
                                icon: Icons.account_balance_wallet,
                                hint: 'Nhập địa chỉ ví $_cryptoType',
                                validator: _validateAddress,
                                suffixIcon: IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          cryptoConfig['color'].withOpacity(0.8),
                                          cryptoConfig['color'].withOpacity(0.6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_scanner,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  onPressed: _scanQRCode,
                                ),
                              ),

                              _buildModernTextField(
                                controller: _amountController,
                                label: 'Số lượng $_cryptoType',
                                icon: Icons.monetization_on,
                                hint: '0.00',
                                validator: _validateAmount,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
                                ],
                                suffixIcon: TextButton(
                                  onPressed: _setMaxAmount,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          cryptoConfig['color'].withOpacity(0.8),
                                          cryptoConfig['color'].withOpacity(0.6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Tối đa',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Advanced Options
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        cryptoConfig['color'].withOpacity(0.8),
                                        cryptoConfig['color'].withOpacity(0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.tune,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: const Text(
                                  'Tùy chọn nâng cao',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Phí và cài đặt',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: AnimatedRotation(
                                  turns: _showAdvancedOptions ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  child: const Icon(
                                    Icons.expand_more,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _showAdvancedOptions = !_showAdvancedOptions;
                                  });
                                  HapticFeedback.selectionClick();
                                },
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: _showAdvancedOptions ? null : 0,
                                child: _showAdvancedOptions
                                    ? Container(
                                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _buildModernTextField(
                                                    controller: _feeAmountController,
                                                    label: 'Phí giao dịch',
                                                    icon: Icons.local_gas_station,
                                                    hint: '0.001',
                                                    validator: _validateFee,
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                ElevatedButton(
                                                  onPressed: _estimateFee,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: cryptoConfig['color'],
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                                  ),
                                                  child: const Text('Ước tính'),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue.withOpacity(0.2),
                                                    Colors.blue.withOpacity(0.1),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.info_outline,
                                                    color: Colors.blue,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Phí tối thiểu: ${cryptoConfig['minFee']} $_cryptoType',
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Bottom Submit Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (_isSubmitting || !_isFormValid)
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => _buildConfirmDialog(),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFormValid
                                ? cryptoConfig['color']
                                : Colors.grey.withOpacity(0.5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: _isFormValid ? 8 : 0,
                            shadowColor: cryptoConfig['color'].withOpacity(0.3),
                          ),
                          child: _isSubmitting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Đang xử lý',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.send_rounded, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Gửi $_cryptoType',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}