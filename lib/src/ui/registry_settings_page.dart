/// Flutter Settings Framework
/// Convention-based settings page built from a registry.
///
/// Renders sections and tiles from [SettingsRegistry] with optional search,
/// split layout on landscape, and custom section/tile builders.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/riverpod_adapter.dart';
import '../core/setting_definition.dart';
import '../core/settings_registry.dart';
import 'responsive_helpers.dart';
import 'settings_section.dart';
import 'settings_tile.dart';

/// Convention-based settings page that builds UI from a [SettingsRegistry].
///
/// Override section expansion state by passing [isSectionExpanded] and
/// [onSectionExpansionChanged] (e.g. backed by stored settings). By default
/// expansion is in-memory only.
///
/// Use [sectionContentBuilder] to supply custom content for sections (e.g.
/// Tags, Data, About) that are not just a list of settings. Use [tileBuilder]
/// to override or wrap the default tile for specific settings.
class RegistrySettingsPage extends ConsumerStatefulWidget {
  /// Registry containing sections and setting definitions.
  final SettingsRegistry registry;

  /// Settings providers (e.g. from [ref.settings]).
  final SettingsProviders settings;

  /// Page title (e.g. localized).
  final String title;

  /// Search field hint.
  final String searchHint;

  /// Maps section title key to display string (e.g. [key] => key.tr()).
  final String Function(String sectionKey) sectionTitleBuilder;

  /// Optional: maps enum/option key to display string (e.g. for easy_localization).
  final String Function(String key)? enumLabelBuilder;

  /// Optional: maps sub-section key to display string.
  final String Function(String subSectionKey)? subSectionTitleBuilder;

  /// Optional: per-section custom content. Return custom widgets or modify
  /// [defaultChildren]. If section has no registry settings, [defaultChildren]
  /// is empty and you can return full custom content.
  final List<Widget> Function(String sectionKey, List<Widget> defaultChildren)?
      sectionContentBuilder;

  /// Optional: override or wrap the default tile for a setting.
  final Widget? Function(SettingDefinition setting, Widget defaultTile)?
      tileBuilder;

  /// Optional: section expansion state (when null, uses in-memory state).
  final bool Function(String sectionId)? isSectionExpanded;

  /// Optional: persist section expansion changes.
  final void Function(String sectionId, bool expanded)?
      onSectionExpansionChanged;

  const RegistrySettingsPage({
    super.key,
    required this.registry,
    required this.settings,
    this.title = 'Settings',
    this.searchHint = 'Search settings...',
    this.sectionTitleBuilder = _defaultSectionTitleBuilder,
    this.enumLabelBuilder,
    this.subSectionTitleBuilder,
    this.sectionContentBuilder,
    this.tileBuilder,
    this.isSectionExpanded,
    this.onSectionExpansionChanged,
  });

  static String _defaultSectionTitleBuilder(String key) => key;

  @override
  ConsumerState<RegistrySettingsPage> createState() =>
      _RegistrySettingsPageState();
}

