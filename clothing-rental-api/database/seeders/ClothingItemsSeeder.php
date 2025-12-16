<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;
use App\Models\ClothingItem;

class ClothingItemsSeeder extends Seeder
{
    public function run(): void
    {
        // Create categories first
        $categories = [
            ['name' => 'Traditional Moroccan', 'description' => 'Traditional Moroccan clothing items'],
            ['name' => 'Modern Casual', 'description' => 'Modern casual wear'],
            ['name' => 'Formal Wear', 'description' => 'Formal and business attire'],
            ['name' => 'Sportswear', 'description' => 'Athletic and sport clothing'],
        ];

        foreach ($categories as $category) {
            Category::firstOrCreate($category);
        }

        // Get category IDs
        $traditional = Category::where('name', 'Traditional Moroccan')->first()->id;
        $casual = Category::where('name', 'Modern Casual')->first()->id;
        $formal = Category::where('name', 'Formal Wear')->first()->id;
        $sport = Category::where('name', 'Sportswear')->first()->id;

        // Sample clothing items with Moroccan Dirham prices
        $items = [
            // Traditional Moroccan Items
            [
                'name' => 'Caftan Luxe',
                'description' => 'Elegant Moroccan caftan with intricate embroidery',
                'category_id' => $traditional,
                'size' => 'M',
                'color' => 'Red',
                'brand' => 'Marrakech Couture',
                'price_per_day' => 350.00,
                'deposit_amount' => 1500.00,
                'status' => 'available',
                'condition' => 'excellent'
            ],
            [
                'name' => 'Jellaba Moderne',
                'description' => 'Modern jellaba with contemporary design',
                'category_id' => $traditional,
                'size' => 'L',
                'color' => 'Navy Blue',
                'brand' => 'Casablanca Style',
                'price_per_day' => 200.00,
                'deposit_amount' => 800.00,
                'status' => 'available',
                'condition' => 'good'
            ],
            [
                'name' => 'Takchita Fête',
                'description' => 'Festive takchita for special occasions',
                'category_id' => $traditional,
                'size' => 'S',
                'color' => 'Gold',
                'brand' => 'Rabat Fashion',
                'price_per_day' => 450.00,
                'deposit_amount' => 2000.00,
                'status' => 'available',
                'condition' => 'new'
            ],
            [
                'name' => 'Djellaba Simple',
                'description' => 'Simple everyday djellaba',
                'category_id' => $traditional,
                'size' => 'XL',
                'color' => 'White',
                'brand' => 'Fez Traditional',
                'price_per_day' => 150.00,
                'deposit_amount' => 600.00,
                'status' => 'available',
                'condition' => 'good'
            ],

            // Modern Casual Items
            [
                'name' => 'Jean Moderne',
                'description' => 'Stylish modern jeans',
                'category_id' => $casual,
                'size' => 'M',
                'color' => 'Blue',
                'brand' => 'Denim Co',
                'price_per_day' => 120.00,
                'deposit_amount' => 400.00,
                'status' => 'available',
                'condition' => 'excellent'
            ],
            [
                'name' => 'T-Shirt Design',
                'description' => 'Designer t-shirt with modern print',
                'category_id' => $casual,
                'size' => 'L',
                'color' => 'Black',
                'brand' => 'Urban Style',
                'price_per_day' => 80.00,
                'deposit_amount' => 200.00,
                'status' => 'available',
                'condition' => 'good'
            ],
            [
                'name' => 'Hoodie Comfort',
                'description' => 'Comfortable hoodie for casual wear',
                'category_id' => $casual,
                'size' => 'S',
                'color' => 'Gray',
                'brand' => 'Cozy Wear',
                'price_per_day' => 100.00,
                'deposit_amount' => 300.00,
                'status' => 'available',
                'condition' => 'excellent'
            ],

            // Formal Wear Items
            [
                'name' => 'Suit Business',
                'description' => 'Professional business suit',
                'category_id' => $formal,
                'size' => 'L',
                'color' => 'Charcoal',
                'brand' => 'Executive Wear',
                'price_per_day' => 400.00,
                'deposit_amount' => 2500.00,
                'status' => 'available',
                'condition' => 'excellent'
            ],
            [
                'name' => 'Dress Evening',
                'description' => 'Elegant evening dress',
                'category_id' => $formal,
                'size' => 'M',
                'color' => 'Black',
                'brand' => 'Elegance',
                'price_per_day' => 350.00,
                'deposit_amount' => 1800.00,
                'status' => 'available',
                'condition' => 'new'
            ],
            [
                'name' => 'Shirt Formal',
                'description' => 'Classic formal shirt',
                'category_id' => $formal,
                'size' => 'XL',
                'color' => 'White',
                'brand' => 'Premium',
                'price_per_day' => 150.00,
                'deposit_amount' => 500.00,
                'status' => 'available',
                'condition' => 'good'
            ],

            // Sportswear Items
            [
                'name' => 'Tracksuit Sport',
                'description' => 'Comfortable tracksuit for exercise',
                'category_id' => $sport,
                'size' => 'M',
                'color' => 'Blue',
                'brand' => 'SportPro',
                'price_per_day' => 180.00,
                'deposit_amount' => 600.00,
                'status' => 'available',
                'condition' => 'excellent'
            ],
            [
                'name' => 'Jersey Team',
                'description' => 'Team sports jersey',
                'category_id' => $sport,
                'size' => 'L',
                'color' => 'Red',
                'brand' => 'TeamSport',
                'price_per_day' => 120.00,
                'deposit_amount' => 400.00,
                'status' => 'available',
                'condition' => 'good'
            ],
        ];

        foreach ($items as $item) {
            ClothingItem::firstOrCreate($item);
        }
    }
}
