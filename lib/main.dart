import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/portfolio/portfolio_list_screen.dart';
import 'controllers/portfolio_controller.dart';
import 'controllers/dividend_controller.dart';
import 'controllers/analysis_controller.dart';
import 'services/local_database_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive 로컬 데이터베이스 초기화 (메모리 효율적 처리)
  try {
    await LocalDatabaseService.initialize();
  } catch (e) {
    // 로컬 데이터베이스 초기화 실패해도 앱은 계속 실행 (Firebase만 사용)
    // 사용자에게는 표시하지 않고 Firebase만 사용
  }

  // 컨트롤러는 필요시 lazy loading으로 초기화
  // 메모리 효율성을 위해 즉시 초기화하지 않음

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Dividend Radar',
      theme: AppTheme.lightTheme, // 새로운 프로페셔널 테마 적용
      home: PortfolioListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
