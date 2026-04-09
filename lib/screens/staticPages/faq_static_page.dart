import 'package:optmsg/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:optmsg/constant/app_typography.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/staticPages/static_pages_notifier.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';

class FabStaticPage extends ConsumerStatefulWidget {
  final String pageKey;
  const FabStaticPage({
    super.key,
    required this.pageKey,
  });

  @override
  ConsumerState<FabStaticPage> createState() => _FabStaticPageState();
}

class _FabStaticPageState extends ConsumerState<FabStaticPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(staticPagesProvider.notifier).fetchData(widget.pageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(staticPagesProvider);
    final notifier = ref.read(staticPagesProvider.notifier);

    // Push route — must include title
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ShellLayout.of(context)?.setAppBarConfig(AppBarConfig(
          title: widget.pageKey,
        ));
      }
    });

    return Scaffold(
        body: DelayedLoadingOverlay(
            isLoading: state.isLoading,
            child: _buildAccordion(state, notifier)));
  }

  Widget _buildAccordion(StaticPagesState state, StaticPagesNotifier notifier) {
    return !state.didDataLoad
        ? (state.fetchAttempted && !state.isLoading
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.9,
                child: const Center(
                    child: EmptyState(
                  variant: EmptyStateVariant.generic,
                )))
            : const SizedBox.shrink())
        : ListView(
            children: state.faq.asMap().entries.map<Widget>((entry) {
              final index = entry.key;
              final item = entry.value;
              return ExpansionPanelList(
                elevation: 0,
                expandedHeaderPadding:
                    const EdgeInsets.only(top: 8.0, bottom: 8.0),
                expansionCallback: (int _, bool isExpanded) {
                  notifier.toggleFaqExpansion(index);
                },
                children: [
                  ExpansionPanel(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(item['question'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            )),
                      );
                    },
                    body: ListTile(
                      title: Text(
                        item['answer'],
                        style: AppTypography.profileSubTitle(context),
                      ),
                    ),
                    isExpanded: item['isExpanded'] == true,
                  ),
                ],
              );
            }).toList(),
          );
  }
}
