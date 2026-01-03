<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('clothing_items', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->unsignedBigInteger('category_id'); // CHANGED THIS LINE
            $table->enum('size', ['XS', 'S', 'M', 'L', 'XL', 'XXL']);
            $table->string('color')->nullable();
            $table->string('brand')->nullable();
            $table->decimal('price_per_day', 10, 2);
            $table->decimal('deposit_amount', 10, 2);
            $table->enum('status', ['available', 'rented', 'maintenance', 'cleaning'])->default('available');
            $table->enum('condition', ['new', 'excellent', 'good', 'fair'])->default('good');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('clothing_items');
    }
};