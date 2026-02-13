/// Data model for Land listing
class Land {
  final String id;
  final String title;
  final String state;
  final String location;
  final double price;
  final String sizeDisplay;
  final double sizeValue;
  final String imageUrl;
  final String ownerPhone;

  Land({
    required this.id,
    required this.title,
    required this.state,
    required this.location,
    required this.price,
    required this.sizeDisplay,
    required this.sizeValue,
    required this.imageUrl,
    required this.ownerPhone,
  });

  /// Factory constructor to parse CSV row
  /// CSV columns: id(0), title(1), state(2), location(3), price(4),
  /// size_display(5), size_value(6), imageUrl(7), ownerPhone(8)
  factory Land.fromCsv(List<dynamic> row) {
    try {
      return Land(
        id: row[0].toString().trim(),
        title: row[1].toString().trim(),
        state: row[2].toString().trim(),
        location: row[3].toString().trim(),
        price: double.tryParse(row[4].toString().trim()) ?? 0.0,
        sizeDisplay: row[5].toString().trim(),
        sizeValue: double.tryParse(row[6].toString().trim()) ?? 0.0,
        imageUrl: row[7].toString().trim(),
        ownerPhone: row[8].toString().trim(),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  String toString() =>
      'Land(id: $id, title: $title, state: $state, location: $location, price: $price)';
}