import 'package:freezed_annotation/freezed_annotation.dart';

part 'podcast_categories.freezed.dart';
part 'podcast_categories.g.dart';

@freezed
class PodcastCategory with _$PodcastCategory {
  const factory PodcastCategory({
    required String id,
    required String name,
    required String emoji,
    @Default([]) List<String> subcategories,
    @Default(true) bool isActive,
  }) = _PodcastCategory;

  factory PodcastCategory.fromJson(Map<String, dynamic> json) =>
      _$PodcastCategoryFromJson(json);
}

class PodcastCategories {
  static List<PodcastCategory> get mainCategories => [
    const PodcastCategory(
      id: 'business',
      name: 'Business & Entrepreneurship',
      emoji: '💼',
      subcategories: [
        'Startups',
        'Marketing & Branding',
        'Leadership',
        'Finance & Investing',
      ],
    ),
    const PodcastCategory(
      id: 'technology',
      name: 'Technology',
      emoji: '💻',
      subcategories: [
        'AI & Machine Learning',
        'Blockchain & Crypto',
        'Gadgets & Reviews',
        'Software & App Development',
      ],
    ),
    const PodcastCategory(
      id: 'health',
      name: 'Health & Wellness',
      emoji: '🏥',
      subcategories: [
        'Mental Health',
        'Fitness & Nutrition',
        'Medical Science',
        'Self-Improvement',
      ],
    ),
    const PodcastCategory(
      id: 'news',
      name: 'News & Politics',
      emoji: '📰',
      subcategories: [
        'Current Events',
        'Political Commentary',
        'Global Affairs',
        'Policy Analysis',
      ],
    ),
    const PodcastCategory(
      id: 'entertainment',
      name: 'Entertainment & Pop Culture',
      emoji: '🎬',
      subcategories: [
        'TV & Movies',
        'Celebrity Gossip',
        'Comedy',
        'Music Industry',
      ],
    ),
    const PodcastCategory(
      id: 'society',
      name: 'Society & Culture',
      emoji: '🌍',
      subcategories: [
        'Relationships',
        'History',
        'Social Issues',
        'Religion & Spirituality',
      ],
    ),
    const PodcastCategory(
      id: 'education',
      name: 'Education & Learning',
      emoji: '📚',
      subcategories: [
        'How-To & Tutorials',
        'Language Learning',
        'Personal Development',
        'Academic Topics',
      ],
    ),
    const PodcastCategory(
      id: 'crime',
      name: 'True Crime & Mystery',
      emoji: '🔍',
      subcategories: [
        'Investigations',
        'Cold Cases',
        'Legal Cases',
        'Paranormal Stories',
      ],
    ),
    const PodcastCategory(
      id: 'lifestyle',
      name: 'Lifestyle',
      emoji: '✨',
      subcategories: [
        'Travel & Adventure',
        'Food & Cooking',
        'Fashion & Beauty',
        'Home & Garden',
      ],
    ),
    const PodcastCategory(
      id: 'gaming',
      name: 'Gaming & Esports',
      emoji: '🎮',
      subcategories: [
        'Game Reviews',
        'Esports',
        'Gaming Industry',
        'Streaming & Content',
      ],
    ),
  ];

  static PodcastCategory? getCategoryById(String id) {
    try {
      return mainCategories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<String> getAllSubcategories() {
    return mainCategories
        .expand((category) => category.subcategories)
        .toList();
  }
}