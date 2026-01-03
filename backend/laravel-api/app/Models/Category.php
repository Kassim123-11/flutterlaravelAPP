<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'description'];

    // A category has many clothing items
    public function clothingItems()
    {
        return $this->hasMany(ClothingItem::class);
    }
}