# رفع تطبيق Index على Netlify

## الطريقة الأولى: الرفع المباشر

### الخطوات:
1. اذهب إلى [netlify.com](https://netlify.com)
2. قم بتسجيل الدخول أو إنشاء حساب جديد
3. اضغط على "Sites" من القائمة الجانبية
4. اسحب مجلد `index_web` كاملاً إلى منطقة الرفع
5. انتظر حتى يكتمل الرفع والنشر

## الطريقة الثانية: ربط مع Git Repository

### الخطوات:
1. ارفع مجلد `index_web` إلى GitHub repository
2. في Netlify، اضغط على "New site from Git"
3. اختر GitHub واربط حسابك
4. اختر المستودع الذي يحتوي على ملفات الويب
5. اضبط إعدادات البناء:
   - **Build command:** (اتركه فارغ)
   - **Publish directory:** `index_web` أو المجلد الذي يحتوي على ملف index.html
   - **Base directory:** (اتركه فارغ)

## إعدادات مهمة لـ Flutter Web:

### 1. إعدادات Headers
أنشئ ملف `_headers` في مجلد `index_web` مع المحتوى التالي:
```
/*
  X-Frame-Options: SAMEORIGIN
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Cross-Origin-Embedder-Policy: credentialless
  Cross-Origin-Opener-Policy: same-origin
```

### 2. إعدادات Redirects
أنشئ ملف `_redirects` في مجلد `index_web` مع المحتوى التالي:
```
/*    /index.html   200
```

## إعدادات الأمان والأداء:

### 1. تفعيل HTTPS
- Netlify يوفر HTTPS تلقائياً
- تأكد من تفعيل "Force HTTPS" في إعدادات الموقع

### 2. تحسين الأداء
- تفعيل Asset optimization في إعدادات Netlify
- تفعيل Pretty URLs
- تفعيل Branch deploys إذا كنت تستخدم Git

## Domain مخصص (اختياري):

### لربط دومين مخصص:
1. اذهب إلى "Domain settings" في لوحة تحكم الموقع
2. اضغط على "Add custom domain"
3. أدخل اسم الدومين الخاص بك
4. اتبع التعليمات لتحديث DNS records

## متغيرات البيئة:

إذا كنت تحتاج لإضافة متغيرات بيئة:
1. اذهب إلى "Site settings" > "Environment variables"
2. أضف المتغيرات المطلوبة مثل:
   - `AMPLITUDE_API_KEY`: d378fab17e2b0902d1c733914afe0437

## مراقبة الأداء:

### Analytics مدمج:
- Netlify يوفر analytics أساسي مجاناً
- يمكنك تفعيل Netlify Analytics للحصول على إحصائيات مفصلة

### مراقبة الأخطاء:
- تحقق من "Functions" log في لوحة التحكم
- راقب "Deploy" logs للتأكد من عدم وجود أخطاء

## استكشاف الأخطاء:

### مشاكل شائعة وحلولها:

1. **صفحة فارغة أو خطأ 404:**
   - تأكد من وجود ملف `index.html` في المجلد الرئيسي
   - تحقق من ملف `_redirects`

2. **مشاكل في تحميل الخطوط:**
   - تأكد من وجود مجلد `assets/fonts`
   - تحقق من ملف `_headers`

3. **مشاكل في CORS:**
   - أضف headers المناسبة في ملف `_headers`
   - تأكد من إعدادات API endpoints

## الصيانة والتحديث:

### لتحديث التطبيق:
1. ارفع الملفات الجديدة (استبدال مجلد `index_web`)
2. Netlify سيقوم بإعادة النشر تلقائياً
3. تحقق من Deploy logs للتأكد من نجاح التحديث

---
**ملاحظة:** تأكد من اختبار التطبيق على أجهزة مختلفة بعد النشر للتأكد من عمله بشكل صحيح.