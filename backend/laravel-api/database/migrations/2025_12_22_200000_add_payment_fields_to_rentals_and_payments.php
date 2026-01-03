<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('rentals', function (Blueprint $table) {
            $table->enum('payment_method', ['card', 'cash'])->nullable()->after('notes');
            $table->enum('payment_status', ['pending', 'paid', 'failed', 'refunded'])->default('pending')->after('payment_method');
            $table->string('payment_reference')->nullable()->after('payment_status');
            $table->timestamp('confirmed_at')->nullable()->after('updated_at');
        });

        Schema::table('payments', function (Blueprint $table) {
            $table->string('stripe_payment_id')->nullable()->after('transaction_reference');
            $table->text('payment_details')->nullable()->after('stripe_payment_id');
            $table->enum('status', ['pending', 'paid', 'failed', 'refunded'])->default('pending')->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('rentals', function (Blueprint $table) {
            $table->dropColumn(['payment_method', 'payment_status', 'payment_reference', 'confirmed_at']);
        });

        Schema::table('payments', function (Blueprint $table) {
            $table->dropColumn(['stripe_payment_id', 'payment_details']);
            // Note: enum column changes are not easily reversible in SQLite
        });
    }
};
