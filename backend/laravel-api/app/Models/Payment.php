<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    use HasFactory;

    protected $fillable = [
        'rental_id',
        'amount',
        'method',
        'status',
        'transaction_reference',
        'paid_at',
        'stripe_payment_id',
        'payment_details',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'paid_at' => 'datetime',
        'payment_details' => 'array',
    ];

    public function rental()
    {
        return $this->belongsTo(Rental::class);
    }

    public function isPaid()
    {
        return $this->status === 'paid';
    }

    public function isPending()
    {
        return $this->status === 'pending';
    }

    public function isFailed()
    {
        return $this->status === 'failed';
    }

    public function markAsPaid($transactionReference = null)
    {
        $this->status = 'paid';
        $this->paid_at = now();
        if ($transactionReference) {
            $this->transaction_reference = $transactionReference;
        }
        $this->save();

        // Update rental status
        $this->rental->payment_status = 'paid';
        $this->rental->save();
    }

    public function markAsFailed($reason = null)
    {
        $this->status = 'failed';
        if ($reason) {
            $this->payment_details = array_merge($this->payment_details ?? [], ['failure_reason' => $reason]);
        }
        $this->save();

        // Update rental status
        $this->rental->payment_status = 'failed';
        $this->rental->save();
    }
}
