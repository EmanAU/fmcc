import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:doctor_app/src/core/theme/app_colors.dart';
import 'package:doctor_app/src/features/patients/presenting_complaint_cache.dart';

/// Draft presenting complaint for the next visit (SharedPreferences only).
class PresentingComplaintPage extends StatefulWidget {
  const PresentingComplaintPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  final String patientId;
  final String patientName;

  @override
  State<PresentingComplaintPage> createState() => _PresentingComplaintPageState();
}

class _PresentingComplaintPageState extends State<PresentingComplaintPage> {
  final _controller = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final existing =
        await PresentingComplaintCache.load(widget.patientId) ?? '';
    if (!mounted) return;
    _controller.text = existing;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _toast('Enter a presenting complaint.');
      return;
    }
    if (text.length > PresentingComplaintCache.maxLength) {
      _toast(
        'Maximum ${PresentingComplaintCache.maxLength} characters allowed.',
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await PresentingComplaintCache.save(widget.patientId, text);
      if (!mounted) return;
      _toast('Presenting complaint saved for visit.');
      Navigator.of(context).pop();
    } on ArgumentError catch (e) {
      if (!mounted) return;
      _toast(e.message?.toString() ?? 'Could not save complaint.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = _controller.text.characters.length;
    final over = count > PresentingComplaintCache.maxLength;

    return Scaffold(
      backgroundColor: AppColors.registrationScreenBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        title: Text(
          'Presenting Complaint',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.patientName.trim().isEmpty
                          ? 'Patient'
                          : widget.patientName.trim(),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Saved on this device for the next visit assessment. '
                      'It is sent with the visit and then cleared.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            PresentingComplaintCache.maxLength,
                          ),
                        ],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Describe the patient\'s complaint…',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: EdgeInsets.all(14.w),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: BorderSide(
                              color: AppColors.registrationFieldBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: BorderSide(
                              color: AppColors.registrationFieldBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: BorderSide(
                              color: AppColors.dashboardPrimary,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$count / ${PresentingComplaintCache.maxLength}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: over
                              ? AppColors.danger
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.registrationSaveBlue,
                        foregroundColor: AppColors.surface,
                        minimumSize: Size(double.infinity, 52.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        _saving ? 'Saving…' : 'Save complaint',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
