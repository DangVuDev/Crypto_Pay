import 'package:crysta_pay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/transaction/transaction_bloc.dart';

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
  bool _isSubmitting = false; // Add local state for submission
  String? _error; // Add local state for error
  
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _buttonAnimationController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonScaleAnimation;

  // Crypto configurations with modern colors
  final Map<String, Map<String, dynamic>> _cryptoConfigs = {
    'ETH': {
      'name': 'Ethereum',
      'color': Color(0xFF627EEA),
      'lightColor': Color(0xFFE8ECFF),
      'icon': Icons.currency_bitcoin,
      'symbol': 'Ξ',
      'minFee': 0.001,
      'addressPattern': r'^0x[a-fA-F0-9]{40}$',
    },
    'BTC': {
      'name': 'Bitcoin',
      'color': Color(0xFFF7931A),
      'lightColor': Color(0xFFFFF3E0),
      'icon': Icons.currency_bitcoin,
      'symbol': '₿',
      'minFee': 0.0001,
      'addressPattern': r'^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$|^bc1[a-z0-9]{39,59}$',
    },
    'USDT': {
      'name': 'Tether USD',
      'color': Color(0xFF26A17B),
      'lightColor': Color(0xFFE8F5F0),
      'icon': Icons.attach_money,
      'symbol': '₮',
      'minFee': 0.0001,
      'addressPattern': r'^0x[a-fA-F0-9]{40}$',
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
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  void _setupListeners() {
    _titleController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
    _amountController.addListener(_validateForm);
    _feeAmountController.addListener(_validateForm);
  }

  void _startAnimations() {
    Future.delayed(Duration(milliseconds: 100), () {
      _slideAnimationController.forward();
    });
    Future.delayed(Duration(milliseconds: 200), () {
      _fadeAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _buttonAnimationController.dispose();
    _titleController.dispose();
    _addressController.dispose();
    _amountController.dispose();
    _feeAmountController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _titleController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _amountController.text.isNotEmpty &&
        _feeAmountController.text.isNotEmpty;
    
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
      
      if (isValid) {
        _buttonAnimationController.forward();
      } else {
        _buttonAnimationController.reverse();
      }
    }
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập địa chỉ ví';
    }
    
    final pattern = _cryptoConfigs[_cryptoType]!['addressPattern'] as String;
    if (!RegExp(pattern).hasMatch(value)) {
      return 'Địa chỉ $_cryptoType không hợp lệ';
    }
    
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số tiền';
    }
    
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Số tiền phải lớn hơn 0';
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

  // SOLUTION 1: Use try-catch with context.read (safer approach)
  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      
      setState(() {
        _isSubmitting = true;
        _error = null;
      });

      try {
        // Try to access the BLoC - will throw if not available
        final transactionBloc = context.read<TransactionBloc>();
        
        transactionBloc.add(CreateSendTransaction(
          title: _titleController.text,
          address: _addressController.text,
          amount: double.parse(_amountController.text),
          cryptoType: _cryptoType,
          feeAmount: double.parse(_feeAmountController.text),
        ));
        
        _showSuccessSnackBar();
        
        // Simulate delay then navigate back
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });
            Navigator.pop(context);
          }
        });
        
      } catch (e) {
        // Handle case where BLoC is not available
        setState(() {
          _isSubmitting = false;
          _error = 'TransactionBloc không khả dụng. Vui lòng thử lại.';
        });
        print('BLoC Error: $e');
      }
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Giao dịch thành công!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Đã gửi ${_amountController.text} $_cryptoType',
                      style: const TextStyle(fontSize: 12,),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _scanQRCode() {
    HapticFeedback.selectionClick();
    // Show bottom sheet for QR scanner
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 48, color: _cryptoConfigs[_cryptoType]!['color']),
              SizedBox(height: 16),
              Text('QR Scanner sẽ được triển khai', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  void _setMaxAmount() {
    HapticFeedback.selectionClick();
    _amountController.text = '1.0'; // Demo value
    _validateForm();
  }

  void _estimateFee() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null) {
      final estimatedFee = amount * 0.001;
      _feeAmountController.text = estimatedFee.toStringAsFixed(6);
      _validateForm();
      HapticFeedback.selectionClick();
    }
  }

  Widget _buildCryptoSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Chọn loại tiền điện tử',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Container(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4),
              itemCount: _cryptoConfigs.length,
              separatorBuilder: (context, index) => SizedBox(width: 12),
              itemBuilder: (context, index) {
                final crypto = _cryptoConfigs.keys.elementAt(index);
                final config = _cryptoConfigs[crypto]!;
                final isSelected = crypto == _cryptoType;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _cryptoType = crypto;
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: 120,
                    decoration: BoxDecoration(
                      color: isSelected ? config['color'] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? config['color'] : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: config['color'].withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ] : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withOpacity(0.2) : config['lightColor'],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            config['symbol'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : config['color'],
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          crypto,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey.shade600,
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
      margin: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cryptoConfigs[_cryptoType]!['lightColor'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: _cryptoConfigs[_cryptoType]!['color'],
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _cryptoConfigs[_cryptoType]!['color'], width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cryptoConfig = _cryptoConfigs[_cryptoType]!;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Gửi ${cryptoConfig['name']}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildCryptoSelector(),
                      
                      SizedBox(height: 16),
                      
                      // Main Form Card
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chi tiết giao dịch',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 20),
                            
                            _buildModernTextField(
                              controller: _titleController,
                              label: 'Tiêu đề giao dịch',
                              icon: Icons.title,
                              hint: 'Nhập mô tả cho giao dịch',
                              validator: (value) => value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                            ),
                            
                            _buildModernTextField(
                              controller: _addressController,
                              label: 'Địa chỉ ví người nhận',
                              icon: Icons.account_balance_wallet,
                              hint: 'Nhập địa chỉ ví ${_cryptoType}',
                              validator: _validateAddress,
                              suffixIcon: IconButton(
                                icon: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: cryptoConfig['lightColor'],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.qr_code_scanner,
                                    color: cryptoConfig['color'],
                                    size: 20,
                                  ),
                                ),
                                onPressed: _scanQRCode,
                              ),
                            ),
                            
                            _buildModernTextField(
                              controller: _amountController,
                              label: 'Số lượng ${_cryptoType}',
                              icon: Icons.monetization_on,
                              hint: '0.00',
                              validator: _validateAmount,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
                              ],
                              suffixIcon: TextButton(
                                onPressed: _setMaxAmount,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: cryptoConfig['color'],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'MAX',
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
                      
                      SizedBox(height: 16),
                      
                      // Advanced Options
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cryptoConfig['lightColor'],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.tune,
                                  color: cryptoConfig['color'],
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                'Tùy chọn nâng cao',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                'Phí giao dịch và cài đặt khác',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              trailing: AnimatedRotation(
                                turns: _showAdvancedOptions ? 0.5 : 0,
                                duration: Duration(milliseconds: 300),
                                child: Icon(Icons.expand_more),
                              ),
                              onTap: () {
                                setState(() {
                                  _showAdvancedOptions = !_showAdvancedOptions;
                                });
                                HapticFeedback.selectionClick();
                              },
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: _showAdvancedOptions ? null : 0,
                              child: _showAdvancedOptions ? Container(
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed: _estimateFee,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: cryptoConfig['color'],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                          ),
                                          child: Text('Ước tính'),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Phí tối thiểu: ${_cryptoConfigs[_cryptoType]!['minFee']} $_cryptoType',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ) : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24),
                    ],
                  ),
                ),
                
                // Bottom Submit Button
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: ScaleTransition(
                      scale: _buttonScaleAnimation,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (_isSubmitting || !_isFormValid) ? null : _submitTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFormValid ? cryptoConfig['color'] : Colors.grey.shade300,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: _isFormValid ? 8 : 0,
                            shadowColor: cryptoConfig['color'].withOpacity(0.3),
                          ),
                          child: _isSubmitting
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Đang xử lý...', style: TextStyle(fontSize: 16)),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.send_rounded, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Gửi ${_amountController.text.isEmpty ? '' : '${_amountController.text} '}$_cryptoType',
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
                ),
                
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// SOLUTION 2: Alternative version with BLoC consumer (wrap the specific parts that need BLoC)
class SendScreenWithBlocConsumer extends StatefulWidget {
  const SendScreenWithBlocConsumer({super.key});

