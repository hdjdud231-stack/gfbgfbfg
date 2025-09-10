# دليل البناء السريع لـ iOS - تطبيق Index

## البناء السريع (5 دقائق)

### المتطلبات:
- macOS مع Xcode مثبت
- Flutter SDK مثبت
- CocoaPods مثبت

### الخطوات السريعة:

#### 1. تشغيل السكريبت التلقائي:
```bash
cd "path/to/builds"
./build_ios.sh
```

#### 2. أو البناء اليدوي:
```bash
# الانتقال للمشروع
cd "path/to/index app"

# تنظيف وتحديث
flutter clean && flutter pub get

# تثبيت pods
cd ios && pod install && cd ..

# البناء
flutter build ios --release
```

#### 3. إنشاء IPA:
```bash
# فتح Xcode
open ios/Runner.xcworkspace

# في Xcode:
# Product → Archive → Distribute App
```

## الملفات المهمة المُحدثة:

### ✅ Info.plist
- تم تحديث اسم التطبيق إلى "Index"
- تم إضافة أذونات الشبكة للـ IPTV

### ✅ ExportOptions.plist
- ملفات تصدير للـ App Store، Development، Ad Hoc

### ✅ السكريبت التلقائي
- `build_ios.sh` - بناء كامل تلقائي

## النتائج المتوقعة:

بعد البناء الناجح ستحصل على:
- **Runner.xcarchive** - الأرشيف الرئيسي
- **Index.ipa** - ملف التطبيق للتثبيت
- ملفات IPA متعددة (App Store، Development، Ad Hoc)

## استكشاف الأخطاء السريع:

### خطأ في CocoaPods:
```bash
cd ios
rm Podfile.lock
pod install
```

### خطأ في الشهادات:
- تحقق من Bundle Identifier في Xcode
- تأكد من وجود شهادة تطوير صالحة

### خطأ في البناء:
```bash
flutter clean
flutter pub get
```

---

## ملاحظات مهمة:

1. **يتطلب macOS**: لا يمكن بناء iOS على Windows/Linux
2. **شهادة Apple**: مطلوبة للتثبيت على الأجهزة الحقيقية
3. **Bundle ID**: يجب أن يكون فريد (مثل: com.voxin.index)

## الدعم:
للمساعدة راجع الدليل الكامل في `IOS_BUILD_GUIDE.md`

---
© 2023 Voxin - تطبيق Index