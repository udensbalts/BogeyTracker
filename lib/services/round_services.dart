import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/models/round_model.dart';

class RoundService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new round in Firestore using the Round model.
  Future<String?> createRound(String courseId, List<String> playerIds) async {
    try {
      // Fetch course details
      DocumentSnapshot courseDoc =
          await _firestore.collection('courses').doc(courseId).get();
      if (!courseDoc.exists) throw Exception("Course not found");

      Map<String, dynamic> courseData =
          courseDoc.data() as Map<String, dynamic>;
      List<dynamic> baskets = courseData['baskets'] ?? [];

      // Convert basket data into BasketScore objects
      List<BasketScore> basketScores = baskets.map((basket) {
        return BasketScore(
          basketNumber: (basket['basketNumber'] as num?)?.toInt() ?? 0,
          par: (basket['par'] as num?)?.toInt() ?? 3,
          distance: (basket['distance'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      // Convert player IDs into PlayerScore objects
      List<PlayerScore> playerScores = playerIds.map((playerId) {
        return PlayerScore(
          playerId: playerId,
          playerName: "", // Fetch player name separately if needed
          basketScores: basketScores
              .map((basket) => BasketScore(
                    basketNumber: basket.basketNumber,
                    par: basket.par,
                    distance: basket.distance,
                    score: 0, // Ensure each player starts with 0 score
                  ))
              .toList(),
        );
      }).toList();

      // Create the Round object
      Round round = Round(
        id: "", // Firestore will generate this
        courseId: courseId,
        courseName: courseData['name'],
        date: DateTime.now(),
        playerScores: playerScores,
      );

      // Store round in Firestore
      DocumentReference roundRef =
          await _firestore.collection('rounds').add(round.toMap());

      return roundRef.id;
    } catch (e) {
      print("Error creating round: $e");
      return null;
    }
  }

  /// Fetch a round from Firestore and convert it to a Round model.
  Future<Round?> getRound(String roundId) async {
    try {
      DocumentSnapshot roundDoc =
          await _firestore.collection('rounds').doc(roundId).get();
      if (!roundDoc.exists) return null;

      return Round.fromMap(
          roundDoc.id, roundDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print("Error fetching round: $e");
      return null;
    }
  }

  /// Update a player's score for a specific hole in Firestore.
  Future<void> updateScore(
      String roundId, int holeIndex, String playerId, int score) async {
    try {
      DocumentReference roundRef = _firestore.collection('rounds').doc(roundId);
      DocumentSnapshot roundDoc = await roundRef.get();

      if (!roundDoc.exists) throw Exception("Round not found");

      Round round =
          Round.fromMap(roundDoc.id, roundDoc.data() as Map<String, dynamic>);

      // Find the player and update their score
      for (var player in round.playerScores) {
        if (player.playerId == playerId) {
          player.basketScores[holeIndex].score = score;
          break;
        }
      }

      // Update Firestore
      await roundRef.update(round.toMap());
    } catch (e) {
      print("Error updating score: $e");
    }
  }
}
