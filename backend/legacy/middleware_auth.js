const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

// Middleware to authenticate JWT tokens
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'MISSING_TOKEN',
          message: 'Access token is required'
        }
      });
    }

    // Verify token with Supabase
    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'INVALID_TOKEN',
          message: 'Invalid or expired token'
        }
      });
    }

    // Add user info to request
    req.user = {
      id: user.id,
      email: user.email,
      role: user.role || 'parent'
    };

    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'AUTH_ERROR',
        message: 'Authentication error'
      }
    });
  }
};

// Middleware to check if user owns the child
const checkChildOwnership = async (req, res, next) => {
  try {
    const { childId } = req.params;
    const userId = req.user.id;

    const { data: child, error } = await supabase
      .from('child_profiles')
      .select('id, user_id')
      .eq('id', childId)
      .eq('user_id', userId)
      .single();

    if (error || !child) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: 'You do not have access to this child profile'
        }
      });
    }

    req.child = child;
    next();
  } catch (error) {
    console.error('Child ownership check error:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'OWNERSHIP_CHECK_ERROR',
        message: 'Error verifying child ownership'
      }
    });
  }
};

module.exports = {
  authenticateToken,
  checkChildOwnership
};
