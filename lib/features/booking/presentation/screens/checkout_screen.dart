import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _withDriver = false;

  void _presentDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("Checkout"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rental Details", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Date Picker Card
            GestureDetector(
              onTap: _presentDateRangePicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dates", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        Text(
                          _startDate != null && _endDate != null
                              ? "${_startDate!.toLocal().toString().split(' ')[0]} - ${_endDate!.toLocal().toString().split(' ')[0]}"
                              : "Select Dates",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
             // Driver Toggle
            SwitchListTile.adaptive(
              title: const Text("Need a Driver?", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Additional charges apply"),
              value: _withDriver,
              onChanged: (val) => setState(() => _withDriver = val),
              secondary: const Icon(Icons.person),
              contentPadding: EdgeInsets.zero,
              activeColor: theme.primaryColor,
            ),
            
            const Divider(height: 48),
            
            Text("Payment Method", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Mock Payment Options
            const _PaymentOption(icon: Icons.credit_card, label: "Credit Card (Visa/Master)", selected: true),
            const SizedBox(height: 8),
            const _PaymentOption(icon: Icons.money, label: "Cash on Pickup", selected: false),
            
            const Divider(height: 48),
            
            // Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Amount", style: TextStyle(fontSize: 16)),
                Text(
                  "\$450.00", 
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    color: theme.primaryColor
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Booking Successful!")),
                );
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Confirm Booking", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _PaymentOption({required this.icon, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
       decoration: BoxDecoration(
         color: selected ? Colors.blue.withOpacity(0.05) : Colors.transparent,
         border: Border.all(color: selected ? Theme.of(context).primaryColor : Colors.grey.shade300),
         borderRadius: BorderRadius.circular(12),
       ),
       child: Row(
         children: [
           Icon(icon, color: selected ? Theme.of(context).primaryColor : Colors.grey),
           const SizedBox(width: 16),
           Text(
             label,
             style: TextStyle(
               fontWeight: selected ? FontWeight.bold : FontWeight.normal,
               color: selected ? Theme.of(context).primaryColor : Colors.black,
             ),
           ),
           const Spacer(),
           if (selected) Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 20),
         ],
       ),
    );
  }
}
