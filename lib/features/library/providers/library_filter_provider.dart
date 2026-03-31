import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LibraryFilter {
  all,
  playlists,
  artists,
  podcasts,
}

class LibraryFilterNotifier extends Notifier<LibraryFilter> {
  @override
  LibraryFilter build() => LibraryFilter.all;

  void setFilter(LibraryFilter filter) {
    state = filter;
  }
}

final libraryFilterProvider = NotifierProvider<LibraryFilterNotifier, LibraryFilter>(() {
  return LibraryFilterNotifier();
});
