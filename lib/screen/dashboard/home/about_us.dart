import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:settlenow/constant/gradient_color_constant.dart';
import 'package:settlenow/constant/ui_constant.dart';
import 'package:settlenow/provider/screen_size_provider.dart';
import 'package:settlenow/util/widgets/gradient_widget.dart';
import 'package:settlenow/util/widgets/widgets.dart';
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
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(
                  UiConstant.cardBorderRadius,
                ),
                boxShadow: getContainerBoxShadow(context),
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
                    style: TextStyle(fontSize: 15, letterSpacing: 0.8),
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
                      InkWell(
                        borderRadius: BorderRadius.circular(
                          UiConstant.cardBorderRadius,
                        ),
                        onTap: () {
                          launchUrl(
                            Uri.parse("mailto:support@settlenow.in"),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: SvgPicture.asset(
                          "assets/icon/email.svg",
                          width: 28,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).iconTheme.color!,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        borderRadius: BorderRadius.circular(
                          UiConstant.cardBorderRadius,
                        ),
                        onTap: () {
                          launchUrl(
                            Uri.parse("http://github.com/rranand"),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: SvgPicture.asset(
                          "assets/icon/github.svg",
                          width: 28,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).iconTheme.color!,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        borderRadius: BorderRadius.circular(
                          UiConstant.cardBorderRadius,
                        ),
                        onTap: () {
                          launchUrl(
                            Uri.parse(
                              "https://www.linkedin.com/in/rohitanand99/",
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: SvgPicture.asset(
                          "assets/icon/linkedin.svg",
                          width: 28,
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
      ),
    );
  }
}
