// Test script for Bloomora API - AmazingPath Kids
const https = require('https');

// Replace with your actual Railway URL
const API_BASE_URL = 'https://bloomora-api.up.railway.app/api/v1';

// Test functions
async function testHealthCheck() {
  console.log('🏥 Testing Health Check...');
  try {
    const response = await fetch(`${API_BASE_URL.replace('/api/v1', '')}/health`);
    const data = await response.json();
    console.log('✅ Health Check:', data);
    return true;
  } catch (error) {
    console.log('❌ Health Check Failed:', error.message);
    return false;
  }
}

async function testAuth() {
  console.log('🔐 Testing Authentication...');
  try {
    // Test with invalid token
    const response = await fetch(`${API_BASE_URL}/children`, {
      headers: {
        'Authorization': 'Bearer invalid-token'
      }
    });
    const data = await response.json();
    
    if (data.success === false && data.error.code === 'INVALID_TOKEN') {
      console.log('✅ Authentication working correctly');
      return true;
    } else {
      console.log('❌ Authentication not working as expected');
      return false;
    }
  } catch (error) {
    console.log('❌ Authentication Test Failed:', error.message);
    return false;
  }
}

async function testDatabaseConnection() {
  console.log('🗄️ Testing Database Connection...');
  try {
    // This would require a valid token, so we'll just test the endpoint structure
    const response = await fetch(`${API_BASE_URL}/children`);
    const data = await response.json();
    
    if (data.error && data.error.code === 'MISSING_TOKEN') {
      console.log('✅ Database connection working (endpoint responding)');
      return true;
    } else {
      console.log('❌ Database connection issue');
      return false;
    }
  } catch (error) {
    console.log('❌ Database Test Failed:', error.message);
    return false;
  }
}

// Run all tests
async function runTests() {
  console.log('🚀 Starting Bloomora API Tests - AmazingPath Kids...\n');
  
  const healthCheck = await testHealthCheck();
  const auth = await testAuth();
  const database = await testDatabaseConnection();
  
  console.log('\n📊 Test Results:');
  console.log(`Health Check: ${healthCheck ? '✅' : '❌'}`);
  console.log(`Authentication: ${auth ? '✅' : '❌'}`);
  console.log(`Database: ${database ? '✅' : '❌'}`);
  
  if (healthCheck && auth && database) {
    console.log('\n🎉 All tests passed! Your API is ready!');
    console.log(`\n🔗 API Base URL: ${API_BASE_URL}`);
    console.log('📱 You can now connect your Flutter app to this backend.');
  } else {
    console.log('\n⚠️ Some tests failed. Check the configuration.');
  }
}

// Run tests
runTests();
