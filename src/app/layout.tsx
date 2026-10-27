import React from 'react';
import type { Metadata, Viewport } from 'next';
import '../styles/globals.css';

export const metadata: Metadata = {
  title: 'صَحِّف | Journal it',
  description: 'منصة التحرير الإخباري الذكية — msoms.ai',
  manifest: '/manifest.json',
  icons: {
    icon: '/assets/journal_it_logo.jpg',
    apple: '/assets/journal_it_logo.jpg',
  },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 5,
  themeColor: '#8B0000',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ar" dir="rtl" suppressHydrationWarning>
      <body className="min-h-screen flex flex-col selection:bg-editorial-crimson selection:text-white">
        {children}
      </body>
    </html>
  );
}
