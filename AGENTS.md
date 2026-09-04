<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan at E:\makhzan\stockflow-app\specs\009-owner-controlled-permissions\plan.md.
The full implementation tasks are in E:\makhzan\stockflow-app\specs\009-owner-controlled-permissions\tasks.md.
<!-- SPECKIT END -->

## Anchored Summary

### Last Session (commit `7174245`)
- **Goal**: Redesign company switcher, roles list, role permissions detail, and create-company screens to match Figma; wire up the full auth flow (splash → login → register → company selection → welcome → create/join → dashboard).
- **Key changes**:
  - `company_switcher.dart` — Redesigned bottom sheet with drag handle, company cards (avatar, name, type, role pill, check/chevron), divider, action rows (create/join/signout) with colored icon containers. `withOpacity` → `withValues`. Extracted `_CompanyCard` → `CompanyCard` (`company_card.dart`), `_ActionRow` → `ActionRow` (`action_row.dart`).
  - `create_company_screen.dart` — Figma design: logo picker, business-type chips, phone/address fields, two bottom buttons, staggered fade+slide animation. Creates `CreateCompanyCubit`.
  - `role_card.dart` — Figma card with themed icon container, role name, member-count pill, description, "إدارة الصلاحيات" button.
  - `roles_page.dart` — Header with title+subtitle, scrollable role cards, `AnimatedSwitcher`.
  - `role_detail_page.dart` — Figma permissions: back+title+subtitle+save pill, role info card, permission sections with `AnimatedAlign` toggle switches.
  - `permission_labels.dart` — Maps 20 keys to Arabic labels grouped into 6 sections.
  - `router.dart` — Full auth redirect logic (splash → login → register → company selection → welcome → create/join → dashboard). Fixed redirect to allow `companyCreate`/`welcomeJoin` when already selected. Sheet actions use `router.push()` (not `go()`) to avoid `GoError: nothing to pop`.
  - `Company.businessTypeId` (int?) → `businessType` (String?) in entity, model, data source, use case.
  - `AppNetworkImage` — wrapper around `CachedNetworkImage`.
  - `LogoPicker` — dashed-border image picker with gallery/camera source.
  - Added `CompanyCubit`, `AuthCubit`, full login/register/splash rewrites.
  - Committed 107 files, +7883 lines.
- **Critical context**:
  - Routes outside shell (`/company-create`, `/welcome/*`) use `parentNavigatorKey: _rootNavigatorKey`.
  - Company switcher actions: capture `GoRouter.of(context)` before `Navigator.pop(context)`, then use `router.push()` or `router.go()` as appropriate.
  - When `CompanySelected`, redirect allows `companyCreate` and `welcomeJoin` through.
- **Next steps**: TBD.
