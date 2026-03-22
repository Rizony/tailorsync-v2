"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { supabase } from "@/lib/supabase";
import { ShieldCheck, LogOut, CheckCircle2, XCircle, RefreshCw, Wallet, UserCircle } from "lucide-react";
import { signOut } from "@/lib/auth";

export default function AdminDashboardPage() {
  const [loading, setLoading] = useState(true);
  const [isAdmin, setIsAdmin] = useState(false);
  const [withdrawals, setWithdrawals] = useState<any[]>([]);
  const [tailors, setTailors] = useState<any[]>([]);
  const [activeTab, setActiveTab] = useState<"withdrawals" | "kyc">("withdrawals");

  useEffect(() => {
    verifyAdmin();
  }, []);

  async function verifyAdmin() {
    setLoading(true);
    try {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) {
        window.location.href = "/login";
        return;
      }
      
      // Check admin status
      const { data: adminData } = await supabase.from("admins").select("role").eq("id", session.user.id).single();
      if (!adminData) {
        setIsAdmin(false);
        return;
      }

      setIsAdmin(true);
      await Promise.all([fetchWithdrawals(), fetchTailors()]);
    } catch (err) {
      console.error("Admin verification failed:", err);
    } finally {
      setLoading(false);
    }
  }

  async function fetchWithdrawals() {
    const { data } = await supabase
      .from("withdrawal_requests")
      .select("*, profiles:tailor_id(full_name, email, shop_name)")
      .order("created_at", { ascending: false });
    if (data) setWithdrawals(data);
  }

  async function fetchTailors() {
    const { data } = await supabase
      .from("profiles")
      .select("*")
      .order("created_at", { ascending: false });
    if (data) setTailors(data);
  }

  async function updateWithdrawalStatus(id: string, newStatus: string) {
    if (!confirm(`Are you sure you want to mark this as ${newStatus}?`)) return;
    const { error } = await supabase.from("withdrawal_requests").update({
      status: newStatus,
      processed_at: new Date().toISOString()
    }).eq("id", id);

    if (error) alert("Failed to update status: " + error.message);
    else fetchWithdrawals();
  }

  async function verifyTailorKYC(id: string, isVerified: boolean) {
    const { error } = await supabase.from("profiles").update({
      is_kyc_verified: isVerified
    }).eq("id", id);

    if (error) alert("Failed to update KYC status: " + error.message);
    else fetchTailors();
  }

  if (loading) return <div className="min-h-screen flex items-center justify-center"><div className="animate-spin h-8 w-8 border-4 border-[#0076B6] border-t-transparent rounded-full" /></div>;

  if (!isAdmin) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-slate-50 gap-4">
        <ShieldCheck className="h-16 w-16 text-red-500 mb-4" />
        <h1 className="text-2xl font-bold text-slate-800">Access Denied</h1>
        <p className="text-slate-500">You do not have administrator privileges.</p>
        <Link href="/" className="px-6 py-2 bg-slate-900 text-white rounded-full font-bold">Go Home</Link>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50 font-sans text-slate-900">
      <nav className="bg-slate-900 text-white border-b border-slate-800">
        <div className="mx-auto flex h-20 max-w-7xl items-center justify-between px-6">
          <div className="flex items-center gap-3">
            <Image src="/logo.png" alt="Needlix" width={120} height={35} className="brightness-0 invert" />
            <span className="bg-red-500 text-[10px] font-bold px-2 py-0.5 rounded-sm tracking-widest uppercase ml-2">Admin Root</span>
          </div>
          <button onClick={() => { signOut(); window.location.href='/'; }} className="text-slate-400 hover:text-white flex items-center gap-2 text-sm font-bold">
            <LogOut className="h-4 w-4" /> Logout
          </button>
        </div>
      </nav>

      <main className="mx-auto max-w-7xl px-6 py-10 grid grid-cols-1 lg:grid-cols-4 gap-8">
        <div className="lg:col-span-1 space-y-2">
          <button onClick={() => setActiveTab("withdrawals")} className={`w-full flex items-center gap-3 px-4 py-3 rounded-2xl font-bold text-left transition-colors ${activeTab === 'withdrawals' ? 'bg-[#0076B6] text-white shadow-md' : 'bg-white text-slate-600 hover:bg-slate-100'}`}>
            <Wallet className="h-5 w-5" /> Escrow Payouts
          </button>
          <button onClick={() => setActiveTab("kyc")} className={`w-full flex items-center gap-3 px-4 py-3 rounded-2xl font-bold text-left transition-colors ${activeTab === 'kyc' ? 'bg-[#0076B6] text-white shadow-md' : 'bg-white text-slate-600 hover:bg-slate-100'}`}>
            <UserCircle className="h-5 w-5" /> Tailor KYC
          </button>
        </div>

        <div className="lg:col-span-3">
          <div className="flex justify-between items-end mb-6">
            <div>
              <h1 className="text-2xl font-extrabold text-[#0A1128]">
                {activeTab === 'withdrawals' ? "Escrow Payouts" : "Tailor Verifications"}
              </h1>
              <p className="text-sm text-slate-500 mt-1">Manage platform funds and user trust safely.</p>
            </div>
            <button onClick={() => { activeTab === 'withdrawals' ? fetchWithdrawals() : fetchTailors() }} className="p-2 bg-white rounded-full border border-slate-200 hover:bg-slate-50 text-slate-600">
              <RefreshCw className="h-5 w-5" />
            </button>
          </div>

          {activeTab === 'withdrawals' && (
            <div className="space-y-4">
              {withdrawals.length === 0 ? <p className="text-slate-500">No withdrawal requests found.</p> : withdrawals.map(w => (
                <div key={w.id} className="bg-white rounded-3xl p-6 border border-slate-100 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4">
                  <div>
                    <div className="flex items-center gap-3 mb-2">
                      <span className={`text-[10px] uppercase font-bold px-2 py-1 rounded-full ${w.status === 'pending' ? 'bg-amber-100 text-amber-800' : w.status === 'paid' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
                        {w.status}
                      </span>
                      <span className="text-xs font-bold text-slate-400">{new Date(w.created_at).toLocaleString()}</span>
                    </div>
                    <p className="font-extrabold text-lg">₦{w.amount}</p>
                    <p className="text-sm text-slate-600">{w.profiles?.shop_name || w.profiles?.full_name} ({w.profiles?.email})</p>
                    <p className="text-xs text-slate-500 mt-2 bg-slate-50 p-2 rounded-lg border border-slate-100 font-mono">
                      Acct: {w.account_number} | {w.bank_name} | {w.account_name}
                    </p>
                  </div>
                  {w.status === 'pending' && (
                    <div className="flex gap-2">
                      <button onClick={() => updateWithdrawalStatus(w.id, 'paid')} className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-xl text-sm font-bold flex flex-col items-center">
                        <CheckCircle2 className="h-4 w-4 mb-1" /> Mark Paid
                      </button>
                      <button onClick={() => updateWithdrawalStatus(w.id, 'rejected')} className="bg-red-50 hover:bg-red-100 text-red-700 border border-red-200 px-4 py-2 rounded-xl text-sm font-bold flex flex-col items-center">
                        <XCircle className="h-4 w-4 mb-1" /> Reject
                      </button>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}

          {activeTab === 'kyc' && (
            <div className="space-y-4">
              {tailors.length === 0 ? <p className="text-slate-500">No tailors found.</p> : tailors.map(t => (
                <div key={t.id} className="bg-white rounded-3xl p-6 border border-slate-100 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4">
                  <div>
                    <div className="flex items-center gap-3 mb-2">
                      <span className={`text-[10px] uppercase font-bold px-2 py-1 rounded-full ${t.is_kyc_verified ? 'bg-green-100 text-green-800' : 'bg-slate-100 text-slate-500'}`}>
                        {t.is_kyc_verified ? 'Verified ✅' : 'Unverified'}
                      </span>
                    </div>
                    <p className="font-extrabold text-[#0A1128]">{t.brand_name || t.shop_name || "Unknown Shop"}</p>
                    <p className="text-sm text-slate-600">{t.full_name} | {t.email}</p>
                    {t.kyc_document_url && (
                      <a href={t.kyc_document_url} target="_blank" rel="noreferrer" className="text-xs font-bold text-[#0076B6] mt-2 inline-block hover:underline">
                        View KYC Document ↗
                      </a>
                    )}
                  </div>
                  <div className="flex gap-2">
                    {!t.is_kyc_verified ? (
                       <button onClick={() => verifyTailorKYC(t.id, true)} className="bg-[#0A1128] hover:bg-[#0076B6] text-white px-4 py-2 rounded-xl text-sm font-bold">
                         Approve KYC
                       </button>
                    ) : (
                       <button onClick={() => verifyTailorKYC(t.id, false)} className="bg-red-50 hover:bg-red-100 border border-red-200 text-red-700 px-4 py-2 rounded-xl text-sm font-bold">
                         Revoke
                       </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
