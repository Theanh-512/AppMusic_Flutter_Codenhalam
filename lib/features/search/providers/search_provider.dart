import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/search_result_group.dart';
import '../../../core/repositories/search_repository.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

final searchResultsProvider = FutureProvider.autoDispose<SearchResultGroup>((ref) async {
  final query = ref.watch(searchQueryProvider);
  
  if (query.trim().isEmpty) {
    return const SearchResultGroup(); // Empty result initially
  }
  
  // Optional: We can add debounce logic here by awaiting a short delay
  await Future.delayed(const Duration(milliseconds: 300));
  
  final repo = ref.read(searchRepositoryProvider);
  return repo.searchAll(query);
});
