/// Request body for `POST /companies`: `{ name, logo_url, business_type?, phone?, address? }`
///
/// The backend currently validates `name` + `logo_url` only; the remaining
/// fields are optional and kept for when the API supports them.
class CreateCompanyRequestDto {
  final String name;
  final String? logoUrl;
  final String? businessType;
  final String? phone;
  final String? address;

  const CreateCompanyRequestDto({
    required this.name,
    this.logoUrl,
    this.businessType,
    this.phone,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (logoUrl != null) 'logo_url': logoUrl,
        if (businessType != null) 'business_type': businessType,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      };
}