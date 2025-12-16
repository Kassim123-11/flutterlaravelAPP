// User Model
class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

// Category Model
class Category {
  final int id;
  final String name;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

// Clothing Item Model
class ClothingItem {
  final int id;
  final String name;
  final String? description;
  final Category? category;
  final String size;
  final String? color;
  final String? brand;
  final double pricePerDay;
  final double depositAmount;
  final String status;
  final String condition;

  ClothingItem({
    required this.id,
    required this.name,
    this.description,
    this.category,
    required this.size,
    this.color,
    this.brand,
    required this.pricePerDay,
    required this.depositAmount,
    required this.status,
    required this.condition,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      size: json['size'],
      color: json['color'],
      brand: json['brand'],
      pricePerDay: double.parse(json['price_per_day'].toString()),
      depositAmount: double.parse(json['deposit_amount'].toString()),
      status: json['status'],
      condition: json['condition'],
    );
  }

  String get statusLabel {
    switch (status) {
      case 'available':
        return 'Available';
      case 'rented':
        return 'Rented';
      case 'maintenance':
        return 'Maintenance';
      case 'cleaning':
        return 'Cleaning';
      default:
        return status;
    }
  }

  String get conditionLabel {
    switch (condition) {
      case 'new':
        return 'New';
      case 'excellent':
        return 'Excellent';
      case 'good':
        return 'Good';
      case 'fair':
        return 'Fair';
      default:
        return condition;
    }
  }

  String get formattedPrice {
    return '${pricePerDay.toStringAsFixed(2)} MAD';
  }

  String get formattedDeposit {
    return '${depositAmount.toStringAsFixed(2)} MAD';
  }
}

// Rental Item Model
class RentalItem {
  final int id;
  final int rentalId;
  final ClothingItem clothingItem;
  final int quantity;
  final double pricePerDay;
  final double subtotal;

  RentalItem({
    required this.id,
    required this.rentalId,
    required this.clothingItem,
    required this.quantity,
    required this.pricePerDay,
    required this.subtotal,
  });

  factory RentalItem.fromJson(Map<String, dynamic> json) {
    return RentalItem(
      id: json['id'],
      rentalId: json['rental_id'],
      clothingItem: ClothingItem.fromJson(json['clothing_item']),
      quantity: json['quantity'],
      pricePerDay: double.parse(json['price_per_day'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}

// Rental Model
class Rental {
  final int id;
  final int userId;
  final DateTime rentalDate;
  final DateTime returnDate;
  final double totalAmount;
  final String status;
  final String? notes;
  final List<RentalItem> items;

  Rental({
    required this.id,
    required this.userId,
    required this.rentalDate,
    required this.returnDate,
    required this.totalAmount,
    required this.status,
    this.notes,
    required this.items,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'],
      userId: json['user_id'],
      rentalDate: DateTime.parse(json['rental_date']),
      returnDate: DateTime.parse(json['return_date']),
      totalAmount: double.parse(json['total_amount'].toString()),
      status: json['status'],
      notes: json['notes'],
      items: (json['items'] as List)
          .map((item) => RentalItem.fromJson(item))
          .toList(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  int get rentalDays {
    return returnDate.difference(rentalDate).inDays;
  }
}