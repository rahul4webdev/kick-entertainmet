import 'dart:developer' as developer;

class Loggers {
  static void info(Object? msg) {
    print('[INFO] $msg');
    developer.log('$msg', name: 'INFO');
  }

  static void success(Object? msg) {
    print('[SUCCESS] $msg');
    developer.log('✅✅✅: $msg', name: 'SUCCESS');
  }

  static void warning(Object? msg) {
    print('[WARNING] $msg');
    developer.log('⚠️⚠️⚠️: $msg', name: 'WARNING');
  }

  static void error(Object? msg) {
    print('[ERROR] $msg');
    developer.log('🔴🔴🔴: $msg', name: 'ERROR');
  }
}
