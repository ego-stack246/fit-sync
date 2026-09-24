import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NutritionScannerScreen extends StatefulWidget {
  const NutritionScannerScreen({super.key});

  @override
  State<NutritionScannerScreen> createState() => _NutritionScannerScreenState();
}

class _NutritionScannerScreenState extends State<NutritionScannerScreen> {
  bool _isAnalyzing = false;
  bool _hasResult = true;

  String _foodName = "Paneer Tikka with Mint Chutney";
  double _calories = 240.0;
  double _protein = 16.0;
  double _carbs = 8.0;
  double _fat = 16.0;
  String _portion = "6 pieces (approx. 150g)";
  double _confidence = 0.94;

  void _scanMeal() async {
    setState(() {
      _isAnalyzing = true;
      _hasResult = false;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _hasResult = true;
      _foodName = "Moong Dal Tadka with 2 Rotis";
      _calories = 373.0;
      _protein = 14.7;
      _carbs = 68.0;
      _fat = 5.5;
      _portion = "1 medium bowl dal + 2 chapatis";
      _confidence = 0.92;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Nutrition Scanner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scanner Viewport Card
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.fastfood_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
                  if (_isAnalyzing)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(color: Colors.greenAccent),
                        SizedBox(height: 12),
                        Text("Analyzing Indian Food Geometry & Macros...", style: TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    )
                  else
                    Positioned(
                      bottom: 16,
                      child: Row(
                        children: [
                          FilledButton.icon(
                            onPressed: _scanMeal,
                            icon: const Icon(Icons.camera_alt_rounded),
                            label: const Text("Scan Food"),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: _scanMeal,
                            icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                            label: const Text("Upload", style: TextStyle(color: Colors.white)),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white30)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Indian Food Safety Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.amber.shade900, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Estimates are for general guidance and wellness only, not medically exact dietary prescriptions.",
                      style: TextStyle(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_hasResult) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _foodName,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Text(
                              "Confidence: ${(_confidence * 100).toInt()}%",
                              style: TextStyle(color: Colors.green.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("Portion: $_portion", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      const Divider(height: 24),

                      // Macro Grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMacroItem("Calories", "${_calories.toInt()}", "kcal", Colors.amber.shade800),
                          _buildMacroItem("Protein", "${_protein.toStringAsFixed(1)}", "g", Colors.red.shade700),
                          _buildMacroItem("Carbs", "${_carbs.toStringAsFixed(1)}", "g", Colors.blue.shade700),
                          _buildMacroItem("Fat", "${_fat.toStringAsFixed(1)}", "g", Colors.orange.shade700),
                        ],
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("$_foodName added to daily nutrition log!")),
                            );
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text("Log Meal to Daily Diary"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(width: 2),
            Text(unit, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}

