enum SessionStatus {
  ongoing('en_cours', 'En cours'),
  finished('termine', 'Terminée');

  const SessionStatus(this.rawValue, this.displayName);

  final String rawValue;
  final String displayName;

  static SessionStatus fromRawValue(String rawValue) {
    return SessionStatus.values.firstWhere((s) => s.rawValue == rawValue);
  }
}
