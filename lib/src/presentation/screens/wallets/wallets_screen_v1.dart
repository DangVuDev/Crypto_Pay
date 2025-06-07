// import 'package:crysta_pay/src/data/models/crypto_type_extension.dart';
// import 'package:crysta_pay/src/data/models/wallet_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';



// class WalletsScreen extends StatefulWidget {
//   const WalletsScreen({super.key});

//   @override
//   State<WalletsScreen> createState() => _WalletsScreenState();
// }

// class _WalletsScreenState extends State<WalletsScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
  
//   final _nameController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _mnemonicController = TextEditingController();
//   CryptoType _selectedCryptoType = CryptoType.eth;

//   // Sample data - replace with actual BLoC state
//   final List<WalletModel> sampleWallets = [
//   // Ví 1: Ethereum wallet với số dư cao
//   WalletModel(
//     id: 'wallet_001',
//     name: 'Ví Ethereum Chính',
//     address: '0x742d35Cc6634C0532925a3b8D598C48A8b3Df6C8',
//     type: CryptoType.eth,
//     balance: 15.75,
//     usdValue: 31850.25,
//     status: WalletStatus.active,
//     createdAt: DateTime(2024, 1, 15, 10, 30),
//     updatedAt: DateTime(2024, 6, 1, 14, 22),
//   ),

//   // Ví 2: Bitcoin wallet
//   WalletModel(
//     id: 'wallet_002', 
//     name: 'Bitcoin Savings',
//     address: '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa',
//     type: CryptoType.btc,
//     balance: 0.5432,
//     usdValue: 23456.78,
//     status: WalletStatus.active,
//     createdAt: DateTime(2024, 2, 20, 9, 15),
//     updatedAt: DateTime(2024, 5, 28, 16, 45),
//   ),

//   // Ví 3: USDT stablecoin wallet
//   WalletModel(
//     id: 'wallet_003',
//     name: 'Ví USDT Trading',
//     address: '0x8ba1f109551bD432803012645Hac136c22C85A7e6',
//     type: CryptoType.usdt,
//     balance: 5000.00,
//     usdValue: 5000.00,
//     status: WalletStatus.active,
//     createdAt: DateTime(2024, 3, 10, 8, 0),
//     updatedAt: DateTime(2024, 6, 5, 11, 30),
//   ),

//   // Ví 4: Solana wallet bị khóa
//   WalletModel(
//     id: 'wallet_004',
//     name: 'Solana DeFi',
//     address: 'DjVE6JNiYqPL2QXyCUUh8rNjHrbz6hXHNwkTtcxjxHvG',
//     type: CryptoType.sol,
//     balance: 250.0,
//     usdValue: 8750.00,
//     status: WalletStatus.locked,
//     createdAt: DateTime(2024, 4, 5, 14, 20),
//     updatedAt: DateTime(2024, 5, 15, 10, 10),
//   ),

//   // Ví 5: BNB wallet với số dư thấp
//   WalletModel(
//     id: 'wallet_005',
//     name: 'Binance Smart Chain',
//     address: '0x8f8221aFbB33998d8584A2B05749Ba73c37a938a',
//     type: CryptoType.bnb,
//     balance: 12.8456,
//     usdValue: 3087.50,
//     status: WalletStatus.active,
//     createdAt: DateTime(2024, 5, 1, 16, 45),
//     updatedAt: null, // Chưa cập nhật lần nào
//   ),
// ];

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
    
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOut,
//     ));
    
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _nameController.dispose();
//     _addressController.dispose();
//     _mnemonicController.dispose();
//     super.dispose();
//   }

//   void _showWalletOptionsBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF1A1A1A),
//               Color(0xFF2D2D2D),
//             ],
//           ),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Add Wallet',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 32),
              
//               _buildOptionButton(
//                 icon: Icons.add_circle_outline,
//                 title: 'Create New Wallet',
//                 subtitle: 'Generate a new wallet with seed phrase',
//                 color: Colors.blue,
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showCreateWalletDialog();
//                 },
//               ),
              
//               const SizedBox(height: 16),
              
//               _buildOptionButton(
//                 icon: Icons.download_outlined,
//                 title: 'Import Wallet',
//                 subtitle: 'Import existing wallet with seed phrase',
//                 color: Colors.green,
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showImportWalletDialog();
//                 },
//               ),
              
//               const SizedBox(height: 16),
              
