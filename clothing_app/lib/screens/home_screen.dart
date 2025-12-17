import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ClothingItem> _items = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedSize;

  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    try {
      final data = await ApiService.getClothingItems(
        size: _selectedSize,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: 'available',
      );

      setState(() {
        _items = data.map((item) => ClothingItem.fromJson(item)).toList();
      });
    } catch (e) {
      if (!mounted) return;
      
      // Show error message but don't crash
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot connect to server. Using offline mode.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Set empty items list to prevent crash
      setState(() {
        _items = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Clothing'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Navigator.pushNamed(context, '/my-rentals'),
              tooltip: 'My Rentals',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF7C3AED),
                  const Color(0xFFA855F7),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find Your Style',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Discover amazing clothing for rent',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search clothing...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF7C3AED)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF7C3AED)),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                          _loadItems();
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    onSubmitted: (_) => _loadItems(),
                  ),
                ),

                const SizedBox(height: 16),
                
                // Size Filter with better styling
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildSizeChip('All', _selectedSize == null, () {
                        setState(() => _selectedSize = null);
                        _loadItems();
                      }),
                      ..._sizes.map((size) => _buildSizeChip(size, _selectedSize == size, () {
                        setState(() => _selectedSize = size);
                        _loadItems();
                      })),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checkroom_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadItems,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _buildClothingCard(item);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNavigationMenu();
        },
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.menu, color: Colors.white),
      ),
    );
  }

  Widget _buildSizeChip(String label, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF7C3AED) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClothingCard(ClothingItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/item-detail',
            arguments: {
              'id': item.id,
              'name': item.name,
              'description': item.description,
              'category': item.category?.name,
              'size': item.size,
              'color': item.color,
              'brand': item.brand,
              'price_per_day': item.pricePerDay,
              'deposit_amount': item.depositAmount,
              'status': item.status,
              'condition': item.condition,
              'image': item.image,
            },
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image with actual item image or placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: item.image != null && item.image!.isNotEmpty
                      ? Image.asset(
                          'assets/pictures/items/${item['image']}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF00897B),
                                    const Color(0xFF26A69A),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.checkroom_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF00897B),
                                const Color(0xFF26A69A),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.checkroom_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 16),

              // Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (item.category != null)
                      Text(
                        item.category!.name,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildChip(item.size, Icons.straighten),
                        const SizedBox(width: 8),
                        _buildChip(item.conditionLabel, Icons.star),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${item.formattedPrice}/day',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.statusLabel,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF7C3AED),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNavigationMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Navigation Menu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.history, color: Color(0xFF7C3AED)),
                      title: const Text('My Rentals'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/my-rentals');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.add_shopping_cart, color: Color(0xFF7C3AED)),
                      title: const Text('Create Rental'),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to create rental (needs item selection)
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.category, color: Color(0xFF7C3AED)),
                      title: const Text('Browse Categories'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/categories');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.search, color: Color(0xFF7C3AED)),
                      title: const Text('Advanced Search'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/advanced-search');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person, color: Color(0xFF7C3AED)),
                      title: const Text('My Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/user-profile');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout'),
                      onTap: () {
                        Navigator.pop(context);
                        _logout();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF7C3AED)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7C3AED),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
