import 'package:makhzanflow/core/sync/create_image_uploader.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import '../usecases/upload_customer_image_usecase.dart';

/// Uploads queued customer images after a `customerCreate` replays.
class CustomerCreateImageUploader implements PendingCreateImageUploader {
  final UploadCustomerImageUseCase _upload;

  const CustomerCreateImageUploader({required UploadCustomerImageUseCase upload})
      : _upload = upload;

  @override
  bool supports(PendingOpType type) => type == PendingOpType.customerCreate;

  @override
  Future<bool> upload({
    required String serverId,
    required String imagePath,
    required String companyId,
  }) async {
    try {
      final result = await _upload(imagePath, serverId);
      return result.isRight();
    } catch (_) {
      return false;
    }
  }
}
