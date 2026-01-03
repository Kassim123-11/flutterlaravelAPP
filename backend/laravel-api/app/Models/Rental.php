<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Rental extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'rental_date',
        'return_date',
        'total_amount',
        'status',
        'notes',
        'payment_method',
        'payment_status',
        'payment_reference',
        'confirmed_at',
    ];

    protected $casts = [
        'rental_date' => 'datetime',
        'return_date' => 'datetime',
        'total_amount' => 'decimal:2',
        'confirmed_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function items()
    {
        return $this->hasMany(RentalItem::class);
    }

    public function payment()
    {
        return $this->hasOne(Payment::class);
    }

    public function isPaid()
    {
        return $this->payment_status === 'paid';
    }

    public function isConfirmed()
    {
        return $this->status === 'confirmed' || $this->confirmed_at !== null;
    }

    public function confirmRental()
    {
        $this->status = 'confirmed';
        $this->confirmed_at = now();
        $this->save();
    }

    public function generatePaymentReference()
    {
        if (!$this->payment_reference) {
            $this->payment_reference = 'PAY-' . strtoupper(uniqid()) . '-' . $this->id;
            $this->save();
        }
        return $this->payment_reference;
    }
}
