import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with TickerProviderStateMixin {
  List<ClothingItem> _allItems = [];
  List<ClothingItem> _filteredItems = [];
  bool _isLoading = true;
  String? _selectedCategory;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Kaftans',
      'icon': Icons.dry_cleaning,
      'color': const Color(0xFF6C63FF),
      'gradient': [const Color(0xFF6C63FF), const Color(0xFF8B80F9)],
      'image': 'kaftan',
    },
    {
      'name': 'Costumes',
      'icon': Icons.theater_comedy,
      'color': const Color(0xFFFF6B6B),
      'gradient': [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)],
      'image': 'costume',
    },
    {
      'name': 'Hoodies',
      'icon': Icons.style,
      'color': const Color(0xFF4ECDC4),
      'gradient': [const Color(0xFF4ECDC4), const Color(0xFF6EE7E0)],
      'image': 'hoodie',
    },
    {
      'name': 'Traditional',
      'icon': Icons.history_edu,
      'color': const Color(0xFF95E1D3),
      'gradient': [const Color(0xFF95E1D3), const Color(0xFFB4F4E8)],
      'image': 'traditional',
    },
    {
      'name': 'Modern',
      'icon': Icons.trending_up,
      'color': const Color(0xFFA8E6CF),
      'gradient': [const Color(0xFFA8E6CF), const Color(0xFFC8F5E0)],
      'image': 'modern',
    },
    {
      'name': 'All Items',
      'icon': Icons.grid_view,
      'color': const Color(0xFF7C3AED),
      'gradient': [const Color(0xFF7C3AED), const Color(0xFFA855F7)],
      'image': 'all',
    },
  ];

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
    _loadItems();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    try {
      final data = await ApiService.getClothingItems(status: 'available');
      setState(() {
        _allItems = data.map((item) => ClothingItem.fromJson(item)).toList();
        _filteredItems = _allItems;
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
        _allItems = [];
        _filteredItems = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All Items') {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) {
          final itemName = item.name.toLowerCase();
          final itemImage = item.image?.toLowerCase() ?? '';

          // Check both name and image path for category matching
          switch (category.toLowerCase()) {
            case 'kaftans':
              return itemName.contains('kaftan') || itemImage.contains('kaftan');
            case 'costumes':
              return itemName.contains('costume') || itemImage.contains('costume');
            case 'hoodies':
              return itemName.contains('hoodie') || itemImage.contains('hoodie');
            case 'traditional':
              return itemName.contains('kaftan') ||
                  itemName.contains('royale') ||
                  itemName.contains('tradition') ||
                  itemImage.contains('kaftan');
            case 'modern':
              return itemName.contains('costume') ||
                  itemName.contains('moderne') ||
                  itemName.contains('chic') ||
                  itemImage.contains('costume') ||
                  itemImage.contains('hoodie');
            default:
              return itemName.contains(category.toLowerCase()) ||
                  itemImage.contains(category.toLowerCase());
          }
        }).toList();
      }
    });
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => CategoryFilterDialog(
        categories: categories,
        selectedCategory: _selectedCategory,
        onCategorySelected: (category) {
          Navigator.pop(context);
          _filterByCategory(category);
        },
      ),
    );
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
                      onPressed: () {
                        print('Categories back button pressed');
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
                    const SizedBox(width: 10),
                    const Text(
                      'Categories',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.filter_list, color: Colors.white),
                        onPressed: _showCategoryDialog,
                        tooltip: 'Filter Categories',
                      ),
                    ),
                  ],
                ),
              ),

              // Categories Grid
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = _selectedCategory == category['name'];
                        final itemCount = category['name'] == 'All Items'
                            ? _allItems.length
                            : _allItems.where((item) {
                          final itemName = item.name.toLowerCase();
                          final itemImage = item.image?.toLowerCase() ?? '';
                          final categoryName = category['name'].toLowerCase();

                          // Use same logic as _filterByCategory
                          switch (categoryName) {
                            case 'kaftans':
                              return itemName.contains('kaftan') || itemImage.contains('kaftan');
                            case 'costumes':
                              return itemName.contains('costume') || itemImage.contains('costume');
                            case 'hoodies':
                              return itemName.contains('hoodie') || itemImage.contains('hoodie');
                            case 'traditional':
                              return itemName.contains('kaftan') ||
                                  itemName.contains('royale') ||
                                  itemName.contains('tradition') ||
                                  itemImage.contains('kaftan');
                            case 'modern':
                              return itemName.contains('costume') ||
                                  itemName.contains('moderne') ||
                                  itemName.contains('chic') ||
                                  itemImage.contains('costume') ||
                                  itemImage.contains('hoodie');
                            default:
                              return itemName.contains(categoryName) ||
                                  itemImage.contains(categoryName);
                          }
                        }).length;

                        return CategoryCard(
                          category: category,
                          itemCount: itemCount,
                          isSelected: isSelected,
                          onTap: () => _filterByCategory(category['name']),
                          index: index,
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Selected Category Info
              if (_selectedCategory != null)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.filter_list,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected: $_selectedCategory',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${_filteredItems.length} items found',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _filterByCategory('All Items'),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ),

              // Filtered Items Display
              if (_selectedCategory != null && _filteredItems.isNotEmpty)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return FilteredItemCard(
                          item: item,
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
                        );
                      },
                    ),
                  ),
                ),
              if (_selectedCategory != null && _filteredItems.isEmpty)
                Expanded(
                  child: Center(
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
                          'No items found in $_selectedCategory',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Try selecting a different category',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
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
}

class FilteredItemCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onTap;

  const FilteredItemCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  child: Image.asset(
                    'pictures/${item.image ?? 'kaftan1.webp'}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Image loading error: ${error.toString()}');
                      print('Trying to load: pictures/${item.image ?? 'kaftan1.webp'}');
                      print('Item image field: ${item.image}');
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
                      '${item.size} • ${item.color}',
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
}

