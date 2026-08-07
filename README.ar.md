<div dir="rtl" lang="ar">

<p align="center">
  <img src="assets/edadat-logo.svg" alt="إعدادات" width="220" />
</p>

<h1 align="center">إعدادات — Edadat</h1>

<p align="center">
  <span dir="ltr"><code>flutter_settings_framework</code></span><br/>
  إعدادات declarative لتطبيقات Flutter — بحث bilingual، وربط Riverpod،<br/>
  وtiles / registry pages جاهزة.
</p>

<p align="center">
  <a href="https://pub.dev/packages/flutter_settings_framework"><img alt="pub.dev" src="https://img.shields.io/pub/v/flutter_settings_framework.svg?style=flat-square&label=pub.dev&color=8B6914" /></a>
  <a href="https://github.com/Zyzto/Edadat"><img alt="repo" src="https://img.shields.io/badge/github-Zyzto%2FEdadat-C0C0C0?style=flat-square" /></a>
  <img alt="flutter" src="https://img.shields.io/badge/Flutter-%3E%3D3.0-C0C0C0?style=flat-square&logo=flutter&logoColor=white" />
  <img alt="license" src="https://img.shields.io/badge/license-MPL--2.0-8B6914?style=flat-square" />
</p>

<p align="center">
  <a href="#التثبيت">Install</a> ·
  <a href="#ابدأ-في-دقائق">Quick start</a> ·
  <a href="#ماذا-تقدّم">Features</a> ·
  <a href="#أنواع-الإعدادات">Types</a> ·
  <a href="#المثال">Example</a>
  <br/>
  <a href="README.md"><span dir="ltr">English</span></a> ·
  <a href="docs/i18n-ar.md">دليل أسلوب العربية</a>
</p>

<p align="center">
  الاسم <span dir="ltr"><strong>edadat</strong></span> من العربية
  <strong>إعدادات</strong>
  (<span dir="ltr"><em>iʿdādāt</em></span>): settings / configurations —
  جمع <em>إعداد</em> (<span dir="ltr"><em>iʿdād</em></span>).
</p>

</div>

---

<div dir="rtl" lang="ar">

## لماذا؟

معظم تطبيقات Flutter تجمع preference notifiers ومفاتيح وtiles متفرقة. ثم تحتاج:

- definitions declarative بدل boilerplate لكل setting
- search يعمل بأكثر من لغة الواجهة الحالية
- صفحة settings متسقة دون إعادة بناء كل شاشة

**إعدادات** تغطي ذلك عبر core من نوع stream/callback، و**Riverpod adapter + UI مشحونان**، وفهرسة بحث bilingual. adapters أخرى لـ state management غير مشمولة اليوم (<span dir="ltr"><code>flutter_riverpod</code></span> اعتماد صلب).

على <span dir="ltr">pub.dev</span>: <span dir="ltr"><a href="https://pub.dev/packages/flutter_settings_framework"><code>flutter_settings_framework</code></a></span> · المستودع: <span dir="ltr"><a href="https://github.com/Zyzto/Edadat">Zyzto/Edadat</a></span>

</div>

---

<div dir="rtl" lang="ar">

## ماذا تقدّم؟

| المجال | ماذا تحصل |
|--------|-----------|
| **Definitions** | settings بأنواع (<span dir="ltr"><code>Bool</code></span>، <span dir="ltr"><code>Enum</code></span>، <span dir="ltr"><code>Color</code></span>، …) في أسطر قليلة |
| **Search** | فهرس متعدد اللغات عبر <span dir="ltr"><code>PreIndexedLocalizationProvider</code></span> + synonyms |
| **Riverpod** | <span dir="ltr"><code>initializeSettings</code></span>، <span dir="ltr"><code>SettingsProviders</code></span>، <span dir="ltr"><code>ref.watchSetting</code></span> / <span dir="ltr"><code>updateSetting</code></span> |
| **UI** | tiles، sections، بحث persistent/compact، <span dir="ltr"><code>RegistrySettingsPage</code></span> |
| **Jump-to** | <span dir="ltr"><code>SettingAnchorRegistry</code></span> تمرير + highlight بعد البحث |
| **Storage** | <span dir="ltr"><code>SharedPreferencesStorage</code></span>، أو <span dir="ltr"><code>SettingsStorage</code></span> خاص بك |
| **Actions** | صفوف <span dir="ltr"><code>ActionSetting</code></span> غير persisted وتبقى قابلة للبحث |

**Core:** controller من نوع stream/callback (بدون import لـ Riverpod). **التكامل المشحون:** Riverpod adapter + UI مبني على Riverpod.

</div>

---

<div dir="rtl" lang="ar">

## التثبيت

</div>

```yaml
dependencies:
  flutter_settings_framework: ^0.6.0
```

<div dir="rtl" lang="ar">

أو:

</div>

```bash
flutter pub add flutter_settings_framework
```

<div dir="rtl" lang="ar">

تثبيت بوسم Git (انظر <span dir="ltr"><a href="VERSIONING.md">VERSIONING.md</a></span>):

