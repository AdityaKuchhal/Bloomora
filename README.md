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

- Flutter SDK
- Node.js
- Supabase account
- OpenAI API key

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

4. **Run Flutter App**
   ```bash
   flutter pub get
   flutter run
   ```

### **Detailed Setup**

- **[MVP Setup Guide](MVP_SETUP_GUIDE.md)**: Complete setup instructions
- **[API Documentation](api_endpoints.md)**: Backend API reference
- **[Database Schema](database_schema.sql)**: Database structure
- **[Backend Setup](backend_setup.md)**: Backend deployment guide

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
