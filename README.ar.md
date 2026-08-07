<div dir="rtl" lang="ar">

<p align="center">
  <img src="assets/edadat-logo.svg" alt="إعدادات" width="220" />
</p>

<h1 align="center">إعدادات</h1>

<p align="center">
  <span dir="ltr"><code>flutter_settings_framework</code></span> · <span dir="ltr"><strong>edadat</strong></span><br/>
  إطار إعدادات لتطبيقات Flutter:<br/>
  تعريفات واضحة، بحث بلغات متعددة، وربط جاهز مع Riverpod وواجهة جاهزة.
</p>

<p align="center">
  <a href="https://pub.dev/packages/flutter_settings_framework"><img alt="pub.dev" src="https://img.shields.io/pub/v/flutter_settings_framework.svg?style=flat-square&label=pub.dev&color=8B6914" /></a>
  <a href="https://github.com/Zyzto/Edadat"><img alt="repo" src="https://img.shields.io/badge/github-Zyzto%2FEdadat-C0C0C0?style=flat-square" /></a>
</p>

<p align="center">
  <a href="#لماذا-إعدادات">لماذا؟</a> ·
  <a href="#ماذا-تقدّم">ماذا تقدّم؟</a> ·
  <a href="#التثبيت">التثبيت</a> ·
  <a href="#ابدأ-في-دقائق">ابدأ</a> ·
  <a href="#الرخصة">الرخصة</a>
  <br/>
  <a href="README.md"><span dir="ltr">English</span></a>
</p>

<p align="center">
  الاسم من العربية: <strong>إعدادات</strong> جمع <em>إعداد</em> — ما يُضبط في التطبيق.<br/>
  والاسم اللاتيني <span dir="ltr"><strong>edadat</strong></span> مأخوذ منه.
</p>

</div>

---

<div dir="rtl" lang="ar">

## لماذا إعدادات؟

غالباً ما تبدأ التطبيقات بـ مفاتيح وتبليغات متفرّقة لكل تفضيل، ثم تحتاج:

- تعريفاً موحّداً بدل تكرار عشرات الأسطر لكل إعداد
- بحثاً يعمل بلغات غير لغة الواجهة الحالية
- صفحة إعدادات متسقة دون إعادة بناء كل شاشة

**إعدادات** يوفّر نواة تعتمد على الـ streams/callbacks، مع **محوّل Riverpod وواجهة جاهزة** (الحزمة تعتمد على <span dir="ltr"><code>flutter_riverpod</code></span>). لا تُشحن محوّلات Provider أو Bloc اليوم.

على pub.dev: <span dir="ltr"><a href="https://pub.dev/packages/flutter_settings_framework"><code>flutter_settings_framework</code></a></span>

---

## ماذا تقدّم؟

| المجال | المحتوى |
|--------|---------|
| **تعريفات** | إعدادات مكتوبة بأنواع واضحة في أسطر قليلة |
| **بحث** | فهرسة متعددة اللغات + مرادفات |
| **Riverpod** | <span dir="ltr"><code>initializeSettings</code></span> وامتدادات <span dir="ltr"><code>ref</code></span> |
| **واجهة** | بلاطات وأقسام وصفحة من السجل مع بحث دائم |
| **انتقال** | تمرير وتمييز بعد اختيار نتيجة البحث |
| **تخزين** | <span dir="ltr"><code>SharedPreferencesStorage</code></span> أو تنفيذك الخاص |

---

## التثبيت

```yaml
dependencies:
  flutter_settings_framework: ^0.6.0
```

أو:

```bash
flutter pub add flutter_settings_framework
```

تثبيت من وسم Git (انظر <span dir="ltr"><a href="VERSIONING.md">VERSIONING.md</a></span>):

```yaml
dependencies:
  flutter_settings_framework:
    git:
      url: https://github.com/Zyzto/edadat.git
      ref: v0.6.0
```

الإصدار الحالي: **0.6.0**.

---

## ابدأ في دقائق

عرّف الإعدادات، ثم اربطها عبر <span dir="ltr"><code>initializeSettings</code></span> مع تجاوز مزوّدات Riverpod الثلاثة، واستخدم البلاطات أو <span dir="ltr"><code>RegistrySettingsPage</code></span>.

أمثلة الكود الكاملة باللغة الإنجليزية في <span dir="ltr"><a href="README.md">README.md</a></span>.

```dart
final settings = await initializeSettings(
  registry: createMyRegistry(),
  storage: SharedPreferencesStorage(),
  localizationProvider: PreIndexedLocalizationProvider({
    'en': en,
    'ar': ar,
  }),
);
```

```dart
final enabled = ref.watchSetting(notificationsSetting);
ref.updateSetting(notificationsSetting, value);
```

---

## المثال

مجلد <span dir="ltr"><a href="example/">example/</a></span> يعرض التعريفات والتهيئة والبلاطات. لا توجد مجلدات منصات؛ للتحليل:

```bash
cd example && flutter pub get && dart analyze --fatal-infos
```

للتفاصيل: <span dir="ltr"><a href="example/README.md">example/README.md</a></span>.

---

## الهوية البصرية

كلمة الشعار بخط <span dir="ltr"><strong><a href="https://www.1001fonts.com/baz-font.html">Baz</a></strong></span> (Baz Light) — نفس الخط المستخدم في <span dir="ltr"><a href="https://github.com/Zyzto/Siglat">Siglat</a></span>. الملف في <span dir="ltr"><code>assets/fonts/baz-Light.otf</code></span>؛ وملف الـ SVG يضم الحروف كمسارات حتى يظهر دون تحميل الخط.

---

## الإصدارات

<span dir="ltr"><a href="VERSIONING.md">VERSIONING.md</a></span> · <span dir="ltr"><a href="CHANGELOG.md">CHANGELOG.md</a></span>

---

## الرخصة

<span dir="ltr"><a href="LICENSE">MPL-2.0</a></span> — حقوق ضعيفة النسخ؛ الاستخدام التجاري مسموح. تعديلات ملفات الحزمة تبقى تحت MPL، وتطبيقك يمكن أن يبقى مغلقاً.

</div>
