class BasketModel {
  final int basketNumber;
  final int par;
  final double distance;

  BasketModel({
    required this.basketNumber,
    required this.par,
    required this.distance,
  });

  factory BasketModel.fromMap(Map<String, dynamic> data) {
    return BasketModel(
      basketNumber: data['basketNumber'],
      par: data['par'],
      distance: data['distance'],
    );
  }
}
