import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mood_controller.dart';
import 'mood_history_screen.dart';

// Konstanta skor — selaras dengan mood_history_screen
const Map<int, Color> _kScoreColors = {
  5: Color(0xFF5E9E8E),
  4: Color(0xFF8CA595),
  3: Color(0xFFA89070),
  2: Color(0xFFBF8070),
  1: Color(0xFFB86B6B),
};

const Map<int, Color> _kScoreBgColors = {
  5: Color(0xFFE5F2EF),
  4: Color(0xFFE8F0EA),
  3: Color(0xFFF3EDE3),
  2: Color(0xFFF3E8E3),
  1: Color(0xFFF2E5E5),
};

const Map<int, String> _kScoreEmojis = {
  5: '😄',
  4: '🙂',
  3: '😐',
  2: '😟',
  1: '😢',
};

const Map<int, String> _kScoreLabels = {
  5: 'Sangat Baik',
  4: 'Baik',
  3: 'Netral',
  2: 'Buruk',
  1: 'Sangat Buruk',
};

const Map<int, String> _kScoreDescriptions = {
  5: 'Kamu tampak penuh semangat dan energi hari ini!',
  4: 'Hari yang cukup baik, tetap pertahankan ya.',
  3: 'Hari yang biasa — tidak ada yang perlu dikhawatirkan.',
  2: 'Kamu mungkin sedang butuh sedikit istirahat ekstra.',
  1: 'Tidak apa-apa merasa begini. Kami mendengarkanmu.',
};

// Ikon per tag aktivitas
const Map<String, IconData> _kTagIcons = {
  'Pekerjaan': Icons.work_outline_rounded,
  'Keluarga': Icons.people_outline_rounded,
  'Istirahat': Icons.bedtime_outlined,
  'Kesehatan': Icons.favorite_outline_rounded,
  'Sosial': Icons.forum_outlined,
  'Hobi': Icons.palette_outlined,
  'Keuangan': Icons.account_balance_wallet_outlined,
  'Olahraga': Icons.directions_run_rounded,
};

// MoodScreen
class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  int _selectedScale = 3;
  final Set<String> _selectedTags = {};
  final TextEditingController _noteController = TextEditingController();

  final List<String> _availableTags = const [
    'Pekerjaan',
    'Keluarga',
    'Istirahat',
    'Kesehatan',
    'Sosial',
    'Hobi',
    'Keuangan',
    'Olahraga',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(moodControllerProvider);
    final isSubmitting = submitState.isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              _buildHeader(context),
              const SizedBox(height: 32),

              // 2. Mood Scale (Hero Section)
              _buildMoodScaleSection(context, isSubmitting),
              const SizedBox(height: 36),

              _buildDivider(context),
              const SizedBox(height: 32),

              // 3. Tag Aktivitas
              _buildTagSection(context, isSubmitting),
              const SizedBox(height: 36),

              _buildDivider(context),
              const SizedBox(height: 32),

              // 4. Catatan Mini
              _buildNoteSection(context, isSubmitting),
              const SizedBox(height: 44),

              // 5. Tombol Simpan
              _buildSubmitButton(context, isSubmitting),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: colorScheme.onSurface,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'Catat Perasaanmu',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  // Header: Tanggal + Pertanyaan
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final dateStr = '${now.day} ${months[now.month]} ${now.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            dateStr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Bagaimana perasaanmu hari ini?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tidak ada jawaban yang salah — ceritakan saja.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  // Mood Scale Section
  Widget _buildMoodScaleSection(BuildContext context, bool isSubmitting) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scoreColor = _kScoreColors[_selectedScale]!;
    final scoreBgColor = _kScoreBgColors[_selectedScale]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kartu Mood Aktif
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: scoreBgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scoreColor.withOpacity(0.22), width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Emoji besar dengan animasi ganti
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: Tween<double>(begin: 0.6, end: 1.0).animate(anim),
                  child: child,
                ),
                child: Text(
                  _kScoreEmojis[_selectedScale]!,
                  key: ValueKey(_selectedScale),
                  style: const TextStyle(fontSize: 52),
                ),
              ),
              const SizedBox(width: 16),
              // Teks label + deskripsi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kamu merasa...',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: scoreColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: Align(
                        key: ValueKey(_selectedScale),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _kScoreLabels[_selectedScale]!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: scoreColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: Text(
                        _kScoreDescriptions[_selectedScale]!,
                        key: ValueKey(_selectedScale),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: scoreColor.withOpacity(0.72),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 5 Selector Emoji
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final scale = index + 1;
            final isSelected = _selectedScale == scale;
            final color = _kScoreColors[scale]!;

            return GestureDetector(
              onTap: isSubmitting
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      setState(() => _selectedScale = scale);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                width: isSelected ? 62 : 52,
                height: isSelected ? 62 : 52,
                decoration: BoxDecoration(
                  color: isSelected ? color : colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : color.withOpacity(0.3),
                    width: isSelected ? 2.0 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _kScoreEmojis[scale]!,
                    style: TextStyle(fontSize: isSelected ? 30 : 24),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),

        // Label angka di bawah selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final scale = index + 1;
            final isSelected = _selectedScale == scale;
            final color = _kScoreColors[scale]!;
            return SizedBox(
              width: 62,
              child: Text(
                scale.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected
                      ? color
                      : colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Tag Aktivitas
  Widget _buildTagSection(BuildContext context, bool isSubmitting) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apa yang memengaruhi\nperasaanmu?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: colorScheme.onSurface,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Pilih semua yang relevan (opsional)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            final icon = _kTagIcons[tag] ?? Icons.label_outline_rounded;

            return GestureDetector(
              onTap: isSubmitting ? null : () => _toggleTag(tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.secondary
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.secondary
                        : colorScheme.primary.withOpacity(0.22),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.secondary.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected
                          ? colorScheme.surface
                          : colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      tag,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: isSelected
                            ? colorScheme.surface
                            : colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Catatan Mini
  Widget _buildNoteSection(BuildContext context, bool isSubmitting) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ada yang ingin\ndiceritakan?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: colorScheme.onSurface,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Tuliskan apa pun yang ada di pikiranmu (opsional)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.tertiary.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.tertiary, width: 1),
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 5,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontStyle: FontStyle.italic,
              fontSize: 14,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: 'Tuliskan pemikiranmu di sini...',
              hintStyle: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
              filled: false,
              contentPadding: const EdgeInsets.all(18),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            enabled: !isSubmitting,
          ),
        ),
      ],
    );
  }

  // Divider
  Widget _buildDivider(BuildContext context) => Divider(
    height: 1,
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.07),
  );

  // Tombol Simpan (gradient)
  Widget _buildSubmitButton(BuildContext context, bool isSubmitting) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.38),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : () => _handleSubmit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.surface,
          shadowColor: Colors.transparent,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isSubmitting
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: colorScheme.surface,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Simpan Catatan',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  // Handler Submit
  Future<void> _handleSubmit(BuildContext context) async {
    HapticFeedback.heavyImpact();
    final colorScheme = Theme.of(context).colorScheme;

    final success = await ref
        .read(moodControllerProvider.notifier)
        .submit(_selectedScale, _selectedTags.toList(), _noteController.text);

    if (!mounted) return;

    if (success) {
      ref.invalidate(moodHistoryProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Perasaanmu telah dicatat. Terima kasih sudah berbagi.',
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600),
          ),
          backgroundColor: colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Gagal menyimpan catatan. Coba lagi nanti.',
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600),
          ),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
    }
  }
}
