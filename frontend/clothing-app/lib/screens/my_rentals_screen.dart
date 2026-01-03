import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../models.dart';

class MyRentalsScreen extends StatefulWidget {
  const MyRentalsScreen({Key? key}) : super(key: key);

  @override
  State<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends State<MyRentalsScreen> {
  List<Map<String, dynamic>> _rentals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  Future<void> _loadRentals() async {
    setState(() => _isLoading = true);

    try {
      print('Loading rentals from API...');
      // Load rentals from API
      final rentals = await ApiService.getMyRentals();
      print('Loaded ${rentals.length} rentals from API');
      
      setState(() {
        _rentals = rentals.map((rental) => {
          'id': rental['id'],
          'item_name': rental['items']?.isNotEmpty == true 
              ? rental['items'][0]['clothing_item']['name'] ?? 'Unknown Item'
              : 'Unknown Item',
          'rental_date': rental['rental_date'],
          'return_date': rental['return_date'],
          'total_cost': double.tryParse(rental['total_amount']?.toString() ?? '0') ?? 0.0,
          'status': rental['status'],
          'rating': null,
        }).toList();
      });
      print('Rentals updated: ${_rentals.length} items');
    } catch (e) {
      print('Error loading rentals: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading rentals: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rentals'),
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            print('My Rentals back button pressed');
            try {
              Navigator.pushReplacementNamed(context, '/home');
            } catch (e) {
              print('Navigation error: $e');
              // Fallback to pop
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushNamed(context, '/home'),
            tooltip: 'Home',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rentals.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadRentals,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _rentals.length,
                itemBuilder: (context, index) {
                  final rental = _rentals[index];
                  return _buildRentalCard(rental);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF7C3AED), const Color(0xFFA855F7)],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Rentals Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start renting amazing clothing items!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Browse Items'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentalCard(Map<String, dynamic> rental) {
    final statusColor = _getStatusColor(rental['status']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(20),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.receipt_long,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          rental['item_name'] ?? 'Rental',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  DateTime.tryParse(rental['rental_date'] ?? '') != null 
                      ? DateFormat('MMM dd, yyyy').format(DateTime.parse(rental['rental_date']))
                      : rental['rental_date'] ?? 'N/A',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 14),
                const SizedBox(width: 8),
                Icon(Icons.event_available, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  DateTime.tryParse(rental['return_date'] ?? '') != null 
                      ? DateFormat('MMM dd, yyyy').format(DateTime.parse(rental['return_date']))
                      : rental['return_date'] ?? 'N/A',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rental['status'] ?? 'Unknown',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          '${(rental['total_cost'] ?? 0.0).toStringAsFixed(2)} MAD',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C3AED),
          ),
        ),
        children: [
          const Divider(),
          const SizedBox(height: 12),

          // Rental Items
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Item Details (simplified)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.checkroom_rounded,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rental['item_name'] ?? 'Rental Item',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${rental['status'] ?? 'Unknown'}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Status Badge - show rental status
          if (rental['status'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(rental['status']),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusText(rental['status']),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending Payment';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}
