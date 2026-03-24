"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { Mail, Lock, ArrowRight, User, Phone, CheckCircle2, Ticket, Eye, EyeOff } from "lucide-react";
import { supabase } from "@/lib/supabase";

export default function ClientSignupPage() {
  const router = useRouter();
  const [fullName, setFullName] = useState("");
  const [whatsapp, setWhatsapp] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [referralCode, setReferralCode] = useState("");
  const [isReferralFromLink, setIsReferralFromLink] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [role, setRole] = useState<"client" | "tailor">("client");
  const [success, setSuccess] = useState<CheckCircle2 | string | null>(null);
  const [showPassword, setShowPassword] = useState(false);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      // If user is already logged in, redirect them
      if (data.session) router.replace(role === "client" ? "/client" : "/");
    });
    
    // Auto-fill referral code from localStorage
    const savedCode = localStorage.getItem("needlix_referrer_id");
    if (savedCode) {
      setReferralCode(savedCode);
      setIsReferralFromLink(true);
    }
  }, [router, role]);


  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      const referrerId = referralCode.trim() || undefined;
      
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: { 
            full_name: fullName, 
            whatsapp, 
            role,
            referrer_id: referrerId
          },
        },
      });
      if (error) throw error;

      if (data.session) {
        if (role === "client") {
          router.push("/client");
        } else {
          setSuccess("Tailor account created! Please download the Needlix mobile app to set up your shop and log in.");
        }
      } else {
        if (role === "client") {
          setSuccess("Account created. Check your email to confirm, then log in to the Client Portal.");
        } else {
          setSuccess("Tailor account created! Check your email to confirm, then download the Needlix mobile app to log in and set up your shop.");
        }
      }
    } catch (err: any) {
      setError(err?.message ?? "Signup failed");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-slate-50 font-sans text-slate-900">
      <nav className="bg-white border-b border-slate-200">
        <div className="mx-auto flex h-20 max-w-7xl items-center justify-between px-6 lg:px-8">
          <Link href="/" className="flex items-center gap-3">
            <Image src="/logo.png" alt="Needlix Logo" width={140} height={40} className="h-8 w-auto object-contain" />
          </Link>
          <div className="flex items-center gap-4">
            <Link href="/marketplace" className="text-sm font-semibold text-slate-600 hover:text-[#0076B6]">
              Marketplace
            </Link>
            <Link href="/login" className="text-sm font-bold text-[#0076B6] hover:text-[#00AEEF]">
              Sign in
            </Link>
          </div>
        </div>
      </nav>

      <main className="mx-auto max-w-xl px-6 py-14">
        <div className="bg-white rounded-3xl border border-slate-100 shadow-sm p-8">
          <h1 className="text-2xl font-extrabold text-[#0A1128]">
            {role === "client" ? "Create client account" : "Join as a Tailor"}
          </h1>
          <p className="text-sm text-slate-500 mt-1">
            {role === "client" 
              ? "Use this to track jobs, rate tailors, and pay securely on the website."
              : "Register here and download the Partner app to grow your fashion business."}
          </p>

          <div className="mt-6 flex bg-slate-100 p-1 rounded-2xl w-full max-w-sm mb-6">
            <button
              onClick={() => setRole("client")}
              className={`flex-1 text-sm font-bold py-2 rounded-xl transition-all ${
                role === "client"
                  ? "bg-white text-[#0A1128] shadow-sm ring-1 ring-slate-900/5"
                  : "text-slate-500 hover:text-slate-700"
              }`}
            >
              I am a Client
            </button>
            <button
              onClick={() => setRole("tailor")}
              className={`flex-1 text-sm font-bold py-2 rounded-xl transition-all ${
                role === "tailor"
                  ? "bg-white text-[#0A1128] shadow-sm ring-1 ring-slate-900/5"
                  : "text-slate-500 hover:text-slate-700"
              }`}
            >
              I am a Tailor
            </button>
          </div>

          {error && (
            <div className="mt-6 rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
              {error}
            </div>
          )}
          {success ? (
            <div className="mt-6 rounded-2xl border border-green-200 bg-green-50 p-6 text-center space-y-4">
              <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-green-100">
                <CheckCircle2 className="h-8 w-8 text-green-600" />
              </div>
              <h3 className="text-lg font-bold text-green-800">Registration Successful!</h3>
              <p className="text-sm text-green-700 font-medium leading-relaxed">{success}</p>
              
              {role === "tailor" && (
                <div className="mt-8 flex flex-col sm:flex-row justify-center gap-3">
                  <button className="flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-3 text-xs font-bold text-slate-700 shadow-sm hover:bg-slate-50">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/3/3c/Download_on_the_App_Store_Badge.svg" alt="App Store" className="h-6" />
                  </button>
                  <button className="flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-3 text-xs font-bold text-slate-700 shadow-sm hover:bg-slate-50">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg" alt="Google Play" className="h-6" />
                  </button>
                </div>
              )}
            </div>
          ) : (

          <form onSubmit={onSubmit} className="mt-6 space-y-4">
            <div>
              <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Full name</label>
              <div className="relative">
                <User className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                <input
                  required
                  type="text"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="w-full pl-11 pr-4 py-3 rounded-2xl bg-slate-50 border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm"
                  placeholder="Jane Doe"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Email</label>
              <div className="relative">
                <Mail className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                <input
                  required
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full pl-11 pr-4 py-3 rounded-2xl bg-slate-50 border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm"
                  placeholder="you@example.com"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">WhatsApp number</label>
              <div className="relative">
                <Phone className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                <input
                  required
                  type="tel"
                  value={whatsapp}
                  onChange={(e) => setWhatsapp(e.target.value)}
                  className="w-full pl-11 pr-4 py-3 rounded-2xl bg-slate-50 border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm"
                  placeholder="e.g. +2348012345678"
                />
              </div>
              <p className="mt-1 text-[11px] text-slate-400 font-medium">
                Tailors use this to send invoices and updates via WhatsApp.
              </p>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Password</label>
              <div className="relative">
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-11 pr-12 py-3 rounded-2xl bg-slate-50 border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm"
                  placeholder="At least 8 characters"
                  minLength={8}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 focus:outline-none"
                >
                  {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">
                Referral Code {isReferralFromLink && "(Locked)"}
              </label>
              <div className="relative">
                {isReferralFromLink ? (
                  <Lock className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-[#0076B6]" />
                ) : (
                  <Ticket className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                )}
                <input
                  type="text"
                  readOnly={isReferralFromLink}
                  value={referralCode}
                  onChange={(e) => setReferralCode(e.target.value)}
                  className={`w-full pl-11 pr-4 py-3 rounded-2xl border border-dashed transition-all text-sm font-bold uppercase tracking-widest ${
                    isReferralFromLink
                      ? "bg-slate-100 border-slate-200 text-slate-400 cursor-not-allowed"
                      : "border-[#00AEEF]/50 bg-[#00AEEF]/5 text-[#0076B6] focus:outline-none focus:ring-2 focus:ring-[#00AEEF] placeholder-slate-400"
                  }`}
                  placeholder="e.g. PARTNER123"
                />
              </div>
              {isReferralFromLink && (
                <p className="mt-1 text-[10px] text-slate-400 font-medium italic">
                  This code was automatically applied from your referral link.
                </p>
              )}
            </div>

            <button
              disabled={loading}
              className="group w-full py-3.5 mt-6 rounded-2xl bg-[#0076B6] hover:bg-[#00AEEF] text-white font-bold shadow-lg disabled:opacity-60 disabled:cursor-not-allowed transition-all flex items-center justify-center gap-2"
            >
              <span>{loading ? "Creating..." : "Create account"}</span>
              {!loading && <ArrowRight className="h-4 w-4 group-hover:translate-x-0.5 transition-transform" />}
            </button>
          </form>
          )}

          {!success && (
            <div className="mt-6 text-sm text-slate-600">
              Already have an account?{" "}
              <Link href="/login" className="font-bold text-[#0076B6] hover:text-[#00AEEF]">
                Sign in
              </Link>
              .
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