</div>

```yaml
dependencies:
  flutter_settings_framework:
    git:
      url: https://github.com/Zyzto/edadat.git
      ref: v0.6.0
```

```dart
import 'package:flutter_settings_framework/flutter_settings_framework.dart';
```

<div dir="rtl" lang="ar">

الإصدار الحالي: **0.6.0**.

</div>

---

<div dir="rtl" lang="ar">

## ابدأ في دقائق

### 1. عرّف الـ settings

</div>

```dart
import 'package:flutter/material.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';

const generalSection = SettingSection(
  key: 'general',
  titleKey: 'general',
  icon: Icons.settings,
  order: 0,
);

const themeModeSetting = EnumSetting(
  'theme_mode',
  defaultValue: 'system',
  titleKey: 'theme',
  options: ['system', 'light', 'dark'],
  section: 'general',
  searchTerms: {
    'en': ['theme', 'dark', 'light', 'mode'],
    'ar': ['المظهر', 'داكن', 'فاتح'],
  },
);

const notificationsSetting = BoolSetting(
  'notifications_enabled',
  defaultValue: true,
  titleKey: 'notifications',
  icon: Icons.notifications,
  section: 'general',
);

SettingsRegistry createMyRegistry() {
  return SettingsRegistry.withSettings(
    sections: [generalSection],
    settings: [themeModeSetting, notificationsSetting],
  );
}
```

<div dir="rtl" lang="ar">

### 2. Initialize (تجاوز الـ providers الثلاثة)

</div>

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final en = Map<String, String>.from(
    jsonDecode(await rootBundle.loadString('assets/translations/en.json')) as Map,
  );
  final ar = Map<String, String>.from(
    jsonDecode(await rootBundle.loadString('assets/translations/ar.json')) as Map,
  );

  final settings = await initializeSettings(
    registry: createMyRegistry(),
    storage: SharedPreferencesStorage(),
    localizationProvider: PreIndexedLocalizationProvider({
      'en': en,
      'ar': ar,
    }),
  );

  runApp(
    ProviderScope(
      overrides: [
        settingsControllerProvider.overrideWithValue(settings.controller),
        settingsSearchIndexProvider.overrideWithValue(settings.searchIndex),
        settingsProvidersProvider.overrideWithValue(settings),
      ],
      child: const MyApp(),
    ),
  );
}
```

<div dir="rtl" lang="ar">

### 3. الاستخدام داخل widgets

</div>

```dart
class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watchSetting(notificationsSetting);

    return SwitchSettingsTile.fromSetting(
      setting: notificationsSetting,
      title: 'notifications'.tr(),
      value: enabled,
      onChanged: (value) => ref.updateSetting(notificationsSetting, value),
    );
  }
}
```

<div dir="rtl" lang="ar">

### 4. Registry page

</div>

```dart
RegistrySettingsPage(
  registry: myRegistry,
  settings: ref.settings,
  title: 'settings'.tr(),
  searchHint: 'search_settings'.tr(),
  sectionTitleBuilder: (key) => key.tr(),
  enumLabelBuilder: (key) => key.tr(),
)
```

<div dir="rtl" lang="ar">

نتائج البحث: <span dir="ltr"><code>ref.watch(settingsSearchResultsProvider(query))</code></span>.

</div>

---

<div dir="rtl" lang="ar">

## أنواع الإعدادات

| Type | Class | مثال |
|------|-------|------|
| String | <span dir="ltr"><code>StringSetting</code></span> | أسماء، مسارات |
| Boolean | <span dir="ltr"><code>BoolSetting</code></span> | تفعيل ميزات |
| Integer | <span dir="ltr"><code>IntSetting</code></span> | أعداد، أيام |
| Double | <span dir="ltr"><code>DoubleSetting</code></span> | مقاييس، مسافات |
| Color | <span dir="ltr"><code>ColorSetting</code></span> | ألوان الثيم |
| Enum | <span dir="ltr"><code>EnumSetting</code></span> | خيارات محدودة |
| String List | <span dir="ltr"><code>StringListSetting</code></span> | tags، filters |
| Action | <span dir="ltr"><code>ActionSetting</code></span> | export، about (غير persisted) |

</div>

---

<div dir="rtl" lang="ar">

## بحث متعدد اللغات

مرّر <span dir="ltr"><code>PreIndexedLocalizationProvider</code></span> عند <span dir="ltr"><code>initializeSettings</code></span> حتى تُفهرَس titles وsubtitles وsection titles لكل locale. أضف <span dir="ltr"><code>searchTerms</code></span> للمرادفات.

لصياغة واجهة عربية (أسلوب فصحى، تجنّب الترجمة الحرفية، ومسرد مشترك)، انظر <a href="docs/i18n-ar.md">دليل أسلوب تعريب الواجهة</a>.

</div>

```dart
const languageSetting = EnumSetting(
  'language',
  defaultValue: 'en',
  titleKey: 'language',
  options: ['en', 'ar'],
  searchTerms: {
    'en': ['locale', 'english', 'arabic'],
    'ar': ['لغة', 'إنجليزي', 'عربي'],
  },
);

