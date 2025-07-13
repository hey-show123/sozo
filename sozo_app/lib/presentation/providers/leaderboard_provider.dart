import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ランキングエントリーモデル
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? username;
  final String? avatarUrl;
  final int rank;
  final int score;
  final int movement;
  final String league;
  final String leagueIcon;
  final String leagueColor;
  final int currentLevel;
  final int totalXp;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.username,
    this.avatarUrl,
    required this.rank,
    required this.score,
    this.movement = 0,
    required this.league,
    required this.leagueIcon,
    required this.leagueColor,
    this.currentLevel = 1,
    this.totalXp = 0,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    return LeaderboardEntry(
      userId: json['user_id'],
      displayName: json['display_name'] ?? 'Unknown',
      username: json['username'],
      avatarUrl: json['avatar_url'],
      rank: json['rank'],
      score: json['score'],
      movement: json['movement'] ?? 0,
      league: json['league'] ?? 'bronze',
      leagueIcon: json['league_icon'] ?? '🥉',
      leagueColor: json['league_color'] ?? '#CD7F32',
      currentLevel: json['current_level'] ?? 1,
      totalXp: json['total_xp'] ?? 0,
      isCurrentUser: currentUserId != null && json['user_id'] == currentUserId,
    );
  }

  String get displayNameOrUsername {
    if (displayName.isNotEmpty && displayName != 'Unknown') {
      return displayName;
    }
    if (username != null && username!.isNotEmpty) {
      return username!;
    }
    return 'ユーザー';
  }
}

// ユーザーのランキング情報
class UserRankInfo {
  final int rank;
  final int score;
  final int totalUsers;
  final double percentile;
  final String league;
  final String leagueIcon;
  final String leagueColor;
  final String? nextLeague;
  final int xpToNextLeague;

  UserRankInfo({
    required this.rank,
    required this.score,
    required this.totalUsers,
    required this.percentile,
    required this.league,
    required this.leagueIcon,
    required this.leagueColor,
    this.nextLeague,
    required this.xpToNextLeague,
  });

  factory UserRankInfo.fromJson(Map<String, dynamic> json) {
    return UserRankInfo(
      rank: json['rank'],
      score: json['score'],
      totalUsers: json['total_users'] ?? 0,
      percentile: (json['percentile'] ?? 0).toDouble(),
      league: json['league'] ?? 'bronze',
      leagueIcon: json['league_icon'] ?? '🥉',
      leagueColor: json['league_color'] ?? '#CD7F32',
      nextLeague: json['next_league'],
      xpToNextLeague: json['xp_to_next_league'] ?? 0,
    );
  }
}

// 週間ランキングプロバイダー
final weeklyLeaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  try {
    // 週間ランキングを更新
    await supabase.rpc('update_weekly_leaderboard');

    // ランキングデータを取得
    final response = await supabase.rpc('get_weekly_leaderboard', params: {
      'p_user_id': userId,
      'p_limit': 50,
    });

    return (response as List)
        .map((data) => LeaderboardEntry.fromJson(data, currentUserId: userId))
        .toList();
  } catch (e) {
    print('Error fetching weekly leaderboard: $e');
    return [];
  }
});

// フレンドランキングプロバイダー
final friendsLeaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) return [];

  try {
    final response = await supabase.rpc('get_friends_weekly_leaderboard', params: {
      'p_user_id': userId,
    });

    return (response as List)
        .map((data) => LeaderboardEntry.fromJson(data, currentUserId: userId))
        .toList();
  } catch (e) {
    print('Error fetching friends leaderboard: $e');
    return [];
  }
});

// ユーザーの週間ランキング情報プロバイダー
final userWeeklyRankProvider = FutureProvider<UserRankInfo>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    return UserRankInfo(rank: 0, score: 0, totalUsers: 0, percentile: 0.0, league: 'bronze', leagueIcon: '🥉', leagueColor: '#CD7F32', xpToNextLeague: 0);
  }

  try {
    final response = await supabase.rpc('get_user_weekly_rank', params: {
      'p_user_id': userId,
    });

    if (response != null && response is List && response.isNotEmpty) {
      return UserRankInfo.fromJson(response.first);
    }

    return UserRankInfo(rank: 0, score: 0, totalUsers: 0, percentile: 0.0, league: 'bronze', leagueIcon: '🥉', leagueColor: '#CD7F32', xpToNextLeague: 0);
  } catch (e) {
    print('Error fetching user weekly rank: $e');
    return UserRankInfo(rank: 0, score: 0, totalUsers: 0, percentile: 0.0, league: 'bronze', leagueIcon: '🥉', leagueColor: '#CD7F32', xpToNextLeague: 0);
  }
});

// リーダーボードの自動更新用プロバイダー
final leaderboardAutoRefreshProvider = StreamProvider.autoDispose<void>((ref) {
  // 5分ごとに自動更新
  return Stream.periodic(const Duration(minutes: 5), (_) {
    ref.invalidate(weeklyLeaderboardProvider);
    ref.invalidate(friendsLeaderboardProvider);
    ref.invalidate(userWeeklyRankProvider);
  });
}); 

// リーグの定義
enum League {
  // ブロンズ - 星バッジ
  bronze3('bronze_3', 'BRONZE III', 'assets/images/ranks/bronze_3.png', '#CD7F32', 0, 500),
  bronze2('bronze_2', 'BRONZE II', 'assets/images/ranks/bronze_2.png', '#CD7F32', 500, 1000),
  bronze1('bronze_1', 'BRONZE I', 'assets/images/ranks/bronze_1.png', '#CD7F32', 1000, 2000),
  
