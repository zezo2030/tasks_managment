import 'package:flutter/material.dart';
import 'dart:math' as math;

/// هذا الكلاس يقوم بإنشاء تأثير الكونفيتي (قصاصات ملونة متساقطة) عند إكمال العادة
/// يستقبل لون العادة لاستخدامه ضمن ألوان الكونفيتي
class ConfettiAnimation extends StatelessWidget {
  /// لون العادة الذي سيتم استخدامه في الكونفيتي
  final Color habitColor;

  /// المُنشئ يتطلب لون العادة كمعامل إلزامي
  const ConfettiAnimation({super.key, required this.habitColor});

  @override
  Widget build(BuildContext context) {
    // استخدام IgnorePointer لتجاهل التفاعلات مع الكونفيتي
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          // إنشاء 30 قطعة من الكونفيتي
          children: List.generate(30, (index) {
            // إنشاء مولد أرقام عشوائية لكل قطعة
            final random = math.Random();
            // تحديد حجم عشوائي لكل قطعة بين 5 و 15
            final size = random.nextDouble() * 10 + 5;
            // تحديد موقع أفقي عشوائي لبداية سقوط القطعة
            final initialPosition =
                random.nextDouble() * MediaQuery.of(context).size.width;
            // اختيار لون عشوائي من مجموعة ألوان تتضمن لون العادة
            final color =
                [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.yellow,
                  Colors.purple,
                  Colors.orange,
                  habitColor,
                ][random.nextInt(7)];

            // وضع كل قطعة في موقعها المبدئي
            return Positioned(
              left: initialPosition,
              top: -20,
              // استخدام TweenAnimationBuilder لتحريك القطعة من أعلى إلى أسفل
              child: TweenAnimationBuilder(
                // تحديد مسار الحركة من 0 إلى ارتفاع الشاشة
                tween: Tween<double>(
                  begin: 0,
                  end: MediaQuery.of(context).size.height + 50,
                ),
                // مدة الحركة عشوائية بين 1.5 و 3.5 ثانية
                duration: Duration(milliseconds: 1500 + random.nextInt(2000)),
                // نمط الحركة بتسارع تدريجي
                curve: Curves.easeOutQuad,
                builder: (context, double value, child) {
                  // تحريك القطعة مع إضافة حركة متموجة أفقياً
                  return Transform.translate(
                    offset: Offset(
                      initialPosition + math.sin(value / 50) * 20,
                      value,
                    ),
                    // دوران القطعة أثناء السقوط
                    child: Transform.rotate(angle: value / 30, child: child!),
                  );
                },
                // شكل القطعة النهائي
                child: Opacity(
                  opacity: 0.7, // شفافية جزئية
                  child: Container(
                    width: size,
                    height: size,
                    // تحديد شكل القطعة بشكل عشوائي (دائرة أو مربع)
                    decoration:
                        random.nextBool()
                            ? BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            )
                            : BoxDecoration(
                              color: color,
                              // بعض المربعات لها زوايا دائرية والبعض الآخر لا
                              borderRadius:
                                  random.nextBool()
                                      ? BorderRadius.circular(2)
                                      : null,
                            ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
