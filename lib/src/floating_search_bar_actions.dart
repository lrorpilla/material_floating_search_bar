import 'package:flutter/material.dart';

import 'floating_search_bar.dart';
import 'widgets/widgets.dart';

// ignore_for_file: public_member_api_docs

/// A widget to be displayed in a row before or after the
/// input text of a [FloatingSearchBar].
///
/// Typically this widget wraps a [CircularButton].
class FloatingSearchBarAction extends StatelessWidget {
  /// The action.
  ///
  /// Typically a [CircularButton].
  final Widget? child;

  /// A builder that can be used when the action needs
  /// to react to changes in its [FloatingSearchBar].
  ///
  /// View [FloatingSearchBarAction.searchToClear] for an example.
  final Widget Function(BuildContext context, Animation<double> animation)?
      builder;

  /// Whether this action should be shown when the [FloatingSearchBar]
  /// is opened.
  ///
  /// If false, this action will be animated out when the
  /// bar [FloatingSearchBar] closed.
  final bool showIfOpened;

  /// Whether this action should be shown when the [FloatingSearchBar]
  /// is closed.
  ///
  /// If false, this action will be animated out when the
  /// bar [FloatingSearchBar] closed.
  final bool showIfClosed;

  /// Creates a widget to be displayed in a row before or after the
  /// input text of a [FloatingSearchBar].
  ///
  /// Typically this widget wraps a [CircularButton].
  const FloatingSearchBarAction({
    Key? key,
    this.child,
    this.builder,
    this.showIfOpened = false,
    this.showIfClosed = true,
  })  : assert(builder != null || child != null),
        super(key: key);

  /// Whether this [FloatingSearchBarAction] is shown when opened
  /// and when closed.
  bool get isAlwaysShown => showIfOpened && showIfClosed;

  /// A hamburger menu that when tapped opens the [Drawer]
  /// of the nearest [Scaffold].
  ///
  /// When the [FloatingSearchBar] opens, the hamburger
  /// transitions into a back button.
  factory FloatingSearchBarAction.hamburgerToBack({
    double size = 24,
    Color? color,
    bool isLeading = true,
  }) {
    return FloatingSearchBarAction(
      showIfOpened: true,
      builder: (context, animation) {
        final isLTR = Directionality.of(context) == TextDirection.ltr;

        return AnimatedBuilder(
          child: RotatedBox(
            quarterTurns: (isLTR ? 0 : 2) + (isLeading ? 0 : 2),
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_arrow,
              // Menu arrow has some weird errors on LTR...
              // Always use LTR and rotate the widget manually
              // for now.
              textDirection: TextDirection.ltr,
              progress: animation,
              color: color,
              size: size,
            ),
          ),
          animation: animation,
          builder: (context, icon) => CircularButton(
            tooltip: animation.isDismissed
                ? MaterialLocalizations.of(context).openAppDrawerTooltip
                : MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              final bar = FloatingSearchAppBar.of(context);
              if (bar?.isOpen == true) {
                bar?.close();
              } else {
                Scaffold.of(context).openDrawer();
              }
            },
            icon: icon!,
          ),
        );
      },
    );
  }

  /// A search icon that transitions into a clear icon
  /// when the query of the [FloatingSearchBar] is not empty.
  factory FloatingSearchBarAction.searchToClear({
    double size = 24,
    Color? color,
    bool showIfClosed = true,
    Duration duration = const Duration(milliseconds: 900),
    String searchButtonSemanticLabel = 'Search',
    String clearButtonSemanticLabel = 'Clear',
  }) {
    return FloatingSearchBarAction(
      showIfOpened: true,
      showIfClosed: showIfClosed,
      builder: (context, animation) {
        final bar = FloatingSearchAppBar.of(context)!;

        return ValueListenableBuilder<String>(
          valueListenable: bar.queryNotifer,
          builder: (context, query, _) {
            final isEmpty = query.isEmpty;

            return SearchToClear(
              isEmpty: isEmpty,
              size: size,
              color: color ?? bar.style.iconColor,
              duration: duration * 0.5,
              onTap: () {
                if (!isEmpty) {
                  bar.clear();
                } else {
                  bar.isOpen =
                      !bar.isOpen || (!bar.hasFocus && bar.isAlwaysOpened);
                }
              },
              searchButtonSemanticLabel: searchButtonSemanticLabel,
              clearButtonSemanticLabel: clearButtonSemanticLabel,
            );
          },
        );
      },
    );
  }

  factory FloatingSearchBarAction.back({
    double size = 24,
    Color? color,
    bool showIfClosed = false,
  }) {
    return FloatingSearchBarAction(
      showIfClosed: showIfClosed,
      showIfOpened: true,
      builder: (context, animation) {
        final canPop = Navigator.canPop(context);

        return CircularButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          size: size,
          icon: Icon(Icons.arrow_back, color: color, size: size),
          onPressed: () {
            final bar = FloatingSearchAppBar.of(context)!;

            if (bar.isOpen && !bar.isAlwaysOpened) {
              bar.close();
            } else if (canPop) {
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  /// A convenience factory to wrap an [Icon] or an [IconData]
  /// into an action.
  factory FloatingSearchBarAction.icon({
    required dynamic icon,
    required VoidCallback onTap,
    double size = 24.0,
    bool showIfOpened = false,
    bool showIfClosed = true,
  }) {
    return FloatingSearchBarAction(
      child: CircularButton(
        size: size,
        icon: icon is IconData ? Icon(icon) : icon,
        onPressed: onTap,
      ),
      showIfClosed: showIfClosed,
      showIfOpened: showIfOpened,
    );
  }

  @override
  Widget build(BuildContext context) {
    return child ??
        builder!(
          context,
          FloatingSearchAppBar.of(context)!.transitionAnimation,
        );
  }
}

/// Creates a row for [FloatingSearchBarActions].
class FloatingSearchActionBar extends StatelessWidget {
  final Animation<double> animation;
  final List<Widget> actions;
  final IconThemeData? iconTheme;
  const FloatingSearchActionBar({
    Key? key,
    required this.animation,
    required this.actions,
    this.iconTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => IconTheme(
        data: iconTheme ?? Theme.of(context).iconTheme,
        child: Row(
          children: _mapActions(),
        ),
      ),
    );
  }

  List<Widget> _mapActions() {
    final animation = ValleyingTween().animate(this.animation);
    final isOpen = this.animation.value >= 0.5;

    var openCount = 0;
    var closedCount = 0;
    for (final action in actions) {
      if (action is FloatingSearchBarAction) {
        if (action.showIfOpened) openCount++;
        if (action.showIfClosed) closedCount++;
      }
    }

    final currentActions = List<Widget>.from(actions)
      ..removeWhere((action) {
        if (action is FloatingSearchBarAction) {
          return (isOpen && !action.showIfOpened) ||
              (!isOpen && !action.showIfClosed);
        } else {
          return false;
        }
      });

    return currentActions.map((action) {
      if (action is FloatingSearchBarAction) {
        if (action.isAlwaysShown) return action;

        final index = currentActions.reversed.toList().indexOf(action);
        final shouldScale = index <= ((isOpen ? closedCount : openCount) - 1);
        if (shouldScale) {
          return ScaleTransition(
            alignment: Alignment.center,
            scale: animation,
            child: action,
          );
        } else {
          return SizeFadeTransition(
            animation: animation,
            axis: Axis.horizontal,
            axisAlignment: 1.0,
            sizeFraction: 0.25,
            child: Center(child: action),
          );
        }
      }

      return action;
    }).toList();
  }
}
