import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/cases/presentation/pages/case_tags_page.dart';
import '../../features/cases/presentation/pages/case_types_page.dart';
import '../../features/cases/presentation/pages/create_case_page.dart';
import '../../features/cases/presentation/pages/cases_page.dart';
import '../../features/cases/presentation/pages/master_case_page.dart';
import '../../features/sessions/presentation/pages/create_session_page.dart';
import '../../features/sessions/presentation/pages/assessment_types_page.dart';
import '../../features/sessions/presentation/pages/intervention_master_page.dart';
import '../../features/sessions/presentation/pages/master_session_page.dart';
import '../../features/sessions/presentation/pages/sessions_page.dart';
import '../../features/sessions/presentation/pages/update_session_page.dart';
import '../../features/clients/presentation/pages/create_client_page.dart';
import '../../features/clients/presentation/pages/clients_page.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/master_data/presentation/pages/master_data_page.dart';
import '../../features/psychologist_portal/presentation/pages/psychologist_portal_pages.dart';
import '../../features/psychologist_portal/presentation/widgets/psychologist_portal_widgets.dart';
import '../../features/psychologists/presentation/pages/create_psychologist_page.dart';
import '../../features/psychologists/presentation/pages/psychologists_page.dart';
import 'router_refresh_notifier.dart';

