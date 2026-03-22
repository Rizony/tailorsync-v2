"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { supabase } from "@/lib/supabase";
import { ArrowLeft, Save, Ruler } from "lucide-react";

export default function ClientProfilePage() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState({ type: "", text: "" });
  const [user, setUser] = useState<any>(null);

  const [measurements, setMeasurements] = useState({
    chest: "",
    waist: "",
    hips: "",
    inseam: "",
    shoulder: "",
    sleeve: "",
    length: "",
  });

  const [contact, setContact] = useState({
    fullName: "",
    phone: "",
  });

  useEffect(() => {
    loadProfile();
  }, []);

  async function loadProfile() {
    setLoading(true);
    try {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) {
        window.location.href = "/login";
        return;
      }
      setUser(session.user);

      // Fetch customer profile
      const { data, error } = await supabase
        .from("customer_profiles")
        .select("*")
        .eq("user_id", session.user.id)
        .single();
      
      if (data) {
        if (data.full_name) setContact(prev => ({ ...prev, fullName: data.full_name }));
        if (data.phone_number) setContact(prev => ({ ...prev, phone: data.phone_number }));
        if (data.measurements) {
          setMeasurements({
            chest: data.measurements.chest || "",
            waist: data.measurements.waist || "",
            hips: data.measurements.hips || "",
            inseam: data.measurements.inseam || "",
            shoulder: data.measurements.shoulder || "",
            sleeve: data.measurements.sleeve || "",
            length: data.measurements.length || "",
          });
        }
      }
    } catch (err: any) {
      console.error("Error loading profile:", err);
    } finally {
      setLoading(false);
    }
  }

  async function saveProfile(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setMessage({ type: "", text: "" });

    try {
      const payload = {
        user_id: user.id,
        email: user.email,
        full_name: contact.fullName,
        phone_number: contact.phone,
        measurements: measurements,
        updated_at: new Date().toISOString(),
      };

      const { error } = await supabase
        .from("customer_profiles")
        .upsert(payload, { onConflict: "user_id" });

      if (error) throw error;
      setMessage({ type: "success", text: "Profile & Measurements Saved!" });
    } catch (err: any) {
      setMessage({ type: "error", text: err.message || "Failed to save profile." });
    } finally {
      setSaving(false);
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
    <div className="min-h-screen bg-slate-50 font-sans text-slate-900 pb-20">
      <nav className="bg-white border-b border-slate-200">
        <div className="mx-auto flex h-20 max-w-3xl items-center px-6">
          <Link href="/client" className="flex items-center gap-2 text-sm font-bold text-slate-600 hover:text-[#0076B6]">
            <ArrowLeft className="h-4 w-4" />
            Back to Dashboard
          </Link>
        </div>
      </nav>

      <main className="mx-auto max-w-3xl px-6 py-10">
        <div className="mb-8">
          <h1 className="text-3xl font-extrabold text-[#0A1128] flex items-center gap-3">
            <Ruler className="h-8 w-8 text-[#00AEEF]" />
            My Body Measurements
          </h1>
          <p className="text-sm text-slate-500 mt-2">
            Save your measurements here. Tailors will automatically receive them when you send a new order request.
          </p>
        </div>

        {message.text && (
          <div className={`mb-6 rounded-2xl border px-4 py-3 text-sm font-bold ${
            message.type === 'success' ? 'bg-green-50 text-green-700 border-green-200' : 'bg-red-50 text-red-700 border-red-200'
          }`}>
            {message.text}
          </div>
        )}

        <form onSubmit={saveProfile} className="space-y-8">
          {/* Contact Details */}
          <div className="bg-white rounded-3xl p-8 border border-slate-100 shadow-sm">
            <h2 className="text-lg font-bold mb-4">Contact Information</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold text-slate-400 mb-1 uppercase tracking-wider">Full Name</label>
                <input
                  type="text"
                  value={contact.fullName}
                  onChange={e => setContact({...contact, fullName: e.target.value})}
                  className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:ring-2 focus:ring-[#00AEEF] outline-none"
                  placeholder="John Doe"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-400 mb-1 uppercase tracking-wider">Phone / WhatsApp</label>
                <input
                  type="text"
                  value={contact.phone}
                  onChange={e => setContact({...contact, phone: e.target.value})}
                  className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:ring-2 focus:ring-[#00AEEF] outline-none"
                  placeholder="+234..."
                />
              </div>
            </div>
          </div>

          {/* Measurements */}
          <div className="bg-white rounded-3xl p-8 border border-slate-100 shadow-sm">
            <h2 className="text-lg font-bold mb-4">Measurements (Inches)</h2>
            <div className="grid grid-cols-2 lg:grid-cols-3 gap-6">
              {[
                { id: 'chest', label: 'Chest / Bust' },
                { id: 'waist', label: 'Waist' },
                { id: 'hips', label: 'Hips' },
                { id: 'shoulder', label: 'Shoulder width' },
                { id: 'sleeve', label: 'Sleeve length' },
                { id: 'inseam', label: 'Inseam / Trouser' },
                { id: 'length', label: 'Full Length' }
              ].map(field => (
                <div key={field.id}>
                  <label className="block text-xs font-bold text-slate-400 mb-1 uppercase tracking-wider">{field.label}</label>
                  <input
                    type="number"
                    step="0.5"
                    value={measurements[field.id as keyof typeof measurements]}
                    onChange={(e) => setMeasurements({...measurements, [field.id]: e.target.value})}
                    className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:ring-2 focus:ring-[#00AEEF] outline-none font-medium"
                    placeholder="e.g. 32.5"
                  />
                </div>
              ))}
            </div>
          </div>

          <button
            type="submit"
            disabled={saving}
            className="w-full py-4 rounded-2xl bg-[#0076B6] text-white font-bold shadow-lg hover:bg-[#00AEEF] transition-colors flex items-center justify-center gap-2 disabled:opacity-70"
          >
            <Save className="h-5 w-5" />
            {saving ? "Saving Profile..." : "Save Measurements"}
          </button>
        </form>
      </main>
    </div>
  );
}
