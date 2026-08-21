/// Flutter Settings Framework
/// Convention-based settings page built from a registry.
///
/// Renders sections and tiles from [SettingsRegistry] with optional search,
/// split layout on landscape, and custom section/tile builders.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/riverpod_adapter.dart';
import '../core/search_index.dart';
import '../core/setting_definition.dart';
import '../core/settings_registry.dart';
import 'responsive_helpers.dart';
import 'setting_scroll_target.dart';
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
///
/// Search uses a persistent bar under the app bar. Selecting a result clears
/// the query, expands the section, and scrolls to / highlights the setting.
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

  /// Optional: filter search results before display (e.g. hide platform sections).
  final bool Function(SearchResult result)? searchResultFilter;

  /// Empty-results message. Receives the query.
  final String Function(String query)? emptySearchMessageBuilder;

  /// Extra [AppBar] actions (e.g. a layout toggle in the example).
  final List<Widget>? actions;

  /// When null, uses a split list/detail pane if width > height.
  /// Set to `true`/`false` to force desktop or stacked (mobile) layout.
  final bool? splitLayout;

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
    this.searchResultFilter,
    this.emptySearchMessageBuilder,
    this.actions,
    this.splitLayout,
  });

  static String _defaultSectionTitleBuilder(String key) => key;

  @override
  ConsumerState<RegistrySettingsPage> createState() =>
      _RegistrySettingsPageState();
}

class _RegistrySettingsPageState extends ConsumerState<RegistrySettingsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final SettingAnchorRegistry _anchors = SettingAnchorRegistry();
  String _searchQuery = '';
  final Map<String, bool> _sectionExpanded = {};
  String? _selectedSectionId;
  Widget? _detailContent;
  String? _detailTitle;
  String? _pendingScrollKey;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _anchors.dispose();
    super.dispose();
  }

  bool _useSplitLayout(BuildContext context) {
    if (widget.splitLayout != null) return widget.splitLayout!;
    final size = MediaQuery.sizeOf(context);
    return size.width > size.height;
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query == _searchQuery) return;
    setState(() {
      _searchQuery = query;
      if (query.isNotEmpty) {
        _selectedSectionId = null;
        _detailContent = null;
        _detailTitle = null;
      }
    });
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

  Future<void> _onResultSelected(SearchResult result) async {
    final setting = result.setting;
    final sectionKey = setting.section;
    final section =
        sectionKey != null ? widget.registry.getSection(sectionKey) : null;
    final useSplit = _useSplitLayout(context);
    final children = sectionKey != null
        ? _sectionChildren(widget.settings, sectionKey)
        : const <Widget>[];

    setState(() {
      _searchQuery = '';
      _pendingScrollKey = setting.key;
      if (sectionKey != null) {
        _sectionExpanded[sectionKey] = true;
        widget.onSectionExpansionChanged?.call(sectionKey, true);
      }
      if (useSplit && section != null && sectionKey != null) {
        _selectedSectionId = sectionKey;
        _detailTitle = widget.sectionTitleBuilder(section.titleKey);
        _detailContent = ListView(
          padding: const EdgeInsets.all(16),
          children: children,
        );
      }
    });
    _searchController.removeListener(_onSearchChanged);
    _searchController.clear();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _pendingScrollKey != setting.key) return;
      await _anchors.scrollTo(setting.key, controller: _scrollController);
      _pendingScrollKey = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSplit = _useSplitLayout(context);
    final hasSearch = _searchQuery.isNotEmpty;
    final settings = widget.settings;
    final registry = widget.registry;

    final searchResults = hasSearch
        ? ref.watch(settingsSearchResultsProvider(_searchQuery))
        : const <SearchResult>[];
    final filteredSearch = hasSearch
        ? _filterSearchResults(searchResults)
        : const <SearchResult>[];

    final Widget listPane;
    if (hasSearch && filteredSearch.isEmpty) {
      listPane = EmptySearchResults(
        query: _searchQuery,
        message: widget.emptySearchMessageBuilder?.call(_searchQuery) ??
            'No settings found for "$_searchQuery"',
      );
    } else if (hasSearch) {
      listPane = ListView(
        children: _searchResultWidgets(settings, registry, filteredSearch),
      );
    } else {
      listPane = ListView(
        controller: _scrollController,
        children: _buildSections(settings, registry, isSplit),
      );
    }

    if (!isSplit && _selectedSectionId != null) {
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

    final bodyContent = isSplit && !hasSearch
        ? SplitScreenLayout(
            listPane: listPane,
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
              child: listPane,
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: widget.actions,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SettingsSearchBar(
              mode: SettingsSearchBarMode.persistent,
              hintText: widget.searchHint,
              controller: _searchController,
              focusNode: _searchFocusNode,
            ),
          ),
          Expanded(child: bodyContent),
        ],
      ),
    );
  }

  List<Widget> _buildSections(
    SettingsProviders settings,
    SettingsRegistry registry,
    bool isLandscape,
  ) {
    final result = <Widget>[];
    final sortedSections = registry.getSortedSections();

    for (final section in sortedSections) {
      final visibleSettings = registry.getVisibleSettingsInSection(section.key);
      List<Widget> children;
      if (widget.sectionContentBuilder != null) {
        final defaultChildren = _sectionChildren(settings, section.key);
        children = widget.sectionContentBuilder!(section.key, defaultChildren);
      } else {
        children = _sectionChildren(settings, section.key);
      }
      if (children.isEmpty && visibleSettings.isEmpty) continue;

      final isExpanded = _isSectionExpanded(section);
      final sectionTitle = widget.sectionTitleBuilder(section.titleKey);
      final icon = section.icon ?? Icons.settings;

      result.add(
        CardSettingsSection(
          title: sectionTitle,
          icon: icon,
          isExpanded: isExpanded,
          onExpansionChanged: (expanded) =>
              _onSectionExpansionChanged(section.key, expanded),
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

  List<Widget> _sectionChildren(
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
        if (setting is ActionSetting) {
          final tile = _buildTileForSetting(settings, setting);
          if (tile != null) {
            result.add(_anchors.wrap(setting.key, tile));
          }
          continue;
        }
        final tile = _buildTileForSetting(settings, setting);
        if (tile != null) result.add(_anchors.wrap(setting.key, tile));
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

  List<SearchResult> _filterSearchResults(List<SearchResult> results) {
    final filter = widget.searchResultFilter;
    if (filter == null) return results;
    return results.where(filter).toList();
  }

  List<Widget> _searchResultWidgets(
    SettingsProviders settings,
    SettingsRegistry registry,
    List<SearchResult> results,
  ) {
    return buildSearchResultWidgets(
      results,
      tileBuilder: (setting) {
        final tile = _buildTileForSetting(settings, setting);
        return tile ??
            ListTile(
              leading: setting.icon != null ? Icon(setting.icon) : null,
              title: Text(widget.sectionTitleBuilder(setting.titleKey)),
              subtitle: setting.subtitleKey != null
                  ? Text(widget.sectionTitleBuilder(setting.subtitleKey!))
                  : null,
            );
      },
      sectionTitleBuilder: (key) {
        final section = registry.getSection(key);
        if (section != null) {
          return widget.sectionTitleBuilder(section.titleKey);
        }
        return widget.sectionTitleBuilder(key);
      },
      settingTitleBuilder: (setting) =>
          widget.sectionTitleBuilder(setting.titleKey),
      onResultSelected: _onResultSelected,
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

    if (setting is ActionSetting) {
      return ActionSettingsTile(
        leading: setting.icon != null ? Icon(setting.icon) : null,
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        onTap: null,
      );
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
