import 'package:flutter/material.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:fritter/generated/l10n.dart';
import 'package:fritter/home/home_model.dart';
import 'package:fritter/ui/errors.dart';
import 'package:provider/provider.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

class SettingsHomeFragment extends StatelessWidget {
  final ScrollController scrollController;

  const SettingsHomeFragment({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var model = context.read<HomeModel>();

    return Scaffold(
      appBar: ScrollAppBar(
        controller: scrollController,
        title: Text(L10n.current.home),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: L10n.current.reset_home_pages,
            onPressed: () async => await model.resetPages()
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ScopedBuilder<HomeModel, Object, List<HomePage>>.transition(
          store: model,
          onError: (_, e) => ScaffoldErrorWidget(
            prefix: L10n.current.unable_to_load_home_pages,
            error: e,
            stackTrace: null,
            onRetry: () async => await model.resetPages(),
            retryText: L10n.current.reset_home_pages,
          ),
          onLoading: (_) => const Center(child: CircularProgressIndicator()),
          onState: (_, data) {
            return ReorderableListView.builder(
              scrollController: scrollController,
              itemCount: data.length,
              itemBuilder: (context, index) {
                var page = data[index];

                return CheckboxListTile(
                  key: Key(page.id),
                  secondary: const Icon(Icons.drag_handle),
                  title: Text(page.page.title),
                  value: page.selected,
                  onChanged: (value) async {
                    var selected = value ?? false;
                    if (selected == false && data.where((e) => e.selected).length == 2) {
                      showSnackBar(context, icon: '🙊', message: L10n.current.you_must_have_at_least_2_home_screen_pages);
                      return;
                    }

                    await model.selectPage(page.id, value ?? false);
                    await model.save();
                  },
                );
              },
              onReorder: (oldIndex, newIndex) async {
                await model.movePage(oldIndex, newIndex);
                await model.save();
              },
            );
          },
        ),
      ),
    );
  }
}