import Footer from "@/Components/Footer";
import "leaflet/dist/leaflet.css";
import { Head, usePage, Link, router } from '@inertiajs/react';
import React, { useState, useEffect } from 'react';
import Mapa from "@/Components/Mapa";
import GuestNavbarLayout from "@/Layouts/GuestNavbarLayout";

// --- COMPONENTE HERO ---
function HeroHeader() {
    return (
        <div className="relative bg-gray-900 overflow-hidden" id='Inicio'>
            <div 
                className="absolute inset-0 bg-cover bg-center opacity-70"
                style={{
                    backgroundImage: "url('https://www.medellincomovamos.org/wp-content/uploads/2025/09/2-El-desastre-no-es-natural.jpg')",
                    backgroundColor: '#1e0a35'
                }}
            ></div>
            <div className="relative max-w-7xl mx-auto px-4 py-16 sm:py-24 lg:py-32 flex items-center h-96">
                <div className="max-w-2xl">
                    <h2 className="text-3xl font-extrabold text-purple-200 sm:text-4xl italic">
                        Descubre hermosos lugares del valle de aburra
                    </h2>
                    <p className="mt-4 text-lg text-purple-300">
                        Encuentra las joyas escondidas y los restaurantes mejor valorados
                    </p>
                    <Link 
                        href="/explorar" 
                        className="mt-6 inline-block bg-purple-600 hover:bg-purple-700 text-white font-bold py-3 px-6 rounded-full transition shadow-lg">
                        Explorar más lugares
                    </Link>
                </div>
            </div>
        </div>
    );
}

const PlaceCard = ({ name, rating, imageUrl }) => {
    const numericRating = Math.round(rating || 0);
    const stars = Array(5).fill(0).map((_, index) => (
        <span key={index} className={`text-2xl ${index < numericRating ? 'text-purple-500' : 'text-gray-600'}`}>★</span>
    ));

    return (
        <div className="flex flex-col items-center p-4 hover:scale-105 transition duration-300 group">
            <div className="relative w-40 h-40">
                <img
                    src={imageUrl || "https://placehold.co/150x150"}
                    alt={name}
                    className="w-full h-full object-cover rounded-full shadow-lg border-4 border-purple-500 group-hover:border-white transition"
                />
            </div>
            <p className="mt-4 text-white text-center font-semibold uppercase text-sm tracking-wider">{name}</p>
            <div className="flex mt-2">{stars}</div>
        </div>
    );
};

export default function Invitados({ lugares = [], restaurantes = [], lugaresMapa = [] }) {
    const { flash } = usePage().props;
    const [showToast, setShowToast] = useState(false);

    // Función de bloqueo corregida
    const requireAuth = () => {
        if (confirm("Debes iniciar sesión para usar esta función. ¿Ir al login?")) {
            router.visit('/login'); 
        }
    };

    useEffect(() => {
        if (flash?.success) {
            setShowToast(true);
            const timer = setTimeout(() => setShowToast(false), 5000);
            return () => clearTimeout(timer);
        }
    }, [flash?.success]);

    return (
        <GuestNavbarLayout>
            <Head title="Modo Invitado" />

            {showToast && (
                <div className="fixed top-24 right-5 z-[120] animate-in fade-in slide-in-from-right-10 duration-500">
                    <div className="bg-purple-600 text-white px-6 py-4 rounded-2xl shadow-2xl border-2 border-purple-400 flex items-center space-x-3">
                        <span className="text-2xl">✨</span>
                        <div>
                            <p className="font-black uppercase tracking-tighter text-xs">Sistema Rame</p>
                            <p className="text-sm font-medium">{flash.success}</p>
                        </div>
                    </div>
                </div>
            )}

            <HeroHeader />

            {/* SECCIÓN LUGARES */}
            <div className="bg-gray-900 py-12 border-t border-purple-800" id="Lugares">
                <div className="max-w-7xl mx-auto px-4">
                    <h3 className="text-3xl font-extrabold text-white text-center mb-10 italic uppercase tracking-widest">
                        Lugares mejor puntuados
                    </h3>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                        {lugares.length > 0 ? lugares.map((l) => (
                            <div key={`lugar-${l.id}`} onClick={requireAuth} className="cursor-pointer">
                                <PlaceCard name={l.nombre} rating={l.valoraciones_avg_puntuacion} imageUrl={l.imagen} />
                            </div>
                        )) : (
                            <p className="text-gray-400 text-center col-span-3">No hay lugares disponibles.</p>
                        )}
                    </div>
                </div>
            </div>

            {/* SECCIÓN RESTAURANTES */}
            <div className="bg-gray-900 py-20 border-t border-purple-800" id="Restaurantes">
                <div className="max-w-7xl mx-auto px-4">
                    <h3 className="text-3xl font-extrabold text-white text-center mb-10 italic uppercase tracking-widest">
                        Restaurantes más buscados
                    </h3>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                        {restaurantes.length > 0 ? restaurantes.map((r) => (
                            <div key={`rest-${r.id}`} onClick={requireAuth} className="cursor-pointer">
                                <PlaceCard name={r.nombre} rating={r.valoraciones_avg_puntuacion} imageUrl={r.imagen} />
                            </div>
                        )) : (
                            <p className="text-gray-400 text-center col-span-3">No hay restaurantes disponibles.</p>
                        )}
                    </div>
                </div>
            </div>

            {/* SECCIÓN: MAPA */}
            <div className="bg-gray-900 py-16 border-t border-purple-800">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <h3 className="text-3xl font-extrabold text-white text-center mb-10">
                        Ubicación de los lugares
                    </h3>
                    <div className="relative z-0 w-full h-[500px] rounded-xl overflow-hidden shadow-2xl border-4 border-purple-700">
                        {<Mapa lugares={lugaresMapa} isGuest={true} />}
                    </div>
                </div>
            </div>

            {/* SECCIÓN CONTACTO */}
            <div className="bg-gray-900 py-16 border-t border-purple-800" id="Contacto">
                <div className="max-w-4xl mx-auto px-4">
                    <h3 className="text-3xl font-extrabold text-white text-center mb-10 uppercase italic tracking-tighter">
                        Contacto
                    </h3>
                    <form onSubmit={(e) => { e.preventDefault(); requireAuth(); }} 
                        className="p-4 md:p-10 bg-gray-800/30 rounded-3xl border border-purple-500/20 shadow-inner">
                        <div className="grid md:grid-cols-3 gap-6 mb-6">
                            <input disabled placeholder="Nombre" className="w-full p-3 rounded-xl bg-gray-700 text-white" />
                            <input disabled placeholder="Teléfono" className="w-full p-3 rounded-xl bg-gray-700 text-white" />
                            <input disabled placeholder="Correo" className="w-full p-3 rounded-xl bg-gray-700 text-white" />
                        </div>
                        <textarea disabled placeholder="Mensaje" className="w-full p-3 mb-6 rounded-xl bg-gray-700 text-white h-32"></textarea>
                        <div className="text-center">
                            <button type="submit" className="px-12 py-3 bg-purple-600 text-white rounded-full hover:bg-purple-700 transition shadow-lg font-black uppercase tracking-widest">
                                Inicia sesión para enviar
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <Footer />
        </GuestNavbarLayout>
    );
}