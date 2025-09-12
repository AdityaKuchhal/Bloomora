const OpenAI = require('openai');

class AIService {
  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY
    });
  }

  async analyzeAssessment(assessmentData) {
    try {
      const { childId, ageMonths, domainScores, responses } = assessmentData;

      const prompt = `
You are an expert child development specialist analyzing assessment results for a ${ageMonths}-month-old child.

Assessment Data:
- Age: ${ageMonths} months
- Domain Scores: ${JSON.stringify(domainScores, null, 2)}
- Individual Responses: ${JSON.stringify(responses, null, 2)}

Please provide a comprehensive analysis in the following JSON format:

{
  "overall_assessment": "Brief overall summary of the child's development",
  "strengths": [
    "List 3-5 key strengths identified"
  ],
  "areas_for_improvement": [
    "List 3-5 areas that need attention"
  ],
  "recommendations": [
    "List 5-7 specific, actionable recommendations for parents"
  ],
  "next_steps": [
    "List 3-4 immediate next steps"
  ],
  "confidence_level": "high|medium|low",
  "follow_up_timing": "suggested time for next assessment"
}

Focus on:
1. Age-appropriate expectations
2. Practical, actionable advice for parents
3. Positive, encouraging tone
4. Specific activity suggestions
5. Warning signs to watch for

Keep recommendations practical and achievable for busy parents.
      `;

      const response = await this.openai.chat.completions.create({
        model: "gpt-4",
        messages: [
          {
            role: "system",
            content: "You are an expert child development specialist with 20+ years of experience. Provide practical, evidence-based advice for parents."
          },
          {
            role: "user",
            content: prompt
          }
        ],
        temperature: 0.7,
        max_tokens: 1500
      });

      const analysis = JSON.parse(response.choices[0].message.content);
      
      return {
        success: true,
        analysis: {
          ...analysis,
          generated_at: new Date().toISOString(),
          model_used: "gpt-4"
        }
      };

    } catch (error) {
      console.error('AI analysis error:', error);
      return {
        success: false,
        error: {
          code: 'AI_ANALYSIS_ERROR',
          message: 'Failed to analyze assessment with AI'
        }
      };
    }
  }

  async generatePersonalizedActivities(childProfile, assessmentResults) {
    try {
      const { ageMonths, name } = childProfile;
      const { domainScores, analysis } = assessmentResults;

      const prompt = `
Generate personalized activity recommendations for ${name}, a ${ageMonths}-month-old child.

Assessment Results:
- Domain Scores: ${JSON.stringify(domainScores, null, 2)}
- Key Areas for Improvement: ${analysis.areas_for_improvement?.join(', ') || 'None specified'}

Create 5-7 specific activity recommendations in this JSON format:

{
  "activities": [
    {
      "title": "Activity name",
      "description": "Brief description",
      "domain": "Fine Motor Skills",
      "difficulty": "beginner|intermediate|advanced",
      "duration_minutes": 15,
      "materials": ["list", "of", "materials"],
      "instructions": ["step", "by", "step", "instructions"],
      "benefits": ["specific", "benefits"],
      "priority": "high|medium|low",
      "reason": "Why this activity is recommended"
    }
  ]
}

Focus on:
1. Age-appropriate activities
2. Addressing identified areas for improvement
3. Using common household materials
4. Clear, simple instructions
5. Fun and engaging for the child
      `;

      const response = await this.openai.chat.completions.create({
        model: "gpt-4",
        messages: [
          {
            role: "system",
            content: "You are an expert early childhood educator creating personalized activity recommendations for parents."
          },
          {
            role: "user",
            content: prompt
          }
        ],
        temperature: 0.8,
        max_tokens: 2000
      });

      const activities = JSON.parse(response.choices[0].message.content);
      
      return {
        success: true,
        data: activities
      };

    } catch (error) {
      console.error('AI activity generation error:', error);
      return {
        success: false,
        error: {
          code: 'AI_ACTIVITY_ERROR',
          message: 'Failed to generate personalized activities'
        }
      };
    }
  }

  async generateProgressInsights(progressData) {
    try {
      const { childName, timeRange, activities, assessments } = progressData;

      const prompt = `
Analyze progress data for ${childName} over the last ${timeRange}.

Progress Data:
- Activities Completed: ${activities.length}
- Recent Assessment Scores: ${JSON.stringify(assessments, null, 2)}
- Activity Performance: ${JSON.stringify(activities, null, 2)}

Generate insights in this JSON format:

{
  "progress_summary": "Overall progress summary",
  "key_achievements": [
    "List 3-5 key achievements"
  ],
  "improvement_areas": [
    "Areas showing improvement"
  ],
  "concerns": [
    "Any areas of concern (if any)"
  ],
  "recommendations": [
    "Next steps and recommendations"
  ],
  "encouragement": "Positive, encouraging message for parents"
}

Focus on:
1. Celebrating progress and achievements
2. Identifying patterns and trends
3. Practical next steps
4. Encouraging continued engagement
      `;

      const response = await this.openai.chat.completions.create({
        model: "gpt-4",
        messages: [
          {
            role: "system",
            content: "You are a child development expert providing progress insights and encouragement to parents."
          },
          {
            role: "user",
            content: prompt
          }
        ],
        temperature: 0.7,
        max_tokens: 1000
      });

      const insights = JSON.parse(response.choices[0].message.content);
      
      return {
        success: true,
        data: insights
      };

    } catch (error) {
      console.error('AI progress insights error:', error);
      return {
        success: false,
        error: {
          code: 'AI_INSIGHTS_ERROR',
          message: 'Failed to generate progress insights'
        }
      };
    }
  }
}

module.exports = new AIService();
