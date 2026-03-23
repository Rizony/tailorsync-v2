import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Needlix — Professional Tailoring Management & Marketplace",
  description:
    "Needlix is the all-in-one platform for professional tailors and their clients. Track orders, manage measurements, pay securely, and find the best tailors in our marketplace.",
  keywords: ["tailor shop management", "fashion designer app", "tailor marketplace", "measurement tracker", "secure tailor payments", "Needlix"],
  openGraph: {
    title: "Needlix — Professional Tailoring & Marketplace",
    description: "The #1 platform for modern tailors. Manage your shop, track jobs, and find clients.",
    url: "https://needlix.com",
    siteName: "Needlix",
    images: [
      {
        url: "/og-image.png", // Ensure this exists or I'll need to help create a placeholder
        width: 1200,
        height: 630,
      },
    ],
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Needlix — Professional Tailoring & Marketplace",
    description: "The #1 platform for modern tailors. Manage your shop, track jobs, and find clients.",
    images: ["/og-image.png"],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
