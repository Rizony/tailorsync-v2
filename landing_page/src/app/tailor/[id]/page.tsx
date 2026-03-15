"use client";

import { useEffect, useState, use } from "react";
import { motion } from "framer-motion";
import { ArrowLeft, ArrowRight, MapPin, Star, Scissors, CheckCircle2, MessageSquare, Send, ShieldCheck, Briefcase } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { supabase } from "@/lib/supabase";

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
  years_of_experience: number;
}

export default function TailorProfilePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const [tailor, setTailor] = useState<TailorProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [formLoading, setFormLoading] = useState(false);
  const [formSuccess, setFormSuccess] = useState(false);

  useEffect(() => {
    fetchTailor();
  }, [id]);

  async function fetchTailor() {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from("profiles")
        .select("*")
        .eq("id", id)
        .single();

      if (error) throw error;
      setTailor(data);
    } catch (err) {
      console.error("Error fetching tailor:", err);
    } finally {
      setLoading(false);
    }
  }

  async function handleRequest(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (!tailor) return;

    const formData = new FormData(e.currentTarget);
    const requestData = {
      tailor_id: tailor.id,
      customer_name: formData.get("name"),
      customer_email: formData.get("email"),
      customer_phone: formData.get("phone"),
      description: formData.get("description"),
      status: "pending",
    };

    try {
      setFormLoading(true);
      const { error } = await supabase.from("marketplace_requests").insert(requestData);
      if (error) throw error;
      setFormSuccess(true);
    } catch (err) {
      console.error("Error sending request:", err);
      alert("Failed to send request. Please try again.");
    } finally {
      setFormLoading(false);
    }
  }

  if (loading) return (
    <div className="min-h-screen flex items-center justify-center bg-slate-50">
      <div className="h-12 w-12 border-4 border-[#0076B6] border-t-transparent rounded-full animate-spin" />
    </div>
  );

  if (!tailor) return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-slate-50">
      <h1 className="text-2xl font-bold mb-4">Designer not found</h1>
      <Link href="/marketplace" className="text-[#0076B6] font-bold">Back to Marketplace</Link>
    </div>
  );

  const isPremium = tailor.subscription_tier === "premium";

  return (
    <div className="min-h-screen bg-slate-50 font-sans text-slate-900 pb-20">
      {/* Navigation */}
      <nav className="fixed left-0 right-0 top-0 z-50 bg-white/80 backdrop-blur-md border-b border-slate-200">
        <div className="mx-auto flex h-20 max-w-7xl items-center justify-between px-6 lg:px-8">
          <Link href="/marketplace" className="flex items-center gap-2 text-sm font-bold text-slate-600 hover:text-[#0076B6] transition-colors">
            <ArrowLeft className="h-4 w-4" />
            <span>Back to Marketplace</span>
          </Link>
          <Link href="/">
             <Image src="/logo.png" alt="Needlix Logo" width={120} height={36} className="h-6 w-auto object-contain" />
          </Link>
        </div>
      </nav>

      {/* Header / Hero */}
      <section className="relative pt-20">
        <div className="h-48 md:h-64 bg-gradient-to-r from-[#0076B6] to-[#00AEEF]" />
        <div className="mx-auto max-w-5xl px-6">
          <div className="relative -mt-16 mb-8 flex flex-col md:flex-row md:items-end gap-6">
            <div className="h-32 w-32 rounded-3xl border-4 border-white bg-slate-100 shadow-xl flex items-center justify-center overflow-hidden">
               {tailor.logo_url ? (
                  <Image src={tailor.logo_url} alt={tailor.brand_name} width={128} height={128} className="object-cover" />
                ) : (
                  <Scissors className="h-12 w-12 text-slate-300" />
                )}
            </div>
            <div className="flex-1 pb-2">
              <div className="flex flex-wrap items-center gap-3 mb-2">
                <h1 className="text-3xl font-extrabold text-[#0A1128]">{tailor.brand_name || tailor.shop_name}</h1>
                {isPremium && (
                   <span className="flex items-center gap-1 rounded-full bg-orange-500 px-3 py-1 text-[10px] font-bold text-white shadow-md">
                    <Star className="h-3 w-3 fill-current" />
                    PREMIUM
                  </span>
                )}
              </div>
              <div className="flex flex-wrap items-center gap-4 text-sm font-medium text-slate-500">
                <div className="flex items-center gap-1.5">
                  <MapPin className="h-4 w-4" />
                  <span>{tailor.shop_address || "Address not provided"}</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <Star className="h-4 w-4 text-yellow-400 fill-current" />
                  <span className="text-slate-900">{tailor.rating || "5.0"} (Verified Rating)</span>
                </div>
              </div>
            </div>
            <div className="mb-2">
               <span className={`inline-flex items-center gap-2 rounded-full px-4 py-1.5 text-sm font-bold shadow-sm ${tailor.is_available ? 'bg-green-100 text-green-700' : 'bg-slate-100 text-slate-500'}`}>
                <span className={`h-2 w-2 rounded-full ${tailor.is_available ? 'bg-green-500 animate-pulse' : 'bg-slate-400'}`} />
                {tailor.is_available ? "Accepting Orders" : "Fully Booked"}
              </span>
            </div>
          </div>
        </div>
      </section>

      <div className="mx-auto max-w-5xl px-6 grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Left Column: About */}
        <div className="lg:col-span-2 space-y-8">
          <div className="bg-white rounded-3xl p-8 shadow-sm border border-slate-100">
            <h2 className="text-xl font-bold mb-4 flex items-center gap-2">
              <Scissors className="h-5 w-5 text-[#00AEEF]" />
              About the Designer
            </h2>
            <p className="text-slate-600 leading-relaxed whitespace-pre-line mb-6">
              {tailor.bio || `Welcome to ${tailor.brand_name || tailor.shop_name}. We pride ourselves on delivering high-quality, bespoke fashion pieces tailored perfectly to your unique style and measurements.`}
            </p>
            
            <div className="grid grid-cols-2 md:grid-cols-3 gap-6 pt-6 border-t border-slate-50">
              <div className="flex flex-col gap-1">
                <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Experience</span>
                <span className="font-bold text-slate-900">{tailor.years_of_experience || "5+"} Years</span>
              </div>
              <div className="flex flex-col gap-1">
                <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Located In</span>
                <span className="font-bold text-slate-900 line-clamp-1">{tailor.shop_address?.split(',')[0] || "Lagos"}</span>
              </div>
              <div className="flex flex-col gap-1">
                <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Status</span>
                <span className="font-bold text-green-600">Verified</span>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-3xl p-8 shadow-sm border border-slate-100">
            <h2 className="text-xl font-bold mb-6 flex items-center gap-2">
              <Briefcase className="h-5 w-5 text-[#00AEEF]" />
              Specialties & Expertise
            </h2>
            <div className="flex flex-wrap gap-3">
              {(tailor.specialties?.length ? tailor.specialties : ["Bespoke Tailoring", "Traditional African Wear", "Corporate Suits", "Wedding Outfits", "Repairs & Alterations"]).map((s) => (
                <div key={s} className="flex items-center gap-2 bg-slate-50 border border-slate-100 px-4 py-2 rounded-2xl">
                  <CheckCircle2 className="h-4 w-4 text-[#00AEEF]" />
                  <span className="text-sm font-bold text-slate-700">{s}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Right Column: Request Form */}
        <div className="space-y-6">
          <div className="bg-white rounded-3xl p-8 shadow-xl border border-slate-100 sticky top-24">
            {formSuccess ? (
              <motion.div 
                initial={{ opacity: 0, scale: 0.9 }} 
                animate={{ opacity: 1, scale: 1 }} 
                className="text-center py-6"
              >
                <div className="h-16 w-16 bg-green-100 text-green-600 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Send className="h-8 w-8" />
                </div>
                <h3 className="text-xl font-bold mb-2 text-slate-900">Request Sent!</h3>
                <p className="text-sm text-slate-500 mb-6">
                  {tailor.brand_name} has been notified. They will contact you shortly via the details provided.
                </p>
                <button 
                  onClick={() => setFormSuccess(false)}
                  className="w-full py-3 rounded-2xl border border-slate-200 text-slate-600 font-bold hover:bg-slate-50 transition-all font-sans"
                >
                  Send Another
                </button>
              </motion.div>
            ) : (
              <>
                <h3 className="text-xl font-bold mb-2">Hire this Designer</h3>
                <p className="text-sm text-slate-500 mb-6">
                  Send a job request and get a professional quote instantly.
                </p>

                <form onSubmit={handleRequest} className="space-y-4">
                  <div>
                    <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Full Name</label>
                    <input name="name" required type="text" placeholder="John Doe" className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm" />
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Email</label>
                      <input name="email" required type="email" placeholder="john@example.com" className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm" />
                    </div>
                    <div>
                      <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Phone</label>
                      <input name="phone" required type="tel" placeholder="080..." className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm" />
                    </div>
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">What do you need?</label>
                    <textarea name="description" required rows={4} placeholder="e.g. I need two traditional outfits and a suit for a wedding next month..." className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm resize-none" />
                  </div>

                  <button 
                    disabled={formLoading || !tailor.is_available}
                    className={`group w-full py-4 rounded-2xl flex items-center justify-center gap-3 text-white font-bold shadow-lg transition-all ${!tailor.is_available ? 'bg-slate-300 cursor-not-allowed' : 'bg-[#0076B6] hover:bg-[#00AEEF] active:translate-y-1'}`}
                  >
                    <span>{formLoading ? "Sending..." : "Send Job Request"}</span>
                    {!formLoading && <ArrowRight className="h-5 w-5 group-hover:translate-x-1 transition-transform" />}
                  </button>
                </form>

                <div className="mt-6 flex items-center justify-center gap-2 text-[10px] font-bold text-slate-400 uppercase tracking-widest">
                  <ShieldCheck className="h-4 w-4 text-green-500" />
                  <span>Secure Marketplace Request</span>
                </div>
              </>
            )}
          </div>

          <div className="bg-slate-900 rounded-3xl p-6 text-white shadow-xl">
            <h4 className="font-bold mb-2 flex items-center gap-2">
              <MessageSquare className="h-4 w-4 text-[#00AEEF]" />
              How it works
            </h4>
            <p className="text-xs text-slate-400 leading-relaxed">
              Once you send a request, the designer is notified on the **Needlix App**. They will review your request and contact you to finalize measurements and pricing.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
