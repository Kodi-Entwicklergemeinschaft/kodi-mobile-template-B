import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:your_app_name/src/data/remote/api/matomo_api.dart';
import 'package:your_app_name/src/data/repository/chat_repository.dart';
import 'package:your_app_name/src/data/repository/forum_repository.dart';
import 'package:your_app_name/src/data/repository/list_repository.dart';
import 'package:your_app_name/src/data/repository/user_repository.dart';
import 'package:your_app_name/src/firebase_options_staging/firebase_options_staging.dart';
import 'package:your_app_name/src/main_screen.dart';
import 'package:your_app_name/src/presentation/cubit/bloc.dart';
import 'package:your_app_name/src/presentation/main/splash_screen/splash_screen.dart';
import 'package:your_app_name/src/services/firebase_messaging_service.dart';
import 'package:your_app_name/src/services/remot_config_service.dart';
import 'package:your_app_name/src/utils/adapters/formdata_adapter.dart';
import 'package:your_app_name/src/utils/configs/application.dart';
import 'package:your_app_name/src/utils/configs/language.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:your_app_name/src/utils/configs/routes.dart';
import 'package:your_app_name/src/utils/your_app_bloc_observer.dart';
import 'package:your_app_name/src/utils/language_manager.dart';
import 'package:your_app_name/src/utils/logging/bloc_logger.dart';
import 'package:your_app_name/src/utils/logging/crashlytics_log_printer.dart';
import 'package:your_app_name/src/utils/logging/drift_logger.dart';
import 'package:your_app_name/src/utils/translate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:upgrader/upgrader.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(FormDataAdapter());
  WidgetsFlutterBinding.ensureInitialized();
  Loggy.initLoggy(
    logPrinter: FirebaseCrashlyticsLogPrinter(),
    filters: [
      BlacklistFilter([
        BlocLoggy,
        DriftLoggy,
      ])
    ],
  );
  await Hive.initFlutter();
  final prefBox = await Preferences.openBox();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Bloc.observer = AppBlocObserver();
  await Upgrader.clearSavedSettings();
  await Firebase.initializeApp(
    // name: should be commented for iOS build.
    // name: 'your-firebase-project-id',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('========================================');
  print('FIREBASE PROJECT ID: ${Firebase.app().options.projectId}');
  print('========================================');
  await RemoteConfigService().initialize();
  Application().loadRemoteConfig(RemoteConfigService().config);

  await FirebaseMessagingService(globalNavKey, prefBox).initNotifications();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  MatomoApi.initialize("YOUR_MATOMO_SITE_ID", 'https://your-matomo-instance.matomo.cloud/matomo.php');

  await SentryFlutter.init((options) {
    options.dsn =
        'https://YOUR_SENTRY_KEY@YOUR_SENTRY_ORG.ingest.de.sentry.io/YOUR_SENTRY_PROJECT_ID';
    options.tracesSampleRate = 0.01;
  }, appRunner: () => runApp(MyApp(prefBox)));
}

final globalNavKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final Preferences prefBox;

  const MyApp(
    this.prefBox, {
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AppBloc.applicationCubit.onSetup();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => UserRepository(),
        ),
        RepositoryProvider(
          create: (context) => ListRepository(widget.prefBox),
        ),
        RepositoryProvider(
          create: (context) => ForumRepository(widget.prefBox),
        ),
        RepositoryProvider(
          create: (context) => ChatRepository(),
        )
      ],
      child: MultiBlocProvider(
        providers: AppBloc.providers,
        child: BlocBuilder<LanguageCubit, Locale>(
          builder: (context, lang) {
            return BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, theme) {
                return ChangeNotifierProvider(
                  create: (_) => LanguageManager(),
                  child: MaterialApp(
                    navigatorKey: globalNavKey,
                    debugShowCheckedModeBanner: false,
                    theme: theme.lightTheme,
                    darkTheme: theme.darkTheme,
                    onGenerateRoute: Routes.generateRoute,
                    localizationsDelegates: const [
                      FlutterQuillLocalizations.delegate,
                      Translate.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: AppLanguage.supportLanguage,
                    home: Scaffold(
                      body: BlocBuilder<ApplicationCubit, ApplicationState>(
                        builder: (context, state) {
                          if (state == const ApplicationState.loaded()) {
                            return const MainScreen();
                          }
                          if (state == const ApplicationState.loading()) {
                            return const SplashScreen();
                          }
                          return const MainScreen();
                        },
                      ),
                    ),
                    builder: (context, child) {
                      final data = MediaQuery.of(context).copyWith(
                        textScaler:
                            TextScaler.linear(theme.textScaleFactor ?? 1),
                      );
                      return MediaQuery(
                        data: data,
                        child: child!,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
