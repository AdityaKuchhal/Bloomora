# 🚀 Bloomora MVP Setup Guide

## AmazingPath Kids - Child Development Platform

## Prerequisites

- GitHub account
- Email address for services
- Credit card (for small charges)

## Step 1: Database Setup (Supabase) 🗄️

### 1.1 Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign up with GitHub
4. Click "New Project"
5. Project name: `bloomora-mvp`
6. Database password: Generate strong password (save it!)
7. Region: Choose closest to your users
8. Click "Create new project"

### 1.2 Set up Database Schema

1. Wait for project to be ready (2-3 minutes)
2. Go to **SQL Editor** in left sidebar
3. Click "New Query"
4. Copy entire contents of `database_schema.sql`
5. Paste and click "Run"
6. Verify tables are created in **Table Editor**

### 1.3 Configure Authentication

1. Go to **Authentication** → **Settings**
2. Site URL: `https://your-domain.com` (or localhost for testing)
3. Redirect URLs: Add `bloomora://auth-callback`
4. Enable email confirmations: OFF (for MVP)

### 1.4 Get API Keys

1. Go to **Settings** → **API**
2. Copy these values:
   - **Project URL**: `https://your-project-id.supabase.co`
   - **Anon Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
   - **Service Role Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

## Step 2: Backend Deployment (Railway) 🚂

### 2.1 Create Railway Account

1. Go to [https://railway.app](https://railway.app)
2. Click "Login" → "Login with GitHub"
3. Authorize Railway access

### 2.2 Deploy Backend

1. Click "New Project"
2. Choose "Deploy from GitHub repo"
3. Select your Bloomora repository
4. Choose "Deploy from folder" → `sample_backend`
5. Click "Deploy"

### 2.3 Configure Environment Variables

1. Go to your deployed project
2. Click on the service
3. Go to **Variables** tab
4. Add these variables:

```bash
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_KEY=your_service_role_key_here
JWT_SECRET=your_jwt_secret_here
OPENAI_API_KEY=your_openai_key_here
NODE_ENV=production
PORT=3000
FRONTEND_URL=https://your-flutter-app-domain.com
```

### 2.4 Get Railway URL

1. Once deployed, copy the URL: `https://amazingpathkids-api-production.up.railway.app`
2. This is your API base URL

## Step 3: OpenAI Setup 🤖

### 3.1 Create OpenAI Account

1. Go to [https://platform.openai.com](https://platform.openai.com)
2. Sign up or log in
3. Go to **API Keys**
4. Click "Create new secret key"
5. Name: `bloomora-mvp`
6. Copy the key (starts with `sk-`)

### 3.2 Add Credits

1. Go to **Billing** → **Usage**
2. Add $10-20 in credits
3. This lasts for several months of MVP usage

## Step 4: Test Your Backend 🧪

### 4.1 Test Health Check

```bash
# Replace with your Railway URL
curl https://your-railway-url.up.railway.app/health
```

Expected response:

```json
{
  "success": true,
  "message": "Bloomora API is running - AmazingPath Kids",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0"
}
```

### 4.2 Test API Endpoints

```bash
# Test children endpoint (should return 401 - missing token)
curl https://your-railway-url.up.railway.app/api/v1/children
```

Expected response:

```json
{
  "success": false,
  "error": {
    "code": "MISSING_TOKEN",
    "message": "Access token is required"
  }
}
```

## Step 5: Connect Flutter App 📱

### 5.1 Update API Client

1. Open `lib/core/api/api_client.dart`
2. Replace `bloomora-api.up.railway.app` with your actual Railway URL
3. Save the file

### 5.2 Add Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

### 5.3 Test Connection

1. Run your Flutter app
2. Try to create a child profile
3. Check if data appears in Supabase dashboard

## Step 6: Verify Everything Works ✅

### 6.1 Database Check

1. Go to Supabase **Table Editor**
2. Check if `child_profiles` table exists
3. Try inserting a test record

### 6.2 API Check

1. Test all endpoints with Postman or curl
2. Verify authentication works
3. Check error handling

### 6.3 Flutter App Check

1. Run the app
2. Create a child profile
3. Verify data appears in database
4. Test all screens work

## Troubleshooting 🔧

### Common Issues

#### 1. Railway Deployment Fails

- Check environment variables are set correctly
- Verify all dependencies in package.json
- Check Railway logs for errors

#### 2. Supabase Connection Issues

- Verify API keys are correct
- Check if database schema was created
- Ensure RLS policies are set up

#### 3. Flutter App Can't Connect

- Check API base URL is correct
- Verify network permissions
- Check if backend is running

#### 4. OpenAI API Errors

- Verify API key is correct
- Check if credits are available
- Ensure API key has proper permissions

### Getting Help

- Check Railway logs: Project → Service → Logs
- Check Supabase logs: Settings → Logs
- Test API with Postman
- Check Flutter console for errors

## Next Steps 🎯

Once everything is working:

1. **Test Core Features**

   - Create child profiles
   - Run assessments
   - Complete activities
   - View progress

2. **Add Real Data**

   - Create sample activities
   - Add assessment questions
   - Test AI analysis

3. **Deploy Flutter App**

   - Build for production
   - Deploy to app stores
   - Set up analytics

4. **Monitor & Scale**
   - Monitor usage and costs
   - Optimize performance
   - Plan for scaling

## Cost Summary 💰

### Monthly Costs

- **Supabase Free Tier**: $0 (500MB DB, 2GB bandwidth)
- **Railway Basic**: $5 (512MB RAM, 1GB storage)
- **OpenAI API**: $10-20 (depending on usage)
- **Total**: $15-25/month

### Scaling Costs

- **1,000 users**: ~$30-50/month
- **10,000 users**: ~$100-200/month
- **100,000 users**: ~$500-1000/month

## Success! 🎉

Your Bloomora MVP backend is now live and ready to impress investors and government officials!

**API Base URL**: `https://your-railway-url.up.railway.app/api/v1`
**Database**: Supabase PostgreSQL
**AI**: OpenAI GPT-4 integration
**Cost**: $15-25/month

Ready to build the future of child development! 🚀
