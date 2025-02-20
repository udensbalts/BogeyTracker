import 'package:cloud_firestore/cloud_firestore.dart';

class Round {
  String id;
  String courseId;
  String courseName;
  DateTime date;
  List<PlayerScore> playerScores;

  Round({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.date,
    required this.playerScores,
  });

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'date': date.toIso8601String(),
      'playerScores': playerScores.map((p) => p.toMap()).toList(),
    };
  }

  factory Round.fromMap(String id, Map<String, dynamic> map) {
    return Round(
      id: id,
      courseId: map['courseId'],
      courseName: map['courseName'],
      date: DateTime.parse(map['date']),
      playerScores: (map['playerScores'] as List)
          .map((p) => PlayerScore.fromMap(p))
          .toList(),
    );
  }
}

class PlayerScore {
  String playerId;
  String playerName;
  List<BasketScore> basketScores;

  PlayerScore({
    required this.playerId,
    required this.playerName,
    required this.basketScores,
  });

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'basketScores': basketScores.map((b) => b.toMap()).toList(),
    };
  }

  factory PlayerScore.fromMap(Map<String, dynamic> map) {
    return PlayerScore(
      playerId: map['playerId'],
      playerName: map['playerName'],
      basketScores: (map['basketScores'] as List)
          .map((b) => BasketScore.fromMap(b))
          .toList(),
    );
  }
}

class BasketScore {
  int basketNumber;
  int par;
  int distance;
  int score;

  BasketScore({
    required this.basketNumber,
    required this.par,
    required this.distance,
    this.score = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'basketNumber': basketNumber,
      'par': par,
      'distance': distance,
      'score': score,
    };
  }

  factory BasketScore.fromMap(Map<String, dynamic> map) {
    return BasketScore(
      basketNumber: map['basketNumber'],
      par: map['par'],
      distance: (map['distance'] as num?)?.toInt() ?? 0,
      score: map['score'],
    );
  }
}
