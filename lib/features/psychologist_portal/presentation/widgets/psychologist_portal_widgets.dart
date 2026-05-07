import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/psychologist_portal_mock_data.dart';
import '../pages/psychologist_portal_pages.dart';

class PsychologistPortalPalette {
  const PsychologistPortalPalette._();

  static const Color primary = Color(0xFFFF3B93);
  static const Color primaryDark = Color(0xFFFF267B);
  static const Color softPink = Color(0xFFFFEDF5);
  static const Color softRose = Color(0xFFFFF3F8);
  static const Color softPeach = Color(0xFFFFF6F2);
  static const Color text = Color(0xFF1F2430);
  static const Color muted = Color(0xFF7A8090);
  static const Color border = Color(0xFFF3DCE6);
  static const Color success = Color(0xFF30B990);
}

enum PsychologistNavTab { home, clients, cases, schedule, profile }

class PsychologistPortalScaffold extends StatelessWidget {
  const PsychologistPortalScaffold({
    super.key,
    required this.body,
    this.activeTab,
    this.title,
    this.topBar,
    this.floatingActionButton,
    this.showBottomNavigation = true,
    this.backgroundColor,
  });

  final Widget body;
  final PsychologistNavTab? activeTab;
  final String? title;
  final Widget? topBar;
  final Widget? floatingActionButton;
  final bool showBottomNavigation;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? PsychologistPortalPalette.softRose,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (topBar != null)
              topBar!
            else if (title != null)
              PsychologistSimpleTopBar(title: title!),
            Expanded(child: body),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showBottomNavigation && activeTab != null
          ? PsychologistBottomNavigation(activeTab: activeTab!)
          : null,
    );
  }
}

class PsychologistSimpleTopBar extends StatelessWidget {
  const PsychologistSimpleTopBar({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: <Widget>[
          leading ?? const SizedBox(width: 32),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: PsychologistPortalPalette.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          trailing ?? const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class PsychologistBottomNavigation extends StatelessWidget {
  const PsychologistBottomNavigation({super.key, required this.activeTab});

  final PsychologistNavTab activeTab;

  @override
  Widget build(BuildContext context) {
    final items =
        <({PsychologistNavTab tab, IconData icon, String label, String path})>[
          (
            tab: PsychologistNavTab.home,
            icon: Icons.home_outlined,
            label: 'Home',
            path: PsychologistDashboardPage.path,
          ),
          (
            tab: PsychologistNavTab.clients,
            icon: Icons.people_outline_rounded,
            label: 'Clients',
            path: PsychologistClientsPage.path,
          ),
          (
            tab: PsychologistNavTab.cases,
            icon: Icons.folder_outlined,
            label: 'Cases',
            path: PsychologistCasesPage.path,
          ),
          (
            tab: PsychologistNavTab.schedule,
            icon: Icons.calendar_month_outlined,
            label: 'Schedule',
            path: PsychologistSchedulePage.path,
          ),
          (
            tab: PsychologistNavTab.profile,
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            path: PsychologistProfilePage.path,
          ),
        ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: PsychologistPortalPalette.border),
        ),
      ),
      child: Row(
        children: items.map((item) {
          final isSelected = item.tab == activeTab;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: isSelected ? null : () => context.go(item.path),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      item.icon,
                      size: 22,
                      color: isSelected
                          ? PsychologistPortalPalette.primary
                          : const Color(0xFF7B8192),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? PsychologistPortalPalette.primary
                            : const Color(0xFF7B8192),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PsychologistSurfaceCard extends StatelessWidget {
  const PsychologistSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PsychologistPortalPalette.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12E67AA7),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PsychologistSectionHeader extends StatelessWidget {
  const PsychologistSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: PsychologistPortalPalette.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionLabel != null)
          InkWell(
            onTap: onTap,
            child: Text(
              actionLabel!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: PsychologistPortalPalette.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class PsychologistSearchBar extends StatelessWidget {
  const PsychologistSearchBar({
    super.key,
    required this.hintText,
    this.showFilter = true,
  });

  final String hintText;
  final bool showFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PsychologistPortalPalette.border),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.search_rounded, color: Color(0xFF8C8FA1)),
                const SizedBox(width: 10),
                Text(
                  hintText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showFilter) ...<Widget>[
          const SizedBox(width: 10),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PsychologistPortalPalette.border),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: PsychologistPortalPalette.text,
            ),
          ),
        ],
      ],
    );
  }
}

class PsychologistStatusChip extends StatelessWidget {
  const PsychologistStatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PsychologistPrimaryButton extends StatelessWidget {
  const PsychologistPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isOutlined = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    final background = isOutlined
        ? Colors.white
        : PsychologistPortalPalette.primary;
    final foreground = isOutlined
        ? PsychologistPortalPalette.primary
        : Colors.white;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isOutlined
                ? PsychologistPortalPalette.primary.withValues(alpha: 0.34)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, color: foreground, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PsychologistSegmentedSwitch extends StatelessWidget {
  const PsychologistSegmentedSwitch({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.selectLeft,
  });

  final String leftLabel;
  final String rightLabel;
  final bool selectLeft;

  @override
  Widget build(BuildContext context) {
    Widget buildSegment(String label, bool selected) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? PsychologistPortalPalette.primary
                : const Color(0xFFFFF5F8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: selected ? Colors.white : PsychologistPortalPalette.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PsychologistPortalPalette.border),
      ),
      child: Row(
        children: <Widget>[
          buildSegment(leftLabel, selectLeft),
          const SizedBox(width: 8),
          buildSegment(rightLabel, !selectLeft),
        ],
      ),
    );
  }
}

class PsychologistAvatar extends StatelessWidget {
  const PsychologistAvatar({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.radius = 24,
  });

  final String label;
  final Color backgroundColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        label.substring(0, 1),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class PsychologistClientTile extends StatelessWidget {
  const PsychologistClientTile({super.key, required this.client, this.onTap});

  final PsychologistClientPreview client;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: PsychologistSurfaceCard(
        child: Row(
          children: <Widget>[
            PsychologistAvatar(
              label: client.name,
              backgroundColor: client.accent,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    client.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: PsychologistPortalPalette.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${client.age} tahun  •  ${client.gender}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PsychologistPortalPalette.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${client.caseCount} Case  •  ${client.lastSessionLabel}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PsychologistPortalPalette.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF8C8FA1)),
          ],
        ),
      ),
    );
  }
}

class PsychologistCaseTile extends StatelessWidget {
  const PsychologistCaseTile({super.key, required this.item, this.onTap});

  final PsychologistCasePreview item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: PsychologistSurfaceCard(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.clientName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: PsychologistPortalPalette.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.topic,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PsychologistPortalPalette.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Session: ${item.sessionCount}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PsychologistPortalPalette.text,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8C8FA1),
                ),
                const SizedBox(height: 18),
                PsychologistStatusChip(
                  label: item.statusLabel,
                  color: item.statusTone,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
