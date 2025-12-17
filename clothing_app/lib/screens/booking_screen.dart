import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../models.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const BookingScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  DateTime? _startDate;
  DateTime? _endDate;
  int _rentalDays = 0;
  double _totalCost = 0.0;
  double _depositAmount = 0.0;
  bool _isLoading = false;
  String? _selectedSize;
  List<String> _availableSizes = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _depositAmount = 0.0; // Start with 0 deposit
    _availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
    _selectedSize = widget.item['size'] ?? 'M';
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateTotalCost() {
    if (_startDate != null && _endDate != null) {
      setState(() {
        _rentalDays = _endDate!.difference(_startDate!).inDays + 1;
        final dailyPrice = widget.item['price_per_day']?.toDouble() ?? 0.0;
        _totalCost = (_rentalDays * dailyPrice).toDouble();
        
        // Set reasonable deposit amount (10% of total cost or 100DH minimum)
        _depositAmount = (_totalCost * 0.1).clamp(100.0, 500.0);
      });
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
      _calculateTotalCost();
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start date first')),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!.add(const Duration(days: 1)),
      lastDate: _startDate!.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      _calculateTotalCost();
    }
  }

  Future<void> _createBooking() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select rental dates')),
      );
      return;
    }

    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a size')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save booking to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final rentalHistory = prefs.getStringList('rental_history') ?? [];
      
      // Create rental entry
      final rentalEntry = '${widget.item['name'] ?? 'Unknown Item'}|'
          '${DateFormat('yyyy-MM-dd').format(_startDate!)}|'
          '${DateFormat('yyyy-MM-dd').format(_endDate!)}|'
          '${_totalCost.toStringAsFixed(2)}|'
          'active|'; // status, no rating yet
      
      rentalHistory.add(rentalEntry);
      await prefs.setStringList('rental_history', rentalHistory);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to home
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating booking: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7C3AED),
              Color(0xFFA855F7),
              Color(0xFFF5F7FA),
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Book Item',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Booking Content
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item Preview
                          _buildItemPreview(),
                          
                          const SizedBox(height: 30),
                          
                          // Size Selection
                          _buildSizeSelection(),
                          
                          const SizedBox(height: 30),
                          
                          // Date Selection
                          _buildDateSelection(),
                          
                          const SizedBox(height: 30),
                          
                          // Cost Summary
                          _buildCostSummary(),
                          
                          const SizedBox(height: 30),
                          
                          // Booking Button
                          _buildBookingButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF7C3AED), const Color(0xFFA855F7)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                'http://localhost:8000/api/images/${widget.item['image'] ?? ''}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.checkroom_rounded,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item['name'] ?? 'Item',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${widget.item['size'] ?? 'N/A'} • ${widget.item['color'] ?? 'N/A'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.item['price_per_day'] ?? 0} MAD/day',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Size',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableSizes.map((size) {
            final isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF7C3AED) : Colors.white,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF7C3AED) : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rental Period',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildDateCard(
                'Start Date',
                _startDate != null
                    ? DateFormat('MMM dd, yyyy').format(_startDate!)
                    : 'Select date',
                Icons.calendar_today,
                _selectStartDate,
                _startDate != null,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildDateCard(
                'End Date',
                _endDate != null
                    ? DateFormat('MMM dd, yyyy').format(_endDate!)
                    : 'Select date',
                Icons.event,
                _selectEndDate,
                _endDate != null,
              ),
            ),
          ],
        ),
        if (_rentalDays > 0)
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: const Color(0xFF7C3AED)),
                  const SizedBox(width: 10),
                  Text(
                    'Rental duration: $_rentalDays days',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateCard(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? const Color(0xFF7C3AED) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF7C3AED)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF7C3AED) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cost Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(height: 15),
          _buildCostRow('Daily Rate', '${widget.item['price_per_day'] ?? 0} MAD'),
          if (_rentalDays > 0) ...[
            _buildCostRow('Rental Days', '$_rentalDays days'),
            _buildCostRow('Subtotal', '${_totalCost.toStringAsFixed(2)} MAD'),
            _buildCostRow('Security Deposit', '${_depositAmount.toStringAsFixed(2)} MAD'),
            const Divider(),
            _buildCostRow(
              'Total Amount',
              '${(_totalCost + _depositAmount).toStringAsFixed(2)} MAD',
              isTotal: true,
            ),
          ] else ...[
            _buildCostRow('Security Deposit', 'Select dates to calculate', isPlaceholder: true),
            const Divider(),
            _buildCostRow('Total Amount', 'Select dates to calculate', isPlaceholder: true),
          ],
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {bool isTotal = false, bool isPlaceholder = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isPlaceholder ? Colors.grey.shade500 : (isTotal ? Colors.black : Colors.grey.shade700),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.w600,
              color: isPlaceholder ? Colors.grey.shade500 : (isTotal ? const Color(0xFF7C3AED) : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C3AED),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Confirm Booking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
