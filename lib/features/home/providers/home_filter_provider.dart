import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HomeFilter {
  all,
  music,
  musicFollowing,
  podcasts,
  podcastsFollowing,
}

class HomeFilterNotifier extends Notifier<HomeFilter> {
  @override
  HomeFilter build() => HomeFilter.all;

  void setFilter(HomeFilter filter) {
    state = filter;
  }
}

final homeFilterProvider = NotifierProvider<HomeFilterNotifier, HomeFilter>(() {
  return HomeFilterNotifier();
});
