/// Request body for `PATCH /companies/:id`: `{ name?, logo_url? }`
class UpdateCompanyRequestDto {
  final String? name;
  final String? logoUrl;

  const UpdateCompanyRequestDto({this.name, this.logoUrl});

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (logoUrl != null) 'logo_url': logoUrl,
      };
}