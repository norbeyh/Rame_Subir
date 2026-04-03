<?php

use App\Http\Controllers\SearchController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\ContactoController;
use App\Http\Controllers\ValoracionController;
use App\Http\Controllers\AdminController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

// --- RUTAS PÚBLICAS ---
Route::get('/', function () {
    return Inertia::render('Invitados', [
        'lugaresDestacados' => \App\Models\Lugar::latest()->limit(6)->get(),   // ← Cambiado aquí (evita error)
        'lugares'           => \App\Models\Lugar::all(),
        'canLogin'          => Route::has('login'),
        'canRegister'       => Route::has('register'),
    ]);
})->name('invitados');

Route::post('/contactos', [ContactoController::class, 'store'])->name('contactos.store');
Route::get('/explorar', [SearchController::class, 'index'])->name('explorar');

// --- RUTAS DE USUARIO AUTENTICADO ---
Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::post('/dashboard/store', [DashboardController::class, 'store'])->name('dashboard.store');
    Route::post('/valoraciones', [ValoracionController::class, 'store'])->name('valoraciones.store');
    
    // Perfil
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    // Logout
    Route::post('/logout', function () {
        Auth::logout();
        request()->session()->invalidate();
        request()->session()->regenerateToken();
        return redirect()->route('welcome');
    })->name('logout');
});

// --- RUTAS DE ADMINISTRADOR (EL HUB) ---
Route::middleware(['auth', 'admin'])->prefix('admin')->group(function () {
    // Vista principal
    Route::get('/dashboard', [AdminController::class, 'index'])->name('admin.dashboard');
    
    // Gestión de Perfil Admin
    Route::post('/profile/update', [AdminController::class, 'updateProfile'])->name('admin.profile.update');
    
    // Gestión de otros Admins
    Route::post('/admins/store', [AdminController::class, 'storeAdmin'])->name('admin.admins.store');
    Route::patch('/admins/toggle/{id}', [AdminController::class, 'toggleAdminStatus'])->name('admin.admins.toggle');

    // Rutas para eliminar registros
    Route::delete('/lugar/{id}', [AdminController::class, 'destroyLugar'])->name('admin.lugar.delete');
    Route::delete('/restaurante/{id}', [AdminController::class, 'destroyRestaurante'])->name('admin.restaurante.delete');
    Route::delete('/mensaje/{id}', [AdminController::class, 'destroyMensaje'])->name('admin.mensaje.delete');
    Route::delete('/usuario/{id}', [AdminController::class, 'destroyUser'])->name('admin.user.delete');
});

require __DIR__.'/auth.php';