<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ClothingItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'category_id',
        'size',
        'color',
        'brand',
        'price_per_day',
        'deposit_amount',
        'status',
        'condition'
    ];

    protected $casts = [
        'price_per_day' => 'decimal:2',
        'deposit_amount' => 'decimal:2'
    ];

    // A clothing item belongs to a category
    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    // Check if available for rent
    public function isAvailable()
    {
        return $this->status === 'available';
    }
}