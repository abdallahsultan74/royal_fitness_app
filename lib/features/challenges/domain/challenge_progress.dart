class ChallengeProgress {
  const ChallengeProgress({
    required this.userChallengeId,
    required this.challengeId,
    required this.slug,
    required this.title,
    required this.titleAr,
    required this.level,
    required this.daysCount,
    required this.currentDay,
    required this.completedDays,
    required this.progressPercent,
    required this.status,
    this.coverImageUrl,
  });

  final String userChallengeId;
  final String challengeId;
  final String slug;
  final String title;
  final String titleAr;
  final String level;
  final int daysCount;
  final int currentDay;
  final int completedDays;
  final double progressPercent;
  final String status;
  final String? coverImageUrl;

  String displayTitle(String languageCode) {
    return languageCode == 'ar' && titleAr.isNotEmpty ? titleAr : title;
  }

  /// Minimal template for [ChallengeDetailsPage] (details load from API).
  ChallengeTemplate toTemplate() {
    return ChallengeTemplate(
      id: challengeId,
      slug: slug,
      title: title,
      titleAr: titleAr,
      description: '',
      descriptionAr: '',
      level: level,
      daysCount: daysCount,
      isActive: true,
      coverImageUrl: coverImageUrl,
    );
  }
}

class ChallengeTemplate {
  const ChallengeTemplate({
    required this.id,
    required this.slug,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.level,
    required this.daysCount,
    required this.isActive,
    this.coverImageUrl,
  });

  final String id;
  final String slug;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final String level;
  final int daysCount;
  final bool isActive;
  final String? coverImageUrl;

  String displayTitle(String languageCode) {
    return languageCode == 'ar' && titleAr.isNotEmpty ? titleAr : title;
  }

  String displayDescription(String languageCode) {
    return languageCode == 'ar' && descriptionAr.isNotEmpty
        ? descriptionAr
        : description;
  }
}
