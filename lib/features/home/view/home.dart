import 'package:archis_academy/features/home/widgets/video_section.dart';
import 'package:archis_academy/product/init/language/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: SvgPicture.asset('assets/images/logo.svg', height: 32),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const HomeHeroSection(),
            SizedBox(height: 32),
            VideoApp(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    const verticalSpacing = SizedBox(height: 24);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          LocaleKeys.home_heroTitle.tr(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        verticalSpacing,

        SizedBox(
          child: Text(
            LocaleKeys.home_heroDescription.tr(),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        verticalSpacing,

        Row(
          children: [
            _HeroButton(
              text: LocaleKeys.home_ctaTrial.tr(),
              onPressed: () => debugPrint("Trial tapped"),
              isPrimary: true,
            ),
            const SizedBox(width: 8),
            _HeroButton(
              text: LocaleKeys.home_ctaDemo.tr(),
              onPressed: () => debugPrint("Demo tapped"),
            ),
          ],
        ),
        verticalSpacing,

        Wrap(
          spacing: 24,
          runSpacing: 14,
          alignment: WrapAlignment.start,
          children: [
            _FeatureItem(
              icon: Icons.school_outlined,
              text: LocaleKeys.home_features_appliedLearning.tr(),
              iconColor: const Color(0xFFFF5722),
            ),
            _FeatureItem(
              icon: Icons.emoji_events_outlined,
              text: LocaleKeys.home_features_mentorSupport.tr(),
              iconColor: const Color(0xFF00BCD4),
            ),
            _FeatureItem(
              icon: Icons.rocket_launch_outlined,
              text: LocaleKeys.home_features_realProjects.tr(),
              iconColor: const Color(0xFF2196F3),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _HeroButton({
    required this.text,
    this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF0050D9) : Colors.white,
        foregroundColor: isPrimary ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const _FeatureItem({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}
