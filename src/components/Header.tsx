'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { Locale, translations } from '../lib/translations';
import { Sun, Moon, Globe, Download } from 'lucide-react';

interface HeaderProps {
  locale: Locale;
  theme: 'light' | 'dark';
  onToggleTheme: () => void;
  onToggleLocale: () => void;
}

export function Header({ locale, theme, onToggleTheme, onToggleLocale }: HeaderProps) {
  const t = translations[locale];
  const isArabic = locale === 'ar';
  const [isStandalone, setIsStandalone] = useState(false);

  useEffect(() => {
    const standalone =
      window.matchMedia('(display-mode: standalone)').matches ||
      (window.navigator as any).standalone === true;
    setIsStandalone(standalone);
  }, []);

  const handleInstallClick = () => {
    window.dispatchEvent(new CustomEvent('open-install-prompt'));
  };

  return (
    <header className="w-full bg-surface border-b border-editorial-rule shadow-xs no-print transition-colors">
      <div className="max-w-7xl mx-auto px-3 sm:px-6 h-20 flex items-center justify-between">
        {/* Left Side: Small buttons for Light/Dark, English/Arabic, and Install App */}
        <div className="flex items-center gap-1.5 sm:gap-2">
          {/* Light/Dark Toggle */}
          <button
            onClick={onToggleTheme}
            className="flex items-center gap-1.5 px-2.5 sm:px-3 py-1.5 rounded-lg border border-editorial-rule bg-subtle hover:bg-surface text-xs font-medium text-ink-primary transition-colors shadow-2xs"
            title="Toggle Light/Dark Mode"
            aria-label="Toggle Theme"
          >
            {theme === 'dark' ? (
              <>
                <Sun className="w-4 h-4 text-amber-500" />
                <span className="hidden md:inline">{t.lightMode}</span>
              </>
            ) : (
              <>
                <Moon className="w-4 h-4 text-editorial-navy" />
                <span className="hidden md:inline">{t.darkMode}</span>
              </>
            )}
          </button>

          {/* English/Arabic Toggle */}
          <button
            onClick={onToggleLocale}
            className="flex items-center gap-1.5 px-2.5 sm:px-3 py-1.5 rounded-lg border border-editorial-rule bg-subtle hover:bg-surface text-xs font-bold text-ink-primary transition-colors shadow-2xs"
            title="Switch Language"
            aria-label="Toggle Language"
          >
            <Globe className="w-3.5 h-3.5 text-editorial-crimson" />
            <span>{isArabic ? 'English' : 'العربية'}</span>
          </button>

          {/* Install App Quick Action (hidden once installed in standalone mode) */}
          {!isStandalone && (
            <button
              onClick={handleInstallClick}
              className="flex items-center gap-1 px-2.5 sm:px-3 py-1.5 rounded-lg border border-editorial-crimson/30 bg-editorial-crimson/10 hover:bg-editorial-crimson/20 text-editorial-crimson text-xs font-bold transition-all shadow-2xs cursor-pointer"
              title={isArabic ? 'تثبيت التطبيق على شاشة هاتفك' : 'Install App'}
            >
              <Download className="w-3.5 h-3.5" />
              <span className="text-[11px] sm:text-xs">{isArabic ? 'تثبيت' : 'Install'}</span>
            </button>
          )}
        </div>

        {/* Middle: Just Logo */}
        <div className="flex items-center justify-center">
          <Link href="/" className="flex items-center justify-center group">
            <img
              src="/assets/journal_it_logo.jpg"
              alt={isArabic ? 'صَحِّف' : 'Journal it'}
              className="h-12 sm:h-16 w-auto object-contain rounded-lg border border-editorial-rule shadow-xs group-hover:opacity-95 transition-opacity"
            />
          </Link>
        </div>

        {/* Right Side: MSOMS.AI Link */}
        <div className="flex items-center">
          <a
            href="https://msoms.ai"
            target="_blank"
            rel="noopener noreferrer"
            className="text-xs sm:text-sm font-bold tracking-wider text-editorial-crimson hover:underline px-2.5 sm:px-3 py-1.5 rounded-lg border border-transparent hover:border-editorial-rule transition-colors"
          >
            {t.msomsLink}
          </a>
        </div>
      </div>
    </header>
  );
}
