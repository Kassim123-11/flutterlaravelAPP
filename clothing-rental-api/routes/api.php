<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ClothingController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\RentalController;
use App\Http\Controllers\PaymentController;

use Illuminate\Support\Facades\DB;

// Test route to verify API is working
Route::get('/test', function () {
    return response()->json([
        'status' => 'success',
        'message' => 'Clothing Rental API is working!',
        'version' => '1.0',
        'timestamp' => now()
    ]);
});

// Temporary route to check database tables
Route::get('/debug/tables', function () {
    try {
        $tables = DB::select('SHOW TABLES');
        return response()->json([
            'status' => 'success',
            'tables' => array_map('current', $tables)
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage()
        ], 500);
    }
});

// Authentication routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    // Rentals (protected)
    Route::post('/rentals', [RentalController::class, 'store']);
    Route::get('/rentals/my', [RentalController::class, 'myRentals']);

    // Payments (protected)
    Route::post('/payments', [PaymentController::class, 'store']);

    // Protected routes (e.g. rentals) will go here later
});

// Clothing Items API - CRUD Operations (public for now)
Route::prefix('clothing')->group(function () {
    Route::get('/', [ClothingController::class, 'index']);           // Get all items
    Route::post('/', [ClothingController::class, 'store']);          // Create new item
    Route::get('/{id}', [ClothingController::class, 'show']);        // Get single item
    Route::put('/{id}', [ClothingController::class, 'update']);      // Update item
    Route::delete('/{id}', [ClothingController::class, 'destroy']);  // Delete item
});

// Health check route (for mobile app)
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'service' => 'Clothing Rental API',
        'database' => 'connected',
        'timestamp' => now()
    ]);
});