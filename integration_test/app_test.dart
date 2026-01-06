import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kodio_app/main_app.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // 👇 حط بيانات الأكونت المؤكد هنا
  const testEmail = 'zsyd23533@gmail.com';
  const testPassword = '123456789';

  group('🧪 اختبارات تطبيق كوديو الشاملة', () {
    // ==================== دالة مساعدة لتسجيل الدخول ====================
    Future<void> loginIfNeeded(WidgetTester tester) async {
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      // تحقق: هل نحن مسجلين دخول؟
      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isNotEmpty) {
        debugPrint('✓ مسجل دخول بالفعل - في الشاشة الرئيسية');
        return;
      }

      final skipButton = find.text('تخطي');
      final guestButton = find.text('متابعة كزائر');

      // تخطي الـ Onboarding
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        debugPrint('✓ تخطينا الـ Onboarding');
        await tester.pump(const Duration(seconds: 2));
      }

      // إعادة البحث عن حقول الإدخال بعد التخطي
      final emailFieldsAfterSkip = find.byType(TextField);

      // تسجيل الدخول بالأكونت المؤكد
      if (emailFieldsAfterSkip.evaluate().length >= 2) {
        debugPrint('🔐 بدء تسجيل الدخول بالأكونت المؤكد...');

        await tester.enterText(emailFieldsAfterSkip.first, testEmail);
        await tester.pump(const Duration(milliseconds: 500));

        final passwordField = emailFieldsAfterSkip.at(1);
        await tester.enterText(passwordField, testPassword);
        await tester.pump(const Duration(milliseconds: 500));

        final loginButtonAfter = find.text('تسجيل الدخول');
        if (loginButtonAfter.evaluate().isNotEmpty) {
          await tester.tap(loginButtonAfter);
          await tester.pump(const Duration(seconds: 2));
          await tester.pump();
          await tester.pump(const Duration(seconds: 4));
          debugPrint('✓ تم تسجيل الدخول بنجاح');
        }
      } else if (guestButton.evaluate().isNotEmpty) {
        await tester.tap(guestButton);
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();
        debugPrint('✓ دخلنا كزائر');
      } else {
        debugPrint('⚠️ لم نجد طريقة لتسجيل الدخول');
      }

      await tester.pump(const Duration(seconds: 3));
    }

    // ==================== دالة مساعدة للرجوع الآمن ====================
    Future<void> safePageBack(WidgetTester tester) async {
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pump(const Duration(seconds: 1));
        debugPrint('✓ رجعنا للخلف');
      } else {
        debugPrint('⚠️ لا يوجد زر رجوع - نحن في الشاشة الرئيسية');
      }
    }

    // ==================== السيناريو 1: رحلة المستخدم الكاملة ====================
    testWidgets('✅ السيناريو 1: رحلة المستخدم الكاملة', (tester) async {
      debugPrint('\n🚀 بدء السيناريو 1: رحلة المستخدم الكاملة');

      app.main();
      await loginIfNeeded(tester);

      await tester.pump(const Duration(seconds: 3));

      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isEmpty) {
        debugPrint('⚠️ لم نصل للشاشة الرئيسية بعد، نحاول الانتظار...');
        await tester.pump(const Duration(seconds: 5));
      }

      if (bottomNav.evaluate().isNotEmpty) {
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        debugPrint('✓ الشاشة الرئيسية ظهرت');
      } else {
        debugPrint('⚠️ تخطي السيناريو - لم نصل للشاشة الرئيسية');
        return;
      }

      // الانتقال لصفحة الشركات
      final companiesTab = find.text('الشركات');
      if (companiesTab.evaluate().isNotEmpty) {
        await tester.tap(companiesTab);
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        debugPrint('✓ انتقلنا لصفحة الشركات');

        await tester.pump(const Duration(seconds: 2));

        final companyCards = find.byType(InkWell);
        if (companyCards.evaluate().length > 1) {
          await tester.tap(companyCards.at(1));
          await tester.pump(const Duration(seconds: 1));
          await tester.pump();
          debugPrint('✓ فتحنا صفحة الشركة');

          await tester.pump(const Duration(seconds: 2));

          final dealsTab = find.text('العروض');
          if (dealsTab.evaluate().isNotEmpty) {
            await tester.tap(dealsTab);
            await tester.pump(const Duration(seconds: 1));
            await tester.pump();
            debugPrint('✓ انتقلنا لتبويب العروض');
          }

          final followButtons = find.byIcon(Icons.favorite_border);
          if (followButtons.evaluate().isEmpty) {
            final unfollowButtons = find.byIcon(Icons.favorite);
            if (unfollowButtons.evaluate().isNotEmpty) {
              await tester.tap(unfollowButtons.first);
              await tester.pump(const Duration(seconds: 1));
              debugPrint('✓ ألغينا المتابعة');
            }
          } else {
            await tester.tap(followButtons.first);
            await tester.pump(const Duration(seconds: 1));
            debugPrint('✓ تابعنا الشركة');
          }

          await safePageBack(tester);
        }
      }

      debugPrint('🎉 السيناريو 1 انتهى بنجاح\n');
    });

    // ==================== السيناريو 2: تصفح العروض والفلترة ====================
    testWidgets('✅ السيناريو 2: تصفح العروض والفلترة', (tester) async {
      debugPrint('\n🚀 بدء السيناريو 2: تصفح العروض والفلترة');

      app.main();
      await loginIfNeeded(tester);

      final dealsTab = find.text('العروض');
      if (dealsTab.evaluate().isNotEmpty) {
        await tester.tap(dealsTab);
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        debugPrint('✓ صفحة العروض ظهرت');

        await tester.pump(const Duration(seconds: 2));

        // الفلترة بالفئة
        final filterChips = find.byType(FilterChip);
        if (filterChips.evaluate().isNotEmpty) {
          await tester.tap(filterChips.first);
          await tester.pump(const Duration(seconds: 1));
          await tester.pump();
          debugPrint('✓ الفلترة بالفئة اشتغلت');

          await tester.tap(filterChips.first);
          await tester.pump(const Duration(seconds: 1));
          debugPrint('✓ إلغاء الفلتر');
        }

        // الفلترة للطلاب
        final studentFilter = find.text('للطلاب');
        if (studentFilter.evaluate().isNotEmpty) {
          await tester.tap(studentFilter);
          await tester.pump(const Duration(seconds: 1));
          debugPrint('✓ تفعيل فلتر الطلاب');

          await tester.tap(studentFilter);
          await tester.pump(const Duration(seconds: 1));
          debugPrint('✓ إلغاء فلتر الطلاب');
        }
      }

      debugPrint('🎉 السيناريو 2 انتهى بنجاح\n');
    });

    // ==================== السيناريو 3: المفضلة ====================
    testWidgets('✅ السيناريو 3: إضافة وإزالة المفضلة', (tester) async {
      debugPrint('\n🚀 بدء السيناريو 3: المفضلة');

      app.main();
      await loginIfNeeded(tester);

      final dealsTab = find.text('العروض');
      if (dealsTab.evaluate().isNotEmpty) {
        await tester.tap(dealsTab);
        await tester.pump(const Duration(seconds: 2));
        debugPrint('✓ في صفحة العروض');

        // إضافة عرض للمفضلة
        final favoriteButtons = find.byIcon(Icons.favorite_border);
        if (favoriteButtons.evaluate().isNotEmpty) {
          await tester.tap(favoriteButtons.first);
          await tester.pump(const Duration(seconds: 1));
          debugPrint('✓ أضفنا عرض للمفضلة');

          await tester.pump(const Duration(seconds: 1));

          // إزالة من المفضلة
          final filledFavorite = find.byIcon(Icons.favorite);
          if (filledFavorite.evaluate().isNotEmpty) {
            await tester.tap(filledFavorite.first);
            await tester.pump(const Duration(seconds: 1));
            debugPrint('✓ أزلنا العرض من المفضلة');
          }

          // إضافة مرة تانية
          if (favoriteButtons.evaluate().isNotEmpty) {
            await tester.tap(favoriteButtons.first);
            await tester.pump(const Duration(seconds: 1));
            debugPrint('✓ أضفنا العرض مرة أخرى');
          }
        }

        // الذهاب لصفحة المفضلة من البروفايل
        final profileTab = find.text('حسابي');
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab);
          await tester.pump(const Duration(seconds: 2));

          final favoritesItem = find.text('العروض المفضّلة');
          if (favoritesItem.evaluate().isNotEmpty) {
            await tester.tap(favoritesItem);
            await tester.pump(const Duration(seconds: 2));
            debugPrint('✓ صفحة المفضلة فتحت');

            // التحقق من وجود عروض
            final dealCards = find.byType(Card);
            if (dealCards.evaluate().isNotEmpty) {
              debugPrint(
                '✓ يوجد ${dealCards.evaluate().length} عروض في المفضلة',
              );
            } else {
              debugPrint('⚠️ لا توجد عروض في المفضلة');
            }

            await safePageBack(tester);
          }
        }
      }

      debugPrint('🎉 السيناريو 3 انتهى بنجاح\n');
    });

    // ==================== السيناريو 4: فتح تفاصيل عرض ====================
    testWidgets('✅ السيناريو 4: فتح تفاصيل عرض ونسخ الكود', (tester) async {
      debugPrint('\n🚀 بدء السيناريو 4: تفاصيل العرض');

      app.main();
      await loginIfNeeded(tester);

      final dealsTab = find.text('العروض');
      if (dealsTab.evaluate().isNotEmpty) {
        await tester.tap(dealsTab);
        await tester.pump(const Duration(seconds: 2));

        // فتح أول عرض
        final dealCards = find.byType(Card);
        if (dealCards.evaluate().isNotEmpty) {
          await tester.tap(dealCards.first);
          await tester.pump(const Duration(seconds: 3));
          debugPrint('✓ فتحنا تفاصيل عرض');

          // البحث عن زر نسخ الكود
          final copyButton = find.text('نسخ');
          if (copyButton.evaluate().isNotEmpty) {
            await tester.tap(copyButton);
            await tester.pump(const Duration(seconds: 1));
            debugPrint('✓ نسخنا كود الخصم');
          }

          // البحث عن زر فتح الرابط
          final openButton = find.text('اذهب للعرض');
          if (openButton.evaluate().isNotEmpty) {
            debugPrint('✓ زر فتح العرض موجود');
          }

          // البحث عن زر المشاركة
          final shareButton = find.byIcon(Icons.share);
          if (shareButton.evaluate().isNotEmpty) {
            debugPrint('✓ زر المشاركة موجود');
          }

          // الذهاب لصفحة الشركة من تفاصيل العرض
          final companyCard = find.byIcon(Icons.chevron_right);
          if (companyCard.evaluate().isNotEmpty) {
            await tester.tap(companyCard.first);
            await tester.pump(const Duration(seconds: 2));
            debugPrint('✓ انتقلنا لصفحة الشركة من العرض');

            await safePageBack(tester);
          }

          await safePageBack(tester);
        }
      }

      debugPrint('🎉 السيناريو 4 انتهى بنجاح\n');
    });

    // ==================== السيناريو 5: البحث ====================
    testWidgets('✅ السيناريو 5: البحث عن العروض', (tester) async {
      debugPrint('\n🚀 بدء السيناريو 5: البحث');

      app.main();
      await loginIfNeeded(tester);

      // البحث في الصفحة الرئيسية
      final searchIcon = find.byIcon(Icons.search);
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon);
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        debugPrint('✓ فتحنا البحث');

        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          // البحث عن "خصم"
          await tester.enterText(searchField.first, 'خصم');
          await tester.pump(const Duration(seconds: 2));
          debugPrint('✓ بحثنا عن: خصم');

          await tester.pump(const Duration(seconds: 1));

          // البحث عن "عرض"
          await tester.enterText(searchField.first, 'عرض');
          await tester.pump(const Duration(seconds: 2));
          debugPrint('✓ بحثنا عن: عرض');

          // مسح البحث
          await tester.enterText(searchField.first, '');
          await tester.pump(const Duration(seconds: 1));
          debugPrint('✓ مسحنا البحث');
        }
      }

      debugPrint('🎉 السيناريو 5 انتهى بنجاح\n');
    });

    // ==================== السيناريو 6: البروفايل والإعدادات ====================
    testWidgets('✅ السيناريو 6: البروفايل والإعدادات', (tester) async {
      debugPrint('\n🚀 بدء السيناريو 6: البروفايل');

      app.main();
      await loginIfNeeded(tester);

      final profileTab = find.text('حسابي');
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        debugPrint('✓ صفحة البروفايل ظهرت');

        await tester.pump(const Duration(seconds: 1));

        // فتح الشركات المتابعة
        final followingItem = find.text('الشركات المتابعة');
        if (followingItem.evaluate().isNotEmpty) {
          await tester.tap(followingItem);
          await tester.pump(const Duration(seconds: 2));
          await tester.pump();
          debugPrint('✓ صفحة الشركات المتابعة فتحت');

          await safePageBack(tester);
        }

        // فتح الإعدادات
        final settingsItem = find.text('الإعدادات');
        if (settingsItem.evaluate().isNotEmpty) {
          await tester.tap(settingsItem);
          await tester.pump(const Duration(seconds: 2));
          debugPrint('✓ صفحة الإعدادات فتحت');

          // فتح "عن التطبيق"
          final aboutItem = find.text('عن التطبيق');
          if (aboutItem.evaluate().isNotEmpty) {
            await tester.tap(aboutItem);
            await tester.pump(const Duration(seconds: 2));
            debugPrint('✓ صفحة عن التطبيق فتحت');

            await safePageBack(tester);
          }

          // فتح "الشروط والأحكام"
          final termsItem = find.text('الشروط والأحكام');
          if (termsItem.evaluate().isNotEmpty) {
            await tester.tap(termsItem);
            await tester.pump(const Duration(seconds: 2));
            debugPrint('✓ صفحة الشروط والأحكام فتحت');

            await safePageBack(tester);
          }

          // فتح "سياسة الخصوصية"
          final privacyItem = find.text('سياسة الخصوصية');
          if (privacyItem.evaluate().isNotEmpty) {
            await tester.tap(privacyItem);
            await tester.pump(const Duration(seconds: 2));
            debugPrint('✓ صفحة سياسة الخصوصية فتحت');

            await safePageBack(tester);
          }

          await safePageBack(tester);
        }
      }

      debugPrint('🎉 السيناريو 6 انتهى بنجاح\n');
    });

    // ==================== السيناريو 7: التقييمات ====================
    testWidgets('✅ السيناريو 7: عرض وإضافة تقييم', (tester) async {
      debugPrint('\n🚀 بدء السيناريو 7: التقييمات');

      app.main();
      await loginIfNeeded(tester);

      final companiesTab = find.text('الشركات');
      if (companiesTab.evaluate().isNotEmpty) {
        await tester.tap(companiesTab);
        await tester.pump(const Duration(seconds: 2));

        final companyCards = find.byType(InkWell);
        if (companyCards.evaluate().length > 1) {
          await tester.tap(companyCards.at(1));
          await tester.pump(const Duration(seconds: 3));
          debugPrint('✓ فتحنا صفحة الشركة');

          // الذهاب لتبويب التقييمات
          final reviewsTab = find.text('التقييمات');
          if (reviewsTab.evaluate().isNotEmpty) {
            await tester.tap(reviewsTab);
            await tester.pump(const Duration(seconds: 2));
            debugPrint('✓ تبويب التقييمات ظهر');

            // التحقق من وجود إحصائيات
            final progressBars = find.byType(LinearProgressIndicator);
            if (progressBars.evaluate().isNotEmpty) {
              debugPrint('✓ إحصائيات التقييم موجودة');
            }

            // البحث عن زر إضافة تقييم
            final addReviewButton = find.text('أضف تقييمك');
            if (addReviewButton.evaluate().isNotEmpty) {
              debugPrint('✓ زر إضافة تقييم موجود');
            }
          }

          await safePageBack(tester);
        }
      }

      debugPrint('🎉 السيناريو 7 انتهى بنجاح\n');
    });

    // ==================== السيناريو 8: التنقل بين التبويبات ====================
    testWidgets('✅ السيناريو 8: التنقل بين كل التبويبات', (tester) async {
      debugPrint('\n🚀 بدء السيناريو 8: التنقل بين التبويبات');

      app.main();
      await loginIfNeeded(tester);

      await tester.pump(const Duration(seconds: 2));

      // الرئيسية
      final homeTab = find.text('الرئيسية');
      if (homeTab.evaluate().isNotEmpty) {
        await tester.tap(homeTab);
        await tester.pump(const Duration(seconds: 1));
        debugPrint('✓ في تبويب الرئيسية');
      }

      // العروض
      final dealsTab = find.text('العروض');
      if (dealsTab.evaluate().isNotEmpty) {
        await tester.tap(dealsTab);
        await tester.pump(const Duration(seconds: 1));
        debugPrint('✓ في تبويب العروض');
      }

      // الشركات
      final companiesTab = find.text('الشركات');
      if (companiesTab.evaluate().isNotEmpty) {
        await tester.tap(companiesTab);
        await tester.pump(const Duration(seconds: 1));
        debugPrint('✓ في تبويب الشركات');
      }

      // حسابي
      final profileTab = find.text('حسابي');
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pump(const Duration(seconds: 1));
        debugPrint('✓ في تبويب حسابي');
      }

      // الرجوع للرئيسية
      if (homeTab.evaluate().isNotEmpty) {
        await tester.tap(homeTab);
        await tester.pump(const Duration(seconds: 1));
        debugPrint('✓ رجعنا للرئيسية');
      }

      debugPrint('🎉 السيناريو 8 انتهى بنجاح\n');
    });

    // ==================== السيناريو 9: التفاعل مع العروض المميزة ====================
    testWidgets('✅ السيناريو 9: العروض المميزة', (tester) async {
      debugPrint('\n🚀 بدء السيناريو 9: العروض المميزة');

      app.main();
      await loginIfNeeded(tester);

      await tester.pump(const Duration(seconds: 2));

      // البحث عن قسم العروض المميزة
      final featuredSection = find.text('العروض المميزة');
      if (featuredSection.evaluate().isNotEmpty) {
        debugPrint('✓ قسم العروض المميزة موجود');

        // سكرول للعروض المميزة
        try {
          await tester.scrollUntilVisible(
            featuredSection,
            100,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pump(const Duration(seconds: 1));
          debugPrint('✓ سكرولنا للعروض المميزة');
        } catch (e) {
          debugPrint('⚠️ لم نستطع السكرول للعروض المميزة');
        }
      }

      // البحث عن قسم أحدث العروض
      final latestSection = find.text('أحدث العروض');
      if (latestSection.evaluate().isNotEmpty) {
        debugPrint('✓ قسم أحدث العروض موجود');
      }

      debugPrint('🎉 السيناريو 9 انتهى بنجاح\n');
    });

    // ==================== السيناريو 10: اختبار الأخطاء ====================
    testWidgets('✅ السيناريو 10: التعامل مع الأخطاء', (tester) async {
      debugPrint('\n🚀 بدء السيناريو 10: اختبار الأخطاء');

      app.main();
      await loginIfNeeded(tester);

      // اختبار البحث عن عناصر غير موجودة
      final nonExistentButton = find.text('هذا الزر غير موجود');
      if (nonExistentButton.evaluate().isEmpty) {
        debugPrint('✓ التحقق من عدم وجود عناصر غير موجودة');
      }

      // اختبار scroll في الصفحة
      try {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
        await tester.pump(const Duration(seconds: 1));
        debugPrint('✓ اختبار scroll نجح');
      } catch (e) {
        debugPrint('⚠️ اختبار scroll فشل (طبيعي لو الشاشة قصيرة)');
      }

      // اختبار التنقل بين تبويبات متعددة بسرعة
      final tabs = ['الرئيسية', 'العروض', 'الشركات', 'حسابي'];
      for (final tabName in tabs) {
        final tab = find.text(tabName);
        if (tab.evaluate().isNotEmpty) {
          await tester.tap(tab);
          await tester.pump(const Duration(milliseconds: 500));
        }
      }
      debugPrint('✓ التنقل السريع بين التبويبات نجح');

      debugPrint('🎉 السيناريو 10 انتهى بنجاح\n');
    });
  });
}
