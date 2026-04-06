"use client";

import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { Search, MapPin, Star, Scissors, ArrowRight, Filter, CheckCircle2 } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { supabase } from "@/lib/supabase";
import { signOut } from "@/lib/auth";

interface TailorProfile {
  id: string;
  full_name: string;
  shop_name: string;
  brand_name: string;
  shop_address: string;
  subscription_tier: string;
  bio: string;
  specialties: string[];
  rating: number;
  is_available: boolean;
  logo_url: string;
  photo_url?: string;
  avatar_url?: string;
  years_of_experience?: number;
  tailor_type?: string;
  latitude?: number;
  longitude?: number;
  distance?: number;
}

function getDistance(lat1: number, lon1: number, lat2: number, lon2: number) {
  const R = 6371; // km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

function getTailorLogoUrl(tailor: Partial<TailorProfile> | null | undefined) {
  return tailor?.logo_url || tailor?.photo_url || tailor?.avatar_url || "";
}

export default function MarketplacePage() {
  const [tailors, setTailors] = useState<TailorProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  
  const [showFilters, setShowFilters] = useState(false);
  const [filterType, setFilterType] = useState("All");
  const [filterSpecialty, setFilterSpecialty] = useState("All"); 
  const [minExperience, setMinExperience] = useState(0);
  const [minRating, setMinRating] = useState(0);
  const [useLocation, setUseLocation] = useState(false);
  const [clientLocation, setClientLocation] = useState<{lat: number, lng: number} | null>(null);

  const SPECIALTIES = ['Bespoke', 'Traditional African', 'Suits', 'Bridal', 'Casual Wear', 'Alterations', 'Native Attire'];

  useEffect(() => {
    if (useLocation) {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
          (pos) => setClientLocation({lat: pos.coords.latitude, lng: pos.coords.longitude}),
          (err) => {
            console.error(err);
            setUseLocation(false);
            alert("Could not get your location. Please check your browser permissions.");
          }
        );
      } else {
        setUseLocation(false);
      }
    } else {
      setClientLocation(null);
    }
  }, [useLocation]);

  useEffect(() => {
    fetchTailors();
  }, []);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => setIsLoggedIn(!!data.session));
    const { data: sub } = supabase.auth.onAuthStateChange((_e, session) => setIsLoggedIn(!!session));
    return () => sub.subscription.unsubscribe();
  }, []);

  async function fetchTailors() {
    try {
      setLoading(true);
      // Fetch public profiles
      const { data, error } = await supabase
        .from("profiles")
        .select("*")
        .eq("public_profile_enabled", true)
        .order("subscription_tier", { ascending: false }) // This won't work perfectly for enums, but we can sort in JS
        .order("rating", { ascending: false });

      if (error) throw error;

      // Custom sort: Premium > Standard > Freemium
      const sorted = (data as TailorProfile[]).sort((a, b) => {
        const tiers = { premium: 3, standard: 2, freemium: 1 };
        const tierA = tiers[a.subscription_tier as keyof typeof tiers] || 0;
        const tierB = tiers[b.subscription_tier as keyof typeof tiers] || 0;
        return tierB - tierA;
      });

      setTailors(sorted);
    } catch (err) {
      console.error("Error fetching tailors:", err);
    } finally {
      setLoading(false);
    }
  }

  const filteredTailors = tailors.filter((t) => {
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      const matchSearch = t.brand_name?.toLowerCase().includes(q) ||
        t.full_name?.toLowerCase().includes(q) ||
        t.specialties?.some(s => s.toLowerCase().includes(q)) ||
        t.shop_address?.toLowerCase().includes(q);
      if (!matchSearch) return false;
    }
    
    if (filterType !== "All") {
      const type = t.tailor_type || 'Unisex';
      if (type !== filterType && type !== "Unisex") return false;
    }
    
    if (filterSpecialty !== "All") {
      if (!t.specialties?.includes(filterSpecialty)) return false;
    }
    
    if (minRating > 0 && (t.rating || 5) < minRating) return false;
    if (minExperience > 0 && (t.years_of_experience || 0) < minExperience) return false;
    
    return true;
  }).map(t => {
     if (clientLocation && t.latitude && t.longitude) {
       return { ...t, distance: getDistance(clientLocation.lat, clientLocation.lng, t.latitude!, t.longitude!) };
     }
     return { ...t, distance: 999999 };
  }).sort((a, b) => {
    if (clientLocation) {
       return (a.distance || 0) - (b.distance || 0);
    }
    return 0; // Maintain default sort
  });

  return (
    <div className="min-h-screen bg-slate-50 font-sans text-slate-900">
      {/* Navigation */}
       <nav className="fixed left-0 right-0 top-0 z-50 bg-white/80 backdrop-blur-md border-b border-slate-200">
        <div className="mx-auto flex h-20 max-w-7xl items-center justify-between px-6 lg:px-8">
          <Link href="/" className="flex items-center gap-3">
            <Image src="/logo.png" alt="Needlix Logo" width={160} height={48} className="needlix-logo h-8 sm:h-9 w-auto object-contain" />
          </Link>
          <div className="flex items-center gap-6">
            <Link href="/" className="text-sm font-semibold text-slate-600 hover:text-[#0076B6]">Home</Link>
            {isLoggedIn ? (
              <>
                <Link href="/client" className="text-sm font-bold text-[#0076B6] hover:text-[#00AEEF]">My Dashboard</Link>
                <button onClick={() => signOut()} className="text-sm font-bold text-slate-700 hover:text-[#0076B6]">Logout</button>
              </>
            ) : (
              <>
                <Link href="/login" className="text-sm font-bold text-[#0076B6] hover:text-[#00AEEF]">Client Login</Link>
                <Link href="/signup" className="text-sm font-bold text-slate-700 hover:text-[#0076B6]">Sign up</Link>
              </>
            )}
            <a href="#download" className="rounded-full bg-[#0076B6] px-5 py-2 text-sm font-semibold text-white hover:bg-[#00AEEF]">Get App</a>
          </div>
        </div>
      </nav>

      <main className="pt-32 pb-20">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          {/* Header */}
          <div className="mb-12">
            <h1 className="text-4xl font-extrabold text-[#0A1128] mb-4">Find Your Perfect Designer</h1>
            <p className="text-lg text-slate-600 max-w-2xl">
              Browse top-rated tailors and fashion designers in the Needlix community. Quality craftsmanship, delivered to your door.
            </p>
            <div className="mt-6 flex flex-col sm:flex-row gap-3">
              <Link
                href="/client"
                className="inline-flex items-center justify-center gap-2 rounded-2xl border border-[#00AEEF]/30 bg-[#00AEEF]/10 px-6 py-3 text-sm font-bold text-[#0076B6] hover:bg-[#00AEEF]/15"
              >
                Track your request / job <ArrowRight className="h-4 w-4" />
              </Link>
              <Link
                href="/signup"
                className="inline-flex items-center justify-center gap-2 rounded-2xl bg-[#0A1128] px-6 py-3 text-sm font-bold text-white hover:bg-[#0076B6] transition-colors"
              >
                Create client account <ArrowRight className="h-4 w-4" />
              </Link>
              <Link
                href="/login"
                className="inline-flex items-center justify-center gap-2 rounded-2xl border border-slate-200 bg-white px-6 py-3 text-sm font-bold text-slate-700 hover:bg-slate-50"
              >
                Login <ArrowRight className="h-4 w-4" />
              </Link>
            </div>
          </div>

          {/* Search & Filter Bar */}
          <div className="flex flex-col md:flex-row gap-4 mb-6">
            <div className="relative flex-1">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
              <input
                type="text"
                placeholder="Search by brand name, specialty, or location..."
                className="w-full pl-12 pr-4 py-4 rounded-2xl border border-slate-200 bg-white shadow-sm focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
            </div>
            <button 
              onClick={() => setShowFilters(!showFilters)}
              className={`flex items-center justify-center gap-2 px-6 py-4 rounded-2xl border font-semibold transition-all ${showFilters ? 'bg-slate-100 border-slate-300 text-slate-900' : 'bg-white border-slate-200 text-slate-700 hover:bg-slate-50'}`}
            >
              <Filter className="h-5 w-5" />
              <span>Filters</span>
            </button>
          </div>

          {showFilters && (
            <motion.div 
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: 'auto', opacity: 1 }}
              className="bg-white rounded-3xl p-6 shadow-sm border border-slate-200 mb-8 overflow-hidden"
            >
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 text-left">
                <div>
                  <label className="block text-[11px] font-bold text-slate-400 mb-2 uppercase tracking-wider">Tailor Type</label>
                  <select 
                    value={filterType} 
                    onChange={e => setFilterType(e.target.value)}
                    className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 font-medium focus:ring-2 focus:ring-[#00AEEF] outline-none"
                  >
                    <option value="All">All Types</option>
                    <option value="Male Fashion">Male Fashion</option>
                    <option value="Female Fashion">Female Fashion</option>
                    <option value="Unisex">Unisex</option>
                  </select>
                </div>
                <div>
                  <label className="block text-[11px] font-bold text-slate-400 mb-2 uppercase tracking-wider">Specialty</label>
                  <select 
                    value={filterSpecialty} 
                    onChange={e => setFilterSpecialty(e.target.value)}
                    className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 font-medium focus:ring-2 focus:ring-[#00AEEF] outline-none"
                  >
                    <option value="All">All Specialties</option>
                    {SPECIALTIES.map(s => <option key={s} value={s}>{s}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-[11px] font-bold text-slate-400 mb-2 uppercase tracking-wider">Experience</label>
                  <select 
                    value={minExperience} 
                    onChange={e => setMinExperience(Number(e.target.value))}
                    className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 font-medium focus:ring-2 focus:ring-[#00AEEF] outline-none"
                  >
                    <option value={0}>Any Experience</option>
                    <option value={2}>2+ Years</option>
                    <option value={5}>5+ Years</option>
                    <option value={10}>10+ Years</option>
                  </select>
                </div>
                <div>
                  <label className="block text-[11px] font-bold text-slate-400 mb-2 uppercase tracking-wider">Location Sorting</label>
                  <label className="flex items-center gap-3 cursor-pointer w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 hover:bg-slate-100 transition-colors">
                    <input 
                      type="checkbox" 
                      className="h-5 w-5 rounded border-slate-300 text-[#00AEEF] focus:ring-[#00AEEF]"
                      checked={useLocation}
                      onChange={e => setUseLocation(e.target.checked)}
                    />
                    <span className="font-medium text-slate-700">Sort by nearest to me</span>
                  </label>
                </div>
              </div>
            </motion.div>
          )}

          {/* Listings */}
          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {[1, 2, 3, 4, 5, 6].map((i) => (
                <div key={i} className="h-[400px] rounded-3xl bg-slate-200 animate-pulse" />
              ))}
            </div>
          ) : filteredTailors.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {filteredTailors.map((tailor) => (
                <TailorCard key={tailor.id} tailor={tailor} />
              ))}
            </div>
          ) : (
            <div className="text-center py-20 bg-white rounded-3xl border border-dashed border-slate-300">
              <Scissors className="h-12 w-12 text-slate-300 mx-auto mb-4" />
              <h3 className="text-xl font-bold text-slate-900">No tailors found</h3>
              <p className="text-slate-500">Try adjusting your search or filters.</p>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

function TailorCard({ tailor }: { tailor: TailorProfile }) {
  const isPremium = tailor.subscription_tier === "premium";
  const isStandard = tailor.subscription_tier === "standard";
  const logoUrl = getTailorLogoUrl(tailor);

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="group relative flex flex-col bg-white rounded-3xl border border-slate-100 shadow-sm hover:shadow-xl transition-all overflow-hidden"
    >
      {/* Tier Badge */}
      <div className="absolute top-4 right-4 z-10">
        {isPremium ? (
          <div className="flex items-center gap-1 rounded-full bg-orange-500 px-3 py-1 text-[10px] font-bold text-white shadow-lg">
            <Star className="h-3 w-3 fill-current" />
            PREMIUM
          </div>
        ) : isStandard ? (
          <div className="flex items-center gap-1 rounded-full bg-[#0076B6] px-3 py-1 text-[10px] font-bold text-white shadow-lg">
            <CheckCircle2 className="h-3 w-3" />
            STANDARD
          </div>
        ) : null}
      </div>

      {/* Cover/Header */}
      <div className="h-32 bg-gradient-to-r from-[#0076B6] to-[#00AEEF] relative">
        <div className="absolute -bottom-10 left-6 h-20 w-20 rounded-2xl border-4 border-white bg-slate-100 shadow-md flex items-center justify-center overflow-hidden">
          {logoUrl ? (
            <Image src={logoUrl} alt={tailor.brand_name} width={80} height={80} className="object-cover" />
          ) : (
            <Scissors className="h-8 w-8 text-slate-300" />
          )}
        </div>
      </div>

      {/* Content */}
      <div className="pt-12 px-6 pb-6 flex-1 flex flex-col">
        <div className="mb-4">
          <h3 className="text-xl font-bold text-[#0A1128] group-hover:text-[#0076B6] transition-colors">
            {tailor.brand_name || tailor.shop_name || "Fashion House"}
          </h3>
          <p className="text-sm text-slate-500 font-medium">{tailor.full_name}</p>
        </div>

        <div className="space-y-3 mb-6">
          <div className="flex items-center gap-2 text-sm text-slate-600">
            <MapPin className="h-4 w-4 text-slate-400" />
            <span className="line-clamp-1">
              {tailor.distance && tailor.distance !== 999999 
                ? `${tailor.distance.toFixed(1)} km away (${tailor.shop_address?.split(',')[0] || 'Unknown'})` 
                : (tailor.shop_address || "Lagos, Nigeria")}
            </span>
          </div>
          <div className="flex items-center gap-2 text-sm text-slate-600">
            <div className="flex items-center">
              {[1, 2, 3, 4, 5].map((s) => (
                <Star key={s} className={`h-3.5 w-3.5 ${s <= (tailor.rating || 5) ? 'text-yellow-400 fill-current' : 'text-slate-200'}`} />
              ))}
            </div>
            <span className="font-bold text-slate-900">{tailor.rating || 5.0}</span>
          </div>
        </div>

        <div className="flex flex-wrap gap-2 mb-6">
          {(tailor.specialties?.length ? tailor.specialties : ["Bespoke", "Traditional", "Suits"]).slice(0, 3).map((s) => (
            <span key={s} className="px-3 py-1 rounded-lg bg-slate-50 text-[11px] font-bold text-slate-500 border border-slate-100">
              {s}
            </span>
          ))}
        </div>

        <div className="mt-auto pt-4 border-t border-slate-50">
          <Link 
            href={`/tailor/${tailor.id}`}
            className="flex items-center justify-between group/btn text-[#0076B6] font-bold text-sm"
          >
            <span>View Profile</span>
            <div className="h-8 w-8 rounded-full bg-slate-50 flex items-center justify-center group-hover/btn:bg-[#0076B6] group-hover/btn:text-white transition-all">
              <ArrowRight className="h-4 w-4" />
            </div>
          </Link>
        </div>
      </div>
    </motion.div>
  );
}
