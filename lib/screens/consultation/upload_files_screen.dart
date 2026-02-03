import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:image_picker/image_picker.dart'; // Removed for design phase
// import 'dart:io'; // Removed for design phase
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/toastification.dart';
import '../../widgets/custom_button.dart';

class UploadFilesScreen extends StatefulWidget {
  const UploadFilesScreen({super.key});

  @override
  State<UploadFilesScreen> createState() => _UploadFilesScreenState();
}

class _UploadFilesScreenState extends State<UploadFilesScreen> {
  // final ImagePicker _picker = ImagePicker(); // Removed for design phase
  final List<String> _uploadedFiles =
      []; // Using String for design phase instead of File

  Future<void> _pickImage(String source) async {
    // Image picker temporarily disabled for design phase
    infoSnack('Image picker coming soon');
    // Simulate file upload for design
    setState(() {
      _uploadedFiles.add('image_${_uploadedFiles.length + 1}.jpg');
    });
  }

  Future<void> _pickDocument() async {
    // Document picker temporarily disabled for design phase
    infoSnack('Document picker coming soon');
    // Simulate file upload for design
    setState(() {
      _uploadedFiles.add('document_${_uploadedFiles.length + 1}.pdf');
    });
  }

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    const Text(
                      'Upload Files',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      'Add medical records or images (optional)',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
                    // Upload Options
                    Row(
                      children: [
                        Expanded(
                          child: _buildUploadOption(
                            icon: Icons.camera_alt,
                            label: 'Camera',
                            backgroundColor: const Color(
                              0xFFE3F2FD,
                            ), // Light blue
                            iconColor: AppColors.primaryColor,
                            textColor: AppColors.primaryColor,
                            onTap: () => _pickImage('camera'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildUploadOption(
                            icon: Icons.photo_library,
                            label: 'Gallery',
                            backgroundColor: const Color(
                              0xFFE8F5E9,
                            ), // Light green
                            iconColor: AppColors.primaryGreen,
                            textColor: AppColors.primaryGreen,
                            onTap: () => _pickImage('gallery'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildUploadOption(
                            icon: Icons.insert_drive_file,
                            label: 'Document',
                            backgroundColor: const Color(
                              0xFFF3E5F5,
                            ), // Light purple
                            iconColor: AppColors.primaryPurple,
                            textColor: AppColors.primaryPurple,
                            onTap: _pickDocument,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Uploaded Files Preview
                    if (_uploadedFiles.isNotEmpty) ...[
                      const Text(
                        'Uploaded Files',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: _uploadedFiles.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundGrey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _uploadedFiles[index].endsWith('.pdf')
                                            ? Icons.description
                                            : Icons.image,
                                        size: 40,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _uploadedFiles[index],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeFile(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Continue Button and Skip Link
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CustomButton(
                    text: 'Continue',
                    onPressed: () {
                      context.push(AppRoutes.reviewConfirm);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.push(AppRoutes.reviewConfirm);
                    },
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