//               _buildOptionButton(
//                 icon: Icons.link,
//                 title: 'Connect Wallet',
//                 subtitle: 'Connect MetaMask, WalletConnect, etc.',
//                 color: Colors.purple,
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showConnectWalletDialog();
//                 },
//               ),
              
//               const SizedBox(height: 16),
              
//               _buildOptionButton(
//                 icon: Icons.security,
//                 title: 'Hardware Wallet',
//                 subtitle: 'Connect Ledger or Trezor device',
//                 color: Colors.orange,
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showHardwareWalletDialog();
//                 },
//               ),
              
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildOptionButton({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Colors.white.withOpacity(0.1),
//               Colors.white.withOpacity(0.05),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: Colors.white.withOpacity(0.2),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: Colors.white, size: 24),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.7),
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               color: Colors.white.withOpacity(0.5),
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showCreateWalletDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF2D2D2D),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text(
//           'Create New Wallet',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _nameController,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 labelText: 'Wallet Name',
//                 labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: _selectedCryptoType.color),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<CryptoType>(
//               value: _selectedCryptoType,
//               dropdownColor: const Color(0xFF2D2D2D),
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 labelText: 'Blockchain',
//                 labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: _selectedCryptoType.color),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               items: CryptoType.values.map((type) {
//                 return DropdownMenuItem<CryptoType>(
//                   value: type,
//                   child: Row(
//                     children: [
//                       Icon(type.icon, color: type.color, size: 20),
//                       const SizedBox(width: 8),
//                       Text(type.displayName),
//                     ],
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedCryptoType = value!;
//                 });
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: Colors.white.withOpacity(0.7)),
//             ),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _selectedCryptoType.color,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             onPressed: () {
//               // Generate new wallet logic
//               _createNewWallet();
//               Navigator.pop(context);
//             },
//             child: const Text('Create', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showImportWalletDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF2D2D2D),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text(
//           'Import Wallet',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _nameController,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 labelText: 'Wallet Name',
//                 labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: _selectedCryptoType.color),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _mnemonicController,
//               style: const TextStyle(color: Colors.white),
//               maxLines: 3,
//               decoration: InputDecoration(
//                 labelText: 'Seed Phrase (12 or 24 words)',
//                 labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: _selectedCryptoType.color),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<CryptoType>(
//               value: _selectedCryptoType,
//               dropdownColor: const Color(0xFF2D2D2D),
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 labelText: 'Blockchain',
//                 labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               items: CryptoType.values.map((type) {
//                 return DropdownMenuItem<CryptoType>(
//                   value: type,
//                   child: Row(
//                     children: [
//                       Icon(type.icon, color: type.color, size: 20),
//                       const SizedBox(width: 8),
//                       Text(type.displayName),
//                     ],
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedCryptoType = value!;
//                 });
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: Colors.white.withOpacity(0.7)),
//             ),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             onPressed: () {
//               // Import wallet logic
//               _importWallet();
//               Navigator.pop(context);
//             },
//             child: const Text('Import', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showConnectWalletDialog() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
//           ),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Connect Wallet',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 32),
              
//               _buildWalletConnectOption(
//                 'MetaMask',
//                 'Connect using MetaMask browser extension',
//                 'assets/metamask.png',
//                 Colors.orange,
//               ),
              
//               const SizedBox(height: 16),
              
//               _buildWalletConnectOption(
//                 'WalletConnect',
//                 'Connect using WalletConnect protocol',
//                 'assets/walletconnect.png',
//                 Colors.blue,
//               ),
              
//               const SizedBox(height: 16),
              
