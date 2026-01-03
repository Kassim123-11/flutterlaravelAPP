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
    Route::post('/payments/cash', [PaymentController::class, 'createCashPayment']);
    Route::post('/payments/card', [PaymentController::class, 'processCardPayment']);
    Route::get('/payments/status/{rentalId}', [PaymentController::class, 'getPaymentStatus']);
    
    // Admin payment management (protected)
    Route::get('/admin/payments/pending-cash', [PaymentController::class, 'getPendingCashPayments']);
    Route::post('/admin/payments/confirm-cash/{rentalId}', [PaymentController::class, 'confirmCashPayment']);

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

// Image serving route with CORS headers
Route::get('/images/{path}', function ($path) {
    $imagePath = storage_path('app/public/' . $path);
    
    if (!file_exists($imagePath)) {
        return response()->json(['error' => 'Image not found'], 404);
    }
    
    $image = file_get_contents($imagePath);
    $mimeType = mime_content_type($imagePath);
    
    return response($image)
        ->header('Content-Type', $mimeType)
        ->header('Access-Control-Allow-Origin', '*')
        ->header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
})->where('path', '.*');

// Health check route (for mobile app)
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'service' => 'Clothing Rental API',
        'database' => 'connected',
        'timestamp' => now()
    ]);
});