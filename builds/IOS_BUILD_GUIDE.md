# دليل بناء تطبيق Index لنظام iOS

## المتطلبات الأساسية

### 1. النظام والأدوات المطلوبة:
- **macOS** (Big Sur 11.0 أو أحدث)
- **Xcode** (13.0 أو أحدث)
- **Flutter SDK** (3.24.5 أو أحدث)
- **CocoaPods** (1.11.0 أو أحدث)

### 2. تثبيت الأدوات:

#### تثبيت Flutter:
```bash
# تحميل Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# التحقق من التثبيت
flutter doctor
```

#### تثبيت CocoaPods:
```bash
sudo gem install cocoapods
```

#### تثبيت Xcode:
- قم بتحميل Xcode من App Store
- قم بتشغيل: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`

## خطوات البناء

### الخطوة 1: إعداد المشروع
```bash
# انتقل إلى مجلد المشروع
cd "path/to/index app"

# تحديث التبعيات
flutter pub get

# تنظيف المشروع
flutter clean
```

### الخطوة 2: إعداد iOS
```bash
# الانتقال إلى مجلد iOS
cd ios

# تثبيت pods
pod install

# العودة إلى المجلد الرئيسي
cd ..
```

### الخطوة 3: إعداد الشهادات والهوية

#### للتطوير (Development):
1. افتح `ios/Runner.xcworkspace` في Xcode
2. اختر فريق التطوير في "Signing & Capabilities"
3. تأكد من Bundle Identifier فريد (مثل: com.voxin.index)

#### للنشر (Distribution):
1. إنشاء App ID في Apple Developer Console
2. إنشاء Distribution Certificate
3. إنشاء Provisioning Profile
4. تكوين الشهادات في Xcode

### الخطوة 4: تكوين إعدادات التطبيق

#### تحديث Info.plist:
الملف موجود في: `ios/Runner/Info.plist`

```xml
<!-- تم تحديث اسم التطبيق بالفعل -->
<key>CFBundleDisplayName</key>
<string>Index</string>
<key>CFBundleName</key>
<string>Index</string>

<!-- إضافة أذونات الشبكة للـ IPTV والأنمي -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### الخطوة 5: البناء

#### للتطوير والاختبار:
```bash
# بناء للمحاكي
flutter build ios --simulator

# بناء للجهاز (يتطلب شهادة تطوير)
flutter build ios --debug
```

#### للنشر:
```bash
# بناء نسخة الإنتاج
flutter build ios --release

# أو بناء مع تحسينات إضافية
flutter build ios --release --obfuscate --split-debug-info=build/ios/symbols
```

### الخطوة 6: إنشاء IPA للتوزيع

#### الطريقة الأولى: باستخدام Xcode
1. افتح `ios/Runner.xcworkspace`
2. اختر "Product" > "Archive"
3. بعد انتهاء الأرشفة، اختر "Distribute App"
4. اختر طريقة التوزيع (App Store، Ad Hoc، Enterprise)

#### الطريقة الثانية: باستخدام Command Line
```bash
# بناء الأرشيف
xcodebuild -workspace ios/Runner.xcworkspace \
           -scheme Runner \
           -configuration Release \
           -archivePath build/ios/Runner.xcarchive \
           archive

# تصدير IPA
xcodebuild -exportArchive \
           -archivePath build/ios/Runner.xcarchive \
           -exportPath build/ios/ipa \
           -exportOptionsPlist ios/ExportOptions.plist
```

## إعدادات خاصة بتطبيق Index

### 1. أذونات الشبكة:
```xml
<!-- في Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 2. دعم الاتجاهات:
```xml
<!-- دعم جميع الاتجاهات للفيديو -->
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```

### 3. إعدادات الخصوصية:
```xml
<!-- إذا كان التطبيق يحتاج للوصول للكاميرا أو الميكروفون -->
<key>NSCameraUsageDescription</key>
<string>يستخدم التطبيق الكاميرا لالتقاط الصور</string>
<key>NSMicrophoneUsageDescription</key>
<string>يستخدم التطبيق الميكروفون للتسجيل</string>
```

## استكشاف الأخطاء

### مشاكل شائعة وحلولها:

#### 1. خطأ في CocoaPods:
```bash
# حذف Podfile.lock وإعادة التثبيت
cd ios
rm Podfile.lock
rm -rf Pods
pod install
```

#### 2. خطأ في الشهادات:
- تأكد من صحة Bundle Identifier
- تحقق من صلاحية الشهادات في Keychain Access
- تأكد من تطابق Provisioning Profile مع Bundle ID

#### 3. خطأ في البناء:
```bash
# تنظيف شامل
flutter clean
cd ios
xcodebuild clean
pod install
cd ..
flutter pub get
```

#### 4. مشاكل في الأيقونات:
- تأكد من وجود جميع أحجام الأيقونات في `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- استخدم أداة مثل App Icon Generator لإنشاء جميع الأحجام

## التحسينات والأداء

### 1. تحسين حجم التطبيق:
```bash
# بناء مع تقسيم debug info
flutter build ios --release --split-debug-info=build/ios/symbols

# بناء مع obfuscation
flutter build ios --release --obfuscate --split-debug-info=build/ios/symbols
```

### 2. تحسين الأداء:
- تفعيل bitcode في Xcode
- استخدام release mode للنشر
- تحسين الصور والأصول

## النشر على App Store

### 1. إعداد App Store Connect:
- إنشاء App ID جديد
- رفع البيانات الوصفية
- إضافة لقطات الشاشة
- كتابة وصف التطبيق

### 2. رفع التطبيق:
```bash
# باستخدام Xcode
# Product > Archive > Distribute App > App Store Connect

# أو باستخدام Transporter app من Apple
```

### 3. مراجعة Apple:
- تأكد من اتباع App Store Guidelines
- اختبار التطبيق على أجهزة مختلفة
- التأكد من عمل جميع الميزات

## ملاحظات مهمة

### 1. الميزات الخاصة بـ Index:
- **IPTV**: يعمل بشكل طبيعي على iOS
- **AnimeX**: متوافق مع مشغل الفيديو في iOS
- **Analytics**: Amplitude يدعم iOS بالكامل
- **Privacy Policy**: متوافق مع متطلبات Apple

### 2. متطلبات Apple:
- يجب إضافة Privacy Policy في App Store Connect
- التأكد من عدم انتهاك حقوق الطبع والنشر
- اتباع Human Interface Guidelines

### 3. الاختبار:
- اختبار على iPhone و iPad
- اختبار جميع الاتجاهات
- اختبار الشبكة البطيئة
- اختبار انقطاع الاتصال

---

## الدعم الفني

للحصول على المساعدة:
1. تحقق من Flutter Doctor: `flutter doctor`
2. راجع سجلات Xcode للأخطاء التفصيلية
3. تأكد من تحديث جميع الأدوات لأحدث إصدار

---

**ملاحظة:** بناء تطبيقات iOS يتطلب macOS و Xcode. لا يمكن بناء تطبيقات iOS على Windows أو Linux.

© 2023 Voxin - تطبيق Index