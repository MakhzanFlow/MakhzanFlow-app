/// Request body for `POST /customers`:
/// `{ name, phone?, email?, address?, opening_balance? }`
class CreateCustomerRequestDto {
  final String name;
  final String? nameOfficial;
  final String? phone;
  final String? email;
  final String? address;
  final double? openingBalance;

  const CreateCustomerRequestDto({
    required this.name,
    this.nameOfficial,
    this.phone,
    this.email,
    this.address,
    this.openingBalance,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (nameOfficial != null) 'name_official': nameOfficial,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
        if (openingBalance != null) 'opening_balance': openingBalance,
      };
}
