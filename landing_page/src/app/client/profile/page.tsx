"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { supabase } from "@/lib/supabase";
import { ArrowLeft, Save, Ruler, Camera } from "lucide-react";

export default function ClientProfilePage() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState({ type: "", text: "" });
  const [user, setUser] = useState<any>(null);

  const [measurements, setMeasurements] = useState<Record<string, string>>({});
  const [gender, setGender] = useState<"Male" | "Female">("Male");

  const [photoUrl, setPhotoUrl] = useState<string>("");
  const [uploadingPhoto, setUploadingPhoto] = useState(false);

  const [contact, setContact] = useState({
    fullName: "",
    phone: "",
    email: "",
  });

  const MALE_MEASUREMENTS = [
    'Neck', 'Shoulder', 'Chest', 'Stomach', 'Top Length', 'Sleeve Length', 
    'Muscle', 'Forearm', 'Wrist', 'Waist', 'Hips', 'Thigh', 'Knee', 
    'Calf', 'Ankle', 'Trouser Length'
  ];

  const FEMALE_MEASUREMENTS = [
    'Bust', 'Waist', 'Hips', 'Shoulder', 'Sleeve', 'Nipple to Nipple', 
    'Shoulder to Nipple', 'Shoulder to Underbust', 'Shoulder to Waist', 
    'Gown Length', 'Skirt Length', 'Blouse Length', 'Wrapper Length'
  ];

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
        if (data.email) setContact(prev => ({ ...prev, email: data.email }));
        if (data.photo_url) setPhotoUrl(data.photo_url);
        if (data.measurements) {
          setMeasurements(data.measurements);
        }
        if (data.gender) {
          setGender(data.gender === "Female" ? "Female" : "Male");
        }
      }
    } catch (err: any) {
      console.error("Error loading profile:", err);
    } finally {
      setLoading(false);
    }
  }

  async function handlePhotoUpload(e: React.ChangeEvent<HTMLInputElement>) {
    if (!e.target.files || e.target.files.length === 0) return;
    const file = e.target.files[0];
    
    try {
      setUploadingPhoto(true);
      const safeName = (file.name || `photo_${Date.now()}.jpg`).replace(/[^\w.\-]+/g, "_");
      const path = `avatars/${user?.id || Date.now()}_${safeName}`;
      
      const { error } = await supabase.storage
        .from("marketplace_uploads")
        .upload(path, file, { cacheControl: "3600", upsert: true });

      if (error) throw error;
      
      const { data } = supabase.storage
        .from("marketplace_uploads")
        .getPublicUrl(path);
        
      setPhotoUrl(data.publicUrl);
      setMessage({ type: "success", text: "Profile picture uploaded successfully." });
    } catch (err: any) {
      setMessage({ type: "error", text: "Error uploading photo: " + (err.message || err.toString()) });
    } finally {
      setUploadingPhoto(false);
    }
  }

  async function saveProfile(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setMessage({ type: "", text: "" });

    try {
      const payload = {
        user_id: user.id,
        email: contact.email || user.email,
        full_name: contact.fullName,
        phone_number: contact.phone,
        gender: gender,
        photo_url: photoUrl,
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
          {/* Profile & Contact Details */}
          <div className="bg-white rounded-3xl p-8 border border-slate-100 shadow-sm">
            <h2 className="text-lg font-bold mb-4">Profile Information</h2>
            
            <div className="mb-6 flex flex-col items-center sm:flex-row sm:items-start gap-6">
              <div className="relative h-24 w-24 rounded-full bg-slate-100 border-4 border-white shadow-md flex items-center justify-center overflow-hidden shrink-0">
                {photoUrl ? (
                  <img src={photoUrl} alt="Profile" className="h-full w-full object-cover" />
                ) : (
                  <Camera className="h-8 w-8 text-slate-300" />
                )}
                {uploadingPhoto && (
                  <div className="absolute inset-0 bg-white/60 flex items-center justify-center">
                    <div className="h-4 w-4 border-2 border-[#0076B6] border-t-transparent rounded-full animate-spin" />
                  </div>
                )}
              </div>
              <div className="flex-1 space-y-2 text-center sm:text-left">
                <p className="text-sm font-bold text-slate-700">Profile Picture</p>
                <p className="text-xs text-slate-500 mb-2">Upload a picture so tailors know who you are.</p>
                <label className="inline-block px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-100 cursor-pointer transition-colors">
                  {uploadingPhoto ? "Uploading..." : "Choose Photo"}
                  <input type="file" accept="image/*" className="hidden" onChange={handlePhotoUpload} disabled={uploadingPhoto} />
                </label>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="md:col-span-2">
                <label className="block text-xs font-bold text-slate-400 mb-1 uppercase tracking-wider">Email Address</label>
                <input
                  type="email"
                  value={contact.email}
                  onChange={e => setContact({...contact, email: e.target.value})}
                  className="w-full px-4 py-3 rounded-xl bg-slate-50 border border-slate-100 focus:ring-2 focus:ring-[#00AEEF] outline-none"
                  placeholder="john@example.com"
                />
              </div>
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
            <div className="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4">
              <h2 className="text-lg font-bold">Measurements (Inches)</h2>
              <div className="flex bg-slate-100 p-1 rounded-full items-center">
                <button
                  type="button"
                  onClick={() => setGender("Male")}
                  className={`px-4 py-1.5 rounded-full text-sm font-bold transition-colors ${gender === "Male" ? "bg-white shadow text-[#0076B6]" : "text-slate-500 hover:text-slate-700"}`}
                >
                  Male
                </button>
                <button
                  type="button"
                  onClick={() => setGender("Female")}
                  className={`px-4 py-1.5 rounded-full text-sm font-bold transition-colors ${gender === "Female" ? "bg-white shadow text-[#0076B6]" : "text-slate-500 hover:text-slate-700"}`}
                >
                  Female
                </button>
              </div>
            </div>
            
            <div className="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {(gender === "Male" ? MALE_MEASUREMENTS : FEMALE_MEASUREMENTS).map(field => (
                <div key={field}>
                  <label className="block text-[10px] font-bold text-slate-400 mb-1 uppercase tracking-wider">{field}</label>
                  <input
                    type="number"
                    step="0.1"
                    value={measurements[field] || ""}
                    onChange={(e) => setMeasurements({...measurements, [field]: e.target.value})}
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
