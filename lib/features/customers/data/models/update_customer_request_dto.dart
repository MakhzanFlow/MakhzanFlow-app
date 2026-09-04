/// Request body for `PUT /customers/:id` — all fields optional.
class UpdateCustomerRequestDto {
  final String? name;
  final String? nameOfficial;
  final String? phone;
  final String? email;
  final String? address;

  const UpdateCustomerRequestDto({
    this.name,
    this.nameOfficial,
    this.phone,
    this.email,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (nameOfficial != null) 'name_official': nameOfficial,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
      };
}
