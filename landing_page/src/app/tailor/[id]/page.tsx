"use client";

import { useEffect, useState, use } from "react";
import { motion } from "framer-motion";
import { ArrowLeft, ArrowRight, MapPin, Star, Scissors, CheckCircle2, MessageSquare, Send, ShieldCheck, Briefcase } from "lucide-react";
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
  years_of_experience: number;
}

function getTailorLogoUrl(tailor: Partial<TailorProfile> | null | undefined) {
  return tailor?.logo_url || tailor?.photo_url || tailor?.avatar_url || "";
}

const MARKETPLACE_UPLOAD_BUCKET = "marketplace_uploads";

export default function TailorProfilePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const [tailor, setTailor] = useState<TailorProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [formLoading, setFormLoading] = useState(false);
  const [formSuccess, setFormSuccess] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [sessionEmail, setSessionEmail] = useState<string | null>(null);
  const [sessionName, setSessionName] = useState<string | null>(null);
  const [sessionWhatsapp, setSessionWhatsapp] = useState<string | null>(null);
  const [isLoggedIn, setIsLoggedIn] = useState<boolean>(false);

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [whatsapp, setWhatsapp] = useState("");

  useEffect(() => {
    fetchTailor();
  }, [id]);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      const s = data.session;
      setIsLoggedIn(!!s);
      if (!s) return;
      setSessionEmail(s.user.email ?? null);
      setSessionName((s.user.user_metadata as any)?.full_name ?? null);
      setSessionWhatsapp((s.user.user_metadata as any)?.whatsapp ?? null);

      // Prefill form (user can still edit)
      setName(((s.user.user_metadata as any)?.full_name ?? "").toString());
      setEmail((s.user.email ?? "").toString());
      setWhatsapp((((s.user.user_metadata as any)?.whatsapp ?? "") as string).toString());
    });

    const { data: sub } = supabase.auth.onAuthStateChange((_e, session) => {
      setIsLoggedIn(!!session);
    });
    return () => {
      sub.subscription.unsubscribe();
    };
  }, []);

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
    if (!tailor.is_available) {
      setFormError("This designer is currently not accepting orders.");
      return;
    }

    const formData = new FormData(e.currentTarget);
    const { data: sessionData } = await supabase.auth.getSession();
    const qtyRaw = String(formData.get("quantity") ?? "").trim();
    const quantity = qtyRaw ? Number(qtyRaw) : null;

    const imageUrls = String(formData.get("image_urls") ?? "")
      .split("\n")
      .map((s) => s.trim())
      .filter(Boolean);

    // Optional direct photo uploads (requires client login for storage access)
    const photoInput = e.currentTarget.querySelector('input[name="photos"]') as HTMLInputElement | null;
    const photoFiles = Array.from(photoInput?.files ?? []);
    const customerId = sessionData.session?.user?.id ?? null;

    if (photoFiles.length > 0 && !customerId) {
      alert("Please login to upload photos (or paste photo links). We'll still send your request without uploads.");
    }

    let uploadedUrls: string[] = [];
    if (photoFiles.length > 0 && customerId) {
      const uploadPrefix = `requests/${tailor.id}/${customerId}/${Date.now()}`;
      const uploads = await Promise.all(
        photoFiles.map(async (file, i) => {
          const safeName = (file.name || `photo_${i}.jpg`).replace(/[^\w.\-]+/g, "_");
          const path = `${uploadPrefix}/${i}_${safeName}`;
          const up = await supabase.storage.from(MARKETPLACE_UPLOAD_BUCKET).upload(path, file, {
            cacheControl: "3600",
            upsert: false,
          });
          if (up.error) throw up.error;
          const pub = supabase.storage.from(MARKETPLACE_UPLOAD_BUCKET).getPublicUrl(path);
          return pub.data.publicUrl;
        })
      );
      uploadedUrls = uploads.filter(Boolean);
    }

    const referenceLinks = String(formData.get("reference_links") ?? "")
      .split("\n")
      .map((s) => s.trim())
      .filter(Boolean);

    const requestDataBase = {
      tailor_id: tailor.id,
      customer_name: name,
      customer_email: email,
      customer_phone: whatsapp,
      customer_whatsapp: whatsapp,
      description: formData.get("description"),
      item_quantity: Number.isFinite(quantity) ? quantity : null,
      image_urls: [...uploadedUrls, ...imageUrls],
      reference_links: referenceLinks,
      status: "pending",
    };

    try {
      setFormLoading(true);
      setFormError(null);
      // Prefer inserting customer_id when available (for secure client portal).
      // If the DB column isn't deployed yet, gracefully retry without it.
      const first = await supabase
        .from("marketplace_requests")
        .insert(customerId ? { ...requestDataBase, customer_id: customerId } : requestDataBase)
        .select("id")
        .maybeSingle();

      if (first.error) {
        const msg = (first.error as any)?.message ?? "";
        const missingColumn = msg.includes("customer_id") && msg.toLowerCase().includes("column");
        const maybeSchemaMismatch =
          missingColumn ||
          (msg.toLowerCase().includes("column") &&
            (msg.includes("item_quantity") ||
              msg.includes("image_urls") ||
              msg.includes("reference_links") ||
              msg.includes("customer_whatsapp")));

        if (!maybeSchemaMismatch) throw first.error;

        // Retry with minimal payload for older DB schema.
        const minimal = {
          tailor_id: tailor.id,
          customer_name: name,
          customer_email: email,
          customer_phone: whatsapp,
          description: formData.get("description"),
          status: "pending",
        };
        const retry = await supabase.from("marketplace_requests").insert(minimal).select("id").maybeSingle();
        if (retry.error) throw retry.error;
      }
      setFormSuccess(true);
    } catch (err) {
      console.error("Error sending request:", err);
      const msg = (err as any)?.message ?? String(err ?? "");
      const looksLikeRls =
        msg.toLowerCase().includes("row-level security") ||
        msg.toLowerCase().includes("permission denied") ||
        msg.toLowerCase().includes("not authorized");

      if (looksLikeRls) {
        const m = "Please login to send requests right now. (Your database security settings are blocking guest requests.)";
        setFormError(m);
        alert(m);
      } else {
        const m = `Failed to send request. Please try again.\n\n${msg}`;
        setFormError(m);
        alert(m);
      }
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
  const logoUrl = getTailorLogoUrl(tailor);

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
             <Image src="/logo.png" alt="Needlix Logo" width={140} height={40} className="needlix-logo h-6 sm:h-7 w-auto object-contain" />
          </Link>
          <div className="flex items-center gap-3">
            {isLoggedIn ? (
              <>
                <Link
                  href="/client"
                  className="inline-flex items-center justify-center rounded-full border border-[#00AEEF]/30 bg-[#00AEEF]/10 px-3 sm:px-4 py-2 text-xs sm:text-sm font-bold text-[#0076B6] hover:bg-[#00AEEF]/15"
                >
                  My Dashboard
                </Link>
                <button
                  onClick={async () => {
                    await signOut();
                  }}
                  className="inline-flex items-center justify-center rounded-full border border-slate-200 bg-white px-3 sm:px-4 py-2 text-xs sm:text-sm font-bold text-slate-700 hover:bg-slate-50"
                >
                  Logout
                </button>
              </>
            ) : (
              <>
                <Link
                  href="/login"
                  className="inline-flex items-center justify-center rounded-full border border-slate-200 bg-white px-3 sm:px-4 py-2 text-xs sm:text-sm font-bold text-slate-700 hover:bg-slate-50"
                >
                  Client Login
                </Link>
                <Link
                  href="/signup"
                  className="inline-flex items-center justify-center rounded-full bg-[#0A1128] px-3 sm:px-4 py-2 text-xs sm:text-sm font-bold text-white hover:bg-[#0076B6] transition-colors"
                >
                  Sign up
                </Link>
              </>
            )}
          </div>
        </div>
      </nav>

      {/* Header / Hero */}
      <section className="relative pt-20">
        <div className="h-48 md:h-64 bg-gradient-to-r from-[#0076B6] to-[#00AEEF]" />
        <div className="mx-auto max-w-5xl px-6">
          <div className="relative -mt-16 mb-8 flex flex-col md:flex-row md:items-end gap-6">
            <div className="h-32 w-32 rounded-3xl border-4 border-white bg-slate-100 shadow-xl flex items-center justify-center overflow-hidden">
               {logoUrl ? (
                  <Image src={logoUrl} alt={tailor.brand_name} width={128} height={128} className="object-cover" />
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

                <form
                  onSubmit={handleRequest}
                  className="space-y-4"
                  onChange={() => {
                    if (formError) setFormError(null);
                  }}
                >
                  <div>
                    <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Full Name</label>
                    <input value={name} onChange={(e) => setName(e.target.value)} required type="text" placeholder="John Doe" className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm" />
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Email</label>
                      <input value={email} onChange={(e) => setEmail(e.target.value)} required type="email" placeholder="john@example.com" className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm" />
                    </div>
                    <div>
                      <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">WhatsApp</label>
                      <input value={whatsapp} onChange={(e) => setWhatsapp(e.target.value)} required type="tel" placeholder="+234..." className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm" />
                    </div>
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">What do you need?</label>
                    <textarea name="description" required rows={4} placeholder="e.g. I need two traditional outfits and a suit for a wedding next month..." className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm resize-none" />
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Quantity</label>
                      <input
                        name="quantity"
                        type="number"
                        min={1}
                        placeholder="1"
                        className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm"
                      />
                    </div>
                    <div className="text-xs text-slate-500 flex items-end">
                      Optional. Helps the tailor quote faster.
                    </div>
                  </div>

                  <div>
                    <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Photo links (optional)</label>
                    <textarea
                      name="image_urls"
                      rows={3}
                      placeholder={"Paste image URLs, one per line\nhttps://..."}
                      className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm resize-none"
                    />
                    <p className="mt-1 text-[11px] text-slate-400 font-medium">
                      Tip: upload photos anywhere (Google Drive, iCloud, etc.) and paste share links.
                    </p>
                  </div>

                  <div>
                    <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Upload photos (optional)</label>
                    <input
                      name="photos"
                      type="file"
                      accept="image/*"
                      multiple
                      className="w-full text-sm file:mr-4 file:rounded-xl file:border-0 file:bg-slate-100 file:px-4 file:py-2 file:text-sm file:font-bold file:text-slate-700 hover:file:bg-slate-200"
                    />
                    <p className="mt-1 text-[11px] text-slate-400 font-medium">
                      Best experience: login first so uploads attach directly to your request.
                    </p>
                  </div>

                  <div>
                    <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Reference links (optional)</label>
                    <textarea
                      name="reference_links"
                      rows={2}
                      placeholder={"Fabric / style references, one per line\nhttps://..."}
                      className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm resize-none"
                    />
                  </div>

                  <button
                    type="submit"
                    disabled={formLoading || !tailor.is_available}
                    className={`group w-full py-4 rounded-2xl flex items-center justify-center gap-3 text-white font-bold shadow-lg transition-all ${!tailor.is_available ? 'bg-slate-300 cursor-not-allowed' : 'bg-[#0076B6] hover:bg-[#00AEEF] active:translate-y-1'}`}
                  >
                    <span>{formLoading ? "Sending..." : "Send Job Request"}</span>
                    {!formLoading && <ArrowRight className="h-5 w-5 group-hover:translate-x-1 transition-transform" />}
                  </button>

                  {!tailor.is_available && (
                    <div className="rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-xs font-semibold text-slate-600">
                      This designer is currently not accepting orders.
                    </div>
                  )}

                  {formError && (
                    <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-xs font-semibold text-red-700 whitespace-pre-line">
                      {formError}
                    </div>
                  )}
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