//               _buildWalletConnectOption(
//                 'Trust Wallet',
//                 'Connect your Trust Wallet',
//                 'assets/trust.png',
//                 Colors.blue.shade800,
//               ),
              
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildWalletConnectOption(String name, String description, String iconPath, Color color) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pop(context);
//         _connectExternalWallet(name);
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
//           ),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.white.withOpacity(0.2)),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(Icons.account_balance_wallet, color: color),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     description,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.7),
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showHardwareWalletDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF2D2D2D),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text(
//           'Connect Hardware Wallet',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Connect your hardware wallet device',
//               style: TextStyle(color: Colors.white70),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildHardwareOption('Ledger', Icons.memory, Colors.blue),
//                 _buildHardwareOption('Trezor', Icons.security, Colors.green),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: Colors.white.withOpacity(0.7)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHardwareOption(String name, IconData icon, Color color) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pop(context);
//         _connectHardwareWallet(name);
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
//           ),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 32),
//             const SizedBox(height: 8),
//             Text(name, style: const TextStyle(color: Colors.white)),
//           ],
//         ),
//       ),
//     );
//   }

//   void _createNewWallet() {
//     // Implement wallet creation logic
//     setState(() {
//       sampleWallets.add(WalletModel(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         name: _nameController.text,
//         address: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
//         type: _selectedCryptoType,
//         balance: 0,
//         status: WalletStatus.active,
//         usdValue: 0,
//         updatedAt: DateTime.now(),
//         createdAt: DateTime.now(),
//       ));
//     });
//     _nameController.clear();
//   }

//   void _importWallet() {
//     // Implement wallet import logic
//     setState(() {
//       sampleWallets.add(WalletModel(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         name: _nameController.text,
//         address: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
//         type: _selectedCryptoType,
//         balance: 0,
//         usdValue: 0,
//         status: WalletStatus.active,
//         updatedAt: DateTime.now(),
//         createdAt: DateTime.now(),
//       ));
//     });
//     _nameController.clear();
//     _mnemonicController.clear();
//   }

//   void _connectExternalWallet(String walletName) {
//     // Implement external wallet connection
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Connecting to $walletName...'),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }

//   void _connectHardwareWallet(String deviceName) {
//     // Implement hardware wallet connection
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Connecting to $deviceName...'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   void _showWalletDetails(WalletModel wallet) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.7,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
//           ),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
              
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           wallet.type.color.withOpacity(0.8),
//                           wallet.type.color.withOpacity(0.6),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Icon(wallet.type.icon, color: Colors.white, size: 24),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           wallet.name,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           wallet.type.displayName,
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.7),
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (wallet.status == WalletStatus.active)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.green),
//                       ),
//                       child: const Text(
//                         'Connected',
//                         style: TextStyle(color: Colors.green, fontSize: 12),
//                       ),
//                     ),
//                 ],
//               ),
              
//               const SizedBox(height: 32),
              
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.white.withOpacity(0.1),
//                       Colors.white.withOpacity(0.05),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Balance',
//                       style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '${wallet.balance} ${wallet.type.symbol}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 24),
              
//               const Text(
//                 'Address',
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         wallet.address,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontFamily: 'monospace',
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.copy, color: Colors.white70),
//                       onPressed: () {
//                         Clipboard.setData(ClipboardData(text: wallet.address));
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Address copied!')),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
              
