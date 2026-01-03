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

            // Update rental payment status
            $rental->update(['payment_status' => 'paid']);
            
            // Auto-confirm rental if payment is complete
            if ($rental->payment_status === 'paid') {
                $rental->confirmRental();
            }

            return response()->json([
                'message' => 'Payment recorded successfully',
                'payment' => $payment,
                'rental' => $rental,
            ], 201);
        });
    }

    public function createCashPayment(Request $request)
    {
        $validated = $request->validate([
            'rental_id' => 'required|exists:rentals,id',
            'amount' => 'required|numeric|min:0',
        ]);

        return DB::transaction(function () use ($validated) {
            $rental = Rental::findOrFail($validated['rental_id']);
            
            // Generate payment reference
            $paymentReference = $rental->generatePaymentReference();

            // Create pending cash payment
            $payment = Payment::create([
                'rental_id' => $rental->id,
                'amount' => $validated['amount'],
                'method' => 'cash',
                'status' => 'pending',
                'transaction_reference' => $paymentReference,
            ]);

            // Update rental with payment method and reference
            $rental->update([
                'payment_method' => 'cash',
                'payment_status' => 'pending',
                'payment_reference' => $paymentReference,
            ]);

            return response()->json([
                'message' => 'Cash payment created successfully',
                'payment' => $payment,
                'rental' => $rental,
                'payment_reference' => $paymentReference,
            ], 201);
        });
    }

    public function confirmCashPayment(Request $request, $rentalId)
    {
        $validated = $request->validate([
            'amount_received' => 'required|numeric|min:0',
            'notes' => 'nullable|string|max:500',
        ]);

        return DB::transaction(function () use ($rentalId, $validated) {
            $rental = Rental::findOrFail($rentalId);
            $payment = $rental->payment;

            if (!$payment || $payment->method !== 'cash') {
                return response()->json([
                    'message' => 'No cash payment found for this rental',
                ], 404);
            }

            if ($payment->isPaid()) {
                return response()->json([
                    'message' => 'Payment already confirmed',
                ], 400);
            }

            // Confirm payment
            $payment->markAsPaid('CASH-' . strtoupper(uniqid()));
            
            // Add payment details
            $payment->payment_details = array_merge($payment->payment_details ?? [], [
                'confirmed_by' => auth()->id() ?? 'system',
                'amount_received' => $validated['amount_received'],
                'confirmation_notes' => $validated['notes'] ?? null,
                'confirmed_at' => now()->toISOString(),
            ]);
            $payment->save();

            // Confirm rental
            $rental->confirmRental();

            return response()->json([
                'message' => 'Cash payment confirmed successfully',
                'payment' => $payment,
                'rental' => $rental,
            ]);
        });
    }

    public function getPaymentStatus($rentalId)
    {
        $rental = Rental::findOrFail($rentalId);
        
        return response()->json([
            'rental_id' => $rental->id,
            'payment_method' => $rental->payment_method,
            'payment_status' => $rental->payment_status,
            'payment_reference' => $rental->payment_reference,
            'is_paid' => $rental->isPaid(),
            'is_confirmed' => $rental->isConfirmed(),
            'payment' => $rental->payment,
        ]);
    }

    public function getPendingCashPayments()
    {
        $pendingPayments = Payment::with('rental.user')
            ->where('method', 'cash')
            ->where('status', 'pending')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'pending_payments' => $pendingPayments,
        ]);
    }

    public function processCardPayment(Request $request)
    {
        $validated = $request->validate([
            'rental_id' => 'required|exists:rentals,id',
            'amount' => 'required|numeric|min:0',
            'stripe_payment_id' => 'required|string',
            'payment_intent_id' => 'required|string',
        ]);

        return DB::transaction(function () use ($validated) {
            $rental = Rental::findOrFail($validated['rental_id']);

            // Create card payment record
            $payment = Payment::create([
                'rental_id' => $rental->id,
                'amount' => $validated['amount'],
                'method' => 'card',
                'status' => 'paid',
                'stripe_payment_id' => $validated['stripe_payment_id'],
                'transaction_reference' => $validated['payment_intent_id'],
                'paid_at' => Carbon::now(),
                'payment_details' => [
                    'payment_intent_id' => $validated['payment_intent_id'],
                    'processed_at' => now()->toISOString(),
                ],
            ]);

            // Update rental
            $rental->update([
                'payment_method' => 'card',
                'payment_status' => 'paid',
            ]);
            
            // Confirm rental
            $rental->confirmRental();

            return response()->json([
                'message' => 'Card payment processed successfully',
                'payment' => $payment,
                'rental' => $rental,
            ]);
        });
    }
}
