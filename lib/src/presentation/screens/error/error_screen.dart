import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorScreen extends StatelessWidget {
 final String error;
 
 const ErrorScreen({super.key, required this.error});

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('Error'),
       backgroundColor: Colors.red.shade50,
       foregroundColor: Colors.red.shade800,
     ),
     body: Center(
       child: Padding(
         padding: const EdgeInsets.all(32.0),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(
               Icons.error_outline,
               size: 80,
               color: Colors.red.shade400,
             ),
             const SizedBox(height: 32),
             Text(
               'Oops! Something went wrong',
               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                 fontWeight: FontWeight.bold,
                 color: Colors.red.shade800,
               ),
               textAlign: TextAlign.center,
             ),
             const SizedBox(height: 16),
             Text(
               error,
               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                 color: Colors.grey[600],
               ),
               textAlign: TextAlign.center,
             ),
             const SizedBox(height: 32),
             ElevatedButton(
               onPressed: () => context.go('/'),
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.red.shade400,
                 foregroundColor: Colors.white,
                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
               ),
               child: const Text('Go Home'),
             ),
           ],
         ),
       ),
     ),
   );
 }
}