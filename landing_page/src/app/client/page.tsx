"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { supabase, supabaseUrl } from "@/lib/supabase";
import { signOut } from "@/lib/auth";
import { ArrowRight, CreditCard, LogOut, RefreshCw, Scissors, Star, CheckCircle2 } from "lucide-react";

type RequestStatus = "pending" | "accepted" | "rejected" | "completed" | string;

interface MarketplaceRequest {
  id: string;
  tailor_id: string;
  customer_name: string;
  customer_email: string;
  customer_phone?: string | null;
  customer_whatsapp?: string | null;
  description: string;
  status: RequestStatus;
  payment_status?: string | null;
  quote_amount?: number | null;
  quote_currency?: string | null;
  quote_message?: string | null;
  quote_status?: string | null; // pending, accepted, declined, countered
  counter_offer_amount?: number | null;
  counter_offer_message?: string | null;
  created_at: string;
  order_id?: string | null;
  customer_id?: string | null;
  orders?: { status: string; title: string; due_date?: string } | null;
}

interface MarketplaceRating {
  request_id: string;
  rating: number;
  review?: string | null;
}

function statusBadge(status: RequestStatus) {
  const s = (status || "pending").toLowerCase();
  if (s === "accepted") return "bg-blue-50 text-blue-700 border-blue-200";
  if (s === "rejected") return "bg-red-50 text-red-700 border-red-200";
  if (s === "completed") return "bg-green-50 text-green-700 border-green-200";
  return "bg-amber-50 text-amber-700 border-amber-200";
}

function OrderTrackingTimeline({ status }: { status: string }) {
  const norm = status.toLowerCase();
  if (norm === 'canceled') {
    return (
      <div className="mt-4 rounded-xl border border-red-200 bg-red-50 p-4">
        <p className="text-sm font-bold text-red-700 text-center">This order was canceled.</p>
      </div>
    );
  }

  const stages = [
    { key: "pending", label: "Confirmed" },
    { key: "in_progress", label: "Tailoring" },
    { key: "fitting", label: "Fitting" }, // We merge 'adjustment' into this stage visually
    { key: "completed", label: "Ready" },
    { key: "delivered", label: "Delivered" },
  ];

  let currentIndex = 0;
  if (norm === "in_progress") currentIndex = 1;
  else if (norm === "fitting" || norm === "adjustment") currentIndex = 2;
  else if (norm === "completed") currentIndex = 3;
  else if (norm === "delivered") currentIndex = 4;

  return (
    <div className="mt-6 border-t border-slate-100 pt-5">
      <h4 className="text-xs font-extrabold text-[#0076B6] uppercase tracking-wider mb-4">
        Live Order Tracking
      </h4>
      <div className="flex items-center justify-between relative">
        <div className="absolute left-0 top-3 w-full h-1 bg-slate-100 rounded-full" />
        <div 
          className="absolute left-0 top-3 h-1 bg-[#0076B6] rounded-full transition-all duration-500 ease-in-out" 
          style={{ width: `${(currentIndex / (stages.length - 1)) * 100}%` }} 
        />
        
        {stages.map((stage, idx) => {
          const isCompleted = idx <= currentIndex;
          const isCurrent = idx === currentIndex;
          return (
            <div key={stage.key} className="relative z-10 flex flex-col items-center gap-2 group">
              <div 
                className={`w-7 h-7 rounded-full flex items-center justify-center border-2 transition-colors ${
                  isCompleted ? "bg-[#0076B6] border-[#0076B6] text-white" : "bg-white border-slate-200 text-transparent"
                } ${isCurrent ? "ring-4 ring-[#0076B6]/20" : ""}`}
              >
                {isCompleted && <span className="text-[10px] font-bold">✓</span>}
              </div>
              <span className={`text-[10px] sm:text-xs font-bold ${isCurrent ? "text-[#0A1128]" : isCompleted ? "text-slate-600" : "text-slate-400"}`}>
                {stage.label}
              </span>
            </div>
          );
        })}
      </div>
    </div>
  );
}

