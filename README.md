# Bloomora - AI-Driven Special Child Support Mobile Application

A comprehensive Flutter application designed to help parents, educators, and therapists identify developmental delays early and provide personalized intervention strategies for children with special needs.

## 🚀 Features

### Core Functionality

- **AI-Powered Assessments**: Comprehensive questionnaires analyzing both parent knowledge and child conditions for early detection
- **Personalized Interventions**: Tailored recommendations that evolve with the child's progress
- **Progress Tracking**: Dynamic, real-time adaptation of recommendations based on continuous data collection
- **7 Developmental Domains**: Fine Motor, Gross Motor, Communication, Social-Emotional, Cognitive, Adaptive Skills, and Sensory Processing
- **4 Age Groups**: 1-2, 2-3, 3-4, and 4-5 years

### User Experience

- **Modern UI/UX**: Beautiful, intuitive interface designed for both tech-savvy and non-technical users
- **Cross-Platform**: Native performance on both iOS and Android
- **Offline Capabilities**: Core features work without internet connection
- **Real-time Synchronization**: Seamless data sync across devices

## 🏗️ Technical Architecture

### Frontend

- **Framework**: Flutter 3.16+ with Dart
- **State Management**: Riverpod with code generation
- **Navigation**: Go Router
- **UI Components**: Material Design 3 with custom theming
- **Animations**: Flutter Animate and Lottie

### Backend (Planned)

- **Architecture**: AWS Serverless Microservices
- **Database**: DynamoDB + RDS PostgreSQL
- **AI/ML**: AWS SageMaker + TensorFlow Lite
- **Authentication**: AWS Cognito
- **Storage**: AWS S3 + CloudFront CDN

### AI/ML Features

- **Assessment Analysis**: Custom models for ADHD/ASD detection
- **Activity Recommendations**: AI-powered personalized suggestions
- **Progress Prediction**: Developmental trajectory modeling
- **Natural Language Processing**: Chatbot and content analysis

## 📱 App Flow

1. **Parent Signup**: Account creation with basic information
2. **Child Profile**: Child details, age, existing diagnoses, and concerns
3. **Assessment**: 35-question questionnaire across 7 developmental domains
4. **Priority Selection**: Choose top 3 developmental areas to focus on
5. **AI Analysis**: Loading screen with AI processing and recommendations
6. **Dashboard**: Personalized activity recommendations and progress tracking
7. **Activities**: Step-by-step activity guidance with media support
8. **Progress Tracking**: Detailed analytics and milestone tracking

## 🛠️ Setup Instructions

### Prerequisites

- Flutter SDK 3.16 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode for mobile development
- VS Code or Android Studio for development

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/AmazingPathKids/Bloomora.git
   cd Bloomora
   git checkout mvp
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate code**

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Firebase Setup (Required for full functionality)

1. Create a new Firebase project
2. Enable Authentication and Firestore
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the appropriate directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants and configuration
│   ├── router/             # Navigation configuration
│   └── theme/              # App theming and colors
├── features/
│   ├── onboarding/         # User registration and child profile
│   ├── assessment/         # Questionnaire and AI analysis
│   ├── dashboard/          # Main app interface
│   ├── activities/         # Activity management
│   ├── progress/           # Progress tracking
│   ├── search/             # Search functionality
│   └── profile/            # User profile management
└── main.dart               # App entry point
```

## 🔒 Security & Compliance

### Data Protection

- **Encryption**: AES-256 for data at rest, TLS 1.3 for data in transit
- **Privacy**: PIPEDA compliant for Canadian market
- **Child Safety**: COPPA compliant with parental controls
- **Healthcare**: HIPAA ready infrastructure

### Compliance Features

- **Data Minimization**: Collect only necessary information
- **Consent Management**: Granular consent controls
- **Data Rights**: Access, correction, and deletion capabilities
- **Audit Logging**: Complete activity tracking

## 🚀 Development Roadmap

### Phase 1: MVP (Months 1-3)

- ✅ Core UI/UX implementation
- ✅ Assessment questionnaire system
- ✅ Basic navigation and routing
- ✅ User onboarding flow
- 🔄 AI integration and analysis
- 🔄 Activity recommendation system

### Phase 2: Enhanced Features (Months 4-6)

- 🔄 Real-time progress tracking
- 🔄 Advanced analytics dashboard
- 🔄 Professional portal for therapists
- 🔄 Chatbot integration
- 🔄 Offline capabilities

### Phase 3: Scale & Optimize (Months 7-9)

- 🔄 Performance optimization
- 🔄 Advanced AI features
- 🔄 International expansion
- 🔄 Enterprise features
- 🔄 API integrations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support, email support@bloomora.com or join our Slack channel.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for state management
- AWS for cloud infrastructure
- The open-source community for inspiration and tools

---

**Built with ❤️ for children and families**
