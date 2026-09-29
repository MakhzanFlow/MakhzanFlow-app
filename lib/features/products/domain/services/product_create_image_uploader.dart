import 'package:makhzanflow/core/sync/create_image_uploader.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import '../usecases/upload_product_image_usecase.dart';

/// Uploads queued product images after a `productCreate` replays.
class ProductCreateImageUploader implements PendingCreateImageUploader {
  final UploadProductImageUseCase _upload;

  const ProductCreateImageUploader({required UploadProductImageUseCase upload})
      : _upload = upload;

  @override
  bool supports(PendingOpType type) => type == PendingOpType.productCreate;

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
