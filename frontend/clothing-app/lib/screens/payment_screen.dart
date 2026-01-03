import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> rentalData;

  const PaymentScreen({Key? key, required this.rentalData}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'cash';
  bool _isProcessing = false;
  Map<String, dynamic>? _paymentResult;

  // Card form controllers
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'MAD ');

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = double.tryParse(widget.rentalData['total_amount']?.toString() ?? '0') ?? 0.0;
    final items = widget.rentalData['items'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            _buildOrderSummary(items, totalAmount),
            
            const SizedBox(height: 24),
            
            // Payment Method Selection
            _buildPaymentMethodSelection(),
            
            const SizedBox(height: 24),
            
            // Payment Details based on selection
            _buildPaymentDetails(),
            
            const SizedBox(height: 32),
            
            // Process Payment Button
            _buildProcessPaymentButton(),
            
            // Payment Result
            if (_paymentResult != null) _buildPaymentResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(List<dynamic> items, double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00897B),
            ),
          ),
          const SizedBox(height: 12),
          
          // Items List
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${item['name']} (${item['quantity']}x)',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                Text(
                  currencyFormat.format(item['price_per_day'] * item['quantity']),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )).toList(),
          
          const Divider(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                currencyFormat.format(totalAmount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00897B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00897B),
            ),
          ),
          const SizedBox(height: 16),
          
          // Cash Payment Option
          _buildPaymentOption(
            'cash',
            'Cash Payment',
            'Pay when you pick up the items',
            Icons.money,
          ),
          
          const SizedBox(height: 12),
          
          // Card Payment Option
          _buildPaymentOption(
            'card',
            'Card Payment',
            'Pay now with credit/debit card',
            Icons.credit_card,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method, String title, String description, IconData icon) {
    final isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF00897B) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? const Color(0xFF00897B).withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00897B) : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF00897B) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: method,
              groupValue: _selectedPaymentMethod,
              activeColor: const Color(0xFF00897B),
              onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    if (_selectedPaymentMethod == 'cash') {
      return _buildCashPaymentDetails();
    } else {
      return _buildCardPaymentDetails();
    }
  }

  Widget _buildCashPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Cash Payment Instructions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '1. Complete your booking now\n'
            '2. You will receive a payment reference code\n'
            '3. Pay the total amount when you pick up the items\n'
            '4. Show your payment reference code to the staff\n'
            '5. Your rental will be confirmed after payment',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2196F3)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Card Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Card Number
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
              maxLength: 19,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card number';
                }
                if (value.replaceAll(' ', '').length < 13) {
                  return 'Please enter a valid card number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            // Cardholder Name
            TextFormField(
              controller: _cardNameController,
              decoration: InputDecoration(
                labelText: 'Cardholder Name',
                hintText: 'John Doe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter cardholder name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            // Expiry and CVV Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    decoration: InputDecoration(
                      labelText: 'Expiry Date',
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    maxLength: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                        return 'MM/YY format';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (value.length != 3) {
                        return '3 digits';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Security Note
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your card information is encrypted and secure',
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
      ),
    );
  }

  Widget _buildProcessPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () {
          print('=== PAYMENT BUTTON PRESSED ===');
          print('Current payment method: $_selectedPaymentMethod');
          print('Is processing: $_isProcessing');
          _processPayment();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00897B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Processing...'),
                ],
              )
            : Text(
                _selectedPaymentMethod == 'cash' 
                    ? 'Complete Booking (Pay Later)' 
                    : 'Pay Now',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildPaymentResult() {
    if (_paymentResult == null) return const SizedBox.shrink();
    
    final isSuccess = _paymentResult!['message'] != null && 
                     !_paymentResult!['message'].toString().contains('error');
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFFE8F5E8) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
        ),
      ),
      child: Column(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: isSuccess ? Colors.green : Colors.red,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            isSuccess ? 'Payment Successful!' : 'Payment Failed',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSuccess ? Colors.green : Colors.red,
            ),
          ),
          if (_paymentResult!['payment_reference'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Reference: ${_paymentResult!['payment_reference']}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
          if (!isSuccess) ...[
            const SizedBox(height: 8),
            Text(
              _paymentResult!['message']?.toString() ?? 'An error occurred',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    print('=== PAYMENT PROCESSING STARTED ===');
    print('Payment method: $_selectedPaymentMethod');
    
    // Validate card form if card payment is selected
    if (_selectedPaymentMethod == 'card') {
      print('Validating card form...');
      if (!_formKey.currentState!.validate()) {
        print('Card validation failed');
        return; // Don't proceed if validation fails
      }
      print('Card validation passed');
    }

    print('Setting processing state to true');
    setState(() => _isProcessing = true);

    try {
      print('Getting rental data...');
      final rentalId = widget.rentalData['rental_id'];
      final totalAmountString = widget.rentalData['total_amount'];
      final totalAmount = double.tryParse(totalAmountString?.toString() ?? '0') ?? 0.0;
      print('Rental ID: $rentalId, Amount: $totalAmount (type: ${totalAmount.runtimeType})');

      Map<String, dynamic> result;

      if (_selectedPaymentMethod == 'cash') {
        // Create cash payment
        result = await ApiService.createCashPayment(
          rentalId: rentalId,
          amount: totalAmount,
        );
      } else {
        // For now, simulate card payment
        // In Phase 2, we'll integrate Stripe here
        result = await _simulateCardPayment(rentalId, totalAmount);
      }

      setState(() {
        _paymentResult = result;
        _isProcessing = false;
      });

      // Direct navigation based on payment method
      if (_selectedPaymentMethod == 'cash') {
        // Cash payment - active state (pending payment), navigate to My Rentals
        print('Cash payment - rental active, navigating to My Rentals');
        if (mounted) {
          Navigator.of(context).pushNamed('/my-rentals');
        }
      } else {
        // Card payment - direct acceptance (already paid), navigate to My Rentals
        print('Card payment - rental accepted, navigating to My Rentals');
        if (mounted) {
          Navigator.of(context).pushNamed('/my-rentals');
        }
      }
    } catch (e) {
      print('Payment processing error: $e');
      setState(() {
        _paymentResult = {'message': 'Payment failed: $e'};
        _isProcessing = false;
      });
    }
  }

  Future<Map<String, dynamic>> _simulateCardPayment(int rentalId, double amount) async {
    // Simulate card payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    // For now, create a regular payment record
    // In Phase 2, this will be replaced with actual Stripe integration
    return {
      'message': 'Card payment processed successfully',
      'payment_id': 'card_payment_${DateTime.now().millisecondsSinceEpoch}',
      'amount': amount,
    };
  }
}
