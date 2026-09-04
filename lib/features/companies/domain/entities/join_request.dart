class JoinRequest {
  final String id;
  final String companyId;
  final String userId;
  final String userName;
  final String userEmail;
  final String status;
  final DateTime createdAt;
  final String companyName;
  final String companyLogo;

  const JoinRequest({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.status,
    required this.createdAt,
    this.companyName = '',
    this.companyLogo = '',
  });
}
