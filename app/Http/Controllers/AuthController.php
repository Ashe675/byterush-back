<?php

namespace App\Http\Controllers;

use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function register(RegisterRequest $request)
    {
        $data = $request->validated();

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => bcrypt($data['password']),
        ]);

        return [
            "token" => $user->createToken('auth_token')->plainTextToken,
            "message" => "Usuario registrado exitosamente."
        ];
    }

    public function login(LoginRequest $request) {
        $data = $request->validated();


        if (!auth()->attempt($data)) {
            return response()->json([
                'message' => 'Credenciales inválidas.'
            ], 401);
        }

        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'Usuario no encontrado.'
            ], 404);
        }

        return [
            'token' => $user->createToken('auth_token')->plainTextToken,
            'message' => 'Usuario autenticado exitosamente.'
        ];
    }

    public function logout(Request $request) {
        $user = $request->user();
        $user->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Usuario desconectado exitosamente.'
        ]);
    }
}
