# Arabic UI localization style guide

Guidance for host-app UI strings (titles, buttons, errors, notifications) when shipping Arabic with **Edadat** (`flutter_settings_framework`) and bilingual search.

Tone target: polished Modern Standard Arabic (**Fusha**), in the spirit of classic **Spacetoon / Venus Centre** animation adaptations — clear, welcoming, and lightly heroic, not dry dictionary calques.

---

## Voice

- Prefer expressive, grammatically precise MSA that feels natural on a settings screen.
- Stay welcoming and confident; avoid harsh “system failure” phrasing for everyday errors.
- Balance classical eloquence with modern digital clarity — no archaic or poetic words that confuse users.

---

## Anti-calque rules

1. **Restructure natively.** Do not mirror English word order, passive voice, or phrasal verbs. Prefer Verb–Subject–Object or natural nominal sentences.
2. **No awkward transliteration.** Do not force English jargon into clumsy Arabic when a standard UI term exists (e.g. **تحديث**, **الإعدادات**). Literal calques like a stiff “انقر هنا” for “Click here” are a last resort when a more organic idiom fits.
3. **Encourage, don’t scold.** Soften failures: *عذراً، حدث خطأ ما* rather than cold machine blame.

---

## UI ergonomics

- Keep labels short enough for tiles, buttons, headers, and cards (avoid layout overflow).
- Prefer one clear idea per string; drop filler that English sometimes needs.
- For loading states, **جاري التحميل...** is fine; warmer copy like **يرجى الانتظار قليلاً...** is welcome when space allows.

---

## Core glossary

| English | Arabic |
|---------|--------|
| App / Software | تطبيق |
| Settings | الإعدادات |
| Profile | الملف الشخصي |
| Loading... | جاري التحميل... / يرجى الانتظار قليلاً... |
| Error / Failed | عذراً، حدث خطأ ما |
| Appearance | المظهر |
| Theme | السمة |
| Language | اللغة |
| Dark / Light | داكن / فاتح |
| Export data | تصدير البيانات |
| Search | بحث |
| Cancel | إلغاء |
| Confirm | تأكيد |
| Select | اختيار |
| Undo | تراجع |

Use these forms consistently in catalogs, `titleKey` values, and `searchTerms['ar']` synonyms.

---

## Examples

Prefer the **natural** column over literal English structure.

| Context | English | Prefer | Avoid (calque / stiff) |
|---------|---------|--------|-------------------------|
| Button | Save | حفظ | قم بحفظ التغييرات الآن |
| Empty search | No settings found for "…" | لم يُعثر على إعدادات تطابق «…» | لا توجد إعدادات وُجدت لـ "…" |
| Snackbar | Copied to clipboard | نُسخ إلى الحافظة | تم النسخ إلى الـ clipboard |
| Error | Something went wrong | عذراً، حدث خطأ ما | فشلت العملية / خطأ النظام |
| Hint | Search settings... | ابحث في الإعدادات... | ابحث settings... |
| Confirm | Are you sure? | هل أنت متأكد؟ | هل أنت متأكد من أنك تريد المتابعة بهذا الإجراء؟ |

<div dir="rtl" lang="ar">

**عيّنة قصيرة**

- الإعدادات · المظهر · السمة · اللغة
- جاري التحميل... · عذراً، حدث خطأ ما · تراجع

</div>

---

## How it fits Edadat

Edadat indexes `titleKey` / subtitle / section titles through `PreIndexedLocalizationProvider` (and optional `searchTerms` per locale). Arabic entries in your JSON catalogs and `searchTerms['ar']` should follow this glossary so search and UI stay aligned.

See [Multi-language search](../README.md#multi-language-search) in the English README and [بحث متعدد اللغات](../README.ar.md#بحث-متعدد-اللغات) in the Arabic README for wiring details. This guide does not change runtime APIs.