final results = searchIndex.search('عربي');
```

<div dir="rtl" lang="ar">

اضبط <span dir="ltr"><code>visible: false</code></span> على الإعدادات الداخلية حتى لا تظهر في البحث (<span dir="ltr"><code>order</code></span> وحده لا يخفيها من <span dir="ltr"><code>SearchIndex</code></span>).

</div>

---

<div dir="rtl" lang="ar">

## جرد الـ UI

**Tiles:** <span dir="ltr"><code>SettingsTile</code></span>، <span dir="ltr"><code>SwitchSettingsTile</code></span>، <span dir="ltr"><code>SelectSettingsTile</code></span>، <span dir="ltr"><code>SliderSettingsTile</code></span>، <span dir="ltr"><code>ColorSettingsTile</code></span>، <span dir="ltr"><code>NavigationSettingsTile</code></span>، <span dir="ltr"><code>ActionSettingsTile</code></span>، <span dir="ltr"><code>InfoSettingsTile</code></span>

**Layout:** <span dir="ltr"><code>SettingsSectionWidget</code></span>، <span dir="ltr"><code>SettingsSearchBar</code></span> (<span dir="ltr"><code>persistent</code></span> / <span dir="ltr"><code>compact</code></span>)، <span dir="ltr"><code>SettingAnchorRegistry</code></span> / <span dir="ltr"><code>scrollToSetting</code></span>، <span dir="ltr"><code>SplitScreenLayout</code></span>، <span dir="ltr"><code>RegistrySettingsPage</code></span>، <span dir="ltr"><code>CardSettingsSection</code></span>

**Helpers:** <span dir="ltr"><code>ref.settings</code></span>، <span dir="ltr"><code>ref.watchSetting</code></span> / <span dir="ltr"><code>updateSetting</code></span> / <span dir="ltr"><code>resetSetting</code></span>، <span dir="ltr"><code>settingsSearchResultsProvider</code></span>، <span dir="ltr"><code>buildSearchResultWidgets</code></span>، <span dir="ltr"><code>isSettingEnabled</code></span>

</div>

---

<div dir="rtl" lang="ar">

## Architecture

</div>

```
┌─────────────────────────────────────────────────────────────┐
│                    Your App (Widgets)                       │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│              Riverpod adapter + settings UI                 │
│   • SettingNotifier<T> / SettingsProviders                  │
│   • RegistrySettingsPage, tiles (Riverpod-coupled)          │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│           Core (streams / callbacks, no Riverpod)           │
│   • SettingsController · SettingsRegistry · SearchIndex     │
│   • SettingsStorage abstraction                             │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│   SharedPreferencesStorage · MemoryStorage · custom         │
└─────────────────────────────────────────────────────────────┘
```

---

<div dir="rtl" lang="ar">

## المثال

انظر <span dir="ltr"><a href="example/"><code>example/</code></a></span> للتعريفات والـ init والـ tiles. المثال بأسلوب package (بدون مجلدات platforms)؛ حلّل بـ:

</div>

```bash
cd example && flutter pub get && dart analyze --fatal-infos
```

<div dir="rtl" lang="ar">

للتشغيل، ولّد الـ platforms أولاً (<span dir="ltr"><code>flutter create .</code></span> داخل <span dir="ltr"><code>example/</code></span>). التفاصيل: <span dir="ltr"><a href="example/README.md">example/README.md</a></span>.

</div>

---

<div dir="rtl" lang="ar">

## Branding

كلمة الشعار بخط <span dir="ltr"><strong><a href="https://www.1001fonts.com/baz-font.html">Baz</a></strong></span> (Baz Light) — نفس الـ typeface العربي في <span dir="ltr"><a href="https://github.com/Zyzto/Siglat">Siglat</a></span>. الملف في <span dir="ltr"><a href="assets/fonts/baz-Light.otf"><code>assets/fonts/baz-Light.otf</code></a></span>؛ وملف الـ SVG يضم الحروف كـ outlines حتى يظهر على GitHub/pub.dev دون تحميل الخط.

</div>

---

<div dir="rtl" lang="ar">

## Versioning

انظر <span dir="ltr"><a href="VERSIONING.md">VERSIONING.md</a></span> و<span dir="ltr"><a href="CHANGELOG.md">CHANGELOG.md</a></span>. الوسوم بصيغة <span dir="ltr"><code>vX.Y.Z</code></span> ويجب أن تطابق <span dir="ltr"><code>pubspec.yaml</code></span>.

</div>

---

<div dir="rtl" lang="ar">

## الرخصة

<span dir="ltr"><a href="LICENSE">MPL-2.0</a></span> — weak copyleft، الاستخدام التجاري مسموح. ملفات الحزمة المعدّلة تبقى تحت MPL؛ تطبيقك يمكن أن يبقى closed-source.

</div>
