<?php

namespace App\Http\Controllers;

use App\Models\Payment;
use App\Models\Rental;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PaymentController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'rental_id' => 'required|exists:rentals,id',
            'amount' => 'required|numeric|min:0',
            'method' => 'required|in:cash,card,online',
            'transaction_reference' => 'nullable|string|max:255',
        ]);

        return DB::transaction(function () use ($validated) {
            $rental = Rental::findOrFail($validated['rental_id']);

            $payment = Payment::create([
                'rental_id' => $rental->id,
                'amount' => $validated['amount'],
                'method' => $validated['method'],
                'status' => 'paid',
                'transaction_reference' => $validated['transaction_reference'] ?? null,
                'paid_at' => Carbon::now(),
            ]);

            // Optionally update rental status when paid
            $rental->update(['status' => 'confirmed']);

            return response()->json([
                'message' => 'Payment recorded successfully',
                'payment' => $payment,
                'rental' => $rental,
            ], 201);
        });
    }
}
