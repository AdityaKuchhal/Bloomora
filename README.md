# 🌸 Bloomora

## AmazingPath Kids - Child Development Platform

**Bloomora** is a comprehensive child development platform that helps parents track, assess, and support their child's growth through AI-powered insights and personalized activities. Built for the MVP phase with a focus on investor readiness and government appeal.

## 🚀 **MVP Features**

### **Frontend (Flutter)**

- **Modern UI Design**: Glassmorphism effects with dark blue color palette
- **Child Profile Management**: Age-based development tracking
- **Assessment System**: AI-powered developmental assessments with Yes/No questions
- **Activity Management**: Personalized activity recommendations
- **Progress Tracking**: Real-time progress monitoring and analytics
- **Parent Dashboard**: Comprehensive overview of child's development
- **Cross-Platform**: Native performance on iOS and Android

### **Backend (Node.js + Express)**

- **RESTful API**: Complete backend infrastructure
- **Database**: PostgreSQL with Supabase
- **Authentication**: Secure user management
- **AI Integration**: OpenAI GPT-4 for assessment analysis
- **Real-time Features**: Live progress updates

### **Database Schema**

- **Child Profiles**: User management with age calculations
- **Development Domains**: 6 core areas (Fine Motor, Gross Motor, Cognitive, Language & Communication, Social & Emotional, Self-Care Skills)
- **Assessment System**: Questions, sessions, responses, and results
- **Activities**: Comprehensive activity management
- **Progress Tracking**: Real-time progress monitoring
- **Age Groups**: 1-2, 2-3, 3-4, 4-5 years

## 🛠️ **Tech Stack**

### **Frontend**

- **Flutter**: Cross-platform mobile development
- **Riverpod**: State management
- **GoRouter**: Navigation
- **Custom UI**: Glassmorphism design system
- **Material Design 3**: Modern UI components

### **Backend**

- **Node.js + Express**: API server
- **Supabase**: Database and authentication
- **OpenAI GPT-4**: AI analysis and recommendations
- **Railway**: Cloud hosting

### **Database**

- **PostgreSQL**: Primary database
- **Row Level Security**: GDPR-compliant data protection
- **Real-time Subscriptions**: Live updates

### **AI/ML Features**

- **Assessment Analysis**: GPT-4 powered development insights
- **Activity Recommendations**: AI-generated personalized suggestions
- **Progress Insights**: Smart progress analysis and encouragement
- **Parent-Friendly**: Clear, actionable advice for busy parents

## 📱 **App Flow**

1. **Intro Screens**: Beautiful onboarding with glassmorphism design
2. **Email Verification**: Secure account creation process
3. **Parent Signup/Signin**: Account management with auto-population
4. **Child Profile**: Child details, age, gender, and relationship
5. **Assessment**: Age-appropriate Yes/No questions across 6 developmental domains
6. **Priority Selection**: Choose top 3 developmental areas to focus on
7. **AI Analysis**: Loading screen with AI processing and recommendations
8. **Dashboard**: Modern fitness-app inspired interface with activity recommendations
9. **Activities**: Step-by-step activity guidance with media support
10. **Progress Tracking**: Detailed analytics and milestone tracking

## 🚀 **Quick Start**

### **Prerequisites**

