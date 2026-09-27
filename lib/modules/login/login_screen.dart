import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import 'login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      resizeToAvoidBottomInset: true,
      body: Obx(() => Stack(
        children: [
          Positioned(
            top: -size.width * 0.35,
            right: -size.width * 0.30,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.maroon.withOpacity(0.14), AppTheme.maroon.withOpacity(0.0)]),
              ),
            ),
          ),
          Positioned(
            top: -size.width * 0.15,
            left: -size.width * 0.25,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFFE8A93B).withOpacity(0.10), Colors.transparent]),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(left: 28, right: 28, top: size.height * 0.08, bottom: bottomInset > 0 ? 24 : size.height * 0.06),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height * 0.86),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CherryMark(),
                    const SizedBox(height: 42),
                    const Text(
                      "Speak with\nconfidence",
                      style: TextStyle(
                        fontSize: 34,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.maroon,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Live 1-on-1 sessions with expert English tutors, whenever you're ready.",
                      style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black.withOpacity(0.55), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 60),

                    Text(
                      "Mobile number",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withOpacity(0.45),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _PhoneField(
                      controller: controller.phoneController,
                      isValid: controller.isValid.value,
                      onSubmitted: (_) => controller.sendOtp(),
                      enabled: !controller.authController.isLoading.value,
                    ),
                    const SizedBox(height: 24),

                    _SendOtpButton(
                        enabled: controller.isValid.value && !controller.authController.isLoading.value,
                        loading: controller.authController.isLoading.value,
                        onPressed: controller.sendOtp),
                    const SizedBox(height: 20),

                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: "By continuing, you agree to our ",
                          style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.45), height: 1.5),
                          children: [
                            TextSpan(
                              text: "Terms",
                              style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.w700),
                            ),
                            const TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class _CherryMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 64, height: 64, child: CustomPaint(painter: _CherryPainter()));
  }
}

class _CherryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stemPaint = Paint()
      ..color = const Color(0xFF4E8B5C)
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final leftFruit = Paint()..color = AppTheme.maroon;
    final rightFruit = Paint()..color = const Color(0xFFC41E3A);
    final highlight = Paint()..color = Colors.white.withOpacity(0.35);

    final stemTop = Offset(size.width * 0.52, size.height * 0.06);
    final leftAnchor = Offset(size.width * 0.30, size.height * 0.52);
    final rightAnchor = Offset(size.width * 0.68, size.height * 0.46);

    final leftStem = Path()
      ..moveTo(stemTop.dx, stemTop.dy)
      ..quadraticBezierTo(size.width * 0.30, size.height * 0.10, leftAnchor.dx, leftAnchor.dy);
    final rightStem = Path()
      ..moveTo(stemTop.dx, stemTop.dy)
      ..quadraticBezierTo(size.width * 0.70, size.height * 0.14, rightAnchor.dx, rightAnchor.dy);

    canvas.drawPath(leftStem, stemPaint);
    canvas.drawPath(rightStem, stemPaint);

    canvas.drawCircle(Offset(leftAnchor.dx, leftAnchor.dy + 12), 15, leftFruit);
    canvas.drawCircle(Offset(rightAnchor.dx, rightAnchor.dy + 14), 17, rightFruit);

    canvas.drawCircle(Offset(leftAnchor.dx - 5, leftAnchor.dy + 7), 3, highlight);
    canvas.drawCircle(Offset(rightAnchor.dx - 6, rightAnchor.dy + 8), 3.5, highlight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;
  final ValueChanged<String> onSubmitted;
  final bool enabled;

  const _PhoneField({required this.controller, required this.isValid, required this.onSubmitted, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isValid ? AppTheme.maroon.withOpacity(0.55) : Colors.black.withOpacity(0.08), width: isValid ? 1.4 : 1),
        boxShadow: [BoxShadow(color: AppTheme.maroon.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 12),
            child: Text(
              "🇮🇳  +91",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.maroon),
            ),
          ),
          Container(width: 1, height: 22, color: Colors.black.withOpacity(0.08)),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              enabled: enabled,
              maxLength: 10,
              textInputAction: TextInputAction.done,
              onSubmitted: onSubmitted,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.4),
              decoration: const InputDecoration(
                counterText: "",
                hintText: "98765 43210",
                hintStyle: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFB8ACAE)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 14),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: isValid ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.check_circle_rounded, color: AppTheme.maroon, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _SendOtpButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  const _SendOtpButton({required this.enabled, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: enabled ? [AppTheme.maroon, const Color(0xFFC41E3A)] : [const Color(0xFFD8CFC9), const Color(0xFFD8CFC9)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: enabled ? [BoxShadow(color: AppTheme.maroon.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))] : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation(Colors.white)),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Send OTP",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: enabled ? Colors.white : Colors.black.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18, color: enabled ? Colors.white : Colors.black.withOpacity(0.4)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
