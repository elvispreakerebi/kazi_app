import 'package:flutter/material.dart';
import 'app_theme.dart';

class OverviewCardData {
  final IconData icon;
  final String title;
  final String value;
  OverviewCardData({
    required this.icon,
    required this.title,
    required this.value,
  });
}

class OverviewCards extends StatelessWidget {
  final List<OverviewCardData> topCards;
  final OverviewCardData fullWidthCard;
  final VoidCallback? onClassesTap;
  final VoidCallback? onSubjectsTap;
  final VoidCallback? onLessonPlansTap;
  const OverviewCards({
    super.key,
    required this.topCards,
    required this.fullWidthCard,
    this.onClassesTap,
    this.onSubjectsTap,
    this.onLessonPlansTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: _OverviewSingleCard(
                  card: topCards[0],
                  onTap: onClassesTap,
                ),
              ),
              const SizedBox(width: 8), // 8px gap between cards
              Flexible(
                child: _OverviewSingleCard(
                  card: topCards[1],
                  onTap: onSubjectsTap,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Full width card: Lesson plans
        _OverviewSingleCard(
          card: fullWidthCard,
          onTap: onLessonPlansTap,
        ),
      ],
    );
  }
}

class _OverviewSingleCard extends StatelessWidget {
  final OverviewCardData card;
  final VoidCallback? onTap;
  const _OverviewSingleCard({required this.card, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.addClassContainerBg,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(card.icon, size: 22, color: AppTheme.inputDescription),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      card.title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                card.value,
                style: const TextStyle(
                  fontSize: 30,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