- Flutter SDK (pinned via FVM — see [Development Setup](#-development-setup) below)
- Node.js
- Supabase account
- Anthropic API key (server-side only — see [Development Setup](#-development-setup))

### **Setup Instructions**

1. **Clone the repository**

   ```bash
   git clone https://github.com/AmazingPathKids/Bloomora.git
   cd Bloomora
   git checkout mvp
   ```

2. **Set up Supabase**

   - Create Supabase project
   - Run `database_schema.sql`
   - Get API keys

3. **Deploy Backend**

   - Deploy `sample_backend/` to Railway
   - Configure environment variables

4. **Run Flutter App** — see [Development Setup](#-development-setup) for the FVM/env-file steps that must come before `flutter pub get`/`flutter run`.

### **Detailed Setup**

- **[MVP Setup Guide](MVP_SETUP_GUIDE.md)**: Complete setup instructions
- **[API Documentation](api_endpoints.md)**: Backend API reference
- **[Database Schema](database_schema.sql)**: Database structure
- **[Backend Setup](backend_setup.md)**: Backend deployment guide

## 🛠️ **Development Setup**

This section is the source of truth for Flutter/Dart/Node versions and
environment configuration (FT-001). See `docs/audit-findings.md` for the
audit this closes out.

### Flutter/Dart version (pinned via FVM)

- **Flutter: `3.24.0`** / **Dart: `3.5.0`** (the Dart version Flutter 3.24.0 ships with) — pinned in the committed [`.fvmrc`](.fvmrc) and in `pubspec.yaml`'s `environment.sdk` constraint (`>=3.5.0 <4.0.0`).
- This matches what [`.github/workflows/ci.yml`](.github/workflows/ci.yml) hardcodes in its three `flutter-version: '3.24.0'` steps. **If you ever bump the Flutter version, update `.fvmrc` and all three CI steps together** — they are not currently wired to read from one place (see "Known follow-ups" below).
- To use the pin locally:
  ```bash
  dart pub global activate fvm   # one-time
  fvm install                    # installs 3.24.0 per .fvmrc
  fvm flutter pub get
  fvm flutter run
  ```
  (Prefix any `flutter`/`dart` command with `fvm` to use the pinned version. Without `fvm`, your global Flutter install is used, which may not match 3.24.0.)

### Node/backend version

- `backend/package-lock.json` is committed — always run `npm ci` (not `npm install`) in `backend/` for reproducible installs matching that lockfile.

### Environment configuration (dev/staging/production)

There are three **source** files, one per environment — but only ever
**one** of them is ever bundled into a build. `pubspec.yaml` declares just
`.env` as a Flutter asset (never `.env.development`/`.env.staging`/
`.env.production` directly), so a compiled app — including a "release"
build — only ever contains the single environment's values it was built
for, never all three. This matters because `SUPABASE_ANON_KEY` etc. are
public-tier but still environment-specific — a production binary must not
ship dev credentials.

| Environment | Source file | Selected via | Backing infra |
|---|---|---|---|
| development (default) | `.env.development` | `scripts/select_env.sh development` (or no arg), + `--dart-define=APP_ENV=development` or no flag | existing dev Supabase project ("bloomora") |
| staging | `.env.staging` | `scripts/select_env.sh staging` + `--dart-define=APP_ENV=staging` | **does not exist yet** — placeholder values only |
| production | `.env.production` | `scripts/select_env.sh production` + `--dart-define=APP_ENV=production` | **does not exist yet** — placeholder values only |

Setup:

```bash
cp .env.development.example .env.development   # fill in real dev values (ask a teammate)
cp .env.staging.example .env.staging            # leave as placeholders until staging infra exists
cp .env.production.example .env.production       # leave as placeholders until production infra exists
```

Before every `flutter run`/`flutter build`, copy the target environment's
file to `.env` (the one file pubspec.yaml actually bundles) with
[`scripts/select_env.sh`](scripts/select_env.sh), passing the **same**
environment name you're about to pass via `--dart-define`:

```bash
scripts/select_env.sh development && flutter run
scripts/select_env.sh staging && flutter run --dart-define=APP_ENV=staging       # shows the config-error screen today (expected — staging infra doesn't exist yet)
scripts/select_env.sh production && flutter build apk --release --dart-define=APP_ENV=production
```

If these two ever disagree (e.g. you forget to re-run the script after
switching `--dart-define`), the app detects the mismatch at startup and
shows the Configuration Error screen rather than silently running
against the wrong environment's data — see
[`lib/main.dart`](lib/main.dart).

`.env` and all three `.env.<environment>` source files are gitignored —
never commit any of them.

Backend:

```bash
cp backend/.env.example backend/.env
# fill in real values, then:
cd backend && npm ci && npm run dev
```

See [Mobile App Configuration](#-mobile-app-configuration) below for what each mobile variable is and its public/secret classification.

### Known follow-ups (intentionally out of FT-001's scope)

- CI still hardcodes `3.24.0` directly in three `flutter-action` steps rather than reading `.fvmrc`; switching CI to `fvm flutter` was judged a non-trivial workflow restructuring and left for a follow-up.
- CI's staging/production values (where used) are hardcoded placeholders in the workflow file, not pulled from GitHub Secrets — once real staging/production infra and secrets exist, update the corresponding CI steps to source them from secrets instead.
- `scripts/select_env.sh` is a manual step before `flutter run`/`flutter build` today; folding it into a `flutter run` wrapper or IDE launch config would remove the chance of forgetting it (mitigated for now by the startup mismatch check described above).

## 📱 **Mobile App Configuration**

Every public config variable the Flutter app reads, defined in
[`lib/core/config/app_config.dart`](lib/core/config/app_config.dart). All of
these are **public-tier** — safe to ship inside the compiled app — per the
Security & Access doc's classification (see `docs/audit-findings.md`
Section A/E): Supabase's anon/publishable key and Google's OAuth client IDs
are designed to be embedded client-side; RLS (not key secrecy) is the real
access boundary for Supabase, and Google client IDs are not secrets.

| Variable | Purpose | Source |
|---|---|---|
| `APP_ENV` | Which environment this build/run targets (`development`/`staging`/`production`) | Set inside `.env.<environment>`, copied into the bundled `.env` by `scripts/select_env.sh`; cross-checked at startup against the `--dart-define=APP_ENV=...` flag |
| `API_BASE_URL` | Base URL of the Node/Express backend API | `.env.<environment>`, via `.env` (see above) |
| `SUPABASE_URL` | Supabase project URL | `.env.<environment>`, via `.env` (see above) |
| `SUPABASE_ANON_KEY` | Supabase anon/publishable key (public by design — RLS is the real boundary) | `.env.<environment>`, via `.env` (see above) |
| `GOOGLE_IOS_CLIENT_ID` | Google Sign-In OAuth client ID (iOS) | Compile-time `--dart-define`, with a checked-in default in `app_config.dart` (not per-environment today) |
| `GOOGLE_WEB_CLIENT_ID` | Google Sign-In OAuth client ID (web/server) | Compile-time `--dart-define`, with a checked-in default in `app_config.dart` (not per-environment today) |

**Never add an AI provider key (Anthropic or otherwise) to any
`.env.<environment>` file or to `app_config.dart`.** That class of key is
server-only — see `backend/.env.example` — and must never be bundled into
the Flutter app. This is enforced by omission: there is no AI-provider-key
getter in `app_config.dart` and none of the `.env.<environment>` files
contain one. (A prior `OPENAI_API_KEY`/`openAiApiKey` pairing existed here
and shipped inside CI's release builds' bundled `.env`; both were removed
as part of FT-001 — see `docs/audit-findings.md` Section A/E.)

Required vs. optional: `API_BASE_URL`, `SUPABASE_URL`, and
`SUPABASE_ANON_KEY` are required — the app fails fast with a readable
**Configuration Error** screen at startup (see
[`lib/core/config/config_error_screen.dart`](lib/core/config/config_error_screen.dart))
if any is missing or still a `REPLACE_WITH_*` placeholder for the selected
environment. `GOOGLE_IOS_CLIENT_ID`/`GOOGLE_WEB_CLIENT_ID` have checked-in
defaults and are not part of that fail-fast check.

## 📁 **Project Structure**

```
Bloomora/
├── lib/                    # Flutter app source code
│   ├── core/              # Core utilities and widgets
│   ├── features/          # Feature-based architecture
│   └── main.dart          # App entry point
├── sample_backend/         # Node.js backend API
│   ├── src/               # Backend source code
│   └── package.json       # Backend dependencies
├── database_schema.sql     # PostgreSQL database schema
├── api_endpoints.md        # API documentation
├── MVP_SETUP_GUIDE.md     # Complete setup guide
└── README.md              # This file
```

## 💰 **Cost Structure**

### **MVP Phase**

- **Supabase Free Tier**: $0 (500MB DB, 2GB bandwidth)
- **Railway Basic**: $5 (512MB RAM, 1GB storage)
- **OpenAI API**: $10-20 (pay-per-use)
- **Total**: $15-25/month

### **Scaling Phase**

- **1,000 users**: ~$30-50/month
- **10,000 users**: ~$100-200/month
- **100,000 users**: ~$500-1000/month

## 🔒 **Security & Compliance**

### **Data Protection**

- **Encryption**: All sensitive data encrypted at rest and in transit
- **HTTPS**: All API communications encrypted
- **JWT**: Secure token-based authentication
- **RLS**: Row-level security in database
- **GDPR**: Compliant data handling

### **Privacy Features**

- **Data Anonymization**: Remove PII when possible
- **Consent Management**: Clear data usage policies
- **Data Export**: Allow parents to export their data
- **Data Deletion**: Complete data removal on request

## 🎯 **MVP Goals**

### **For Investors**

- **Scalable Architecture**: Ready for enterprise deployment
- **AI Integration**: Advanced assessment analysis
- **User Engagement**: Comprehensive tracking and analytics
- **Cost Effective**: $15-25/month operational costs

### **For Government Officials**

- **Data Security**: GDPR-compliant data handling
- **Evidence-Based**: Research-backed development tracking
- **Accessibility**: Inclusive design for all families
- **Scalability**: Ready for national deployment

## 🔮 **Future Roadmap**

### **Phase 1: MVP Launch** (Months 1-3)

- ✅ Core functionality deployment
- ✅ User acquisition and feedback
- ✅ Basic AI integration
- ✅ Modern UI with glassmorphism design

### **Phase 2: Enhanced Features** (Months 4-6)

- 🔄 Advanced analytics
- 🔄 Real-time notifications
- 🔄 Parent education content
- 🔄 Activity recommendation engine

### **Phase 3: Scale & Optimize** (Months 7+)

- 🔄 Multi-language support
- 🔄 Healthcare provider integration
- 🔄 Advanced AI features
- 🔄 Global expansion

## 🌟 **Key Features for MVP**

1. **Child Development Tracking**: Age-appropriate assessments
2. **AI-Powered Insights**: GPT-4 analysis and recommendations
3. **Activity Management**: Personalized activity suggestions
4. **Progress Analytics**: Real-time development monitoring
5. **Parent Dashboard**: Comprehensive overview and insights
6. **Modern UI**: Glassmorphism design with dark blue theme
7. **Cross-Platform**: Flutter for iOS and Android
8. **Scalable Backend**: Ready for enterprise deployment

## 🤝 **Contributing**

We welcome contributions! Please see our contributing guidelines for details.

## 📄 **License**

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 **Contact**

- **Company**: AmazingPath Kids
- **App**: Bloomora
- **Repository**: [https://github.com/AmazingPathKids/Bloomora](https://github.com/AmazingPathKids/Bloomora)
- **Support**: founder@amazingpathkids.com

## 🙏 **Acknowledgments**

- Flutter team for the amazing framework
- Riverpod for state management
- Supabase for backend infrastructure
- OpenAI for AI capabilities
- The open-source community for inspiration and tools

---

**Ready to revolutionize child development tracking! 🌸**
