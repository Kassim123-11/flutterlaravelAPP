<?php

namespace App\Http\Controllers;

use App\Models\Rental;
use App\Models\RentalItem;
use App\Models\ClothingItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class RentalController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'rental_date' => 'required|date',
            'return_date' => 'required|date|after:rental_date',
            'notes' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.clothing_item_id' => 'required|exists:clothing_items,id',
            'items.*.quantity' => 'required|integer|min:1',
        ]);

        $user = $request->user();

        try {
            return DB::transaction(function () use ($validated, $user) {
                $totalAmount = 0;
                $start = Carbon::parse($validated['rental_date']);
                $end = Carbon::parse($validated['return_date']);
                $rentalDays = max(1, $start->diffInDays($end));

                $rental = Rental::create([
                    'user_id' => $user->id,
                    'rental_date' => $validated['rental_date'],
                    'return_date' => $validated['return_date'],
                    'total_amount' => 0,
                    'status' => 'pending',
                    'notes' => $validated['notes'] ?? null,
                ]);

                foreach ($validated['items'] as $itemData) {
                    $clothingItem = ClothingItem::findOrFail($itemData['clothing_item_id']);

                    $pricePerDay = $clothingItem->price_per_day;
                    $subtotal = $pricePerDay * $rentalDays * $itemData['quantity'];
                    $totalAmount += $subtotal;

                    RentalItem::create([
                        'rental_id' => $rental->id,
                        'clothing_item_id' => $clothingItem->id,
                        'quantity' => $itemData['quantity'],
                        'price_per_day' => $pricePerDay,
                        'subtotal' => $subtotal,
                    ]);

                    // Optionally mark item as rented
                    // $clothingItem->update(['status' => 'rented']);
                }

                $rental->update(['total_amount' => $totalAmount]);

                return response()->json([
                    'message' => 'Rental created successfully',
                    'rental' => $rental->load(['items.clothingItem']),
                ], 201);
            });
        } catch (\Throwable $e) {
            return response()->json([
                'message' => 'Rental creation failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function myRentals(Request $request)
    {
        $user = $request->user();

        $rentals = Rental::with(['items.clothingItem'])
            ->where('user_id', $user->id)
            ->orderByDesc('rental_date')
            ->get();

        return response()->json($rentals);
    }
}
