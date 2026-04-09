import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/model/static_page_model.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/constant/string_constant.dart';

class StaticPagesState {
  final bool isLoading;
  final String htmlData;
  final bool didDataLoad;
  final bool fetchAttempted;
  final List<Map<String, dynamic>> faq;

  StaticPagesState({
    this.isLoading = false,
    this.htmlData = '',
    this.didDataLoad = false,
    this.fetchAttempted = false,
    this.faq = const [],
  });

  StaticPagesState copyWith({
    bool? isLoading,
    String? htmlData,
    bool? didDataLoad,
    bool? fetchAttempted,
    List<Map<String, dynamic>>? faq,
  }) {
    return StaticPagesState(
      isLoading: isLoading ?? this.isLoading,
      htmlData: htmlData ?? this.htmlData,
      didDataLoad: didDataLoad ?? this.didDataLoad,
      fetchAttempted: fetchAttempted ?? this.fetchAttempted,
      faq: faq ?? this.faq,
    );
  }
}

final staticPagesProvider =
    NotifierProvider<StaticPagesNotifier, StaticPagesState>(StaticPagesNotifier.new);

class StaticPagesNotifier extends Notifier<StaticPagesState> {
  late final ApiService _apiService;
  bool _disposed = false;

  @override
  StaticPagesState build() {
    _apiService = ref.read(apiServiceProvider);
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
    });
    return StaticPagesState();
  }

  Future<void> fetchData(String pageKey) async {
    state = state.copyWith(isLoading: true, didDataLoad: false, fetchAttempted: true);

    try {
      if (pageKey == faq || pageKey == "faq") {
        final response = await _apiService.get('auth/faq');
        if (response['success']) {
          final faqList =
              List<Map<String, dynamic>>.from(response['data']['faq']);
          if (!_disposed) {
            state = state.copyWith(
              faq: faqList,
              didDataLoad: true,
            );
          }
        } else {
          CommonService.animatedToast(response['message'], 'error');
        }
      } else {
        String url = '';
        if (pageKey == "Contact Us" || pageKey == "contact_us") {
          url = 'auth/page/contact-us';
        } else if (pageKey == "Terms and Conditions" ||
            pageKey == "terms_conditions") {
          url = 'auth/page/toc';
        } else if (pageKey == "Privacy Policy" || pageKey == "privacy_policy") {
          url = 'auth/page/privacy-policy';
        } else if (pageKey == faq || pageKey == "faq") {
          url = 'auth/page/faq';
        }

        final response = await _apiService.get(url);
        StaticPage staticPage = StaticPage.fromJson(response);

        if (staticPage.success) {
          if (!_disposed) {
            state = state.copyWith(
              htmlData: staticPage.data.page.description,
              didDataLoad: true,
            );
          }
        } else {
          CommonService.animatedToast(staticPage.message, 'error');
        }
      }
    } catch (e) {
      // Network errors: global snackbar handles notification
      if (e is! NoInternetException) rethrow;
    } finally {
      if (!_disposed) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  void toggleFaqExpansion(int index) {
    final updatedFaq = state.faq.asMap().entries.map((entry) {
      if (entry.key == index) {
        final item = Map<String, dynamic>.from(entry.value);
        item['isExpanded'] = !(item['isExpanded'] ?? false);
        return item;
      }
      return entry.value;
    }).toList();
    state = state.copyWith(faq: updatedFaq);
  }
}
