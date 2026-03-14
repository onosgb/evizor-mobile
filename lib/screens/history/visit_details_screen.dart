import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../models/appointment.dart';

class VisitDetailsScreen extends StatelessWidget {
  final Appointment appointment;

  const VisitDetailsScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('Visit Details'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.lightBlue,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appointment.doctorName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'General Practitioner • ${dateFormat.format(appointment.scheduledAt)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (appointment.description.isNotEmpty)
              _buildSection('Description', appointment.description),
            if (appointment.symptoms.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildSection(
                  'Symptoms',
                  appointment.symptoms.map((s) => s.name).join(', '),
                ),
              ),
            if (appointment.doctorNotes?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildSection('Doctor Notes', appointment.doctorNotes!),
            ],
            const SizedBox(height: 16),
            _buildPrescriptionSection(context),
            const SizedBox(height: 24),
            CustomButton(text: 'Download Summary', onPressed: () {}),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Share',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionSection(BuildContext context) {
    // Prescriptions are usually available for completed or clinical status
    final isAvailable = appointment.status == AppointmentStatus.completed || 
                        appointment.status == AppointmentStatus.clinical;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Prescription',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              if (isAvailable)
                TextButton(
                  onPressed: () => context.push('/prescription/${appointment.id}'),
                  child: const Text('View Details'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isAvailable 
              ? 'Prescription follows the consultation details.' 
              : 'No prescription available yet.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
