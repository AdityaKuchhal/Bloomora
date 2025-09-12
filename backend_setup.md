# Bloomora Backend Setup Guide

## AmazingPath Kids - Child Development Platform

## 🚀 Quick Start (Cost-Effective MVP)

### Option 1: Supabase + Railway (Recommended)

**Monthly Cost: $0-15**

#### 1. Database Setup (Supabase)

```bash
# 1. Create Supabase project
# Go to https://supabase.com
# Create new project: "bloomora-mvp"

# 2. Run database schema
# Copy contents of database_schema.sql
# Paste in Supabase SQL Editor and run

# 3. Enable Row Level Security (RLS)
ALTER TABLE child_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE parent_notifications ENABLE ROW LEVEL SECURITY;

# 4. Create RLS policies
CREATE POLICY "Users can view own children" ON child_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own children" ON child_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

# Add similar policies for other tables...
```

#### 2. Backend API (Railway)

```bash
# 1. Create Railway project
# Go to https://railway.app
# Connect GitHub repository

# 2. Environment variables
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_KEY=your_supabase_service_key
JWT_SECRET=your_jwt_secret
OPENAI_API_KEY=your_openai_key
NODE_ENV=production
PORT=3000
```

### Option 2: Firebase + Vercel (Alternative)

**Monthly Cost: $0-25**

#### 1. Firebase Setup

```bash
# 1. Create Firebase project
# Go to https://console.firebase.google.com
# Enable Authentication, Firestore, Functions

# 2. Install Firebase CLI
npm install -g firebase-tools
firebase login
firebase init
```

#### 2. Vercel Deployment

```bash
# 1. Install Vercel CLI
npm install -g vercel

# 2. Deploy
vercel --prod
```

## 🏗️ Backend Architecture

### Project Structure

```
backend/
├── src/
│   ├── controllers/          # API route handlers
│   │   ├── authController.js
│   │   ├── childController.js
│   │   ├── assessmentController.js
│   │   ├── activityController.js
│   │   └── progressController.js
│   ├── middleware/           # Custom middleware
│   │   ├── auth.js
│   │   ├── validation.js
│   │   └── rateLimiter.js
│   ├── models/              # Database models
│   │   ├── Child.js
│   │   ├── Assessment.js
│   │   ├── Activity.js
│   │   └── Progress.js
│   ├── services/            # Business logic
│   │   ├── aiService.js
│   │   ├── assessmentService.js
│   │   └── notificationService.js
│   ├── utils/               # Utility functions
│   │   ├── database.js
│   │   ├── validation.js
│   │   └── helpers.js
│   ├── routes/              # API routes
│   │   ├── auth.js
│   │   ├── children.js
│   │   ├── assessments.js
│   │   ├── activities.js
│   │   └── progress.js
│   └── app.js               # Express app setup
├── package.json
├── .env.example
└── README.md
```

### Core Dependencies

```json
{
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "dotenv": "^16.3.1",
    "@supabase/supabase-js": "^2.38.0",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "joi": "^17.11.0",
    "express-rate-limit": "^7.1.5",
    "openai": "^4.20.1",
    "node-cron": "^3.0.3"
  },
  "devDependencies": {
    "nodemon": "^3.0.2",
    "jest": "^29.7.0",
    "supertest": "^6.3.3"
  }
}
```

## 🤖 AI Integration Strategy

### 1. Assessment Analysis

```javascript
// services/aiService.js
const OpenAI = require("openai");

class AIService {
  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });
  }

  async analyzeAssessment(assessmentData) {
    const prompt = `
    Analyze this child development assessment data:
    
    Child Age: ${assessmentData.age_months} months
    Domain Scores: ${JSON.stringify(assessmentData.domain_scores)}
    
    Provide:
    1. Overall assessment summary
    2. Key strengths identified
    3. Areas needing improvement
    4. Specific recommendations
    5. Suggested activities
    
    Format as JSON with clear, actionable insights for parents.
    `;

    const response = await this.openai.chat.completions.create({
      model: "gpt-4",
      messages: [{ role: "user", content: prompt }],
      temperature: 0.7,
      max_tokens: 1000,
    });

    return JSON.parse(response.choices[0].message.content);
  }

  async generatePersonalizedActivities(childProfile, assessmentResults) {
    // Generate activity recommendations based on assessment
  }
}
```

### 2. Smart Recommendations

