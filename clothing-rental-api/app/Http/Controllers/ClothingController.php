<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\ClothingItem;
use App\Models\Category;

class ClothingController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        // Optional filters: category_id, size, status, search
        $query = ClothingItem::with('category');

        if (request()->filled('category_id')) {
            $query->where('category_id', request('category_id'));
        }

        if (request()->filled('size')) {
            $query->where('size', request('size'));
        }

        if (request()->filled('status')) {
            $query->where('status', request('status'));
        }

        if (request()->filled('search')) {
            $search = request('search');
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%");
            });
        }

        $items = $query->paginate(10);

        return response()->json($items);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category_id' => 'required|exists:categories,id',
            'size' => 'required|in:XS,S,M,L,XL,XXL',
            'color' => 'nullable|string|max:100',
            'brand' => 'nullable|string|max:100',
            'price_per_day' => 'required|numeric|min:0',
            'deposit_amount' => 'required|numeric|min:0',
            'status' => 'nullable|in:available,rented,maintenance,cleaning',
            'condition' => 'nullable|in:new,excellent,good,fair',
        ]);

        $item = ClothingItem::create($validated);

        return response()->json([
            'message' => 'Clothing item created successfully',
            'data' => $item->load('category'),
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $item = ClothingItem::with('category')->find($id);

        if (! $item) {
            return response()->json([
                'message' => 'Clothing item not found',
            ], 404);
        }

        return response()->json($item);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $item = ClothingItem::find($id);

        if (! $item) {
            return response()->json([
                'message' => 'Clothing item not found',
            ], 404);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'category_id' => 'sometimes|required|exists:categories,id',
            'size' => 'sometimes|required|in:XS,S,M,L,XL,XXL',
            'color' => 'nullable|string|max:100',
            'brand' => 'nullable|string|max:100',
            'price_per_day' => 'sometimes|required|numeric|min:0',
            'deposit_amount' => 'sometimes|required|numeric|min:0',
            'status' => 'nullable|in:available,rented,maintenance,cleaning',
            'condition' => 'nullable|in:new,excellent,good,fair',
        ]);

        $item->update($validated);

        return response()->json([
            'message' => 'Clothing item updated successfully',
            'data' => $item->load('category'),
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $item = ClothingItem::find($id);

        if (! $item) {
            return response()->json([
                'message' => 'Clothing item not found',
            ], 404);
        }

        $item->delete();

        return response()->json([
            'message' => 'Clothing item deleted successfully',
        ]);
    }
}
