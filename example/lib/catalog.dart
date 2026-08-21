import 'package:flutter/material.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';

/// Bilingual catalogs for titles, subtitles, enum labels, and search.
const exampleTranslations = <String, Map<String, String>>{
  'en': {
    'app_title': 'Edadat',
    'search_hint': 'Search settings...',
    'empty_search': 'No settings found for "{query}"',
    'general': 'General',
    'appearance': 'Appearance',
    'behavior': 'Behavior',
    'data': 'Data',
    'about': 'About',
    'language': 'Language',
    'language_subtitle': 'Interface language',
    'theme': 'Theme',
    'theme_subtitle': 'Light, dark, or system',
    'notifications': 'Notifications',
    'notifications_subtitle': 'Allow alerts and reminders',
    'display_name': 'Display name',
    'display_name_subtitle': 'Shown on the profile tile',
    'theme_color': 'Accent color',
    'theme_color_subtitle': 'Seed for Material color scheme',
    'font_size': 'Font size',
    'card_elevation': 'Card elevation',
    'auto_lock': 'Auto-lock',
    'auto_lock_subtitle': 'Idle minutes before lock',
    'quiet_hours': 'Quiet hours',
    'quiet_hours_subtitle': 'Silence notifications at night',
    'quiet_hours_start': 'Quiet hours start',
    'quiet_hours_start_subtitle': 'Hour of day (0–23)',
    'export': 'Export settings',
    'export_subtitle': 'Copy a JSON snapshot',
    'reset': 'Reset to defaults',
    'reset_subtitle': 'Restore every setting',
    'tags': 'Tags',
    'version': 'Version',
    'license': 'License',
    'system': 'System',
    'light': 'Light',
    'dark': 'Dark',
    'en': 'English',
    'ar': 'Arabic',
    'small': 'Small',
    'normal': 'Normal',
    'large': 'Large',
    'extra_large': 'Extra large',
    'copied': 'Copied to clipboard',
    'reset_done': 'Settings reset',
    'name_dialog': 'Display name',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'layout_mobile': 'Mobile view',
    'layout_desktop': 'Desktop view',
  },
  'ar': {
    'app_title': 'إعدادات',
    'search_hint': 'ابحث في الإعدادات...',
    'empty_search': 'لم يُعثر على إعدادات تطابق «{query}»',
    'general': 'عام',
    'appearance': 'المظهر',
    'behavior': 'السلوك',
    'data': 'البيانات',
    'about': 'حول',
    'language': 'اللغة',
    'language_subtitle': 'لغة الواجهة',
    'theme': 'السمة',
    'theme_subtitle': 'فاتح أو داكن أو تلقائي',
    'notifications': 'الإشعارات',
    'notifications_subtitle': 'السماح بالتنبيهات والتذكيرات',
    'display_name': 'الاسم المعروض',
    'display_name_subtitle': 'يظهر في بطاقة الملف',
    'theme_color': 'لون التمييز',
    'theme_color_subtitle': 'أساس مخطط ألوان Material',
    'font_size': 'حجم الخط',
    'card_elevation': 'ارتفاع البطاقة',
    'auto_lock': 'القفل التلقائي',
    'auto_lock_subtitle': 'دقائق الخمول قبل القفل',
    'quiet_hours': 'ساعات الهدوء',
    'quiet_hours_subtitle': 'كتم الإشعارات ليلاً',
    'quiet_hours_start': 'بداية ساعات الهدوء',
    'quiet_hours_start_subtitle': 'ساعة اليوم (0–23)',
    'export': 'تصدير الإعدادات',
    'export_subtitle': 'نسخ لقطة JSON',
    'reset': 'استعادة الافتراضي',
    'reset_subtitle': 'إعادة كل إعداد',
    'tags': 'الوسوم',
    'version': 'الإصدار',
    'license': 'الرخصة',
    'system': 'تلقائي',
    'light': 'فاتح',
    'dark': 'داكن',
    'en': 'الإنجليزية',
    'ar': 'العربية',
    'small': 'صغير',
    'normal': 'عادي',
    'large': 'كبير',
    'extra_large': 'كبير جداً',
    'copied': 'نُسخ إلى الحافظة',
    'reset_done': 'أُعيدت الإعدادات',
    'name_dialog': 'الاسم المعروض',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'layout_mobile': 'عرض الجوال',
    'layout_desktop': 'عرض سطح المكتب',
  },
};

