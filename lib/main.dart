import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'homepage.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0x00000000),
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const GigafyApp());
}

class GigafyApp extends StatefulWidget {
  const GigafyApp({super.key});

  @override
  State<GigafyApp> createState() => _GigafyAppState();
}

class _GigafyAppState extends State<GigafyApp> {
  bool isDark = true;
  bool showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        showSplash = false;
      });
    });
  }

  void toggleTheme(bool value) {
    setState(() {
      isDark = value;
    });
  }

  void _showTeamDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Gigafy Team"),
          content: Column(
            children: const [
              SizedBox(height: 15),
              Text("Jiro Gonzales"),
              Text("Nicole Joyce"),
              Text("Nicole Ashley"),
              Text("Jenah Anne"),
              SizedBox(height: 15),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("Close"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    required Color color,
    VoidCallback? onTap,
  }) {
    return CupertinoListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ]
        ),
        child: Icon(icon, size: 18, color: CupertinoColors.white),
      ),
      trailing: trailing,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: "Gigafy",
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primaryColor: CupertinoColors.activeBlue,
        scaffoldBackgroundColor: isDark
            ? const Color(0xFF000000)
            : const Color(0xFFF2F2F7),
        barBackgroundColor: isDark
            ? const Color(0xFF1C1C1E).withOpacity(0.9)
            : const Color(0xF9FFFFFF).withOpacity(0.9),
      ),
      home: showSplash
          ? const SplashScreen()
          : CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            backgroundColor: isDark
                ? const Color(0xFF1C1C1E).withOpacity(0.9)
                : const Color(0xF9FFFFFF).withOpacity(0.9),
            border: Border(
              top: BorderSide(
                color: CupertinoColors.separator.resolveFrom(context).withOpacity(0.3),
                width: 0.5,
              ),
            ),
            activeColor: CupertinoColors.activeBlue,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.waveform), label: "Storage"),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.settings_solid), label: "Settings"),
            ],
          ),
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return const CupertinoPageScaffold(child: Homepage());
              default:
                return CupertinoPageScaffold(
                  backgroundColor: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGroupedBackground, context),
                  child: CustomScrollView(
                    slivers: [
                      const CupertinoSliverNavigationBar(
                        largeTitle: Text("Settings"),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          CupertinoListSection.insetGrouped(
                              header: const Text("General"),
                              children: [
                                _buildTile(
                                  icon: CupertinoIcons.cloud_fill,
                                  title: "Current Plan",
                                  trailing: const Text("Free Tier", style: TextStyle(color: CupertinoColors.systemGrey)),
                                  color: CupertinoColors.systemBlue,
                                ),
                                _buildTile(
                                  icon: CupertinoIcons.moon_fill,
                                  title: "Dark Mode",
                                  trailing: CupertinoSwitch(
                                    value: isDark,
                                    onChanged: (v) => toggleTheme(v),
                                  ),
                                  color: CupertinoColors.systemIndigo,
                                ),
                              ]
                          ),
                          CupertinoListSection.insetGrouped(
                              header: const Text("Information"),
                              children: [
                                _buildTile(
                                  icon: CupertinoIcons.person_2_fill,
                                  title: "About Team",
                                  trailing: const Icon(CupertinoIcons.chevron_forward, color: CupertinoColors.systemGrey),
                                  color: CupertinoColors.systemGreen,
                                  onTap: () => _showTeamDialog(context),
                                ),
                              ]
                          )
                        ]),
                      )
                    ],
                  ),
                );
            }
          }),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.activeBlue,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ]
              ),
              child: const Icon(CupertinoIcons.waveform_circle_fill,
                  color: CupertinoColors.activeBlue, size: 70),
            ),
            const SizedBox(height: 25),
            const Text(
              "Gigafy",
              style: TextStyle(
                fontFamily: '.SF Pro Display',
                color: CupertinoColors.white,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 10),
            const CupertinoActivityIndicator(
                color: CupertinoColors.white, radius: 14)
          ],
        ),
      ),
    );
  }}