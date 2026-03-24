"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Mail, ArrowLeft, Send, CheckCircle2 } from "lucide-react";
import { supabase } from "@/lib/supabase";

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSuccess(false);

    try {
      // 1. Check if the email is verified in our system via RPC
      const { data: isVerified, error: rpcError } = await supabase.rpc(
        'is_email_verified',
        { email_input: email.trim() }
      );

      if (rpcError) throw rpcError;

      if (!isVerified) {
        setError("This email is not verified or does not exist. Password recovery is only available for verified accounts.");
        setLoading(false);
        return;
      }

      // 2. Send reset link
      const { error: resetError } = await supabase.auth.resetPasswordForEmail(
        email.trim(),
        { redirectTo: `${window.location.origin}/reset-password` }
      );

      if (resetError) throw resetError;
      
      setSuccess(true);
    } catch (err: any) {
      setError(err?.message ?? "Failed to send reset link");
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
          <Link href="/login" className="text-sm font-bold text-[#0076B6] hover:text-[#00AEEF] flex items-center gap-2">
            <ArrowLeft className="h-4 w-4" />
            Back to sign in
          </Link>
        </div>
      </nav>

      <main className="mx-auto max-w-xl px-6 py-14">
        <div className="bg-white rounded-3xl border border-slate-100 shadow-sm p-8">
          {success ? (
            <div className="text-center space-y-4">
              <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-green-100">
                <CheckCircle2 className="h-8 w-8 text-green-600" />
              </div>
              <h1 className="text-2xl font-extrabold text-[#0A1128]">Check your email</h1>
              <p className="text-sm text-slate-500 max-w-xs mx-auto">
                We've sent a password reset link to <span className="font-bold text-slate-900">{email}</span>.
              </p>
              <div className="pt-6">
                <Link href="/login" className="text-sm font-bold text-[#0076B6] hover:text-[#00AEEF]">
                  Return to sign in
                </Link>
              </div>
            </div>
          ) : (
            <>
              <h1 className="text-2xl font-extrabold text-[#0A1128]">Forgot password?</h1>
              <p className="text-sm text-slate-500 mt-1">
                No worries, we'll send you reset instructions. Only verified emails are eligible for recovery.
              </p>

              {error && (
                <div className="mt-6 rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
                  {error}
                </div>
              )}

              <form onSubmit={onSubmit} className="mt-6 space-y-4">
                <div>
                  <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Email address</label>
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

                <button
                  disabled={loading}
                  className="group w-full py-3.5 rounded-2xl bg-[#0076B6] hover:bg-[#00AEEF] text-white font-bold shadow-lg disabled:opacity-60 disabled:cursor-not-allowed transition-all flex items-center justify-center gap-2"
                >
                  <Send className="h-4 w-4" />
                  <span>{loading ? "Sending..." : "Reset password"}</span>
                </button>
              </form>
            </>
          )}
        </div>
      </main>
    </div>
  );
}
