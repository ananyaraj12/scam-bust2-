import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/constants.dart';
import '../services/overlay_service.dart';
import '../services/notification_listener.dart';
import '../services/scam_processor.dart';

// ✅ Add these imports
import '../localization/translator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<Map<String, dynamic>>? _subscription;
  final ScamProcessor _scamProcessor = ScamProcessor();

  DateTime _lastOverlayShown = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _overlayCooldown = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /* ---------------- INITIAL SETUP ---------------- */

  Future<void> _initialize() async {
    await _requestPermissions();
    await _scamProcessor.init();
    _startNotificationListener();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.sms,
      Permission.notification,
      Permission.systemAlertWindow,
    ].request();
  }

  void _startNotificationListener() {
    _subscription = NotificationListenerService.notifications.listen(
      (event) async {
        if (!mounted) return;

        final title = (event['title'] ?? '') as String;
        final text = (event['text'] ?? '') as String;

        final message = [title, text].where((e) => e.isNotEmpty).join(' - ');
        if (message.isEmpty) return;

        try {
          final probability = await _scamProcessor.checkScamProbability(message);

          if (probability > 0.5 && _canShowOverlay()) {
            _lastOverlayShown = DateTime.now();
            await OverlayService.showScamOverlay(message);
          }
        } catch (_) {
          // Fail silently (background-safe)
        }
      },
      onError: (_) {},
    );
  }

  bool _canShowOverlay() {
    return DateTime.now().difference(_lastOverlayShown).compareTo(_overlayCooldown) > 0;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /* ---------------- LANGUAGE SWITCH ---------------- */

  void _setLanguage(String langCode) {
    Translator.setLang(langCode).then((_) {
      if (mounted) setState(() {});
    });
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(Translator.t("app_title")),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        actions: [
          // ✅ Language Dropdown (Hindi / Bengali / Odia)
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: Translator.currentLang,
              icon: const Icon(Icons.language, color: Colors.white),
              dropdownColor: AppColors.primary,
              items: const [
                DropdownMenuItem(
                  value: "en",
                  child: Text("English", style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: "hi",
                  child: Text("Hindi", style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: "bn",
                  child: Text("Bengali", style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: "or",
                  child: Text("Odia", style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (value) {
                if (value != null) _setLanguage(value);
              },
            ),
          ),

          IconButton(
            tooltip: Translator.t("notification_access"),
            icon: const Icon(Icons.notifications_active),
            onPressed: () async {
              await NotificationListenerService.openNotificationSettings();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(Translator.t("opened_notification_settings"))),
                );
              }
            },
          ),
          IconButton(
            tooltip: Translator.t("overlay_permission"),
            icon: const Icon(Icons.layers),
            onPressed: () async {
              final granted = await OverlayService.requestOverlayPermission();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      granted
                          ? Translator.t("overlay_granted")
                          : Translator.t("overlay_not_granted"),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await OverlayService.showScamOverlay(
            Translator.t("test_scam_message"),
          );
        },
        backgroundColor: AppColors.danger,
        child: const Icon(Icons.warning),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildStatusCard(),
            const SizedBox(height: 30),
            _buildNavigationGrid(context),
            const Spacer(),
            _buildSOSButton(),
          ],
        ),
      ),
    );
  }

  /* ---------------- COMPONENTS ---------------- */

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.shield,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 15),
          Text(
            Translator.t("system_active"),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Translator.t("scanning_realtime"),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationGrid(BuildContext context) {
    return Row(
      children: [
        _menuItem(
          context,
          Translator.t("scam_log"),
          Icons.history,
          Colors.blue,
        ),
        const SizedBox(width: 15),
        _menuItem(
          context,
          Translator.t("safe_list"),
          Icons.verified_user,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _menuItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSOSButton() {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {},
        icon: const Icon(
          Icons.phone_android,
          color: Colors.white,
        ),
        label: Text(
          Translator.t("sos_alert_family"),
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
