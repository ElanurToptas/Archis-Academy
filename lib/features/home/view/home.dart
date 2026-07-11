import 'package:archis_academy/features/home/widgets/video_section.dart';
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [const HomeHeroSection(),
          SizedBox(height:32),
          VideoApp(),
           SizedBox(height:32),]),
        ),
      ),
    );
  }
}

class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Yapay Zeka ve Proje\nTabanlı Yazılım Eğitimi",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            child: const Text(
              "Gerçek dünya projelerinden oluşan bir portföy oluşturarak becerilerinizi öne çıkan bir CV'de sergileyin ve Archi's Academy ile yazılım geliştirme deneyimi kazanın – üstelik uygun fiyatlarla.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0050D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "1 Haftalık Ücretsiz Denemenize Başlayın",
                  style: TextStyle(fontSize: 13),
                ),
              ),
              SizedBox(width: 8),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Demo", style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 24,
            runSpacing: 14,
            alignment: WrapAlignment.start,
            children: const [
              _FeatureItem(
                icon: Icons.school_outlined,
                text: "Uygulamalı Öğrenme",
                iconColor: Color(0xFFFF5722),
              ),
              _FeatureItem(
                icon: Icons.emoji_events_outlined,
                text: "1:1 Mentorluk",
                iconColor: Color(0xFF00BCD4),
              ),
              _FeatureItem(
                icon: Icons.rocket_launch_outlined,
                text: "Gerçek Dünya Projeleri",
                iconColor: Color(0xFF2196F3),
              ),
            ],
          ),
        ],
      ),
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
