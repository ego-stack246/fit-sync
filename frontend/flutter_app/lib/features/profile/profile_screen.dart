import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _useCloudAI = true;
  bool _preferOfflineEdge = true;
  String _selectedTone = "Calm";
  double _voiceSpeed = 1.0;
  double _voicePitch = 1.0;
  String _retentionPref = "30 Days";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings & Privacy"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                radius: 28,
                child: Icon(Icons.person, size: 32),
              ),
              title: const Text("Shivam Patel", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: const Text("shivam@fitsync.ai • Beginner Level"),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Voice Modulation Settings (Mandated Section 11)
          Text("AI Voice Coaching Modulation", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Coaching Tone / Persona", style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ["Calm", "Energetic", "Professional", "Friendly"].map((tone) {
                      final isSelected = _selectedTone == tone;
                      return ChoiceChip(
                        label: Text(tone),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _selectedTone = tone),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text("Speech Speed (${_voiceSpeed.toStringAsFixed(1)}x)"),
                  Slider(
                    value: _voiceSpeed,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    onChanged: (val) => setState(() => _voiceSpeed = val),
                  ),
                  Text("Speech Pitch (${_voicePitch.toStringAsFixed(1)})"),
                  Slider(
                    value: _voicePitch,
                    min: 0.8,
                    max: 1.2,
                    divisions: 4,
                    onChanged: (val) => setState(() => _voicePitch = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Privacy & Edge AI Settings (Section 15)
          Text("Privacy & AI Routing", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.shield_outlined),
                  title: const Text("Zero Video Cloud Upload", style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text("Guaranteed: Camera streams are computed strictly on-device."),
                  value: true,
                  onChanged: null, // Immutable strict privacy rule
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.cloud_outlined),
                  title: const Text("Enable Cloud Gemini for Complex Plans"),
                  subtitle: const Text("Sends only text prompts to cloud LLM for multi-day analysis."),
                  value: _useCloudAI,
                  onChanged: (val) => setState(() => _useCloudAI = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.offline_bolt_outlined),
                  title: const Text("Prefer On-Device Edge AI"),
                  subtitle: const Text("Process simple queries and workouts offline."),
                  value: _preferOfflineEdge,
                  onChanged: (val) => setState(() => _preferOfflineEdge = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Account & Data Sovereignty
          Text("Data Sovereignty & Account", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text("Export My Fitness Data"),
                  subtitle: const Text("Download workout sessions and nutrition logs in JSON format."),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Exporting data to device storage...")),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: const Text("Delete Account & All Biometric Data", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  subtitle: const Text("Permanently erase all profile, workout metrics, and logs."),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Delete All Data?"),
                        content: const Text("This action cannot be undone. All workout logs and profile details will be completely wiped from the device and server."),
                        actions: [
                          TextButton(onPressed: () => ctx.pop(), child: const Text("Cancel")),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () {
                              ctx.pop();
                              context.go('/auth');
                            },
                            child: const Text("Confirm Deletion"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text("Log Out"),
                  onTap: () => context.go('/auth'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