class AppRouter {
  AppRouter({required AuthCubit authCubit, required bool isSupabaseConfigured})
    : _refreshNotifier = RouterRefreshNotifier(authCubit.stream) {
    router = GoRouter(
      initialLocation: LoginPage.path,
      refreshListenable: _refreshNotifier,
      routes: <RouteBase>[
        GoRoute(
          path: LoginPage.path,
          name: LoginPage.name,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: HomePage.path,
          name: HomePage.name,
          builder: (context, state) => const HomePage(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            final location = state.matchedLocation;
            final activeTab = switch (location) {
              PsychologistClientsPage.path => PsychologistNavTab.clients,
              PsychologistCasesPage.path => PsychologistNavTab.cases,
              PsychologistSchedulePage.path => PsychologistNavTab.schedule,
              PsychologistProfilePage.path => PsychologistNavTab.profile,
              _ => PsychologistNavTab.home,
            };

            return PsychologistPortalShell(activeTab: activeTab, child: child);
          },
          routes: <RouteBase>[
            GoRoute(
              path: PsychologistDashboardPage.path,
              name: PsychologistDashboardPage.name,
              builder: (context, state) => const PsychologistDashboardPage(),
            ),
            GoRoute(
              path: PsychologistClientsPage.path,
              name: PsychologistClientsPage.name,
              builder: (context, state) => const PsychologistClientsPage(),
            ),
            GoRoute(
              path: PsychologistCasesPage.path,
              name: PsychologistCasesPage.name,
              builder: (context, state) => const PsychologistCasesPage(),
            ),
            GoRoute(
              path: PsychologistSchedulePage.path,
              name: PsychologistSchedulePage.name,
              builder: (context, state) => const PsychologistSchedulePage(),
            ),
            GoRoute(
              path: PsychologistProfilePage.path,
              name: PsychologistProfilePage.name,
              builder: (context, state) => const PsychologistProfilePage(),
            ),
          ],
        ),
        GoRoute(
          path: PsychologistCaseDetailPage.path,
          name: PsychologistCaseDetailPage.name,
          builder: (context, state) => const PsychologistCaseDetailPage(),
        ),
        GoRoute(
          path: PsychologistNewSessionPage.path,
          name: PsychologistNewSessionPage.name,
          builder: (context, state) => const PsychologistNewSessionPage(),
        ),
        GoRoute(
          path: PsychologistSessionDetailPage.path,
          name: PsychologistSessionDetailPage.name,
          builder: (context, state) => const PsychologistSessionDetailPage(),
        ),
        GoRoute(
          path: PsychologistNotificationsPage.path,
          name: PsychologistNotificationsPage.name,
          builder: (context, state) => const PsychologistNotificationsPage(),
        ),
        GoRoute(
          path: PsychologistSettingsPage.path,
          name: PsychologistSettingsPage.name,
          builder: (context, state) => const PsychologistSettingsPage(),
        ),
        GoRoute(
          path: ProfilePage.path,
          name: ProfilePage.name,
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: MasterDataPage.path,
          name: MasterDataPage.name,
          builder: (context, state) => const MasterDataPage(),
        ),
        GoRoute(
          path: ClientsPage.path,
          name: ClientsPage.name,
          builder: (context, state) => const ClientsPage(),
        ),
        GoRoute(
          path: CreateClientPage.path,
          name: CreateClientPage.name,
          builder: (context, state) => const CreateClientPage(),
        ),
        GoRoute(
          path: PsychologistsPage.path,
          name: PsychologistsPage.name,
          builder: (context, state) => const PsychologistsPage(),
        ),
        GoRoute(
          path: CreatePsychologistPage.path,
          name: CreatePsychologistPage.name,
          builder: (context, state) => const CreatePsychologistPage(),
        ),
        GoRoute(
          path: CasesPage.path,
          name: CasesPage.name,
          builder: (context, state) => const CasesPage(),
        ),
        GoRoute(
          path: MasterCasePage.path,
          name: MasterCasePage.name,
          builder: (context, state) => const MasterCasePage(),
        ),
        GoRoute(
          path: CreateCasePage.path,
          name: CreateCasePage.name,
          builder: (context, state) => const CreateCasePage(),
        ),
        GoRoute(
          path: CaseTagsPage.path,
          name: CaseTagsPage.name,
          builder: (context, state) => const CaseTagsPage(),
        ),
        GoRoute(
          path: CaseTypesPage.path,
          name: CaseTypesPage.name,
          builder: (context, state) => const CaseTypesPage(),
        ),
        GoRoute(
          path: MasterSessionPage.path,
          name: MasterSessionPage.name,
          builder: (context, state) => const MasterSessionPage(),
        ),
        GoRoute(
          path: AssessmentTypesPage.path,
          name: AssessmentTypesPage.name,
          builder: (context, state) => const AssessmentTypesPage(),
        ),
        GoRoute(
          path: InterventionMasterPage.path,
          name: InterventionMasterPage.name,
          builder: (context, state) => const InterventionMasterPage(),
        ),
        GoRoute(
          path: SessionsPage.path,
          name: SessionsPage.name,
          builder: (context, state) {
            final caseSummary = state.extra as dynamic;
            return SessionsPage(caseSummary: caseSummary);
          },
        ),
        GoRoute(
          path: CreateSessionPage.path,
          name: CreateSessionPage.name,
          builder: (context, state) {
            final caseSummary = state.extra as dynamic;
            return CreateSessionPage(caseSummary: caseSummary);
          },
        ),
        GoRoute(
          path: UpdateSessionPage.path,
          name: UpdateSessionPage.name,
          builder: (context, state) {
            final args = state.extra as UpdateSessionArgs;
            return UpdateSessionPage(args: args);
          },
        ),
      ],
      redirect: (context, state) {
        final authState = authCubit.state;
        final isLoading =
            authState.status == AuthStatus.initial ||
            authState.status == AuthStatus.loading;
        final isLoggedIn = authState.status == AuthStatus.authenticated;
        final isGoingToLogin = state.matchedLocation == LoginPage.path;

        if (isLoading) {
          return null;
        }

        if (!isSupabaseConfigured) {
          return isGoingToLogin ? null : LoginPage.path;
        }

        if (!isLoggedIn) {
          return isGoingToLogin ? null : LoginPage.path;
        }

        if (isGoingToLogin) {
          return authState.isPsychologistUser
              ? PsychologistDashboardPage.path
              : HomePage.path;
        }

        return null;
      },
    );
  }

  final RouterRefreshNotifier _refreshNotifier;
  late final GoRouter router;

  @visibleForTesting
  RouterRefreshNotifier get refreshNotifier => _refreshNotifier;
}
