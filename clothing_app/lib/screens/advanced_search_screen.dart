import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  
  List<ClothingItem> _allItems = [];
  List<ClothingItem> _filteredItems = [];
  List<ClothingItem> _displayedItems = [];
  bool _isLoading = true;
  
  // Filter options
  String? _selectedSize;
  String? _selectedColor;
  String? _selectedBrand;
  String? _selectedCondition;
  String _sortBy = 'name'; // name, price_low, price_high, newest
  bool _favoritesOnly = false;
  
  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _conditions = ['new', 'excellent', 'good', 'fair'];
  
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await ApiService.getClothingItems(status: 'available');
      setState(() {
        _allItems = data.map((item) => ClothingItem.fromJson(item)).toList();
        _filteredItems = _allItems;
        _displayedItems = _allItems;
        _extractFilterOptions();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _extractFilterOptions() {
    final colors = _allItems
        .map((item) => item.color)
        .where((color) => color != null && color!.isNotEmpty)
        .toSet()
        .cast<String>()
        .toList();
    
    final brands = _allItems
        .map((item) => item.brand)
        .where((brand) => brand != null && brand!.isNotEmpty)
        .toSet()
        .cast<String>()
        .toList();
    
    // Update state with extracted options
    setState(() {});
  }

  void _applyFilters() {
    setState(() {
      _filteredItems = _allItems.where((item) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        if (searchQuery.isNotEmpty) {
          final matchesName = item.name.toLowerCase().contains(searchQuery);
          final matchesBrand = item.brand?.toLowerCase().contains(searchQuery) ?? false;
          final matchesColor = item.color?.toLowerCase().contains(searchQuery) ?? false;
          if (!matchesName && !matchesBrand && !matchesColor) return false;
        }

        // Size filter
        if (_selectedSize != null && item.size != _selectedSize) return false;

        // Color filter
        if (_selectedColor != null && item.color != _selectedColor) return false;

        // Brand filter
        if (_selectedBrand != null && item.brand != _selectedBrand) return false;

        // Condition filter
        if (_selectedCondition != null && item.condition != _selectedCondition) return false;

        // Price range filter
        final minPrice = _minPriceController.text.isNotEmpty
            ? double.tryParse(_minPriceController.text)
            : null;
        final maxPrice = _maxPriceController.text.isNotEmpty
            ? double.tryParse(_maxPriceController.text)
            : null;

        if (minPrice != null && item.pricePerDay < minPrice) return false;
        if (maxPrice != null && item.pricePerDay > maxPrice) return false;

        return true;
      }).toList();

      // Apply sorting
      _applySorting();
    });
  }

  void _applySorting() {
    setState(() {
      switch (_sortBy) {
        case 'name':
          _displayedItems = List.from(_filteredItems)
            ..sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'price_low':
          _displayedItems = List.from(_filteredItems)
            ..sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
          break;
        case 'price_high':
          _displayedItems = List.from(_filteredItems)
            ..sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
          break;
        case 'newest':
          _displayedItems = List.from(_filteredItems)
            ..sort((a, b) => b.id.compareTo(a.id)); // Assuming higher ID = newer
          break;
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedSize = null;
      _selectedColor = null;
      _selectedBrand = null;
      _selectedCondition = null;
      _sortBy = 'name';
      _favoritesOnly = false;
      _filteredItems = _allItems;
      _displayedItems = _allItems;
    });
  }

  List<String> _getAvailableColors() {
    return _allItems
        .map((item) => item.color)
        .where((color) => color != null && color!.isNotEmpty)
        .toSet()
        .cast<String>()
        .toList();
  }

  List<String> _getAvailableBrands() {
    return _allItems
        .map((item) => item.brand)
        .where((brand) => brand != null && brand!.isNotEmpty)
        .toSet()
        .cast<String>()
        .toList();
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
                      'Advanced Search',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.clear_all, color: Colors.white),
                      onPressed: _clearFilters,
                      tooltip: 'Clear All Filters',
                    ),
                  ],
                ),
              ),

              // Search and Filters
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by name, brand, or color...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.tune),
                              onPressed: _showFilterDialog,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onChanged: (_) => _applyFilters(),
                        ),
                      ),

                      // Sort Options
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: DropdownButton<String>(
                                value: _sortBy,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 'name', child: Text('Name')),
                                  DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                                  DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                                  DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _sortBy = value!;
                                    _applySorting();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Active Filters
                      if (_hasActiveFilters())
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Wrap(
                            spacing: 8,
                            children: [
                              if (_selectedSize != null)
                                _buildFilterChip('Size: $_selectedSize', () => setState(() => _selectedSize = null)),
                              if (_selectedColor != null)
                                _buildFilterChip('Color: $_selectedColor', () => setState(() => _selectedColor = null)),
                              if (_selectedBrand != null)
                                _buildFilterChip('Brand: $_selectedBrand', () => setState(() => _selectedBrand = null)),
                              if (_selectedCondition != null)
                                _buildFilterChip('Condition: $_selectedCondition', () => setState(() => _selectedCondition = null)),
                              if (_minPriceController.text.isNotEmpty || _maxPriceController.text.isNotEmpty)
                                _buildFilterChip('Price Range', () {
                                  setState(() {
                                    _minPriceController.clear();
                                    _maxPriceController.clear();
                                  });
                                }),
                            ],
                          ),
                        ),

                      // Results Count
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_displayedItems.length} results found',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_isLoading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Results Grid
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _displayedItems.isEmpty
                                ? _buildEmptyState()
                                : GridView.builder(
                                    padding: const EdgeInsets.all(20),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing: 15,
                                      mainAxisSpacing: 15,
                                    ),
                                    itemCount: _displayedItems.length,
                                    itemBuilder: (context, index) {
                                      final item = _displayedItems[index];
                                      return _buildItemCard(item);
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onDeleted,
      backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1),
      deleteIconColor: const Color(0xFF7C3AED),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'No items found',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _clearFilters,
            child: const Text('Clear All Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(ClothingItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/item-detail',
          arguments: {
            'id': item.id,
            'name': item.name,
            'description': item.description,
            'price_per_day': item.pricePerDay,
            'size': item.size,
            'color': item.color,
            'brand': item.brand,
            'condition': item.condition,
            'image': item.image,
            'status': item.status,
            'deposit_amount': item.depositAmount,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    'http://localhost:8000/api/images/${item.image ?? ''}',
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
            ),
            
            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.size} • ${item.color ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${item.pricePerDay.toStringAsFixed(0)} MAD/day',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF00897B),
                      ),
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

  bool _hasActiveFilters() {
    return _selectedSize != null ||
        _selectedColor != null ||
        _selectedBrand != null ||
        _selectedCondition != null ||
        _minPriceController.text.isNotEmpty ||
        _maxPriceController.text.isNotEmpty ||
        _searchController.text.isNotEmpty;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        selectedSize: _selectedSize,
        selectedColor: _selectedColor,
        selectedBrand: _selectedBrand,
        selectedCondition: _selectedCondition,
        minPriceController: _minPriceController,
        maxPriceController: _maxPriceController,
        availableColors: _getAvailableColors(),
        availableBrands: _getAvailableBrands(),
        availableSizes: _sizes,
        availableConditions: _conditions,
        onApply: ({
          String? size,
          String? color,
          String? brand,
          String? condition,
        }) {
          Navigator.pop(context);
          setState(() {
            _selectedSize = size;
            _selectedColor = color;
            _selectedBrand = brand;
            _selectedCondition = condition;
          });
          _applyFilters();
        },
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  final String? selectedSize;
  final String? selectedColor;
  final String? selectedBrand;
  final String? selectedCondition;
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final List<String> availableColors;
  final List<String> availableBrands;
  final List<String> availableSizes;
  final List<String> availableConditions;
  final Function({
    String? size,
    String? color,
    String? brand,
    String? condition,
  }) onApply;

  const FilterDialog({
    Key? key,
    required this.selectedSize,
    required this.selectedColor,
    required this.selectedBrand,
    required this.selectedCondition,
    required this.minPriceController,
    required this.maxPriceController,
    required this.availableColors,
    required this.availableBrands,
    required this.availableSizes,
    required this.availableConditions,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String? _selectedSize;
  late String? _selectedColor;
  late String? _selectedBrand;
  late String? _selectedCondition;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.selectedSize;
    _selectedColor = widget.selectedColor;
    _selectedBrand = widget.selectedBrand;
    _selectedCondition = widget.selectedCondition;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Advanced Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Filters
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Size Filter
                    _buildSectionTitle('Size'),
                    Wrap(
                      spacing: 8,
                      children: widget.availableSizes.map((size) {
                        final isSelected = _selectedSize == size;
                        return FilterChip(
                          label: Text(size),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSize = selected ? size : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Color Filter
                    _buildSectionTitle('Color'),
                    Wrap(
                      spacing: 8,
                      children: widget.availableColors.map((color) {
                        final isSelected = _selectedColor == color;
                        return FilterChip(
                          label: Text(color),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedColor = selected ? color : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Brand Filter
                    _buildSectionTitle('Brand'),
                    Wrap(
                      spacing: 8,
                      children: widget.availableBrands.map((brand) {
                        final isSelected = _selectedBrand == brand;
                        return FilterChip(
                          label: Text(brand),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedBrand = selected ? brand : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Condition Filter
                    _buildSectionTitle('Condition'),
                    Wrap(
                      spacing: 8,
                      children: widget.availableConditions.map((condition) {
                        final isSelected = _selectedCondition == condition;
                        return FilterChip(
                          label: Text(condition),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCondition = selected ? condition : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Price Range Filter
                    _buildSectionTitle('Price Range (MAD/day)'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: widget.minPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Min Price',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: widget.maxPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Max Price',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    size: _selectedSize,
                    color: _selectedColor,
                    brand: _selectedBrand,
                    condition: _selectedCondition,
                  );
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
