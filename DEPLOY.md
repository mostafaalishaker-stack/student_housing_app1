# 🚀 دليل النشر

## 1. رفع الملفات على GitHub
```bash
git init
git add .
git commit -m "initial commit"
gh repo create sknkm --public --push
```

## 2. نشر الـ Web Backend على Render

1. افتح https://render.com → Sign up with GitHub
2. New → Web Service → Connect your repo
3. Settings:
   - **Name:** `sknkm-api`
   - **Root Directory:** `backend`
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
4. Add Environment Variables:
   - `JWT_SECRET` → أنشئ قيمة عشوائية (يمكنك استخدام `openssl rand -hex 32`)
   - `GOOGLE_CLIENT_ID` → `196449063436-0l9j1q6a7rrlb7gogoht91sc67epes30.apps.googleusercontent.com`
   - `WHATSAPP_INSTANCE_ID` → `instance181067`
   - `WHATSAPP_TOKEN` → `8227s7j7nvk4dull`
   - `ADMIN_WHATSAPP` → `201112291736`
   - `CORS_ORIGIN` → `https://sknkm.onrender.com`
   - `NODE_ENV` → `production`
5. Add a PostgreSQL database:
   - New → PostgreSQL
   - Copy the **Internal Database URL**
   - Add to your Web Service env vars: `DATABASE_URL` = that URL
6. **Seed the database** after first deploy:
   - Go to Shell tab and run: `npm run seed`

### Custom Domain (اختياري)
- في Render Dashboard → Settings → Custom Domain
- أضف `api.sknkm.com` مثلاً واربط DNS

## 3. رفع الـ Frontend HTML

بما أن السيرفر يخدم الملفات HTML بنفسه، ما يحتاج رفع منفصل. فقط غير `CORS_ORIGIN` لدومينك لو عندك custom domain.

لو عايز تكمل بنشر منفصل على Vercel:
```bash
cd frontend/web
npm i -g vercel
vercel --prod
```

## 4. 🔑 إنشاء Keystore لتوقيع Android
```bash
# على جهازك بعد تثبيت Flutter
cd frontend

# أولاً: إنشاء المجلدات المفقودة
flutter pub get
flutter create --platforms=android,ios .

# ثانياً: إنشاء Keystore
keytool -genkey -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload -storepass sknkm@2024 -keypass sknkm@2024

# ثالثاً: تعديل android/app/build.gradle
# أضف قبل android {:
android {
    signingConfigs {
        release {
            keyAlias = 'upload'
            keyPassword = 'sknkm@2024'
            storeFile = file('upload-keystore.jks')
            storePassword = 'sknkm@2024'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}

# رابعاً: بناء الـ APK للتجربة
flutter build apk --release
# ملف APK: build/app/outputs/flutter-apk/app-release.apk

# خامساً: بناء الـ App Bundle لمتجر Google Play
flutter build appbundle --release
# ملف AAB: build/app/outputs/bundle/release/app-release.aab
```

## 5. 📱 Google Play Store

1. افتح https://play.google.com/console
2. ادفع $25 (مرة واحدة) — إنشاء حساب مطور
3. Create app → الاسم: **سكنكم** → Free → Application
4. **App bundle** → ارفع `app-release.aab`
5. املأ:
   - Store listing: صور، وصف، screenshots
   - App content: Questionnaire about target age, ads
   - Pricing: Free
6. Publish → ياخذ من ساعة لـ 24 ساعة للمراجعة

## 6. 📱 App Store (iOS — يحتاج Mac)

1. افتح https://developer.apple.com → $99/سنة
2. سجل في Apple Developer Program
3. افتح Xcode → `frontend/ios/Runner.xcworkspace`
4. Sign in with Apple ID → Fix any signing issues
5. Product → Archive → Distribute App
6. ارفع على App Store Connect:
   - Screenshots (iPhone 6.7" + iPad 12.9")
   - Description, keywords, support URL
7. Submit for Review

## 7. ⚙️ بعد النشر — Google OAuth

**مهم!** أضف الدومين الجديد في Google Cloud Console:
1. https://console.cloud.google.com/auth/audience
2. Authorized JavaScript origins: `https://sknkm.onrender.com`
3. Authorized redirect URIs: (اتركها فاضية أو أضف callback URL لو استخدمت sign-in redirect)
4. **Authorized domains**: `sknkm.onrender.com`
5. لو النطاق عام (وليس Test)، غير وضع OAuth من Testing → **In Production**
6. أنتظر المراجعة من Google (قد تطلب فيديو توضيحي)

> **ملاحظة**: لو بقيت في وضع Testing، لازم تضيف كل مستخدم (email) في Test Users. للعموم حوله لـ In Production.

## 8. ❗ مشاكل متوقعة

| المشكلة | الحل |
|---------|------|
| SQLite يمسح البيانات بعد redeploy | استخدم PostgreSQL (DATABASE_URL) |
| Google login مش شغال | أضف الدومين في Google Console |
| الصور مش بتظهر | غيّر upload path لـ CDN أو استخدم Cloudinary |
| Flutter app مش بتتواصل | غير `productionUrl` في `api_service.dart` لدومين Render |
| Whatsapp مش شغال | تأكد من env vars و ultramsg instance نشط |

## الخلاصة

```
النشر:  ~1-2 ساعات
Google Play review: ~1-3 أيام
App Store review:   ~1-7 أيام
Google OAuth production: ~1-3 أيام
```

الترتيب:
1. ✅ الـ Web Backend على Render (أسرع حاجة)
2. ✅ Google OAuth Production (عشان الناس تدخل)
3. ✅ اختبار Flutter APK يدويًا على الموبايل
4. ❗ رفع على Google Play + App Store (يحتاج حسابات وفلوس)
