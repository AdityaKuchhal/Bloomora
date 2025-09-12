const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const Joi = require('joi');
const { checkChildOwnership } = require('../middleware/auth');

const router = express.Router();
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

// Validation schemas
const createChildSchema = Joi.object({
  name: Joi.string().min(1).max(100).required(),
  date_of_birth: Joi.date().max('now').required(),
  gender: Joi.string().valid('male', 'female', 'other').required(),
  relationship: Joi.string().valid('Mother', 'Father', 'Guardian', 'Grandparent', 'Other').required()
});

const updateChildSchema = Joi.object({
  name: Joi.string().min(1).max(100),
  date_of_birth: Joi.date().max('now'),
  gender: Joi.string().valid('male', 'female', 'other'),
  relationship: Joi.string().valid('Mother', 'Father', 'Guardian', 'Grandparent', 'Other')
});

// Helper function to calculate age in months
const calculateAgeInMonths = (dateOfBirth) => {
  const today = new Date();
  const birthDate = new Date(dateOfBirth);
  const ageInMonths = (today.getFullYear() - birthDate.getFullYear()) * 12 + 
                     (today.getMonth() - birthDate.getMonth());
  return ageInMonths;
};

// Helper function to get age group
const getAgeGroup = (ageInMonths) => {
  if (ageInMonths >= 12 && ageInMonths < 24) return '1-2 years';
  if (ageInMonths >= 24 && ageInMonths < 36) return '2-3 years';
  if (ageInMonths >= 36 && ageInMonths < 48) return '3-4 years';
  if (ageInMonths >= 48 && ageInMonths < 60) return '4-5 years';
  return 'Age group not available';
};

// GET /api/v1/children - Get all children for authenticated user
router.get('/', async (req, res) => {
  try {
    const userId = req.user.id;

    const { data: children, error } = await supabase
      .from('child_profiles')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) {
      throw error;
    }

    // Add calculated fields
    const childrenWithAge = children.map(child => ({
      ...child,
      age_months: calculateAgeInMonths(child.date_of_birth),
      age_group: getAgeGroup(calculateAgeInMonths(child.date_of_birth))
    }));

    res.json({
      success: true,
      data: childrenWithAge
    });
  } catch (error) {
    console.error('Error fetching children:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'FETCH_CHILDREN_ERROR',
        message: 'Failed to fetch children'
      }
    });
  }
});

// GET /api/v1/children/:childId - Get specific child
router.get('/:childId', checkChildOwnership, async (req, res) => {
  try {
    const { childId } = req.params;

    const { data: child, error } = await supabase
      .from('child_profiles')
      .select('*')
      .eq('id', childId)
      .single();

    if (error) {
      throw error;
    }

    const childWithAge = {
      ...child,
      age_months: calculateAgeInMonths(child.date_of_birth),
      age_group: getAgeGroup(calculateAgeInMonths(child.date_of_birth))
    };

    res.json({
      success: true,
      data: childWithAge
    });
  } catch (error) {
    console.error('Error fetching child:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'FETCH_CHILD_ERROR',
        message: 'Failed to fetch child'
      }
    });
  }
});

// POST /api/v1/children - Create new child
router.post('/', async (req, res) => {
  try {
    const { error: validationError, value } = createChildSchema.validate(req.body);
    
    if (validationError) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: validationError.details[0].message
        }
      });
    }

    const userId = req.user.id;
    const childData = {
      ...value,
      user_id: userId
    };

    const { data: child, error } = await supabase
      .from('child_profiles')
      .insert([childData])
      .select()
      .single();

    if (error) {
      throw error;
    }

    const childWithAge = {
      ...child,
      age_months: calculateAgeInMonths(child.date_of_birth),
      age_group: getAgeGroup(calculateAgeInMonths(child.date_of_birth))
    };

    res.status(201).json({
      success: true,
      data: childWithAge
    });
  } catch (error) {
    console.error('Error creating child:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'CREATE_CHILD_ERROR',
        message: 'Failed to create child profile'
      }
    });
  }
});

// PUT /api/v1/children/:childId - Update child
router.put('/:childId', checkChildOwnership, async (req, res) => {
  try {
    const { childId } = req.params;
    const { error: validationError, value } = updateChildSchema.validate(req.body);
    
    if (validationError) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: validationError.details[0].message
        }
      });
    }

    const { data: child, error } = await supabase
      .from('child_profiles')
      .update({
        ...value,
        updated_at: new Date().toISOString()
      })
      .eq('id', childId)
      .select()
      .single();

    if (error) {
      throw error;
    }

    const childWithAge = {
      ...child,
      age_months: calculateAgeInMonths(child.date_of_birth),
      age_group: getAgeGroup(calculateAgeInMonths(child.date_of_birth))
    };

    res.json({
      success: true,
      data: childWithAge
    });
  } catch (error) {
    console.error('Error updating child:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'UPDATE_CHILD_ERROR',
        message: 'Failed to update child profile'
      }
    });
  }
});

// DELETE /api/v1/children/:childId - Delete child
router.delete('/:childId', checkChildOwnership, async (req, res) => {
  try {
    const { childId } = req.params;

    const { error } = await supabase
      .from('child_profiles')
      .delete()
      .eq('id', childId);

    if (error) {
      throw error;
    }

    res.json({
      success: true,
      message: 'Child profile deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting child:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'DELETE_CHILD_ERROR',
        message: 'Failed to delete child profile'
      }
    });
  }
});

module.exports = router;
