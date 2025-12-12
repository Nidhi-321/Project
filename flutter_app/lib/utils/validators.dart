String? notEmptyValidator(String? v) {
  if (v == null || v.trim().isEmpty) return 'Cannot be empty';
  return null;
}