  // ブロンズ上級 - シェブロンバッジ
  bronzeElite3('bronze_elite_3', 'BRONZE ELITE III', 'assets/images/ranks/bronze_chevron_1.png', '#CD7F32', 2000, 3000),
  bronzeElite2('bronze_elite_2', 'BRONZE ELITE II', 'assets/images/ranks/bronze_chevron_2.png', '#CD7F32', 3000, 4000),
  bronzeElite1('bronze_elite_1', 'BRONZE ELITE I', 'assets/images/ranks/bronze_chevron_3.png', '#CD7F32', 4000, 5000),
  
  // シルバー - 星バッジ
  silver3('silver_3', 'SILVER III', 'assets/images/ranks/silver_3.png', '#C0C0C0', 5000, 7000),
  silver2('silver_2', 'SILVER II', 'assets/images/ranks/silver_2.png', '#C0C0C0', 7000, 9000),
  silver1('silver_1', 'SILVER I', 'assets/images/ranks/silver_1.png', '#C0C0C0', 9000, 12000),
  
  // シルバー上級 - シェブロンバッジ
  silverElite3('silver_elite_3', 'SILVER ELITE III', 'assets/images/ranks/silver_chevron_1.png', '#C0C0C0', 12000, 15000),
  silverElite2('silver_elite_2', 'SILVER ELITE II', 'assets/images/ranks/silver_chevron_2.png', '#C0C0C0', 15000, 18000),
  silverElite1('silver_elite_1', 'SILVER ELITE I', 'assets/images/ranks/silver_chevron_3.png', '#C0C0C0', 18000, 22000),
  
  // ゴールド - 星バッジ
  gold3('gold_3', 'GOLD III', 'assets/images/ranks/gold_3.png', '#FFD700', 22000, 26000),
  gold2('gold_2', 'GOLD II', 'assets/images/ranks/gold_2.png', '#FFD700', 26000, 30000),
  gold1('gold_1', 'GOLD I', 'assets/images/ranks/gold_1.png', '#FFD700', 30000, 35000),
  
  // ゴールド上級 - シールドバッジ
  goldElite3('gold_elite_3', 'GOLD ELITE III', 'assets/images/ranks/gold_shield_1.png', '#FFD700', 35000, 40000),
  goldElite2('gold_elite_2', 'GOLD ELITE II', 'assets/images/ranks/gold_shield_2.png', '#FFD700', 40000, 45000),
  goldElite1('gold_elite_1', 'GOLD ELITE I', 'assets/images/ranks/gold_shield_3.png', '#FFD700', 45000, 50000),
  
  // レジェンド - 特殊バッジ
  legend3('legend_3', 'LEGEND III', 'assets/images/ranks/legend_3.png', '#2B2B2B', 50000, 60000),
  legend2('legend_2', 'LEGEND II', 'assets/images/ranks/legend_2.png', '#2B2B2B', 60000, 75000),
  legend1('legend_1', 'LEGEND I', 'assets/images/ranks/legend_1.png', '#2B2B2B', 75000, 100000),
  
  // レジェンド上級 - ウィングバッジ
  legendElite3('legend_elite_3', 'LEGEND ELITE III', 'assets/images/ranks/legend_wing_1.png', '#2B2B2B', 100000, 125000),
  legendElite2('legend_elite_2', 'LEGEND ELITE II', 'assets/images/ranks/legend_wing_2.png', '#2B2B2B', 125000, 150000),
  legendElite1('legend_elite_1', 'LEGEND ELITE I', 'assets/images/ranks/legend_wing_3.png', '#2B2B2B', 150000, 999999999);

  final String id;
  final String displayName;
  final String iconAsset;
  final String color;
  final int minXp;
  final int maxXp;

  const League(this.id, this.displayName, this.iconAsset, this.color, this.minXp, this.maxXp);

  static League fromString(String league) {
    return League.values.firstWhere(
      (l) => l.id == league,
      orElse: () => League.bronze3,
    );
  }

  static League fromTotalXp(int totalXp) {
    for (final league in League.values.reversed) {
      if (totalXp >= league.minXp) {
        return league;
      }
    }
    return League.bronze3;
  }

  String get categoryName {
    if (id.contains('bronze')) return 'BRONZE';
    if (id.contains('silver')) return 'SILVER';
    if (id.contains('gold')) return 'GOLD';
    if (id.contains('legend')) return 'LEGEND';
    return 'BRONZE';
  }

  int get tier {
    if (id.endsWith('3')) return 3;
    if (id.endsWith('2')) return 2;
    if (id.endsWith('1')) return 1;
    return 3;
  }

  bool get isElite => id.contains('elite');

  int get xpToNextLeague => maxXp - minXp;
}

// 特定のリーグのランキングを取得するプロバイダー
final leagueLeaderboardProvider = FutureProvider.family<List<LeaderboardEntry>, String>((ref, leagueId) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  try {
    // 指定されたリーグのランキングを取得
    final response = await supabase.rpc('get_league_leaderboard', params: {
      'p_league': leagueId,
      'p_limit': 50,
    });

    return (response as List)
        .map((data) => LeaderboardEntry.fromJson(data, currentUserId: userId))
        .toList();
  } catch (e) {
    print('Error fetching league leaderboard for $leagueId: $e');
    return [];
  }
});

// 全リーグの概要情報を取得するプロバイダー
final allLeaguesSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase.rpc('get_all_leagues_summary');
    
    if (response is List && response.isNotEmpty) {
      // リストをマップに変換
      final Map<String, dynamic> summary = {};
      for (var item in response) {
        summary[item['league']] = {
          'total_users': item['total_users'],
          'min_xp': item['min_xp'],
          'max_xp': item['max_xp'],
          'avg_xp': item['avg_xp'],
        };
      }
      return summary;
    }
    return {};
  } catch (e) {
    print('Error fetching all leagues summary: $e');
    return {};
  }
}); 