class CategoryCard extends StatefulWidget {
  final Map<String, dynamic> category;
  final int itemCount;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.itemCount,
    required this.isSelected,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start animation with delay
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) {
                _controller.reverse();
                widget.onTap();
              },
              onTapCancel: () => _controller.reverse(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.category['gradient'],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.category['color'].withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                    if (widget.isSelected)
                      BoxShadow(
                        color: widget.category['color'].withOpacity(0.6),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                  ],
                  border: widget.isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                ),
                child: Stack(
                  children: [
                    // Background Pattern
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              widget.category['icon'],
                              color: Colors.white,
                              size: 28,
                            ),
                          ),

                          const Spacer(),

                          // Category Name
                          Text(
                            widget.category['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Item Count
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${widget.itemCount} items',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Selected Badge
                    if (widget.isSelected)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Color(0xFF7C3AED),
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CategoryFilterDialog extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilterDialog({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategoryFilterDialog> createState() => _CategoryFilterDialogState();
}

class _CategoryFilterDialogState extends State<CategoryFilterDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _dialogController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _dialogController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dialogController, curve: Curves.easeInOut),
    );
    _dialogController.forward();
  }

  @override
  void dispose() {
    _dialogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _dialogController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.categories.first['gradient'],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.category,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            'Select Category',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Categories List - Make it scrollable
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.categories.map((category) {
                            final isSelected = widget.selectedCategory == category['name'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CategoryFilterItem(
                                category: category,
                                isSelected: isSelected,
                                onTap: () => widget.onCategorySelected(category['name']),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryFilterItem extends StatefulWidget {
  final Map<String, dynamic> category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterItem({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CategoryFilterItem> createState() => _CategoryFilterItemState();
}

class _CategoryFilterItemState extends State<CategoryFilterItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onTap();
            },
            onTapCancel: () => _controller.reverse(),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: widget.isSelected
                      ? widget.category['gradient']
                      : [Colors.grey.shade100, Colors.grey.shade50],
                ),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: widget.category['color'].withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? Colors.white.withOpacity(0.2)
                          : widget.category['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.category['icon'],
                      color: widget.isSelected
                          ? Colors.white
                          : widget.category['color'],
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Name
                  Expanded(
                    child: Text(
                      widget.category['name'],
                      style: TextStyle(
                        color: widget.isSelected ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Selection Indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? Colors.white
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.isSelected
                        ? const Icon(
                      Icons.check,
                      color: Color(0xFF7C3AED),
                      size: 16,
                    )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}