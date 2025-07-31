import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/widgets/gradient_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: Padding(
        padding: _mainScreenPadding.add(
          EdgeInsets.only(bottom: UiConstant.spaceAtBottom),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                GradientText(
                  gradientColors: GradientColorConstant.vibrantGradient,
                  text: "Settle Now",
                  textSize: 50,
                  letterSpacing: 1.5,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Designed & Developed',
                  style: TextStyle(
                    fontSize: 15,
                    letterSpacing: 0.8,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'By Rohit Anand',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        launchUrl(
                          Uri.parse("mailto:info@settlenow.in"),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.envelope,
                        size: 28,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {
                        launchUrl(
                          Uri.parse("http://github.com/rranand"),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.github,
                        size: 28,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {
                        launchUrl(
                          Uri.parse(
                            "https://www.linkedin.com/in/rohitanand99/",
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.linkedin,
                        size: 28,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  '© 2022-${DateTime.now().year.toString().substring(2, 4)} All rights reserved',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
