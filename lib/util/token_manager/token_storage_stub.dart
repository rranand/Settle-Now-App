// Stub for non-web platforms.
// These functions are never called on mobile — TokenStorage guards with kIsWeb.

void setItem(String key, String value) {}

String? getItem(String key) => null;

void removeItem(String key) {}