  @override
  State<SendScreenWithBlocConsumer> createState() => _SendScreenWithBlocConsumerState();
}

class _SendScreenWithBlocConsumerState extends State<SendScreenWithBlocConsumer> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _feeAmountController = TextEditingController();
  
  String _cryptoType = 'ETH';
  bool _isFormValid = false;
  bool _showAdvancedOptions = false;
  
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _buttonAnimationController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonScaleAnimation;

  // Crypto configurations with modern colors
  final Map<String, Map<String, dynamic>> _cryptoConfigs = {
    'ETH': {
      'name': 'Ethereum',
      'color': Color(0xFF627EEA),
      'lightColor': Color(0xFFE8ECFF),
      'icon': Icons.currency_bitcoin,
      'symbol': 'Ξ',
      'minFee': 0.001,
      'addressPattern': r'^0x[a-fA-F0-9]{40}$',
    },
    'BTC': {
      'name': 'Bitcoin',
      'color': Color(0xFFF7931A),
      'lightColor': Color(0xFFFFF3E0),
      'icon': Icons.currency_bitcoin,
      'symbol': '₿',
      'minFee': 0.0001,
      'addressPattern': r'^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$|^bc1[a-z0-9]{39,59}$',
    },
    'USDT': {
      'name': 'Tether USD',
      'color': Color(0xFF26A17B),
      'lightColor': Color(0xFFE8F5F0),
      'icon': Icons.attach_money,
      'symbol': '₮',
      'minFee': 0.0001,
      'addressPattern': r'^0x[a-fA-F0-9]{40}$',
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
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  void _setupListeners() {
    _titleController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
    _amountController.addListener(_validateForm);
    _feeAmountController.addListener(_validateForm);
  }

  void _startAnimations() {
    Future.delayed(Duration(milliseconds: 100), () {
      _slideAnimationController.forward();
    });
    Future.delayed(Duration(milliseconds: 200), () {
      _fadeAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _buttonAnimationController.dispose();
    _titleController.dispose();
    _addressController.dispose();
    _amountController.dispose();
    _feeAmountController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _titleController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _amountController.text.isNotEmpty &&
        _feeAmountController.text.isNotEmpty;
    
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
      
      if (isValid) {
        _buttonAnimationController.forward();
      } else {
        _buttonAnimationController.reverse();
      }
    }
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập địa chỉ ví';
    }
    
    final pattern = _cryptoConfigs[_cryptoType]!['addressPattern'] as String;
    if (!RegExp(pattern).hasMatch(value)) {
      return 'Địa chỉ $_cryptoType không hợp lệ';
    }
    
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số tiền';
    }
    
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Số tiền phải lớn hơn 0';
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

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Giao dịch thành công!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Đã gửi ${_amountController.text} $_cryptoType',
                      style: const TextStyle(fontSize: 12,),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _scanQRCode() {
    HapticFeedback.selectionClick();
    // Show bottom sheet for QR scanner
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 48, color: _cryptoConfigs[_cryptoType]!['color']),
              SizedBox(height: 16),
              Text('QR Scanner sẽ được triển khai', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  void _setMaxAmount() {
    HapticFeedback.selectionClick();
    _amountController.text = '1.0'; // Demo value
    _validateForm();
  }

  void _estimateFee() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null) {
      final estimatedFee = amount * 0.001;
      _feeAmountController.text = estimatedFee.toStringAsFixed(6);
      _validateForm();
      HapticFeedback.selectionClick();
    }
  }

  Widget _buildCryptoSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Chọn loại tiền điện tử',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Container(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4),
              itemCount: _cryptoConfigs.length,
              separatorBuilder: (context, index) => SizedBox(width: 12),
              itemBuilder: (context, index) {
                final crypto = _cryptoConfigs.keys.elementAt(index);
                final config = _cryptoConfigs[crypto]!;
                final isSelected = crypto == _cryptoType;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _cryptoType = crypto;
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: 120,
                    decoration: BoxDecoration(
                      color: isSelected ? config['color'] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? config['color'] : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: config['color'].withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ] : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withOpacity(0.2) : config['lightColor'],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            config['symbol'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : config['color'],
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          crypto,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey.shade600,
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
      margin: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cryptoConfigs[_cryptoType]!['lightColor'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: _cryptoConfigs[_cryptoType]!['color'],
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _cryptoConfigs[_cryptoType]!['color'], width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cryptoConfig = _cryptoConfigs[_cryptoType]!;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Gửi ${cryptoConfig['name']}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildCryptoSelector(),
                      
                      SizedBox(height: 16),
                      
                      // Main Form Card
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chi tiết giao dịch',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 20),
                            
                            _buildModernTextField(
                              controller: _titleController,
                              label: 'Tiêu đề giao dịch',
                              icon: Icons.title,
                              hint: 'Nhập mô tả cho giao dịch',
                              validator: (value) => value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                            ),
                            
                            _buildModernTextField(
                              controller: _addressController,
                              label: 'Địa chỉ ví người nhận',
                              icon: Icons.account_balance_wallet,
                              hint: 'Nhập địa chỉ ví ${_cryptoType}',
                              validator: _validateAddress,
                              suffixIcon: IconButton(
                                icon: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: cryptoConfig['lightColor'],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.qr_code_scanner,
                                    color: cryptoConfig['color'],
                                    size: 20,
                                  ),
                                ),
                                onPressed: _scanQRCode,
                              ),
                            ),
                            
                            _buildModernTextField(
                              controller: _amountController,
                              label: 'Số lượng ${_cryptoType}',
                              icon: Icons.monetization_on,
                              hint: '0.00',
                              validator: _validateAmount,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
                              ],
                              suffixIcon: TextButton(
                                onPressed: _setMaxAmount,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: cryptoConfig['color'],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'MAX',
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
                      
                      SizedBox(height: 16),
                      
                      // Advanced Options
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cryptoConfig['lightColor'],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.tune,
                                  color: cryptoConfig['color'],
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                'Tùy chọn nâng cao',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                'Phí giao dịch và cài đặt khác',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              trailing: AnimatedRotation(
                                turns: _showAdvancedOptions ? 0.5 : 0,
                                duration: Duration(milliseconds: 300),
                                child: Icon(Icons.expand_more),
                              ),
                              onTap: () {
                                setState(() {
                                  _showAdvancedOptions = !_showAdvancedOptions;
                                });
                                HapticFeedback.selectionClick();
                              },
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: _showAdvancedOptions ? null : 0,
                              child: _showAdvancedOptions ? Container(
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed: _estimateFee,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: cryptoConfig['color'],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                          ),
                                          child: Text('Ước tính'),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Phí tối thiểu: ${_cryptoConfigs[_cryptoType]!['minFee']} $_cryptoType',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ) : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24),
                    ],
                  ),
                ),
                
                // Bottom Submit Button with BLoC Consumer
                BlocConsumer<TransactionBloc, TransactionState>(
                  listener: (context, state) {
                    if (state is TransactionSuccess) {
                      _showSuccessSnackBar();
                      Future.delayed(Duration(seconds: 1), () {
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      });
                    } else if (state is TransactionFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi: ${state.error}'),
                          backgroundColor: Colors.red.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: EdgeInsets.all(16),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isSubmitting = state is TransactionLoading;
                    
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 16,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: ScaleTransition(
                          scale: _buttonScaleAnimation,
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: (isSubmitting || !_isFormValid) ? null : () {
                                if (_formKey.currentState!.validate()) {
                                  HapticFeedback.lightImpact();
                                  
                                  context.read<TransactionBloc>().add(CreateSendTransaction(
                                    title: _titleController.text,
                                    address: _addressController.text,
                                    amount: double.parse(_amountController.text),
                                    cryptoType: _cryptoType,
                                    feeAmount: double.parse(_feeAmountController.text),
                                  ));
                                } else {
                                  HapticFeedback.heavyImpact();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFormValid ? cryptoConfig['color'] : Colors.grey.shade300,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: _isFormValid ? 8 : 0,
                                shadowColor: cryptoConfig['color'].withOpacity(0.3),
                              ),
                              child: isSubmitting
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Đang xử lý...', style: TextStyle(fontSize: 16)),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.send_rounded, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Gửi ${_amountController.text.isEmpty ? '' : '${_amountController.text} '}$_cryptoType',
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
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionSuccess extends TransactionState {
  final String transactionId;
  
  TransactionSuccess({required this.transactionId});
}

class TransactionFailure extends TransactionState {
  final String error;
  
  TransactionFailure({required this.error});
}