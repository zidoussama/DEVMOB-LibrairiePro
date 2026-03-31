import 'package:flutter/material.dart';
import '../../../Config/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String title;
  final String greeting;
  final VoidCallback onNotificationTap;

  const HomeHeader({
    super.key,
    required this.title,
    required this.greeting,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _NotificationButton(onTap: onNotificationTap),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NotificationButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: AppColors.background, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
