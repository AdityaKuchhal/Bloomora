# Bloomora API Endpoints

## AmazingPath Kids - Child Development Platform

## Base URL

- **Development**: `https://bloomora-api.railway.app/api/v1`
- **Production**: `https://api.bloomora.com/v1`

## Authentication

All endpoints require JWT token in Authorization header:

```
Authorization: Bearer <jwt_token>
```

## API Endpoints

### 1. Child Profile Management

#### GET /children

Get all children for authenticated user

```json
Response: {
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Emma",
      "date_of_birth": "2020-05-15",
      "gender": "female",
      "relationship": "daughter",
      "age_months": 42,
      "age_group": "3-4 years"
    }
  ]
}
```

#### POST /children

Create new child profile

```json
Request: {
  "name": "Emma",
  "date_of_birth": "2020-05-15",
  "gender": "female",
  "relationship": "daughter"
}

Response: {
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Emma",
    "date_of_birth": "2020-05-15",
    "gender": "female",
    "relationship": "daughter",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

#### PUT /children/{child_id}

Update child profile

#### DELETE /children/{child_id}

Delete child profile

### 2. Assessment Management

#### GET /assessments/questions/{age_group_id}

Get assessment questions for specific age group

```json
Response: {
  "success": true,
  "data": {
    "age_group": "3-4 years",
    "total_questions": 35,
    "questions": [
      {
        "id": "uuid",
        "domain": "Fine Motor Skills",
        "question_text": "Can your child pick up small objects with thumb and forefinger?",
        "question_type": "yes_no",
        "weight": 1.0
      }
    ]
  }
}
```

#### POST /assessments/sessions

Start new assessment session

```json
Request: {
  "child_id": "uuid",
  "age_group_id": "uuid"
}

Response: {
  "success": true,
  "data": {
    "session_id": "uuid",
    "total_questions": 35,
    "current_question": 1
  }
}
```

#### POST /assessments/sessions/{session_id}/responses

Submit answer for current question

```json
Request: {
  "question_id": "uuid",
  "answer": "yes",
  "response_time_ms": 2500
}

Response: {
  "success": true,
  "data": {
    "next_question": {
      "id": "uuid",
      "domain": "Gross Motor Skills",
      "question_text": "Can your child walk up stairs holding the railing?",
      "question_type": "yes_no"
    },
    "progress": {
      "current": 15,
      "total": 35,
      "percentage": 43
    }
  }
}
```

#### POST /assessments/sessions/{session_id}/complete

Complete assessment and get results

```json
Response: {
  "success": true,
  "data": {
    "session_id": "uuid",
    "overall_score": 78.5,
    "domain_scores": [
      {
        "domain": "Fine Motor Skills",
        "score": 85.0,
        "percentile": 75,
        "level": "advanced",
        "recommendations": [
          "Continue practicing with small objects",
          "Try more complex fine motor activities"
        ]
      }
    ],
    "ai_analysis": {
      "strengths": ["Excellent hand-eye coordination"],
      "areas_for_improvement": ["Bilateral coordination"],
      "next_steps": ["Introduce scissor cutting activities"]
    }
  }
}
```

### 3. Activities Management

#### GET /activities

Get activities with filters

```json
Query Parameters:
- domain_id: Filter by development domain
- age_group_id: Filter by age group
- difficulty: Filter by difficulty level
- featured: Get only featured activities
- limit: Number of results (default: 20)
- offset: Pagination offset

Response: {
  "success": true,
  "data": {
    "activities": [
      {
        "id": "uuid",
        "title": "Finger Painting Fun",
        "description": "Creative art activity for fine motor development",
        "domain": "Fine Motor Skills",
        "age_group": "3-4 years",
        "difficulty_level": "beginner",
        "duration_minutes": 15,
        "materials_needed": ["Paint", "Paper", "Apron"],
        "points": 50,
        "image_url": "https://...",
        "is_featured": true
      }
    ],
    "pagination": {
      "total": 150,
      "limit": 20,
      "offset": 0,
      "has_more": true
    }
  }
}
```

#### GET /activities/{activity_id}

Get detailed activity information

#### POST /activities/{activity_id}/start

Start activity session

```json
Request: {
  "child_id": "uuid"
}

Response: {
  "success": true,
  "data": {
    "session_id": "uuid",
    "activity": {
      "id": "uuid",
      "title": "Finger Painting Fun",
      "instructions": ["Step 1: Put on apron", "Step 2: Dip finger in paint"]
    }
  }
}
```

#### POST /activities/sessions/{session_id}/complete

Complete activity session

```json
Request: {
  "duration_minutes": 18,
  "feedback": "Emma loved this activity!",
  "parent_notes": "She was very focused and creative"
}