```javascript
// services/recommendationService.js
class RecommendationService {
  generateActivityRecommendations(childId, domainScores) {
    // Algorithm to recommend activities based on:
    // - Child's age and development level
    // - Assessment scores
    // - Previous activity performance
    // - Parent preferences
  }

  calculateProgressTrend(childId, timeRange) {
    // Analyze progress over time
    // Identify improvement patterns
    // Predict future development needs
  }
}
```

## 📊 Analytics & Insights

### 1. Progress Tracking

```javascript
// services/analyticsService.js
class AnalyticsService {
  async generateProgressReport(childId, timeRange) {
    // Aggregate data from multiple sources:
    // - Assessment scores over time
    // - Activity completion rates
    // - Time spent on activities
    // - Parent feedback
  }

  async identifyMilestones(childId) {
    // Detect significant progress markers
    // Compare against age-appropriate benchmarks
    // Generate milestone notifications
  }
}
```

### 2. Parent Dashboard Data

```javascript
// Real-time dashboard updates
class DashboardService {
  async getDashboardData(childId) {
    return {
      summary: await this.getSummaryStats(childId),
      featuredActivity: await this.getFeaturedActivity(childId),
      upcomingActivities: await this.getUpcomingActivities(childId),
      recentAchievements: await this.getRecentAchievements(childId),
      progressChart: await this.getProgressChart(childId),
    };
  }
}
```

## 🔒 Security & Compliance

### 1. Data Protection

- **Encryption**: All sensitive data encrypted at rest
- **HTTPS**: All API communications encrypted
- **JWT**: Secure token-based authentication
- **RLS**: Row-level security in database
- **GDPR**: Compliant data handling

### 2. Privacy Features

- **Data Anonymization**: Remove PII when possible
- **Consent Management**: Clear data usage policies
- **Data Export**: Allow parents to export their data
- **Data Deletion**: Complete data removal on request

## 📱 Flutter Integration

### 1. API Client Setup

```dart
// lib/core/api/api_client.dart
class ApiClient {
  static const String baseUrl = 'https://amazingpathkids-api.railway.app/api/v1';

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    // Implement API calls with proper error handling
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    // Implement GET requests
  }
}
```

### 2. State Management Integration

```dart
// lib/features/dashboard/providers/dashboard_provider.dart
class DashboardProvider extends StateNotifier<DashboardState> {
  final ApiClient _apiClient = ApiClient();

  Future<void> loadDashboardData(String childId) async {
    final data = await _apiClient.get('/dashboard/$childId');
    state = DashboardState.fromJson(data);
  }
}
```

## 🚀 Deployment Strategy

### 1. Development Environment

```bash
# Local development
npm run dev
# Runs on http://localhost:3000
```

### 2. Staging Environment

```bash
# Deploy to staging
git push origin staging
# Auto-deploys to Railway staging
```

### 3. Production Environment

```bash
# Deploy to production
git push origin main
# Auto-deploys to Railway production
```

## 💰 Cost Breakdown (Monthly)

### Supabase + Railway

- **Supabase Free Tier**: $0 (500MB DB, 2GB bandwidth)
- **Railway Basic**: $5 (512MB RAM, 1GB storage)
- **OpenAI API**: $10-20 (depending on usage)
- **Total**: $15-25/month

### Scaling Options

- **Supabase Pro**: $25/month (8GB DB, 100GB bandwidth)
- **Railway Pro**: $20/month (2GB RAM, 10GB storage)
- **Total at scale**: $45-65/month

## 🎯 MVP Success Metrics

### Technical Metrics

- **API Response Time**: <200ms average
- **Uptime**: >99.5%
- **Error Rate**: <1%
- **Database Performance**: <100ms query time

### Business Metrics

- **User Engagement**: Daily active users
- **Assessment Completion**: % of started assessments completed
- **Activity Completion**: % of started activities completed
- **Parent Satisfaction**: App store ratings, feedback

## 🔄 Next Steps

1. **Set up Supabase project** and run database schema
2. **Create Railway project** and deploy basic API
3. **Implement core endpoints** (auth, children, assessments)
4. **Integrate OpenAI** for assessment analysis
5. **Connect Flutter app** to backend APIs
6. **Add real-time features** with Supabase subscriptions
7. **Implement analytics** and progress tracking
8. **Deploy to production** and monitor performance

This architecture provides a solid foundation for your MVP while keeping costs low and allowing for future scaling as you grow!
