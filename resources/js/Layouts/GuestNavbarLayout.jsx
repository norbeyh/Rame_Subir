import React from "react";
import { Link } from "@inertiajs/react";

export default function GuestNavbarLayout({ children }) {
    return (
        <div className="min-h-screen bg-gray-900">

            {/* 🔥 NAVBAR */}
            <nav className="bg-purple-900 text-white px-6 py-4 flex justify-between items-center shadow-lg">

                {/* LOGO */}
                <h1 className="font-bold text-lg tracking-wider">
                    RAME
                </h1>

                {/* LINKS */}
                <div className="space-x-6 hidden md:flex font-semibold">
                    <a href="#Inicio">Inicio</a>
                    <a href="#Lugares">Lugares</a>
                    <a href="#Restaurantes">Restaurantes</a>
                    <a href="#Contacto">Contáctanos</a>
                </div>

                {/* AUTH */}
                <div className="space-x-3">
                    <Link
                        href={route('login')}
                        className="bg-white text-purple-900 px-4 py-1 rounded-full font-bold hover:scale-105 transition"
                    >
                        Iniciar Sesión
                    </Link>

                    <Link
                        href={route('register')}
                        className="bg-purple-600 px-4 py-1 rounded-full font-bold hover:bg-purple-700 transition"
                    >
                        Registro
                    </Link>
                </div>
            </nav>

            {children}
        </div>
    );
}