Response: {
  "success": true,
  "data": {
    "points_earned": 50,
    "total_points": 1250,
    "achievements": ["First Art Activity", "Focused for 15+ minutes"]
  }
}
```

### 4. Progress Tracking

#### GET /progress/{child_id}

Get child's progress overview

```json
Response: {
  "success": true,
  "data": {
    "child": {
      "name": "Emma",
      "age_months": 42
    },
    "overview": {
      "total_activities": 45,
      "total_time_minutes": 720,
      "total_points": 2250,
      "current_streak": 7
    },
    "domain_progress": [
      {
        "domain": "Fine Motor Skills",
        "activities_completed": 12,
        "time_spent": 180,
        "current_level": "advanced",
        "improvement": "+15%"
      }
    ],
    "recent_activities": [
      {
        "activity": "Finger Painting Fun",
        "completed_at": "2024-01-15T14:30:00Z",
        "points_earned": 50
      }
    ]
  }
}
```

#### GET /progress/{child_id}/timeline

Get detailed progress timeline

```json
Response: {
  "success": true,
  "data": {
    "timeline": [
      {
        "date": "2024-01-15",
        "activities_completed": 3,
        "time_spent": 45,
        "points_earned": 150,
        "milestones": ["Completed first art activity"]
      }
    ]
  }
}
```

### 5. Dashboard Data

#### GET /dashboard/{child_id}

Get dashboard data for specific child

```json
Response: {
  "success": true,
  "data": {
    "summary": {
      "activities_completed": 12,
      "skills_practiced": 6,
      "time_spent": "2:30",
      "current_streak": 7
    },
    "featured_activity": {
      "id": "uuid",
      "title": "Fine Motor Skills Challenge",
      "description": "Advanced hand-eye coordination activity",
      "duration_minutes": 20,
      "points": 100,
      "image_url": "https://...",
      "difficulty": "intermediate"
    },
    "upcoming_activities": [
      {
        "id": "uuid",
        "title": "Balance Beam Fun",
        "domain": "Gross Motor Skills",
        "scheduled_for": "2024-01-16T10:00:00Z"
      }
    ],
    "recent_achievements": [
      {
        "title": "Art Enthusiast",
        "description": "Completed 5 art activities",
        "earned_at": "2024-01-15T15:00:00Z"
      }
    ]
  }
}
```

### 6. Notifications

#### GET /notifications

Get user notifications

```json
Response: {
  "success": true,
  "data": {
    "unread_count": 3,
    "notifications": [
      {
        "id": "uuid",
        "type": "milestone_achieved",
        "title": "Emma reached a new milestone!",
        "message": "She completed her first assessment with flying colors!",
        "is_read": false,
        "created_at": "2024-01-15T16:00:00Z"
      }
    ]
  }
}
```

#### PUT /notifications/{notification_id}/read

Mark notification as read

### 7. AI Analysis

#### POST /ai/analyze-assessment

Analyze assessment results with AI

```json
Request: {
  "child_id": "uuid",
  "assessment_data": {
    "responses": [
      {
        "domain": "Fine Motor Skills",
        "score": 85,
        "responses": ["yes", "no", "yes"]
      }
    ],
    "age_months": 42
  }
}

Response: {
  "success": true,
  "data": {
    "analysis": {
      "overall_assessment": "Emma shows strong fine motor development for her age",
      "strengths": [
        "Excellent hand-eye coordination",
        "Good finger dexterity"
      ],
      "areas_for_improvement": [
        "Bilateral coordination could be strengthened"
      ],
      "recommendations": [
        "Continue with current fine motor activities",
        "Introduce scissor cutting exercises",
        "Try playdough sculpting for bilateral coordination"
      ],
      "next_assessment": "Schedule follow-up in 3 months"
    },
    "personalized_activities": [
      {
        "activity_id": "uuid",
        "title": "Scissor Skills Practice",
        "priority": "high",
        "reason": "Will help improve bilateral coordination"
      }
    ]
  }
}
```

## Error Handling

All endpoints return consistent error format:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "date_of_birth",
      "issue": "Date cannot be in the future"
    }
  }
}
```

## Rate Limiting

- 100 requests per minute per user
- 1000 requests per hour per user

## Response Codes

- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 429: Rate Limited
- 500: Internal Server Error
