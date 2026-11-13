class RobotCommandException implements Exception {
  final String message;
  const RobotCommandException(this.message);

  @override
  String toString() => 'RobotCommandException: $message';
}
