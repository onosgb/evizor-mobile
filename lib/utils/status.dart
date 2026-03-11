import 'package:evizor/models/appointment.dart';
import 'package:evizor/utils/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildStatusBadge(AppointmentStatus status) {
  Color color;
  String label;
  IconData icon;

  switch (status) {
    case AppointmentStatus.completed:
      color = AppColors.primaryGreen;
      label = 'Completed';
      icon = Icons.check_circle;
      break;
    case AppointmentStatus.clinical:
    case AppointmentStatus.scheduled:
      color = AppColors.info;
      label = 'Scheduled';
      icon = Icons.calendar_today;
      break;
    case AppointmentStatus.progress:
      color = AppColors.warning;
      label = 'In Progress';
      icon = Icons.hourglass_top;
      break;
    case AppointmentStatus.cancelled:
      color = AppColors.error;
      label = 'Cancelled';
      icon = Icons.cancel;
      break;

    default:
      color = AppColors.textSecondary;
      label = 'Unknown';
      icon = Icons.help_outline;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
