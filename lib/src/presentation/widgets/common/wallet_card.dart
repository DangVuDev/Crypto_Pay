// import 'package:flutter/material.dart';
// import 'package:crysta_pay/src/data/models/wallet_model.dart';

// class WalletCard extends StatelessWidget {
//   final WalletModel wallet;

//   const WalletCard({super.key, required this.wallet});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 160,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: wallet.type == CryptoType.eth
//             ? Colors.purple.withOpacity(0.1)
//             : wallet.type == CryptoType.btc
//                 ? Colors.orange.withOpacity(0.1)
//                 : Colors.green.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             wallet.typeName,
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           Text('${wallet.formattedBalance} ${wallet.typeName}'),
//           Text(wallet.formattedUsdValue, style: TextStyle(color: Colors.grey)),
//         ],
//       ),
//     );
//   }
// }