//               const Spacer(),
              
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.edit),
//                       label: const Text('Edit'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context);
//                         // Implement edit functionality
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.delete),
//                       label: const Text('Delete'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context);
//                         _showDeleteWalletDialog(wallet);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeleteWalletDialog(WalletModel wallet) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF2D2D2D),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text(
//           'Delete Wallet',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.warning_amber_rounded,
//               color: Colors.orange,
//               size: 64,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Are you sure you want to delete "${wallet.name}"?',
//               style: const TextStyle(color: Colors.white70),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'This action cannot be undone. Make sure you have backed up your seed phrase.',
//               style: TextStyle(color: Colors.red, fontSize: 12),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: Colors.white.withOpacity(0.7)),
//             ),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             onPressed: () {
//               setState(() {
//                 sampleWallets.removeWhere((w) => w.id == wallet.id);
//               });
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('${wallet.name} deleted'),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF121212),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF1A1A1A),
//               Color(0xFF121212),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Row(
//                     children: [
//                       const Text(
//                         'My Wallets',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const Spacer(),
//                       Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.white.withOpacity(0.2),
//                               Colors.white.withOpacity(0.1),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: IconButton(
//                           icon: const Icon(Icons.notifications_outlined, color: Colors.white),
//                           onPressed: () {
//                             // Implement notifications
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Wallet Statistics
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.blue.withOpacity(0.3),
//                           Colors.purple.withOpacity(0.3),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.2),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Total Wallets',
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.8),
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 '${sampleWallets.length}',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           width: 1,
//                           height: 40,
//                           color: Colors.white.withOpacity(0.3),
//                         ),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 'Connected',
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.8),
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 '${sampleWallets.where((w) => w.status == WalletStatus.active).length}',
//                                 style: const TextStyle(
//                                   color: Colors.green,
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // Filter Chips
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: [
//                         _buildFilterChip('All', true),
//                         const SizedBox(width: 12),
//                         _buildFilterChip('Connected', false),
//                         const SizedBox(width: 12),
//                         _buildFilterChip('Hardware', false),
//                         const SizedBox(width: 12),
//                         _buildFilterChip('Ethereum', false),
//                         const SizedBox(width: 12),
//                         _buildFilterChip('Bitcoin', false),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // Wallets List
//                 Expanded(
//                   child: sampleWallets.isEmpty
//                       ? Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.account_balance_wallet_outlined,
//                                 size: 80,
//                                 color: Colors.white.withOpacity(0.3),
//                               ),
//                               const SizedBox(height: 16),
//                               Text(
//                                 'No Wallets Yet',
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.7),
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Create or import your first wallet to get started',
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.5),
//                                   fontSize: 14,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         )
//                       : ListView.builder(
//                           padding: const EdgeInsets.symmetric(horizontal: 24),
//                           itemCount: sampleWallets.length,
//                           itemBuilder: (context, index) {
//                             final wallet = sampleWallets[index];
//                             return _buildWalletCard(wallet, index);
//                           },
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _showWalletOptionsBottomSheet,
//         backgroundColor: Colors.blue,
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text(
//           'Add Wallet',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterChip(String label, bool isSelected) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         gradient: isSelected
//             ? LinearGradient(
//                 colors: [Colors.blue.withOpacity(0.8), Colors.blue.withOpacity(0.6)],
//               )
//             : null,
//         color: isSelected ? null : Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: isSelected ? Colors.blue : Colors.white.withOpacity(0.3),
//         ),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
//           fontSize: 12,
//           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//     );
//   }

//   Widget _buildWalletCard(WalletModel wallet, int index) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: GestureDetector(
//         onTap: () => _showWalletDetails(wallet),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Colors.white.withOpacity(0.1),
//                 Colors.white.withOpacity(0.05),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: wallet.status == WalletStatus.active 
//                   ? Colors.green.withOpacity(0.5)
//                   : Colors.white.withOpacity(0.2),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           wallet.type.color.withOpacity(0.8),
//                           wallet.type.color.withOpacity(0.6),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Icon(wallet.type.icon, color: Colors.white, size: 24),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 wallet.name,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             if (wallet.isHardwareWallet)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: Colors.orange.withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(6),
//                                   border: Border.all(color: Colors.orange),
//                                 ),
//                                 child: const Text(
//                                   'HW',
//                                   style: TextStyle(color: Colors.orange, fontSize: 10),
//                                 ),
//                               ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           wallet.type.displayName,
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.7),
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         '${wallet.balance} ${wallet.type.symbol}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: wallet.status == WalletStatus.active 
//                               ? Colors.green.withOpacity(0.2)
//                               : Colors.red.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(6),
//                           border: Border.all(
//                             color: wallet.status == WalletStatus.active  ? Colors.green : Colors.red,
//                           ),
//                         ),
//                         child: Text(
//                           wallet.status == WalletStatus.active  ? 'Connected' : 'Offline',
//                           style: TextStyle(
//                             color: wallet.status == WalletStatus.active  ? Colors.green : Colors.red,
//                             fontSize: 10,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 16),
              
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.location_on,
//                       color: Colors.white.withOpacity(0.5),
//                       size: 16,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         '${wallet.address.substring(0, 10)}...${wallet.address.substring(wallet.address.length - 8)}',
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.7),
//                           fontSize: 12,
//                           fontFamily: 'monospace',
//                         ),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Clipboard.setData(ClipboardData(text: wallet.address));
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Address copied!'),
//                             duration: Duration(seconds: 1),
//                           ),
//                         );
//                       },
//                       child: Icon(
//                         Icons.copy,
//                         color: Colors.white.withOpacity(0.5),
//                         size: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 12),
              
//               Row(
//                 children: [
//                   Icon(
//                     Icons.access_time,
//                     color: Colors.white.withOpacity(0.5),
//                     size: 14,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Created ${_formatDate(wallet.createdAt)}',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.5),
//                       fontSize: 12,
//                     ),
//                   ),
//                   const Spacer(),
//                   Icon(
//                     Icons.arrow_forward_ios,
//                     color: Colors.white.withOpacity(0.3),
//                     size: 16,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
    
//     if (difference.inDays > 0) {
//       return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
//     } else {
//       return 'Today';
//     }
//   }
// }