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

        // Sample clothing items with Moroccan Dirham prices and creative names based on actual images
        $items = [
            // Kaftans - Traditional Moroccan Items
            [
                'name' => 'Kaftan Royale d\'Or',
                'description' => 'Luxurious golden kaftan with intricate embroidery, perfect for weddings and special occasions',
                'category_id' => $traditional,
                'size' => 'M',
                'color' => 'Gold',
                'brand' => 'Marrakech Couture',
                'price_per_day' => 450.00,
                'deposit_amount' => 2500.00,
                'status' => 'available',
                'condition' => 'excellent',
                'image' => 'items/kaftan1.webp'
            ],
            [
                'name' => 'Kaftan Bleu Nuit',
                'description' => 'Elegant midnight blue kaftan with silver thread details',
                'category_id' => $traditional,
                'size' => 'L',
                'color' => 'Navy Blue',
                'brand' => 'Casablanca Couture',
                'price_per_day' => 380.00,
                'deposit_amount' => 1800.00,
                'status' => 'available',
                'condition' => 'excellent',
                'image' => 'items/kaftan2.webp'
            ],
            [
                'name' => 'Kaftan Émeraude',
                'description' => 'Stunning emerald green kaftan with traditional Moroccan patterns',
                'category_id' => $traditional,
                'size' => 'S',
                'color' => 'Emerald Green',
                'brand' => 'Rabat Fashion',
                'price_per_day' => 420.00,
                'deposit_amount' => 2000.00,
                'status' => 'available',
                'condition' => 'new',
                'image' => 'items/kaftan3.webp'
            ],
            [
                'name' => 'Kaftan Rose Garden',
                'description' => 'Romantic pink kaftan with floral embroidery and delicate beadwork',
                'category_id' => $traditional,
                'size' => 'XL',
                'color' => 'Rose Pink',
                'brand' => 'Fez Traditional',
                'price_per_day' => 350.00,
                'deposit_amount' => 1500.00,
                'status' => 'available',
                'condition' => 'good',
                'image' => 'items/kaftan4.webp'
            ],

            // Costumes - Modern Casual Items
            [
                'name' => 'Costume Arabe Moderne',
                'description' => 'Contemporary Arabic costume with subtle traditional elements',
                'category_id' => $casual,
                'size' => 'M',
                'color' => 'Royal Purple',
                'brand' => 'Urban Style',
                'price_per_day' => 150.00,
                'deposit_amount' => 600.00,
                'status' => 'available',
                'condition' => 'excellent',
                'image' => 'items/costume1.webp'
            ],
            [
                'name' => 'Costume Oriental Chic',
                'description' => 'Stylish oriental costume with modern design elements',
                'category_id' => $casual,
                'size' => 'L',
                'color' => 'Burgundy',
                'brand' => 'Oriental Fashion',
                'price_per_day' => 180.00,
                'deposit_amount' => 800.00,
                'status' => 'available',
                'condition' => 'good',
                'image' => 'items/costume2.webp'
            ],
            [
                'name' => 'Costume Desert Rose',
                'description' => 'Beautiful desert-inspired costume with warm tones and traditional patterns',
                'category_id' => $casual,
                'size' => 'S',
                'color' => 'Desert Rose',
                'brand' => 'Sahara Style',
                'price_per_day' => 200.00,
                'deposit_amount' => 900.00,
                'status' => 'available',
                'condition' => 'excellent',
                'image' => 'items/costume3.jpg'
            ],
            [
                'name' => 'Costume Marrakech Sunset',
                'description' => 'Vibrant costume inspired by Marrakech sunset colors',
                'category_id' => $casual,
                'size' => 'M',
                'color' => 'Sunset Orange',
                'brand' => 'Marrakech Fashion',
                'price_per_day' => 220.00,
                'deposit_amount' => 1000.00,
                'status' => 'available',
                'condition' => 'good',
                'image' => 'items/costume4.webp'
            ],

            // Hoodies - Modern Casual Items
            [
                'name' => 'Hoodie Marrakech Nights',
                'description' => 'Comfortable hoodie with Marrakech-inspired design and modern fit',
                'category_id' => $casual,
                'size' => 'L',
                'color' => 'Charcoal Gray',
                'brand' => 'Urban Morocco',
                'price_per_day' => 120.00,
                'deposit_amount' => 400.00,
                'status' => 'available',
                'condition' => 'excellent',
                'image' => 'items/hoodie1.jpg'
            ],
            [
                'name' => 'Hoodie Atlas Mountain',
                'description' => 'Cozy hoodie perfect for casual wear with subtle mountain-inspired details',
                'category_id' => $casual,
                'size' => 'M',
                'color' => 'Forest Green',
                'brand' => 'Mountain Wear',
                'price_per_day' => 100.00,
                'deposit_amount' => 350.00,
                'status' => 'available',
                'condition' => 'good',
                'image' => 'items/hoodie2.webp'
            ],
        ];

        foreach ($items as $item) {
            ClothingItem::firstOrCreate($item);
        }
    }
}