const generalSection = SettingSection(
  key: 'general',
  titleKey: 'general',
  icon: Icons.settings,
  order: 0,
  initiallyExpanded: true,
);

const appearanceSection = SettingSection(
  key: 'appearance',
  titleKey: 'appearance',
  icon: Icons.palette,
  order: 1,
  initiallyExpanded: true,
);

const behaviorSection = SettingSection(
  key: 'behavior',
  titleKey: 'behavior',
  icon: Icons.tune,
  order: 2,
  initiallyExpanded: true,
);

const dataSection = SettingSection(
  key: 'data',
  titleKey: 'data',
  icon: Icons.storage,
  order: 3,
  initiallyExpanded: true,
);

const aboutSection = SettingSection(
  key: 'about',
  titleKey: 'about',
  icon: Icons.info_outline,
  order: 4,
  initiallyExpanded: true,
);

const languageSetting = EnumSetting(
  'language',
  defaultValue: 'en',
  titleKey: 'language',
  subtitleKey: 'language_subtitle',
  options: ['en', 'ar'],
  optionLabels: {'en': 'en', 'ar': 'ar'},
  icon: Icons.language,
  section: 'general',
  order: 0,
  searchTerms: {
    'en': ['locale', 'english', 'arabic'],
    'ar': ['لغة', 'إنجليزي', 'عربي'],
  },
);

const themeModeSetting = EnumSetting(
  'theme_mode',
  defaultValue: 'system',
  titleKey: 'theme',
  subtitleKey: 'theme_subtitle',
  options: ['system', 'light', 'dark'],
  optionLabels: {
    'system': 'system',
    'light': 'light',
    'dark': 'dark',
  },
  icon: Icons.brightness_6,
  section: 'general',
  order: 1,
  searchTerms: {
    'en': ['theme', 'dark', 'light', 'mode', 'appearance'],
    'ar': ['السمة', 'داكن', 'فاتح', 'مظهر'],
  },
);

const notificationsSetting = BoolSetting(
  'notifications_enabled',
  defaultValue: true,
  titleKey: 'notifications',
  subtitleKey: 'notifications_subtitle',
  icon: Icons.notifications_outlined,
  section: 'general',
  order: 2,
  searchTerms: {
    'en': ['alerts', 'notify', 'push'],
    'ar': ['تنبيهات', 'إشعار'],
  },
);

const displayNameSetting = StringSetting(
  'display_name',
  defaultValue: 'Ada',
  titleKey: 'display_name',
  subtitleKey: 'display_name_subtitle',
  icon: Icons.badge_outlined,
  section: 'general',
  order: 3,
  maxLength: 32,
  searchTerms: {
    'en': ['name', 'profile'],
    'ar': ['اسم', 'ملف'],
  },
);

const themeColorSetting = ColorSetting(
  'theme_color',
  defaultValue: 0xFF8B6914,
  titleKey: 'theme_color',
  subtitleKey: 'theme_color_subtitle',
  icon: Icons.color_lens_outlined,
  section: 'appearance',
  order: 0,
  colorOptions: [
    0xFF8B6914,
    0xFF6200EE,
    0xFF006C51,
    0xFFB3261E,
    0xFF1D4E89,
  ],
  searchTerms: {
    'en': ['color', 'accent', 'seed'],
    'ar': ['لون', 'تمييز'],
  },
);

const fontSizeScaleSetting = EnumSetting(
  'font_size_scale',
  defaultValue: 'normal',
  titleKey: 'font_size',
  options: ['small', 'normal', 'large', 'extra_large'],
  optionLabels: {
    'small': 'small',
    'normal': 'normal',
    'large': 'large',
    'extra_large': 'extra_large',
  },
  icon: Icons.format_size,
  section: 'appearance',
  order: 1,
  searchTerms: {
    'en': ['font', 'text', 'scale', 'type'],
    'ar': ['خط', 'نص', 'حجم'],
  },
);

const cardElevationSetting = DoubleSetting(
  'card_elevation',
  defaultValue: 1.0,
  min: 0.0,
  max: 8.0,
  step: 0.5,
  titleKey: 'card_elevation',
  icon: Icons.layers_outlined,
  section: 'appearance',
  order: 2,
  searchTerms: {
    'en': ['elevation', 'shadow', 'card'],
    'ar': ['ظل', 'بطاقة', 'ارتفاع'],
  },
);

