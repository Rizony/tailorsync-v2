"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import Image from "next/image";
import { Mail, Lock, ArrowRight, User, Phone } from "lucide-react";
import { supabase } from "@/lib/supabase";

export default function ClientSignupPage() {
  const router = useRouter();
  const [fullName, setFullName] = useState("");
  const [whatsapp, setWhatsapp] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      if (data.session) router.replace("/client");
    });
  }, [router]);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: { full_name: fullName, whatsapp, role: "client" },
        },
      });
      if (error) throw error;

      // If email confirmation is enabled, session may be null.
      if (data.session) {
        router.push("/client");
      } else {
        setSuccess("Account created. Check your email to confirm, then log in.");
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
          <h1 className="text-2xl font-extrabold text-[#0A1128]">Create client account</h1>
          <p className="text-sm text-slate-500 mt-1">
            Use this to track jobs, rate tailors, and pay securely on the website.
          </p>

          {error && (
            <div className="mt-6 rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
              {error}
            </div>
          )}
          {success && (
            <div className="mt-6 rounded-2xl border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700">
              {success}
            </div>
          )}

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
                <Lock className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                <input
                  required
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-11 pr-4 py-3 rounded-2xl bg-slate-50 border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] transition-all text-sm"
                  placeholder="At least 8 characters"
                  minLength={8}
                />
              </div>
            </div>

            <button
              disabled={loading}
              className="group w-full py-3.5 rounded-2xl bg-[#0076B6] hover:bg-[#00AEEF] text-white font-bold shadow-lg disabled:opacity-60 disabled:cursor-not-allowed transition-all flex items-center justify-center gap-2"
            >
              <span>{loading ? "Creating..." : "Create account"}</span>
              {!loading && <ArrowRight className="h-4 w-4 group-hover:translate-x-0.5 transition-transform" />}
            </button>
          </form>

          <div className="mt-6 text-sm text-slate-600">
            Already have an account?{" "}
            <Link href="/login" className="font-bold text-[#0076B6] hover:text-[#00AEEF]">
              Sign in
            </Link>
            .
          </div>
        </div>
      </main>
    </div>
  );
}

