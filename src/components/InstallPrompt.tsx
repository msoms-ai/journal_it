'use client';

import React, { useState, useEffect } from 'react';
import Image from 'next/image';
import { Download, Share2, PlusSquare, MoreVertical, X } from 'lucide-react';
import { Locale, translations } from '../lib/translations';

interface InstallPromptProps {
  locale: Locale;
}

export default function InstallPrompt({ locale }: InstallPromptProps) {
  const [showPrompt, setShowPrompt] = useState(false);
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null);
  const [isIOS, setIsIOS] = useState(false);
  const [isStandalone, setIsStandalone] = useState(false);
  const [showGuide, setShowGuide] = useState(false);

  const t = translations[locale];

  useEffect(() => {
    // 1. Check if already running in standalone / PWA mode
    const isStandaloneMode =
      window.matchMedia('(display-mode: standalone)').matches ||
      (window.navigator as any).standalone === true ||
      document.referrer.includes('android-app://');

    setIsStandalone(isStandaloneMode);
    if (isStandaloneMode) return;

    // 2. Check dismissal cooldown (dismissed within last 2 days)
    const dismissedAt = localStorage.getItem('sahhef_install_dismissed');
    if (dismissedAt) {
      const elapsed = Date.now() - parseInt(dismissedAt, 10);
      if (elapsed < 2 * 24 * 60 * 60 * 1000) {
        return;
      }
    }

    // 3. Detect device
    const ua = window.navigator.userAgent.toLowerCase();
    const isIosDevice = /iphone|ipad|ipod/.test(ua) && !(window as any).MSStream;
    const isMobile = /android|iphone|ipad|ipod|mobile|blackberry|iemobile|opera mini/i.test(ua);

    setIsIOS(isIosDevice);

    // 4. Check if prompt was already captured by early script
    if ((window as any).deferredInstallPrompt) {
      setDeferredPrompt((window as any).deferredInstallPrompt);
      setShowPrompt(true);
    }

    // 5. Handlers for prompt capture
    const handleBeforeInstallPrompt = (e: Event) => {
      e.preventDefault();
      setDeferredPrompt(e);
      (window as any).deferredInstallPrompt = e;
      setShowPrompt(true);
    };

    const handlePromptReady = () => {
      if ((window as any).deferredInstallPrompt) {
        setDeferredPrompt((window as any).deferredInstallPrompt);
        setShowPrompt(true);
      }
    };

    window.addEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
    window.addEventListener('pwa-prompt-ready', handlePromptReady);

    // 6. On mobile browsers, show banner after short delay
    const timer = setTimeout(() => {
      if (isMobile && !isStandaloneMode) {
        setShowPrompt(true);
      }
    }, 2000);

    return () => {
      window.removeEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
      window.removeEventListener('pwa-prompt-ready', handlePromptReady);
      clearTimeout(timer);
    };
  }, []);

  const handleInstallClick = async () => {
    const promptObj = deferredPrompt || (window as any).deferredInstallPrompt;

    if (promptObj) {
      try {
        await promptObj.prompt();
        const choice = await promptObj.userChoice;
        if (choice && choice.outcome === 'accepted') {
          setShowPrompt(false);
        }
      } catch (err) {
        console.error('Install prompt trigger error:', err);
      }
      setDeferredPrompt(null);
      (window as any).deferredInstallPrompt = null;
    } else {
      // Toggle manual instructions guide smoothly without intrusive alert
      setShowGuide((prev) => !prev);
    }
  };

  const handleDismiss = () => {
    setShowPrompt(false);
    localStorage.setItem('sahhef_install_dismissed', Date.now().toString());
  };

  if (!showPrompt || isStandalone) {
    return null;
  }

  return (
    <div className="fixed bottom-3 inset-x-3 sm:inset-x-auto sm:end-6 sm:bottom-6 sm:max-w-md z-50 animate-fadeIn no-print">
      <div className="bg-surface/95 backdrop-blur-md border-2 border-editorial-rule shadow-2xl rounded-2xl p-4 sm:p-5 text-ink-primary">
        {/* Header row: Logo, Titles, and Close Button */}
        <div className="flex items-start gap-3">
          {/* Platform Official Icon */}
          <div className="relative w-12 h-12 rounded-xl overflow-hidden border-2 border-editorial-crimson/30 shadow-xs flex-shrink-0 bg-white">
            <Image
              src="/icons/icon-192.png"
              alt={t.appName}
              width={48}
              height={48}
              className="w-full h-full object-cover"
              priority
            />
          </div>

          {/* Texts */}
          <div className="flex-1 min-w-0">
            <div className="flex items-center justify-between gap-2">
              <h4 className="font-extrabold text-sm sm:text-base text-ink-primary truncate">
                {t.installTitle}
              </h4>
              <button
                type="button"
                onClick={handleDismiss}
                className="text-ink-secondary hover:text-editorial-crimson p-1 rounded-lg transition-colors flex-shrink-0"
                aria-label="Close"
              >
                <X className="w-4 h-4" />
              </button>
            </div>
            <p className="text-xs text-ink-secondary mt-0.5 leading-relaxed line-clamp-2">
              {t.installSubtitle}
            </p>
          </div>
        </div>

        {/* Step-by-Step Visual Guide for iOS or Manual Browser Menu */}
        {showGuide && (
          <div className="mt-3 p-3 bg-subtle/90 rounded-xl border border-editorial-rule text-xs space-y-2 animate-fadeIn">
            {isIOS ? (
              <>
                <div className="flex items-center gap-2 text-ink-primary font-medium">
                  <span className="w-5 h-5 rounded-full bg-editorial-crimson text-white flex items-center justify-center font-bold text-[10px] flex-shrink-0">
                    1
                  </span>
                  <span>{t.installIosStep1}</span>
                  <Share2 className="w-3.5 h-3.5 text-editorial-crimson inline" />
                </div>
                <div className="flex items-center gap-2 text-ink-primary font-medium">
                  <span className="w-5 h-5 rounded-full bg-editorial-crimson text-white flex items-center justify-center font-bold text-[10px] flex-shrink-0">
                    2
                  </span>
                  <span>{t.installIosStep2}</span>
                  <PlusSquare className="w-3.5 h-3.5 text-editorial-navy inline" />
                </div>
              </>
            ) : (
              <>
                <div className="flex items-center gap-2 text-ink-primary font-medium">
                  <span className="w-5 h-5 rounded-full bg-editorial-crimson text-white flex items-center justify-center font-bold text-[10px] flex-shrink-0">
                    1
                  </span>
                  <span>{t.installAndroidStep1}</span>
                  <MoreVertical className="w-3.5 h-3.5 text-editorial-crimson inline" />
                </div>
                <div className="flex items-center gap-2 text-ink-primary font-medium">
                  <span className="w-5 h-5 rounded-full bg-editorial-crimson text-white flex items-center justify-center font-bold text-[10px] flex-shrink-0">
                    2
                  </span>
                  <span>{t.installAndroidStep2}</span>
                  <Download className="w-3.5 h-3.5 text-editorial-navy inline" />
                </div>
              </>
            )}
          </div>
        )}

        {/* Action Buttons */}
        <div className="mt-3 pt-3 border-t border-editorial-rule flex items-center justify-end gap-2">
          <button
            type="button"
            onClick={handleDismiss}
            className="px-3 py-1.5 rounded-xl text-xs font-semibold text-ink-secondary hover:bg-subtle transition-colors"
          >
            {t.installNotNow}
          </button>

          <button
            type="button"
            onClick={handleInstallClick}
            className="px-4 py-2 rounded-xl bg-editorial-crimson hover:opacity-95 text-white font-bold text-xs sm:text-sm shadow-xs flex items-center gap-1.5 transition-transform active:scale-95 cursor-pointer"
          >
            <Download className="w-3.5 h-3.5" />
            <span>{t.installBtn}</span>
          </button>
        </div>
      </div>
    </div>
  );
}
