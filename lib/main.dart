import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_recipes_app/config/app_config.dart';
import 'package:food_recipes_app/providers/app_provider.dart';
import 'package:food_recipes_app/providers/auth_provider.dart';
import 'package:food_recipes_app/providers/category_provider.dart';
import 'package:food_recipes_app/providers/cuisine_provider.dart';
import 'package:food_recipes_app/providers/recipe_provider.dart';
import 'package:food_recipes_app/routes.dart';
import 'package:food_recipes_app/screens/Auth/splash/splash_screen.dart';
import 'package:food_recipes_app/services/notification_service.dart';
import 'package:food_recipes_app/theme.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeago;

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator");

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
        Locale('ar', 'AL'),
      ],
      path: 'lang',
      fallbackLocale: Locale('en', 'US'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => AppProvider()),
          ChangeNotifierProvider(create: (_) => RecipeProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => CuisineProvider()),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.instance.start(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appState, child) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarBrightness: Brightness.light,
        ));
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return RefreshConfiguration(
          headerBuilder: () => WaterDropHeader(),
          footerBuilder: () => ClassicFooter(),
          headerTriggerDistance: 80.0,
          springDescription: SpringDescription(
            stiffness: 170,
            damping: 16,
            mass: 1.9,
          ),
          maxOverScrollExtent: 100,
          maxUnderScrollExtent: 0,
          enableScrollWhenRefreshCompleted: true,
          enableLoadingWhenFailed: true,
          hideFooterWhenNotFull: false,
          enableBallisticLoad: true,
          child: MaterialApp(
            key: navigatorKey,
            color: Colors.white,
            title: AppConfig.AppName,
            debugShowCheckedModeBanner: false,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            theme: appState.theme,
            initialRoute: SplashScreen.routeName,
            routes: routes,
          ),
        );
      },
    );
  }
}
