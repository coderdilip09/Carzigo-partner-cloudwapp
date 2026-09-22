import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/utils/base_provider.dart';

class HelpArticleData {
  const HelpArticleData({
    required this.id,
    required this.question,
    required this.answer,
  });

  final String id;
  final String question;
  final String answer;
}

class HelpTopicData {
  const HelpTopicData({
    required this.key,
    required this.title,
    required this.subtitle,
    this.articles = const [],
  });

  final String key;
  final String title;
  final String subtitle;
  final List<HelpArticleData> articles;
}

class HelpSupportProvider extends BaseProvider {
  HelpSupportProvider() {
    loadHelp();
  }

  String? expandedTopicKey;
  String searchQuery = '';
  List<HelpTopicData> topics = const [];
  List<HelpTopicData> _allTopics = const [];
  List<HelpArticleData> searchArticles = const [];
  bool isSearching = false;
  String? headline;
  String? subtitle;
  String? supportPhone;
  String? supportEmail;
  String? supportHours;
  bool isLoading = false;
  String? loadError;

  void tapOnTopic(String topicKey) {
    if (topicKey.isEmpty) return;
    expandedTopicKey = expandedTopicKey == topicKey ? null : topicKey;
    safeNotifyListeners();
  }

  void onSearchChanged(String value) {
    searchQuery = value.trim();
    safeNotifyListeners();
    if (searchQuery.isEmpty) {
      isSearching = false;
      searchArticles = const [];
      topics = List<HelpTopicData>.from(_allTopics);
      safeNotifyListeners();
      return;
    }
    if (searchQuery.length >= 2) {
      searchHelp(searchQuery);
    }
  }

  Future<void> loadHelp() async {
    isLoading = true;
    loadError = null;
    safeNotifyListeners();

    final overview = await Api.getHelp();
    if (overview.isSuccess && overview.data != null) {
      _applyOverview(overview.data!);
      isLoading = false;
      safeNotifyListeners();
      return;
    }

    final topicsRes = await Api.getHelpTopics();
    final contact = await Api.getHelpContact();
    final hasTopics = topicsRes.isSuccess && topicsRes.data != null;
    final hasContact = contact.isSuccess && contact.data != null;

    if (!hasTopics && !hasContact) {
      loadError = overview.message ?? topicsRes.message ?? contact.message;
      isLoading = false;
      safeNotifyListeners();
      return;
    }

    if (hasTopics) {
      _allTopics = _parseTopics(topicsRes.data);
      topics = List<HelpTopicData>.from(_allTopics);
    }
    if (hasContact) {
      _applyContact(contact.data!);
    }

    isLoading = false;
    safeNotifyListeners();
  }

  Future<void> searchHelp(String query) async {
    final response = await Api.searchHelp(query: query);
    if (!response.isSuccess || response.data == null) return;
    if (searchQuery != query) return;

    final data = response.data!;
    final items = data['items'];
    final matchedTopics = data['topics'];

    searchArticles = _parseArticles(items is List ? items : null);
    isSearching = true;

    if (matchedTopics is List && matchedTopics.isNotEmpty) {
      final keys = matchedTopics
          .whereType<Map>()
          .map((e) => (e['key'] ?? '').toString())
          .where((k) => k.isNotEmpty)
          .toSet();
      topics = _allTopics.where((t) => keys.contains(t.key)).toList();
    } else {
      topics = const [];
    }
    safeNotifyListeners();
  }

  void _applyOverview(Map<String, dynamic> data) {
    _applyContact(data);
    final topicsRaw = data['topics'];
    if (topicsRaw is List) {
      _allTopics = _parseTopics(
        topicsRaw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      );
    } else {
      _allTopics = const [];
    }
    topics = List<HelpTopicData>.from(_allTopics);
  }

  void _applyContact(Map<String, dynamic> data) {
    headline = _nonEmpty(data['headline']);
    subtitle = _nonEmpty(data['subtitle']);

    final callCard = data['call_card'];
    final emailCard = data['email_card'];

    supportPhone = _nonEmpty(
      data['phone'] ??
          data['mobile'] ??
          data['support_phone'] ??
          data['phone_display'] ??
          (callCard is Map ? callCard['value'] : null),
    );
    supportEmail = _nonEmpty(
      data['email'] ??
          data['support_email'] ??
          (emailCard is Map ? emailCard['value'] : null),
    );
    supportHours = _nonEmpty(data['hours']);
  }

  String? _nonEmpty(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  List<HelpTopicData> _parseTopics(List<Map<String, dynamic>>? data) {
    if (data == null) return const [];
    return data.map((item) {
      final articlesRaw = item['articles'];
      return HelpTopicData(
        key: (item['key'] ?? item['id'] ?? item['title'] ?? '').toString(),
        title: (item['title'] ?? item['name'] ?? '').toString(),
        subtitle: (item['subtitle'] ?? item['summary'] ?? '').toString(),
        articles: _parseArticles(articlesRaw is List ? articlesRaw : null),
      );
    }).toList();
  }

  List<HelpArticleData> _parseArticles(List<dynamic>? data) {
    if (data == null) return const [];
    return data.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      return HelpArticleData(
        id: (map['id'] ?? map['question'] ?? '').toString(),
        question: (map['question'] ?? map['title'] ?? '').toString(),
        answer: (map['answer'] ?? map['body'] ?? map['content'] ?? '').toString(),
      );
    }).toList();
  }
}
