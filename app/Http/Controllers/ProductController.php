<?php

namespace App\Http\Controllers;

use App\Http\Resources\ProductCollection;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{

    public function index()
    {
        // return new ProductCollection(Product::orderBy('id', 'DESC')->paginate());
        return new ProductCollection(Product::orderBy('id', 'DESC')->get());
    }

     public function getProductsAvailables()
    {
        // return new ProductCollection(Product::orderBy('id', 'DESC')->paginate());
        return new ProductCollection(Product::where('available', 1)->orderBy('id', 'DESC')->get());
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Product  $product
     * @return \Illuminate\Http\Response
     */
    public function show(Product $product)
    {
        //
    }

    public function update(Request $request, Product $product)
    {
        if ($product->available) {
            $product->available = 0;
            $message = "Producto inhabilitado exitosamente.";
        } else {
            $product->available = 1;
            $message = "Producto habilitado exitosamente.";
        }
        $product->save();

        return response()->json(['message' => $message], 200);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Product  $product
     * @return \Illuminate\Http\Response
     */
    public function destroy(Product $product)
    {
        //
    }
}
