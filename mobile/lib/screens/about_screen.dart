import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_theme.dart';

class PlatformItem {
  final String titleAr;
  final String titleEn;
  final String descAr;
  final String descEn;
  final String url;
  final IconData icon;

  const PlatformItem({
    required this.titleAr,
    required this.titleEn,
    required this.descAr,
    required this.descEn,
    required this.url,
    required this.icon,
  });
}

class AboutScreen extends StatelessWidget {
  final bool isArabic;

  const AboutScreen({
    super.key,
    required this.isArabic,
  });

  static const List<PlatformItem> platforms = [
    PlatformItem(
      titleAr: 'منصة Documator',
      titleEn: 'Documator Platform',
      descAr: 'تحويل المستندات الثابتة إلى مستندات تفاعلية ديناميكية ذكية',
      descEn: 'Static to dynamic intelligent document creator',
      url: 'https://documate.msoms.ai',
      icon: Icons.document_scanner_outlined,
    ),
    PlatformItem(
      titleAr: 'منصة Subtie',
      titleEn: 'Subtie Anime AI',
      descAr: 'المترجم الذكي لأعمال الأنمي والميديا بأحدث تقنيات الذكاء الاصطناعي',
      descEn: 'The Anime AI Subtitler powered by state-of-the-art AI',
      url: 'https://subtie.msoms.ai',
      icon: Icons.subtitles_outlined,
    ),
    PlatformItem(
      titleAr: 'منصة Fansubs.tv',
      titleEn: 'Fansubs.tv Community',
      descAr: 'الوجهة الأولى لمترجمي الفانسب العربي لنشر ومشاركة أعمالهم',
      descEn: 'The ultimate destination for Arabic Fansubbers to deploy & share',
      url: 'https://www.fansubs.tv',
      icon: Icons.ondemand_video_outlined,
    ),
    PlatformItem(
      titleAr: 'منصة قصص (QISAS)',
      titleEn: 'QISAS Story Generator',
      descAr: 'توليد القصص المصورة والناطقة للأطفال وتحويل النصوص إلى قصص ممتعة',
      descEn: 'Smart Children Story Generator with visuals and narration',
      url: 'https://sg.msoms.ai',
      icon: Icons.auto_stories_outlined,
    ),
  ];

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'تعذر فتح الرابط' : 'Could not open link'),
            backgroundColor: AppTheme.crimson,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'تعذر فتح الرابط' : 'Could not open link'),
            backgroundColor: AppTheme.crimson,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t ? 'عن المنصة ومبادراتنا' : 'About Sahhef & Initiatives',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Center Logo
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: AppTheme.crimson.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text(
                      'صَحِّف',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.crimson,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // App Brand Name & Badge
            const Text(
              'صَحِّف | Journal it',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.crimson,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.crimson.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                t ? 'المنظومة الصحفية الذكية' : 'Intelligent Newsroom System',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.crimson,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description: Why Sahhef was made
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mic_external_on, color: AppTheme.crimson, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        t ? 'لماذا صُممت منصة «صَحِّف»؟' : 'Why Sahhef Was Built',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t
                        ? '«صَحِّف» هي أداة ذكية متخصصة لغرف الأخبار والصحفيين والمراسلين الميدانيين في دولة الإمارات العربية المتحدة. صُممت المنصة لتفريغ المقابلات والمؤتمرات الصحفية المتعددة الأصوات بدقة فائقة، مع الحفاظ الصارم على أسماء وهوّيات المتحدثين، وصياغة البيانات الشفوية والتسجيلات مباشرة إلى تقارير إخبارية موحدة تتطابق مع أرقى المعايير المهنية لوكالة أنباء الإمارات (وام).'
                        : 'Sahhef is an intelligent editorial platform built specifically for newsrooms, journalists, and field correspondents in the UAE. It transcribes multi-speaker press conferences and recordings with high fidelity, preserving real speaker identities and instantly synthesizing verbatim statements into official UAE news wire dispatches aligned with WAM agency standards.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description: MSOMS.AI Initiatives
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hub_outlined, color: AppTheme.navy, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        t ? 'مبادرات MSOMS.AI' : 'MSOMS.AI Initiatives',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t
                        ? 'تلتزم MSOMS.AI ببناء وتطوير منظومات ذكاء اصطناعي سيادية ومبتكرة لخدمة دولة الإمارات والعالم العربي، وتسخير تقنيات النماذج التوليدية لتمكين الصحافة، التعليم، الإبداع الرقمي، وأتمتة الوثائق بكفاءة عربية أصيلة.'
                        : 'MSOMS.AI is dedicated to developing sovereign, high-impact AI platforms tailored to serve the UAE and the Arab world, empowering journalism, education, digital storytelling, and document automation with cutting-edge AI.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Platforms Header
            Align(
              alignment: t ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                t ? 'منصات ومشاريع MSOMS.AI الشقيقة' : 'MSOMS.AI Sister Platforms',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2 x 2 Platform Cards Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: platforms.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final item = platforms[index];
                return InkWell(
                  onTap: () => _openUrl(context, item.url),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.crimson.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item.icon,
                            color: AppTheme.crimson,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t ? item.titleAr : item.titleEn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            t ? item.descAr : item.descEn,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.35,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              t ? 'زيارة المنصة' : 'Visit',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.crimson,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.arrow_outward,
                              size: 13,
                              color: AppTheme.crimson,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            // Footer copyright
            Text(
              '© ${DateTime.now().year} MSOMS.AI • All Rights Reserved',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