class _RegistrySettingsPageState extends ConsumerState<RegistrySettingsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearchExpanded = false;
  final Map<String, bool> _sectionExpanded = {};
  String? _selectedSectionId;
  Widget? _detailContent;
  String? _detailTitle;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    if (!_searchFocusNode.hasFocus &&
        _searchController.text.trim().isEmpty &&
        _isSearchExpanded) {
      setState(() => _isSearchExpanded = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _searchQuery) setState(() => _searchQuery = query);
  }

  bool _isSectionExpanded(SettingSection section) {
    if (widget.isSectionExpanded != null) {
      return widget.isSectionExpanded!(section.key);
    }
    return _sectionExpanded[section.key] ?? section.initiallyExpanded;
  }

  void _onSectionExpansionChanged(String sectionId, bool expanded) {
    widget.onSectionExpansionChanged?.call(sectionId, expanded);
    if (widget.onSectionExpansionChanged == null) {
      setState(() => _sectionExpanded[sectionId] = expanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.size.width > mediaQuery.size.height;
    final hasSearch = _searchQuery.isNotEmpty;
    final settings = widget.settings;
    final registry = widget.registry;

    final sections = hasSearch
        ? _buildSearchResults(settings, registry)
        : _buildSections(settings, registry, isLandscape, hasSearch);

    final listView = ListView(children: sections);

    if (!isLandscape && _selectedSectionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedSectionId = null;
            _detailContent = null;
            _detailTitle = null;
          });
        }
      });
    }

    final bodyContent = isLandscape
        ? SplitScreenLayout(
            listPane: listView,
            detailPane: _detailContent,
            detailTitle: _detailTitle,
            onCloseDetail: () => setState(() {
              _selectedSectionId = null;
              _detailContent = null;
              _detailTitle = null;
            }),
          )
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: listView,
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [_buildSearchBar()],
      ),
      body: bodyContent,
    );
  }

  Widget _buildSearchBar() {
    if (!_isSearchExpanded) {
      return IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          setState(() => _isSearchExpanded = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _searchFocusNode.requestFocus();
          });
        },
        tooltip: widget.searchHint,
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 300,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _isSearchExpanded = false;
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          hintText: widget.searchHint,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        textInputAction: TextInputAction.search,
        onTapOutside: (_) {
          if (_searchController.text.trim().isEmpty) {
            setState(() => _isSearchExpanded = false);
          }
        },
      ),
    );
  }

  List<Widget> _buildSections(
    SettingsProviders settings,
    SettingsRegistry registry,
    bool isLandscape,
    bool hasSearch,
  ) {
    final result = <Widget>[];
    final sortedSections = registry.getSortedSections();

    for (final section in sortedSections) {
      final visibleSettings = registry.getVisibleSettingsInSection(section.key);
      List<Widget> children;
      if (widget.sectionContentBuilder != null) {
        final defaultChildren = _buildSectionChildren(settings, section.key);
        children = widget.sectionContentBuilder!(section.key, defaultChildren);
      } else {
        children = _buildSectionChildren(settings, section.key);
      }
      if (children.isEmpty && visibleSettings.isEmpty) continue;

      final isExpanded = hasSearch ? true : _isSectionExpanded(section);
      final sectionTitle = widget.sectionTitleBuilder(section.titleKey);
      final icon = section.icon ?? Icons.settings;

      result.add(
        CardSettingsSection(
          title: sectionTitle,
          icon: icon,
          isExpanded: isExpanded,
          onExpansionChanged: hasSearch
              ? null
              : (expanded) => _onSectionExpansionChanged(section.key, expanded),
          sectionId: section.key,
          isSelected: _selectedSectionId == section.key && isLandscape,
          isLandscape: isLandscape,
          onLandscapeTap: () => _showSectionInDetail(
            sectionId: section.key,
            title: sectionTitle,
            content: ListView(
              padding: const EdgeInsets.all(16),
              children: children,
            ),
          ),
          children: children,
        ),
      );
    }
    return result;
  }

  List<Widget> _buildSectionChildren(
    SettingsProviders settings,
    String sectionKey,
  ) {
    final registry = widget.registry;
    final bySub = registry.getSettingsGroupedBySubSection(sectionKey);
    final result = <Widget>[];
    final keys = bySub.keys.toList()
      ..sort((a, b) => (a ?? '').compareTo(b ?? ''));

    for (final subKey in keys) {
      final settingsList = bySub[subKey]!;
      if (subKey != null && subKey.isNotEmpty) {
        final subTitle = widget.subSectionTitleBuilder?.call(subKey) ?? subKey;
        result.add(SettingsSubsectionHeader(
          title: subTitle,
          icon: Icons.subdirectory_arrow_right,
        ));
      }
      for (final setting in settingsList) {
        final tile = _buildTileForSetting(settings, setting);
        if (tile != null) result.add(tile);
      }
    }
    return result;
  }

  void _showSectionInDetail({
    required String sectionId,
    required String title,
    required Widget content,
  }) {
    setState(() {
      _selectedSectionId = sectionId;
      _detailTitle = title;
      _detailContent = content;
    });
  }

  List<Widget> _buildSearchResults(
    SettingsProviders settings,
    SettingsRegistry registry,
  ) {
    final results = ref.watch(settingsSearchResultsProvider(_searchQuery));
    if (results.isEmpty) {
      return [
        EmptySearchResults(
          query: _searchQuery,
          message: 'No settings found for "$_searchQuery"',
        ),
      ];
    }
    return buildSearchResultWidgets(
      results,
      tileBuilder: (setting) {
        final tile = _buildTileForSetting(settings, setting);
        return tile ?? const SizedBox.shrink();
      },
      sectionTitleBuilder: (key) => widget.sectionTitleBuilder(key),
    );
  }

  Widget? _buildTileForSetting(
    SettingsProviders settings,
    SettingDefinition setting,
  ) {
    final defaultTile = _buildDefaultTile(settings, setting);
    if (defaultTile == null) return null;
    final overridden = widget.tileBuilder?.call(setting, defaultTile);
    return overridden ?? defaultTile;
  }

  Widget? _buildDefaultTile(
    SettingsProviders settings,
    SettingDefinition setting,
  ) {
    final enabled = isSettingEnabled(settings, setting, ref);
    final title = widget.sectionTitleBuilder(setting.titleKey);
    final subtitle = setting.subtitleKey != null
        ? widget.sectionTitleBuilder(setting.subtitleKey!)
        : null;

    String enumLabel(String value) {
      if (setting is EnumSetting && setting.useRawLabels) return value;
      if (setting is EnumSetting && setting.optionLabels != null) {
        final key = setting.optionLabels![value];
        if (key != null) return widget.enumLabelBuilder?.call(key) ?? key;
      }
      return widget.enumLabelBuilder?.call(value) ?? value;
    }

    if (setting is BoolSetting) {
      final value = ref.watch(settings.provider(setting));
      return SwitchSettingsTile.fromSetting(
        setting: setting,
        title: title,
        subtitle: subtitle,
        value: value,
        enabled: enabled,
        onChanged: enabled
            ? (v) => ref.read(settings.provider(setting).notifier).set(v)
            : null,
      );
    }
    if (setting is EnumSetting) {
      final value = ref.watch(settings.provider(setting));
      return EnumSettingsTile.fromSetting(
        setting: setting,
        title: title,
        subtitle: enumLabel(value),
        value: value,
        labelBuilder: enumLabel,
        enabled: enabled,
        dialogTitle: title,
        onChanged: enabled
            ? (v) => ref.read(settings.provider(setting).notifier).set(v)
            : null,
      );
    }
    if (setting is IntSetting) {
      final value = ref.watch(settings.provider(setting));
      return IntSettingsTile.fromSetting(
        setting: setting,
        title: title,
        subtitle: value.toString(),
        value: value,
        enabled: enabled,
        dialogTitle: title,
        onChanged: enabled
            ? (v) => ref.read(settings.provider(setting).notifier).set(v)
            : null,
      );
    }
    if (setting is DoubleSetting) {
      final value = ref.watch(settings.provider(setting));
      return SliderSettingsTile.fromDoubleSetting(
        setting: setting,
        title: title,
        value: value,
        enabled: enabled,
        dialogTitle: title,
        onChanged: enabled
            ? (v) => ref.read(settings.provider(setting).notifier).set(v)
            : null,
      );
    }
    if (setting is ColorSetting) {
      final value = ref.watch(settings.provider(setting));
      return ColorSettingsTile.fromSetting(
        setting: setting,
        title: title,
        value: value,
        enabled: enabled,
        dialogTitle: title,
        onChanged: enabled
            ? (v) => ref.read(settings.provider(setting).notifier).set(v)
            : null,
      );
    }
    if (setting is StringSetting) {
      final value = ref.watch(settings.provider(setting));
      return ListTile(
        leading: setting.icon != null ? Icon(setting.icon) : null,
        title: Text(title),
        subtitle: Text(value),
        enabled: enabled,
      );
    }
    return null;
  }
}
