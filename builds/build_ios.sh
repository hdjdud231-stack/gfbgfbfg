#!/bin/bash

# سكريبت بناء تطبيق Index لنظام iOS
# يجب تشغيل هذا السكريبت على macOS مع Xcode مثبت

set -e

echo "🚀 بدء بناء تطبيق Index لنظام iOS..."

# التحقق من وجود Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter غير مثبت. يرجى تثبيت Flutter أولاً."
    exit 1
fi

# التحقق من وجود Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode غير مثبت. يرجى تثبيت Xcode أولاً."
    exit 1
fi

# الانتقال إلى مجلد المشروع
PROJECT_DIR="$(dirname "$0")/../index app"
cd "$PROJECT_DIR"

echo "📁 المجلد الحالي: $(pwd)"

# تنظيف المشروع
echo "🧹 تنظيف المشروع..."
flutter clean

# تحديث التبعيات
echo "📦 تحديث التبعيات..."
flutter pub get

# تثبيت CocoaPods
echo "🍫 تثبيت CocoaPods..."
cd ios
pod install
cd ..

# التحقق من إعدادات Flutter
echo "🔍 التحقق من إعدادات Flutter..."
flutter doctor

# بناء للمحاكي (للاختبار)
echo "📱 بناء للمحاكي..."
flutter build ios --simulator --release

# بناء للجهاز
echo "📱 بناء للجهاز..."
flutter build ios --release

# إنشاء الأرشيف
echo "📦 إنشاء الأرشيف..."
xcodebuild -workspace ios/Runner.xcworkspace \
           -scheme Runner \
           -configuration Release \
           -archivePath build/ios/Runner.xcarchive \
           archive

# التحقق من نجاح الأرشفة
if [ -d "build/ios/Runner.xcarchive" ]; then
    echo "✅ تم إنشاء الأرشيف بنجاح!"
    
    # إنشاء مجلد للـ IPA
    mkdir -p build/ios/ipa
    
    # تصدير IPA للـ App Store
    echo "📤 تصدير IPA للـ App Store..."
    xcodebuild -exportArchive \
               -archivePath build/ios/Runner.xcarchive \
               -exportPath build/ios/ipa/appstore \
               -exportOptionsPlist ios/ExportOptions.plist
    
    # تصدير IPA للتطوير
    echo "📤 تصدير IPA للتطوير..."
    xcodebuild -exportArchive \
               -archivePath build/ios/Runner.xcarchive \
               -exportPath build/ios/ipa/development \
               -exportOptionsPlist ios/ExportOptions-Development.plist
    
    # تصدير IPA للـ Ad Hoc
    echo "📤 تصدير IPA للـ Ad Hoc..."
    xcodebuild -exportArchive \
               -archivePath build/ios/Runner.xcarchive \
               -exportPath build/ios/ipa/adhoc \
               -exportOptionsPlist ios/ExportOptions-AdHoc.plist
    
    echo "🎉 تم بناء التطبيق بنجاح!"
    echo "📁 ملفات IPA متوفرة في: build/ios/ipa/"
    
    # عرض معلومات الملفات
    echo "📋 ملفات IPA المُنشأة:"
    find build/ios/ipa -name "*.ipa" -exec ls -lh {} \;
    
else
    echo "❌ فشل في إنشاء الأرشيف!"
    exit 1
fi

echo "✨ انتهى بناء تطبيق Index لنظام iOS بنجاح!"