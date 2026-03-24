"use client";

import { useEffect } from "react";
import { useParams, useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";

export default function ReferralCapturePage() {
  const router = useRouter();
  const params = useParams();

  useEffect(() => {
    const code = params?.code;
    if (code) {
      // Save the referral code to localStorage
      localStorage.setItem("needlix_referrer_id", String(code));
      // Redirect to the unified signup page
      router.push("/signup");
    }
  }, [params, router]);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-slate-50 text-slate-600">
      <Loader2 className="h-8 w-8 animate-spin text-[#0076B6] mb-4" />
      <p className="font-medium animate-pulse">Applying your referral code...</p>
    </div>
  );
}
