'use client';

import React from 'react';
import { Locale, translations } from '../lib/translations';

interface FooterProps {
  locale: Locale;
}

export function Footer({ locale }: FooterProps) {
  const t = translations[locale];

  return (
    <footer className="w-full bg-surface border-t border-editorial-rule py-4 px-4 sm:px-6 no-print transition-colors mt-auto">
      <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-2 text-xs sm:text-sm text-ink-secondary">
        {/* Left side: an AI initiative by msoms.ai - 2026 */}
        <div className="font-medium">
          {t.footerInitiative}
        </div>

        {/* Right side: Platform Version 1.0.0 */}
        <div className="font-mono font-semibold text-ink-primary">
          {t.footerVersion}
        </div>
      </div>
    </footer>
  );
}
