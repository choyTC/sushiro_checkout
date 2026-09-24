/// Enumeration representing the different Sushiro plate categories,
/// their respective prices, and metadata.
enum PlateType {
  red(label: 'Red Plate', price: 12.0, hexCode: '#D32F2F'),
  silver(label: 'Silver Plate', price: 17.0, hexCode: '#9E9E9E'),
  gold(label: 'Gold Plate', price: 22.0, hexCode: '#FFC107'),
  black(label: 'Black Plate', price: 27.0, hexCode: '#212121');

  final String label;
  final double price;
  final String hexCode;

  const PlateType({
    required this.label,
    required this.price,
    required this.hexCode,
  });
}
