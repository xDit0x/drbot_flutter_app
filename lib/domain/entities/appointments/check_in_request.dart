import 'dart:typed_data';

class CheckInRequest {
  final String appointmentId;
  final Uint8List? signatureBytes;
  const CheckInRequest({required this.appointmentId, this.signatureBytes});
}
