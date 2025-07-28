<?php

namespace App\Http\Controllers;

use App\Http\Resources\OrderCollection;
use App\Models\Order;
use App\Models\OrderProduct;
use App\Models\Product;
use Illuminate\Http\Request;

class OrderController extends Controller
{

    public function index()
    {
        return new OrderCollection(Order::with('user')->with('products')->where('status', 0)->get());
    }



    public function store(Request $request)
    {
        try {
            $orderProducts = $request->input('order');

            $order = new Order;
            $order->user_id = auth()->id();

            $products = [];
            $total = 0;
            foreach ($orderProducts as $orderProduct) {
                $product = Product::find($orderProduct['product_id']);
                if (!$product) {
                    return response()->json(['message' => 'Product not found'], 404);
                }
                $total += $product->price * $orderProduct['quantity'];
                $products[] = [
                    'product_id' => $product->id,
                    'quantity' => $orderProduct['quantity'],
                    'price' => $product->price,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }

            $order->total = $total;
            $order->status = 0; // Assuming 0 means pending
            $order->save();


            OrderProduct::insert(array_map(function ($product) use ($order) {
                return array_merge($product, ['order_id' => $order->id]);
            }, $products));


            return response()->json(['message' => 'Pedido realizado correctamente, estará listo en unos minutos.'], 201);
        } catch (\Throwable $th) {
            return response()->json(['message' => 'An error occurred while creating the order'], 500);
        }
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Order  $order
     * @return \Illuminate\Http\Response
     */
    public function show(Order $order)
    {
        //
    }

   
    public function update(Request $request, Order $order)
    {
        $order->status = 1;
        $order->save();

        return response()->json(['message' => 'Pedido completado exitosamente.'], 200);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Order  $order
     * @return \Illuminate\Http\Response
     */
    public function destroy(Order $order)
    {
        //
    }
}
