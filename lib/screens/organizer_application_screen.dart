import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/src/models/organizer_request.dart';
import 'package:my_app/src/services/organizer_service.dart';

class OrganizerApplicationScreen extends StatefulWidget {
  const OrganizerApplicationScreen({Key? key}) : super(key: key);

  @override
  State<OrganizerApplicationScreen> createState() =>
      _OrganizerApplicationScreenState();
}

class _OrganizerApplicationScreenState
    extends State<OrganizerApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  String? _verificationId;
  bool _phoneVerified = false;
  bool _sendingOtp = false;
  bool _submitting = false;

  @override
  void dispose() {
    _orgController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    setState(() => _sendingOtp = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          setState(() => _phoneVerified = true);
        } catch (_) {}
      },
      verificationFailed: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
      },
      codeSent: (verificationId, resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('OTP sent')));
      },
      codeAutoRetrievalTimeout: (id) {
        _verificationId = id;
      },
    );
    setState(() => _sendingOtp = false);
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (_verificationId == null || otp.isEmpty) return;
    final cred = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    try {
      await FirebaseAuth.instance.signInWithCredential(cred);
      setState(() => _phoneVerified = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Phone verified')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OTP verify failed: $e')));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final now = DateTime.now().toUtc().toIso8601String();
    final req = OrganizerRequest(
      id: '',
      uid: FirebaseAuth.instance.currentUser?.uid ?? '',
      organizationName: _orgController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      phoneVerified: _phoneVerified,
      status: 'submitted',
      submittedAt: now,
      university: null,
      experience: null,
    );
    try {
      final docId = await OrganizerService.submitRequest(req);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application submitted')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Submit failed: $e')));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizer Application')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _orgController,
                decoration: const InputDecoration(
                  labelText: 'Organization name',
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v?.contains('@') ?? false) ? null : 'Enter a valid email',
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (E.164, e.g. +15551234567)',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _sendingOtp ? null : _sendOtp,
                    child: _sendingOtp
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send OTP'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _otpController,
                      decoration: const InputDecoration(labelText: 'OTP'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _verifyOtp,
                    child: const Text('Verify'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const CircularProgressIndicator()
                    : const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
