"use client";

import { motion } from "framer-motion";
import { ArrowRight, CheckCircle2, ChevronRight, Play, Scissors, Search, ShieldCheck, Star, Users } from "lucide-react";
import Image from "next/image";
import Link from "next/link";

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-slate-50 font-sans text-slate-900 selection:bg-[#00AEEF] selection:text-white">
      {/* Navigation */}
      <nav className="fixed left-0 right-0 top-0 z-50 glass-panel border-b border-white/20">
        <div className="mx-auto flex h-20 max-w-7xl items-center justify-between px-6 lg:px-8">
          <Link href="/" className="flex items-center gap-3">
            <Image
              src="/logo.png"
              alt="Needlix Logo"
              width={220}
              height={66}
              className="needlix-logo h-10 sm:h-12 md:h-14 w-auto object-contain"
              priority
            />
          </Link>
          <div className="flex items-center gap-3 sm:gap-6">
            <Link href="#features" className="hidden text-sm font-semibold text-slate-600 transition-colors hover:text-[#0076B6] sm:block">
              Features
            </Link>
            <Link href="#community" className="hidden text-sm font-semibold text-slate-600 transition-colors hover:text-[#0076B6] sm:block">
              Community
            </Link>
            <Link href="/marketplace" className="hidden text-sm font-semibold text-[#0076B6] transition-colors hover:text-[#00AEEF] sm:flex items-center gap-1.5">
              <Search className="h-4 w-4" />
              Find a Tailor
            </Link>
            <Link
              href="/login"
              className="inline-flex items-center justify-center rounded-full border border-slate-200 bg-white px-3 sm:px-5 py-2 text-xs sm:text-sm font-bold text-slate-700 hover:bg-slate-50"
            >
              Client Login
            </Link>
            <Link
              href="/signup"
              className="inline-flex items-center justify-center rounded-full bg-[#0A1128] px-3 sm:px-5 py-2 text-xs sm:text-sm font-bold text-white hover:bg-[#0076B6] transition-colors"
            >
              Sign up
            </Link>
            <a
              href="#download"
              className="group relative inline-flex items-center justify-center gap-2 overflow-hidden rounded-full bg-[#0076B6] px-6 py-2.5 text-sm font-semibold text-white shadow-md transition-all hover:bg-[#00AEEF] hover:shadow-lg hover:shadow-[#00AEEF]/30 focus:outline-none focus:ring-2 focus:ring-[#00AEEF] focus:ring-offset-2"
            >
              <span>Get the App</span>
              <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
            </a>
          </div>
        </div>
      </nav>

      <main>
        {/* Hero Section */}
        <section className="relative overflow-hidden pt-32 pb-20 lg:pt-48 lg:pb-32">
          {/* Background Gradient Orbs */}
          <div className="absolute -top-[20%] right-[-10%] h-[600px] w-[600px] rounded-full bg-gradient-to-br from-[#00AEEF]/20 to-[#0076B6]/5 blur-3xl" />
          <div className="absolute -left-[10%] top-[40%] h-[500px] w-[500px] rounded-full bg-gradient-to-tr from-[#0076B6]/10 to-transparent blur-3xl" />

          <div className="mx-auto max-w-7xl px-6 lg:px-8 relative z-10">
            <div className="grid gap-16 lg:grid-cols-2 lg:gap-8 items-center">
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6 }}
                className="max-w-2xl"
              >
                <div className="inline-flex items-center gap-2 rounded-full border border-[#00AEEF]/30 bg-[#00AEEF]/10 px-4 py-1.5 mb-8">
                  <span className="flex h-2 w-2 rounded-full bg-[#00AEEF] animate-pulse" />
                  <span className="text-sm font-semibold text-[#0076B6]">The Ultimate Tool for Tailors</span>
                </div>

                <h1 className="text-5xl font-extrabold tracking-tight text-[#0A1128] sm:text-7xl lg:text-7xl mb-8 leading-[1.1]">
                  Connect &amp; <br />
                  <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#0076B6] to-[#00AEEF]">Create.</span>
                </h1>

                <p className="text-lg leading-8 text-slate-600 mb-10 max-w-lg">
                  Elevate your fashion business with Needlix. Track orders, manage customer measurements, send PDF invoices, and join an exclusive tailor community—all from your smartphone.
                </p>

                <div className="flex flex-col sm:flex-row gap-4">
                  <a
                    href="#download"
                    className="inline-flex items-center justify-center gap-2 rounded-2xl bg-[#0076B6] px-8 py-4 text-lg font-bold text-white shadow-xl shadow-[#0076B6]/20 transition-all hover:-translate-y-1 hover:bg-[#00AEEF] hover:shadow-2xl hover:shadow-[#00AEEF]/40"
                  >
                    Download Now Free
                  </a>
                  <Link
                    href="/marketplace"
                    className="inline-flex items-center justify-center gap-2 rounded-2xl bg-white px-8 py-4 text-lg font-bold text-slate-900 border border-slate-200 shadow-sm transition-all hover:bg-slate-50 hover:border-[#0076B6] hover:text-[#0076B6]"
                  >
                    <Search className="h-5 w-5 text-[#00AEEF]" />
                    Find a Tailor
                  </Link>
                </div>

                {/* Client Portal CTA (make it obvious) */}
                <div className="mt-6 rounded-3xl border border-slate-200 bg-white/70 backdrop-blur-md p-5 shadow-sm">
                  <div className="flex items-start gap-3">
                    <div className="h-10 w-10 rounded-2xl bg-[#00AEEF]/10 flex items-center justify-center flex-shrink-0">
                      <ShieldCheck className="h-5 w-5 text-[#0076B6]" />
                    </div>
                    <div className="flex-1">
                      <p className="text-sm font-extrabold text-[#0A1128]">Client Portal (Web)</p>
                      <p className="text-sm text-slate-600 mt-1">
                        Sign up to track requests, pay securely, and rate your tailor — right from your browser.
                      </p>
                      <div className="mt-4 flex flex-col sm:flex-row gap-3">
                        <Link
                          href="/signup"
                          className="inline-flex items-center justify-center gap-2 rounded-2xl bg-[#0A1128] px-6 py-3 text-sm font-bold text-white hover:bg-[#0076B6] transition-colors"
                        >
                          Create Client Account <ArrowRight className="h-4 w-4" />
                        </Link>
                        <Link
                          href="/login"
                          className="inline-flex items-center justify-center gap-2 rounded-2xl border border-slate-200 bg-white px-6 py-3 text-sm font-bold text-slate-700 hover:bg-slate-50"
                        >
                          Login <ChevronRight className="h-4 w-4" />
                        </Link>
                        <Link
                          href="/client"
                          className="inline-flex items-center justify-center gap-2 rounded-2xl border border-[#00AEEF]/30 bg-[#00AEEF]/10 px-6 py-3 text-sm font-bold text-[#0076B6] hover:bg-[#00AEEF]/15"
                        >
                          Track your job <ChevronRight className="h-4 w-4" />
                        </Link>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="mt-12 flex items-center gap-4 text-sm text-slate-500 font-medium">
                  <div className="flex -space-x-2">
                    {[1, 2, 3, 4].map((i) => (
                      <div key={i} className="h-8 w-8 rounded-full border-2 border-white bg-slate-200" />
                    ))}
                  </div>
                  <p>Trusted by <span className="text-[#0A1128] font-bold">1,000+</span> tailors in Africa.</p>
                </div>
              </motion.div>

              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.8, delay: 0.2 }}
                className="relative mx-auto w-full max-w-lg lg:max-w-none"
              >
                {/* Decorative Elements around "Phone" */}
                <div className="hidden sm:block absolute -left-12 top-20 z-20 animate-float-delayed glass-panel p-4 rounded-2xl shadow-xl border border-white/40">
                  <div className="flex items-center gap-3">
                    <div className="h-10 w-10 rounded-full bg-green-100 flex items-center justify-center">
                      <CheckCircle2 className="h-5 w-5 text-green-600" />
                    </div>
                    <div>
                      <p className="text-sm font-bold text-slate-900">Invoice Paid</p>
                      <p className="text-xs text-slate-500">₦25,000 via Flutterwave</p>
                    </div>
                  </div>
                </div>

                <div className="hidden sm:block absolute -right-8 bottom-32 z-20 animate-float glass-panel p-4 rounded-2xl shadow-xl border border-white/40">
                  <div className="flex items-center gap-3">
                    <div className="h-10 w-10 rounded-full bg-[#00AEEF]/10 flex items-center justify-center">
                      <Users className="h-5 w-5 text-[#00AEEF]" />
                    </div>
                    <div>
                      <p className="text-sm font-bold text-slate-900">New Referral</p>
                      <p className="text-xs text-slate-500">+ ₦1,000 Commission</p>
                    </div>
                  </div>
                </div>

                {/* Abstract Phone Mockup */}
                <div className="relative aspect-[1/2] w-full max-w-[320px] mx-auto rounded-[3rem] bg-[#0A1128] p-3 shadow-2xl ring-1 ring-slate-900/10">
                  <div className="absolute top-4 left-1/2 h-6 w-32 -translate-x-1/2 rounded-full bg-black z-20" />
                  <div className="h-full w-full overflow-hidden rounded-[2.5rem] bg-slate-50 relative">
                    {/* App Mockup UI */}
                    <div className="absolute inset-0 bg-gradient-to-b from-[#0076B6] to-[#00AEEF]">
                      <div className="p-6 pt-16 text-white pb-32">
                        <h3 className="text-2xl font-bold mb-1">Hi, Designer!</h3>
                        <p className="text-cyan-100/80 mb-6 text-sm">Here&apos;s your shop overview</p>

                        <div className="bg-white/10 backdrop-blur-md rounded-2xl p-5 border border-white/20 mb-6">
                          <p className="text-white/70 text-sm mb-1">Wallet Balance</p>
                          <h4 className="text-4xl font-bold">₦14,500</h4>
                        </div>

                        <div className="space-y-3">
                          {[1, 2, 3].map((i) => (
                            <div key={i} className="bg-white rounded-xl p-4 shadow-sm flex items-center justify-between">
                              <div className="flex items-center gap-3">
                                <div className="h-10 w-10 rounded-full bg-slate-100 flex items-center justify-center">
                                  <Scissors className="h-5 w-5 text-slate-400" />
                                </div>
                                <div>
                                  <h5 className="font-bold text-slate-900 text-sm">Order #{1040 + i}</h5>
                                  <p className="text-xs text-slate-500">In Progress</p>
                                </div>
                              </div>
                              <ChevronRight className="h-5 w-5 text-slate-300" />
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </motion.div>
            </div>
          </div>
        </section>

        {/* Marketplace Section */}
        <section id="marketplace" className="relative overflow-hidden py-24 sm:py-32 bg-gradient-to-b from-white to-slate-50">
          <div className="mx-auto max-w-7xl px-6 lg:px-8">
            <div className="grid gap-12 lg:grid-cols-2 items-center">
              {/* Left: Text */}
              <motion.div
                initial={{ opacity: 0, x: -20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6 }}
              >
                <div className="inline-flex items-center gap-2 rounded-full border border-orange-200 bg-orange-50 px-4 py-1.5 mb-6">
                  <Search className="h-4 w-4 text-orange-500" />
                  <span className="text-sm font-semibold text-orange-600">Tailor Marketplace — New!</span>
                </div>
                <h2 className="text-4xl font-extrabold tracking-tight text-[#0A1128] sm:text-5xl mb-6 leading-tight">
                  Find the Perfect Tailor,<br />
                  <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#0076B6] to-[#00AEEF]">Near You.</span>
                </h2>
                <p className="text-lg text-slate-600 leading-relaxed mb-8">
                  Browse verified, professional tailors and fashion designers. Filter by specialty, check real ratings, and send a job request directly — all from your browser. No app needed.
                </p>

                <div className="space-y-4 mb-10">
                  {[
                    { text: 'Search by specialty (suits, ankara, wedding, etc.)', icon: CheckCircle2 },
                    { text: 'View real tailor profiles with bio & availability', icon: CheckCircle2 },
                    { text: 'Send job requests — tailors respond via the app', icon: CheckCircle2 },
                    { text: 'Premium & verified designers listed first', icon: Star },
                  ].map((item) => (
                    <div key={item.text} className="flex items-center gap-3">
                      <item.icon className="h-5 w-5 text-[#00AEEF] flex-shrink-0" />
                      <span className="text-slate-700 font-medium">{item.text}</span>
                    </div>
                  ))}
                </div>

                <Link
                  href="/marketplace"
                  className="group inline-flex items-center justify-center gap-3 rounded-2xl bg-[#0076B6] px-8 py-4 text-lg font-bold text-white shadow-xl shadow-[#0076B6]/20 transition-all hover:-translate-y-1 hover:bg-[#00AEEF] hover:shadow-2xl hover:shadow-[#00AEEF]/30"
                >
                  Browse the Marketplace
                  <ArrowRight className="h-5 w-5 transition-transform group-hover:translate-x-1" />
                </Link>
              </motion.div>

              {/* Right: Preview Cards */}
              <motion.div
                initial={{ opacity: 0, x: 20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: 0.2 }}
                className="space-y-4"
              >
                {[
                  { name: "Adire Design Studio", specialty: "Ankara & Traditional Wear", rating: "4.9", tier: "premium", available: true },
                  { name: "Classic Cuts Atelier", specialty: "Corporate Suits & Menswear", rating: "4.7", tier: "standard", available: true },
                  { name: "Belle Couture", specialty: "Bridal & Evening Gowns", rating: "4.8", tier: "premium", available: false },
                ].map((tailor) => (
                  <div key={tailor.name} className="bg-white rounded-2xl p-5 shadow-md border border-slate-100 flex items-center gap-4 hover:shadow-lg transition-all hover:-translate-y-0.5">
                    <div className="h-14 w-14 rounded-xl bg-gradient-to-br from-[#0076B6] to-[#00AEEF] flex items-center justify-center flex-shrink-0 shadow-md">
                      <Scissors className="h-7 w-7 text-white" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-0.5">
                        <p className="font-bold text-slate-900 truncate">{tailor.name}</p>
                        {tailor.tier === "premium" && (
                          <span className="flex-shrink-0 flex items-center gap-0.5 rounded-full bg-orange-500 px-2 py-0.5 text-[9px] font-bold text-white">
                            <Star className="h-2.5 w-2.5 fill-current" /> PREMIUM
                          </span>
                        )}
                      </div>
                      <p className="text-sm text-slate-500 truncate">{tailor.specialty}</p>
                      <div className="flex items-center gap-3 mt-1">
                        <span className="flex items-center gap-1 text-xs font-bold text-amber-500">
                          <Star className="h-3 w-3 fill-current" /> {tailor.rating}
                        </span>
                        <span className={`text-xs font-bold ${tailor.available ? 'text-green-600' : 'text-slate-400'}`}>
                          {tailor.available ? '● Accepting Orders' : '○ Fully Booked'}
                        </span>
                      </div>
                    </div>
                    <ChevronRight className="h-5 w-5 text-slate-300 flex-shrink-0" />
                  </div>
                ))}

                <div className="text-center pt-2">
                  <Link href="/marketplace" className="text-sm font-bold text-[#0076B6] hover:text-[#00AEEF] transition-colors inline-flex items-center gap-1">
                    View all tailors <ArrowRight className="h-4 w-4" />
                  </Link>
                </div>
              </motion.div>
            </div>
          </div>
        </section>

        {/* Features Section */}
        <section id="features" className="bg-white py-24 sm:py-32">
          <div className="mx-auto max-w-7xl px-6 lg:px-8">
            <div className="mx-auto max-w-2xl lg:text-center mb-16">
              <h2 className="text-base font-semibold leading-7 text-[#00AEEF]">Everything you need</h2>
              <p className="mt-2 text-3xl font-bold tracking-tight text-[#0A1128] sm:text-4xl">
                Run your fashion business like a pro
              </p>
            </div>

            <div className="mx-auto max-w-2xl lg:max-w-none">
              <div className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-16 lg:max-w-none lg:grid-cols-3">
                {[
                  {
                    title: 'Customer Management',
                    description: 'Store precise measurements, contact details, and past orders securely in the cloud. Never lose a notebook again.',
                    icon: Users,
                  },
                  {
                    title: 'Professional Invoices',
                    description: 'Generate and send beautiful PDF invoices and quotations to your clients instantly via WhatsApp or Email.',
                    icon: ShieldCheck,
                  },
                  {
                    title: 'Referral Program',
                    description: 'Earn passive income! Upgrade to Premium and earn up to 40% commission when you refer other tailors to Needlix.',
                    icon: Scissors,
                  },
                ].map((feature) => (
                  <div key={feature.title} className="flex flex-col bg-slate-50 rounded-3xl p-8 border border-slate-100 hover:shadow-lg transition-shadow">
                    <div className="mb-6 flex h-14 w-14 items-center justify-center rounded-2xl bg-gradient-to-br from-[#0076B6] to-[#00AEEF] shadow-lg shadow-[#00AEEF]/20">
                      <feature.icon className="h-6 w-6 text-white" aria-hidden="true" />
                    </div>
                    <h3 className="text-xl font-bold text-[#0A1128] mb-3">{feature.title}</h3>
                    <p className="text-slate-600 leading-relaxed flex-auto">{feature.description}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* Download Section */}
        <section id="download" className="relative overflow-hidden bg-[#0A1128] py-24 sm:py-32">
          <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-20 mix-blend-overlay"></div>
          <div className="absolute top-0 right-0 h-full w-1/2 bg-gradient-to-l from-[#00AEEF]/10 to-transparent blur-3xl"></div>

          <div className="relative mx-auto max-w-7xl px-6 lg:px-8 text-center">
            <h2 className="text-3xl font-bold tracking-tight text-white sm:text-5xl mb-6">
              Ready to Upgrade Your Craft?
            </h2>
            <p className="mx-auto max-w-2xl text-lg text-slate-300 mb-10">
              Join the fastest-growing community of tailors and fashion designers. Available now on Android.
            </p>
            <div className="flex flex-col sm:flex-row justify-center gap-4">
              <button className="inline-flex items-center justify-center gap-3 rounded-2xl bg-white px-8 py-4 text-left shadow-xl transition-transform hover:scale-105">
                <svg className="w-8 h-8 text-slate-900" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M17.523 15.3414C17.5029 12.5539 19.8252 11.2036 19.9255 11.1333C18.636 9.2436 16.6329 8.94817 15.9625 8.86801C14.2882 8.68744 12.6441 9.85108 11.7816 9.85108C10.929 9.85108 9.57463 8.88806 8.16999 8.91817C6.34366 8.94817 4.67789 9.98135 3.73451 11.6263C1.81775 14.9665 3.2428 19.9015 5.11949 22.6186C6.03264 23.9421 7.10626 25.4362 8.52136 25.376C9.89632 25.3157 10.4282 24.4735 12.0836 24.4735C13.7388 24.4735 14.2205 25.376 15.6558 25.3458C17.1311 25.3157 18.0645 23.9922 18.9678 22.6587C20.0215 21.1246 20.453 19.6305 20.4731 19.5503C20.4228 19.5302 17.543 18.4369 17.523 15.3414V15.3414Z" />
                  <path d="M12.0637 5.75336C12.8259 4.83063 13.3377 3.53664 13.1973 2.22266C12.0733 2.27282 10.6885 2.97491 9.90605 3.88761C9.20392 4.69018 8.59223 6.01429 8.75276 7.30829C10.0072 7.40859 11.3018 6.67635 12.0637 5.75336V5.75336Z" />
                </svg>
                <div>
                  <div className="text-[10px] font-bold tracking-wider text-slate-500 uppercase">Download on the</div>
                  <div className="text-xl font-bold text-slate-900 -mt-1">App Store</div>
                </div>
              </button>

              <button className="inline-flex items-center justify-center gap-3 rounded-2xl bg-white px-8 py-4 text-left shadow-xl transition-transform hover:scale-105">
                <svg className="w-8 h-8 text-slate-900" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M3.609 1.814L13.792 11.997L3.609 22.181C3.415 21.986 3.275 21.725 3.275 21.416V2.576C3.275 2.268 3.414 2.01 3.609 1.814ZM14.862 13.067L18.239 16.444L20.245 15.313C21.411 14.656 21.411 13.593 20.245 12.936L18.239 11.805L14.862 13.067ZM4.685 1.488L14.12 10.923L16.657 8.386L5.352 2.028C4.858 1.748 4.708 1.666 4.685 1.488ZM5.352 21.968L16.657 15.61L14.12 13.073L4.685 22.508C4.708 22.33 4.858 22.248 5.352 21.968Z" />
                </svg>
                <div>
                  <div className="text-[10px] font-bold tracking-wider text-slate-500 uppercase">Get it on</div>
                  <div className="text-xl font-bold text-slate-900 -mt-1">Google Play</div>
                </div>
              </button>
            </div>
            <p className="mt-8 text-sm text-slate-500 opacity-60">Web Dashboard available for Subscribed members.</p>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-slate-100 py-12">
        <div className="mx-auto max-w-7xl px-6 lg:px-8 flex flex-col items-center justify-between gap-6 sm:flex-row">
          <div className="flex items-center gap-2">
            <Image
              src="/logo.png"
              alt="Needlix Logo"
              width={160}
              height={48}
              className="needlix-logo h-8 md:h-10 w-auto object-contain"
            />
          </div>
          <div className="flex items-center gap-6 text-sm text-slate-500">
            <Link href="/marketplace" className="hover:text-[#0076B6] font-medium transition-colors">Marketplace</Link>
            <Link href="/client" className="hover:text-[#0076B6] font-medium transition-colors">Client Portal</Link>
            <Link href="#features" className="hover:text-[#0076B6] font-medium transition-colors">Features</Link>
            <Link href="#download" className="hover:text-[#0076B6] font-medium transition-colors">Download</Link>
          </div>
          <p className="text-sm text-slate-500">
            &copy; {new Date().getFullYear()} Needlix App. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}