export default function ClientDashboardPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [requests, setRequests] = useState<MarketplaceRequest[]>([]);
  const [email, setEmail] = useState<string | null>(null);
  const [ratingsByRequestId, setRatingsByRequestId] = useState<Record<string, MarketplaceRating>>({});
  const [ratingTarget, setRatingTarget] = useState<MarketplaceRequest | null>(null);
  const [ratingValue, setRatingValue] = useState<number>(5);
  const [ratingReview, setRatingReview] = useState<string>("");
  const [submittingRating, setSubmittingRating] = useState<boolean>(false);
  const [quoteTarget, setQuoteTarget] = useState<MarketplaceRequest | null>(null);
  const [counterAmount, setCounterAmount] = useState<string>("");
  const [counterMessage, setCounterMessage] = useState<string>("");
  const [submittingQuoteAction, setSubmittingQuoteAction] = useState<boolean>(false);

  const sorted = useMemo(() => {
    return [...requests].sort((a, b) => (a.created_at < b.created_at ? 1 : -1));
  }, [requests]);

  useEffect(() => {
    init();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function init() {
    setLoading(true);
    setError(null);
    try {
      const { data } = await supabase.auth.getSession();
      if (!data.session) {
        router.replace("/login");
        return;
      }
      setEmail(data.session.user.email ?? null);
      await fetchRequests(data.session.user.email ?? null);
    } catch (err: any) {
      setError(err?.message ?? "Failed to load dashboard");
    } finally {
      setLoading(false);
    }
  }

  async function fetchRequests(userEmail: string | null) {
    if (!userEmail) {
      setRequests([]);
      return;
    }

    // NOTE: This relies on a DB/RLS update:
    // - Add marketplace_requests.customer_id uuid (auth.uid())
    // - Allow clients to SELECT their own requests via customer_id
    //
    // Until that’s applied, we fall back to a best-effort email match,
    // which should be replaced with the secure customer_id policy.
    let reqs: MarketplaceRequest[] = [];
    try {
      // Try joining with orders table (requires SQL migration to be run)
      const { data, error } = await supabase
        .from("marketplace_requests")
        .select("*, orders(status, title, due_date)")
        .eq("customer_email", userEmail)
        .order("created_at", { ascending: false });
      
      if (error) throw error;
      reqs = (data as unknown as MarketplaceRequest[]) ?? [];
    } catch (e) {
      // Fallback if the SQL migration isn't run yet (orders foreign key missing)
      const { data, error } = await supabase
        .from("marketplace_requests")
        .select("*")
        .eq("customer_email", userEmail)
        .order("created_at", { ascending: false });
      if (!error) reqs = (data as MarketplaceRequest[]) ?? [];
    }
    setRequests(reqs);

    // Fetch ratings (if table exists)
    if (reqs.length > 0) {
      const ids = reqs.map((r) => r.id);
      const rResp = await supabase
        .from("marketplace_ratings")
        .select("request_id,rating,review")
        .in("request_id", ids);
      if (!rResp.error && Array.isArray(rResp.data)) {
        const map: Record<string, MarketplaceRating> = {};
        for (const rr of rResp.data as any[]) {
          if (rr?.request_id) map[String(rr.request_id)] = rr as MarketplaceRating;
        }
        setRatingsByRequestId(map);
      }
    }
  }

  async function onRefresh() {
    setRefreshing(true);
    setError(null);
    try {
      await fetchRequests(email);
    } catch (err: any) {
      setError(err?.message ?? "Refresh failed");
    } finally {
      setRefreshing(false);
    }
  }

  async function onLogout() {
    await signOut();
    router.push("/");
  }

  async function startPaystackPayment(r: MarketplaceRequest) {
    setError(null);
    try {
      const { data } = await supabase.auth.getSession();
      const session = data.session;
      if (!session) {
        router.replace("/login");
        return;
      }
      if (!r.quote_amount || r.quote_amount <= 0) {
        setError("This request does not have a quote amount yet.");
        return;
      }
      const qs = String(r.quote_status || "pending").toLowerCase();
      if (qs !== "accepted") {
        setError("Please accept the tailor’s quote (or send a counter offer) before making payment.");
        return;
      }

      const reference = `NEEDLIX_MKT_${Date.now()}_${r.id}`;
      const callback_url = `${window.location.origin}/client`;

      const resp = await fetch(`${supabaseUrl}/functions/v1/create-paystack-payment`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${session.access_token}`,
        },
        body: JSON.stringify({
          email: session.user.email,
          amount: r.quote_amount,
          reference,
          callback_url,
          metadata: {
            marketplace_request_id: r.id,
            tailor_id: r.tailor_id,
            customer_id: session.user.id,
          },
        }),
      });

      const payload = await resp.json();
      if (!resp.ok) throw new Error(payload?.error || "Failed to initialize Paystack payment");
      if (!payload?.payment_url) throw new Error("Missing payment URL");

      window.location.href = payload.payment_url;
    } catch (err: any) {
      setError(err?.message ?? "Payment initialization failed");
    }
  }

  async function acceptQuote(r: MarketplaceRequest) {
    setSubmittingQuoteAction(true);
    setError(null);
    try {
      const { data } = await supabase.auth.getSession();
      if (!data.session) {
        router.replace("/login");
        return;
      }
      const resp = await supabase
        .from("marketplace_requests")
        .update({ quote_status: "accepted" })
        .eq("id", r.id);
      if (resp.error) throw resp.error;
      await fetchRequests(email);
    } catch (err: any) {
      setError(err?.message ?? "Failed to accept quote");
    } finally {
      setSubmittingQuoteAction(false);
    }
  }

  async function declineQuote(r: MarketplaceRequest) {
    setSubmittingQuoteAction(true);
    setError(null);
    try {
      const { data } = await supabase.auth.getSession();
      if (!data.session) {
        router.replace("/login");
        return;
      }
      const resp = await supabase
        .from("marketplace_requests")
        .update({ quote_status: "declined" })
        .eq("id", r.id);
      if (resp.error) throw resp.error;
      await fetchRequests(email);
    } catch (err: any) {
      setError(err?.message ?? "Failed to decline quote");
    } finally {
      setSubmittingQuoteAction(false);
    }
  }

  async function submitCounterOffer() {
    if (!quoteTarget) return;
    setSubmittingQuoteAction(true);
    setError(null);
    try {
      const { data } = await supabase.auth.getSession();
      if (!data.session) {
        router.replace("/login");
        return;
      }
      const amt = Number(counterAmount.replaceAll(",", "").trim());
      if (!Number.isFinite(amt) || amt <= 0) {
        setError("Enter a valid counter-offer amount.");
        return;
      }
      const resp = await supabase
        .from("marketplace_requests")
        .update({
          quote_status: "countered",
          counter_offer_amount: amt,
          counter_offer_message: counterMessage.trim() || null,
          counter_offered_at: new Date().toISOString(),
        })
        .eq("id", quoteTarget.id);
      if (resp.error) throw resp.error;

      setQuoteTarget(null);
      setCounterAmount("");
      setCounterMessage("");
      await fetchRequests(email);
    } catch (err: any) {
      setError(err?.message ?? "Failed to submit counter offer");
    } finally {
      setSubmittingQuoteAction(false);
    }
  }

  async function submitRating() {
    if (!ratingTarget) return;
    setSubmittingRating(true);
    setError(null);
    try {
      const { data } = await supabase.auth.getSession();
      const session = data.session;
      if (!session) {
        router.replace("/login");
        return;
      }

      const payload = {
        request_id: ratingTarget.id,
        tailor_id: ratingTarget.tailor_id,
        customer_id: session.user.id,
        rating: ratingValue,
        review: ratingReview.trim() || null,
      };

      const resp = await supabase.from("marketplace_ratings").insert(payload);
      if (resp.error) throw resp.error;

      setRatingTarget(null);
      setRatingReview("");
      setRatingValue(5);
      await fetchRequests(email);
    } catch (err: any) {
      setError(err?.message ?? "Failed to submit rating");
    } finally {
      setSubmittingRating(false);
    }
  }

  async function confirmDelivery(r: MarketplaceRequest) {
    if (!r.orders || !r.order_id) return;
    setSubmittingQuoteAction(true);
    setError(null);
    try {
      const resp = await supabase.rpc('escrow_release_pending', { p_order_id: r.order_id });
      if (resp.error) throw resp.error;
      
      await fetchRequests(email);
    } catch (err: any) {
      setError(err?.message ?? "Failed to confirm delivery. " + (err?.details || ""));
    } finally {
      setSubmittingQuoteAction(false);
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-slate-50">
        <div className="h-12 w-12 border-4 border-[#0076B6] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50 font-sans text-slate-900">
      <nav className="bg-white border-b border-slate-200">
        <div className="mx-auto flex h-20 max-w-7xl items-center justify-between px-6 lg:px-8">
          <Link href="/" className="flex items-center gap-3">
            <Image src="/logo.png" alt="Needlix Logo" width={140} height={40} className="h-8 w-auto object-contain" />
          </Link>
          <div className="flex items-center gap-4 pl-4 ml-auto">
            <Link href="/marketplace" className="hidden sm:block text-sm font-bold text-slate-600 hover:text-[#0076B6]">
              Marketplace
            </Link>
            <Link href="/client/profile" className="text-sm font-bold text-[#0076B6] hover:text-[#00AEEF] px-3 py-1.5 rounded-full bg-[#00AEEF]/10">
              My Profile & Measurements
            </Link>
            <button
              onClick={onLogout}
              className="hidden sm:inline-flex items-center gap-2 rounded-full border border-slate-200 bg-white px-4 py-1.5 text-sm font-bold text-slate-700 hover:bg-slate-50"
            >
              <LogOut className="h-4 w-4" />
              Logout
            </button>
          </div>
        </div>
      </nav>

      <main className="mx-auto max-w-5xl px-6 py-10">
        <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-4 mb-8">
          <div>
            <h1 className="text-3xl font-extrabold text-[#0A1128]">Client dashboard</h1>
            <p className="text-sm text-slate-500 mt-1">
              Signed in as <span className="font-bold text-slate-700">{email ?? "unknown"}</span>
            </p>
          </div>
          <button
            onClick={onRefresh}
            disabled={refreshing}
            className="inline-flex items-center justify-center gap-2 rounded-2xl bg-[#0076B6] px-5 py-3 text-sm font-bold text-white shadow-lg hover:bg-[#00AEEF] disabled:opacity-60"
          >
            <RefreshCw className={`h-4 w-4 ${refreshing ? "animate-spin" : ""}`} />
            Refresh
          </button>
        </div>

        {error && (
          <div className="mb-6 rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
            {error}
          </div>
        )}

        {sorted.length === 0 ? (
          <div className="bg-white rounded-3xl border border-dashed border-slate-300 p-10 text-center">
            <Scissors className="h-12 w-12 text-slate-300 mx-auto mb-4" />
            <h2 className="text-xl font-bold text-slate-900">No requests yet</h2>
            <p className="text-slate-500 mt-1 mb-6">Browse the marketplace and send a job request to a tailor.</p>
            <Link
              href="/marketplace"
              className="inline-flex items-center justify-center gap-2 rounded-2xl bg-[#0076B6] px-6 py-3 text-sm font-bold text-white shadow-lg hover:bg-[#00AEEF]"
            >
              Find a tailor <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        ) : (
          <div className="space-y-4">
            {sorted.map((r) => (
              <div key={r.id} className="bg-white rounded-3xl border border-slate-100 shadow-sm p-6">
                <div className="flex flex-col md:flex-row md:items-start md:justify-between gap-4">
                  <div className="min-w-0">
                    <div className="flex items-center gap-3 mb-2">
                      <span className={`inline-flex items-center rounded-full border px-3 py-1 text-[11px] font-bold ${statusBadge(r.status)}`}>
                        {r.status?.toUpperCase() ?? "PENDING"}
                      </span>
                      <span className="text-xs text-slate-400 font-bold">
                        {new Date(r.created_at).toLocaleString()}
                      </span>
                    </div>
                    <p className="font-bold text-slate-900 line-clamp-1">{r.customer_name}</p>
                    <p className="text-sm text-slate-600 whitespace-pre-line mt-2">{r.description}</p>
                    {r.quote_message ? (
                      <p className="text-sm text-slate-700 mt-3 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3">
                        <span className="font-extrabold">Tailor note:</span> {r.quote_message}
                      </p>
                    ) : null}
                  </div>
                  <div className="flex flex-col gap-2">
                    <Link
                      href={`/tailor/${r.tailor_id}`}
                      className="inline-flex items-center justify-center gap-2 rounded-2xl border border-slate-200 bg-white px-4 py-2 text-sm font-bold text-slate-700 hover:bg-slate-50"
                    >
                      View tailor <ArrowRight className="h-4 w-4" />
                    </Link>
                    {String(r.payment_status || "unpaid").toLowerCase() === "paid" ? (
                      <div className="rounded-2xl border border-green-200 bg-green-50 px-4 py-2 text-sm font-bold text-green-700 text-center">
                        Paid
                      </div>
                    ) : r.quote_amount ? (
                      <button
                        onClick={() => startPaystackPayment(r)}
                        className="inline-flex items-center justify-center gap-2 rounded-2xl bg-[#0A1128] px-4 py-2 text-sm font-bold text-white hover:bg-[#0076B6] transition-colors"
                      >
                        <CreditCard className="h-4 w-4" />
                        Pay ₦{r.quote_amount}
                      </button>
                    ) : (
                      <div className="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-2 text-sm font-bold text-slate-600 text-center">
                        Waiting for quote
                      </div>
                    )}

                    {/* Quote negotiation */}
                    {r.quote_amount && String(r.payment_status || "").toLowerCase() !== "paid" ? (
                      <div className="rounded-2xl border border-slate-200 bg-white px-4 py-3">
                        <p className="text-xs font-extrabold text-slate-500 uppercase tracking-wider mb-2">Quote actions</p>
                        <div className="flex flex-col gap-2">
                          <button
                            onClick={() => acceptQuote(r)}
                            disabled={submittingQuoteAction}
                            className="rounded-2xl bg-[#0076B6] px-4 py-2 text-sm font-bold text-white hover:bg-[#00AEEF] disabled:opacity-60"
                          >
                            Accept quote
                          </button>
                          <button
                            onClick={() => {
                              setQuoteTarget(r);
                              setCounterAmount(r.counter_offer_amount ? String(r.counter_offer_amount) : "");
                              setCounterMessage(r.counter_offer_message ?? "");
                            }}
                            disabled={submittingQuoteAction}
                            className="rounded-2xl border border-amber-200 bg-amber-50 px-4 py-2 text-sm font-bold text-amber-800 hover:bg-amber-100 disabled:opacity-60"
                          >
                            Negotiate (counter offer)
                          </button>
                          <button
                            onClick={() => declineQuote(r)}
                            disabled={submittingQuoteAction}
                            className="rounded-2xl border border-red-200 bg-red-50 px-4 py-2 text-sm font-bold text-red-700 hover:bg-red-100 disabled:opacity-60"
                          >
                            Decline quote
                          </button>
                        </div>
                        <p className="mt-3 text-[11px] text-slate-500 leading-relaxed">
                          Payments must be completed through Needlix to protect both you and the tailor, keep a verified receipt trail, and enable dispute support.
                        </p>
                      </div>
                    ) : null}

                    {String(r.status || "").toLowerCase() === "completed" &&
                    String(r.payment_status || "").toLowerCase() === "paid" ? (
                      <div className="flex flex-col gap-2 mt-2 pt-2 border-t border-slate-100">
                        {r.orders?.status === 'completed' && (
                          <button
                            onClick={() => confirmDelivery(r)}
                            disabled={submittingQuoteAction}
                            className="inline-flex flex-1 items-center justify-center gap-2 rounded-2xl bg-green-600 px-4 py-2 text-sm font-bold text-white hover:bg-green-700 disabled:opacity-60 shadow-md"
                          >
                            <CheckCircle2 className="h-4 w-4" />
                            Confirm Delivery & Release Escrow
                          </button>
                        )}
                        
                        {ratingsByRequestId[r.id] ? (
                          <div className="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-2 text-sm font-bold text-slate-700 text-center">
                            Rated: {ratingsByRequestId[r.id].rating}/5
                          </div>
                        ) : (
                          <button
                            onClick={() => {
                              setRatingTarget(r);
                              setRatingValue(5);
                              setRatingReview("");
                            }}
                            className="inline-flex flex-1 items-center justify-center gap-2 rounded-2xl border border-amber-200 bg-amber-50 px-4 py-2 text-sm font-bold text-amber-800 hover:bg-amber-100"
                          >
                            <Star className="h-4 w-4" />
                            Rate tailor
                          </button>
                        )}
                      </div>
                    ) : null}
                  </div>
                </div>

                {/* If the order is created and linked, show the live tracking timeline */}
                {r.order_id && !r.orders && (
                  <div className="mt-8 pt-6 border-t border-slate-100">
                    <div className="flex items-center gap-3 text-[#0076B6] bg-[#0076B6]/5 px-4 py-3 rounded-2xl border border-[#0076B6]/10">
                      <RefreshCw className="h-4 w-4 animate-spin" />
                      <p className="text-sm font-bold">Tailor is setting up your live tracking. Check back in a moment.</p>
                    </div>
                  </div>
                )}
                {r.orders?.status && (
                  <OrderTrackingTimeline status={r.orders.status} />
                )}
              </div>
            ))}
          </div>
        )}

        {ratingTarget && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-6">
            <div className="w-full max-w-lg rounded-3xl bg-white p-6 shadow-2xl">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <h3 className="text-xl font-extrabold text-[#0A1128]">Rate your tailor</h3>
                  <p className="text-sm text-slate-500 mt-1">Your rating helps other clients choose confidently.</p>
                </div>
                <button
                  onClick={() => setRatingTarget(null)}
                  className="rounded-full border border-slate-200 bg-white px-3 py-1.5 text-sm font-bold text-slate-700 hover:bg-slate-50"
                >
                  Close
                </button>
              </div>

              <div className="mt-5 flex items-center gap-2">
                {[1, 2, 3, 4, 5].map((v) => (
                  <button
                    key={v}
                    onClick={() => setRatingValue(v)}
                    className={`h-10 w-10 rounded-2xl border text-sm font-extrabold ${
                      v <= ratingValue ? "bg-amber-50 border-amber-200 text-amber-800" : "bg-white border-slate-200 text-slate-500"
                    }`}
                    title={`${v} star`}
                  >
                    ★
                  </button>
                ))}
                <span className="ml-2 text-sm font-bold text-slate-700">{ratingValue}/5</span>
              </div>

              <div className="mt-4">
                <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Review (optional)</label>
                <textarea
                  value={ratingReview}
                  onChange={(e) => setRatingReview(e.target.value)}
                  rows={4}
                  className="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-[#00AEEF]"
                  placeholder="What did you like? Anything to improve?"
                />
              </div>

              <div className="mt-5 flex gap-3">
                <button
                  onClick={() => setRatingTarget(null)}
                  className="flex-1 rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm font-bold text-slate-700 hover:bg-slate-50"
                >
                  Cancel
                </button>
                <button
                  onClick={submitRating}
                  disabled={submittingRating}
                  className="flex-1 rounded-2xl bg-[#0076B6] px-4 py-3 text-sm font-bold text-white hover:bg-[#00AEEF] disabled:opacity-60"
                >
                  {submittingRating ? "Submitting..." : "Submit rating"}
                </button>
              </div>
            </div>
          </div>
        )}

        {quoteTarget && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-6">
            <div className="w-full max-w-lg rounded-3xl bg-white p-6 shadow-2xl">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <h3 className="text-xl font-extrabold text-[#0A1128]">Counter offer</h3>
                  <p className="text-sm text-slate-500 mt-1">Propose a new price or terms. The tailor will see this in the app.</p>
                </div>
                <button
                  onClick={() => setQuoteTarget(null)}
                  className="rounded-full border border-slate-200 bg-white px-3 py-1.5 text-sm font-bold text-slate-700 hover:bg-slate-50"
                >
                  Close
                </button>
              </div>

              <div className="mt-4">
                <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Amount (₦)</label>
                <input
                  value={counterAmount}
                  onChange={(e) => setCounterAmount(e.target.value)}
                  className="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-[#00AEEF]"
                  placeholder="e.g. 20000"
                />
              </div>

              <div className="mt-4">
                <label className="block text-xs font-bold text-slate-400 mb-1 tracking-wider uppercase">Message (optional)</label>
                <textarea
                  value={counterMessage}
                  onChange={(e) => setCounterMessage(e.target.value)}
                  rows={4}
                  className="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-[#00AEEF]"
                  placeholder="Add notes about quantity, delivery timeline, fittings, etc."
                />
              </div>

              <div className="mt-5 flex gap-3">
                <button
                  onClick={() => setQuoteTarget(null)}
                  className="flex-1 rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm font-bold text-slate-700 hover:bg-slate-50"
                >
                  Cancel
                </button>
                <button
                  onClick={submitCounterOffer}
                  disabled={submittingQuoteAction}
                  className="flex-1 rounded-2xl bg-[#0076B6] px-4 py-3 text-sm font-bold text-white hover:bg-[#00AEEF] disabled:opacity-60"
                >
                  {submittingQuoteAction ? "Submitting..." : "Send counter offer"}
                </button>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}