const autoLockSetting = IntSetting(
  'auto_lock_minutes',
  defaultValue: 5,
  min: 1,
  max: 30,
  step: 1,
  titleKey: 'auto_lock',
  subtitleKey: 'auto_lock_subtitle',
  icon: Icons.lock_clock_outlined,
  section: 'behavior',
  order: 0,
  searchTerms: {
    'en': ['lock', 'idle', 'timeout'],
    'ar': ['قفل', 'خمول'],
  },
);

const quietHoursSetting = BoolSetting(
  'quiet_hours',
  defaultValue: false,
  titleKey: 'quiet_hours',
  subtitleKey: 'quiet_hours_subtitle',
  icon: Icons.bedtime_outlined,
  section: 'behavior',
  order: 1,
  searchTerms: {
    'en': ['dnd', 'night', 'silence'],
    'ar': ['هدوء', 'ليل', 'كتم'],
  },
);

const quietHoursStartSetting = IntSetting(
  'quiet_hours_start',
  defaultValue: 22,
  min: 0,
  max: 23,
  step: 1,
  titleKey: 'quiet_hours_start',
  subtitleKey: 'quiet_hours_start_subtitle',
  icon: Icons.schedule,
  section: 'behavior',
  order: 2,
  dependsOn: 'quiet_hours',
  enabledWhen: true,
  searchTerms: {
    'en': ['start', 'hour', 'schedule'],
    'ar': ['بداية', 'ساعة'],
  },
);

const exportSetting = ActionSetting(
  'export_settings',
  titleKey: 'export',
  subtitleKey: 'export_subtitle',
  icon: Icons.ios_share,
  section: 'data',
  order: 0,
  searchTerms: {
    'en': ['export', 'json', 'backup'],
    'ar': ['تصدير', 'نسخ'],
  },
);

const resetSetting = ActionSetting(
  'reset_settings',
  titleKey: 'reset',
  subtitleKey: 'reset_subtitle',
  icon: Icons.restart_alt,
  section: 'data',
  order: 1,
  searchTerms: {
    'en': ['reset', 'defaults', 'restore'],
    'ar': ['استعادة', 'افتراضي'],
  },
);

const tagsSetting = StringListSetting(
  'tags',
  defaultValue: ['offline', 'bilingual'],
  titleKey: 'tags',
  icon: Icons.label_outline,
  section: 'data',
  order: 2,
  searchTerms: {
    'en': ['tags', 'labels', 'filters'],
    'ar': ['وسوم', 'تسميات'],
  },
);

const versionSetting = ActionSetting(
  'about_version',
  titleKey: 'version',
  icon: Icons.info_outline,
  section: 'about',
  order: 0,
  searchTerms: {
    'en': ['version', 'about', 'edadat'],
    'ar': ['إصدار', 'حول'],
  },
);

const licenseSetting = ActionSetting(
  'about_license',
  titleKey: 'license',
  icon: Icons.gavel_outlined,
  section: 'about',
  order: 1,
  searchTerms: {
    'en': ['license', 'mpl'],
    'ar': ['رخصة'],
  },
);

SettingsRegistry createExampleRegistry() {
  return SettingsRegistry.withSettings(
    sections: [
      generalSection,
      appearanceSection,
      behaviorSection,
      dataSection,
      aboutSection,
    ],
    settings: [
      languageSetting,
      themeModeSetting,
      notificationsSetting,
      displayNameSetting,
      themeColorSetting,
      fontSizeScaleSetting,
      cardElevationSetting,
      autoLockSetting,
      quietHoursSetting,
      quietHoursStartSetting,
      exportSetting,
      resetSetting,
      tagsSetting,
      versionSetting,
      licenseSetting,
    ],
  );
}

String translateExample(String key, String locale) {
  return exampleTranslations[locale]?[key] ??
      exampleTranslations['en']?[key] ??
      key;
}

PreIndexedLocalizationProvider createExampleLocalization() {
  return PreIndexedLocalizationProvider({
    for (final entry in exampleTranslations.entries)
      entry.key: Map<String, String>.from(entry.value),
  });
}

Future<SettingsProviders> bootExampleSettings({
  SettingsStorage? storage,
}) {
  return initializeSettings(
    registry: createExampleRegistry(),
    storage: storage ?? SharedPreferencesStorage(),
    localizationProvider: createExampleLocalization(),
  );
}

double fontScaleFor(String size) {
  switch (size) {
    case 'small':
      return 0.9;
    case 'large':
      return 1.15;
    case 'extra_large':
      return 1.3;
    case 'normal':
    default:
      return 1.0;
  }
}

ThemeMode themeModeFor(String mode) {
  switch (mode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}
