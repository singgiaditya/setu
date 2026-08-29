import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import '../../core/theme/theme_colors.dart';

class ColorPickerDialog extends StatefulWidget {
  final String title;
  final Color initialColor;
  final SetuColors appColors;

  const ColorPickerDialog({
    super.key,
    required this.title,
    required this.initialColor,
    required this.appColors,
  });

  static Future<Color?> show(
    BuildContext context, {
    required String title,
    required Color initialColor,
    required SetuColors appColors,
  }) {
    return showDialog<Color>(
      context: context,
      builder: (ctx) => ColorPickerDialog(
        title: title,
        initialColor: initialColor,
        appColors: appColors,
      ),
    );
  }

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> with SingleTickerProviderStateMixin {
  late Color _currentColor;
  late TextEditingController _hexController;
  late TabController _tabController;

  static const List<Color> _quickSwatches = [
    // Monochromes / Dark backgrounds
    Color(0xFF0D1117), Color(0xFF161B22), Color(0xFF1A1B26), Color(0xFF282828),
    Color(0xFF282A36), Color(0xFF32302F), Color(0xFFE6EDF3), Color(0xFFFFFFFF),
    // Accents / Primaries
    Color(0xFF58A6FF), Color(0xFF7AA2F7), Color(0xFFB8BB26), Color(0xFF3FB950),
    Color(0xFFFABD2F), Color(0xFFFFA657), Color(0xFFF85149), Color(0xFFBD93F9),
    Color(0xFFA371F7), Color(0xFFFF79C6), Color(0xFF8BE9FD), Color(0xFF209FB5),
  ];

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    _hexController = TextEditingController(
      text: SetuColors.colorToHex(_currentColor, includeHash: true),
    );
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _hexController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updateColor(Color newColor, {bool updateHexField = true}) {
    setState(() {
      _currentColor = newColor;
      if (updateHexField) {
        _hexController.text = SetuColors.colorToHex(newColor, includeHash: true);
      }
    });
  }

  void _onHexChanged(String val) {
    var clean = val.replaceAll('#', '').trim();
    if (clean.length == 6) {
      try {
        final c = Color(int.parse('0xFF$clean'));
        _updateColor(c, updateHexField: false);
      } catch (_) {}
    } else if (clean.length == 8) {
      try {
        final c = Color(int.parse('0x$clean'));
        _updateColor(c, updateHexField: false);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.appColors;
    final hsv = HSVColor.fromColor(_currentColor);
    final r = (_currentColor.r * 255).round();
    final g = (_currentColor.g * 255).round();
    final b = (_currentColor.b * 255).round();

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.foreground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 20, color: colors.foregroundMuted),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Color Comparison & HEX Field
              Row(
                children: [
                  // Color Swatch Comparison
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.border, width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: widget.initialColor,
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              color: Colors.black45,
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              child: const Text(
                                'Old',
                                style: TextStyle(fontSize: 8, color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: _currentColor,
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              color: Colors.black45,
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              child: const Text(
                                'New',
                                style: TextStyle(fontSize: 8, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(12),
                  // HEX Code input
                  Expanded(
                    child: TextField(
                      controller: _hexController,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'HEX CODE',
                        labelStyle: TextStyle(fontSize: 11, color: colors.foregroundMuted),
                        prefixIcon: const Icon(Icons.tag_rounded, size: 16),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.content_paste_rounded, size: 16),
                          tooltip: 'Paste Hex',
                          onPressed: () async {
                            final data = await Clipboard.getData('text/plain');
                            if (data?.text != null) {
                              _hexController.text = data!.text!;
                              _onHexChanged(data.text!);
                            }
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onChanged: _onHexChanged,
                    ),
                  ),
                ],
              ),
              const Gap(16),

              // Mode Tabs: HSV vs RGB
              TabBar(
                controller: _tabController,
                labelColor: colors.primary,
                unselectedLabelColor: colors.foregroundMuted,
                indicatorColor: colors.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'HSV Spectrum'),
                  Tab(text: 'RGB Channels'),
                ],
              ),
              const Gap(12),

              // Tab contents
              SizedBox(
                height: 150,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // HSV Sliders
                    Column(
                      children: [
                        _buildSliderRow(
                          label: 'H',
                          value: hsv.hue,
                          max: 360,
                          color: colors.primary,
                          onChanged: (v) => _updateColor(hsv.withHue(v).toColor()),
                        ),
                        _buildSliderRow(
                          label: 'S',
                          value: hsv.saturation,
                          max: 1.0,
                          color: colors.accent,
                          onChanged: (v) => _updateColor(hsv.withSaturation(v).toColor()),
                        ),
                        _buildSliderRow(
                          label: 'V',
                          value: hsv.value,
                          max: 1.0,
                          color: colors.warning,
                          onChanged: (v) => _updateColor(hsv.withValue(v).toColor()),
                        ),
                      ],
                    ),

                    // RGB Sliders
                    Column(
                      children: [
                        _buildSliderRow(
                          label: 'R',
                          value: r.toDouble(),
                          max: 255,
                          color: colors.error,
                          onChanged: (v) => _updateColor(
                            Color.fromARGB(
                              255,
                              v.round(),
                              g,
                              b,
                            ),
                          ),
                        ),
                        _buildSliderRow(
                          label: 'G',
                          value: g.toDouble(),
                          max: 255,
                          color: colors.success,
                          onChanged: (v) => _updateColor(
                            Color.fromARGB(
                              255,
                              r,
                              v.round(),
                              b,
                            ),
                          ),
                        ),
                        _buildSliderRow(
                          label: 'B',
                          value: b.toDouble(),
                          max: 255,
                          color: colors.primary,
                          onChanged: (v) => _updateColor(
                            Color.fromARGB(
                              255,
                              r,
                              g,
                              v.round(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Gap(8),
              // Preset Swatches
              Text(
                'QUICK PALETTES',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: colors.foregroundMuted,
                ),
              ),
              const Gap(8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _quickSwatches.map((swatch) {
                  final isSelected = swatch.toARGB32() == _currentColor.toARGB32();
                  return InkWell(
                    onTap: () => _updateColor(swatch),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: swatch,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? colors.primary : colors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 14,
                              color: swatch.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: colors.foregroundMuted)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_currentColor),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: const Color(0xFF0D1117),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Apply Color', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double max,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    final colors = widget.appColors;
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colors.foregroundMuted,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: value.clamp(0.0, max),
              min: 0,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            max == 1.0 ? '${(value * 100).round()}%' : value.round().toString(),
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'JetBrainsMono',
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
