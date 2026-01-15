abstract class PersistenceService<T> {
  Future<void> save(data);
  Future<T?> load();
  Future<void> clear();
}
