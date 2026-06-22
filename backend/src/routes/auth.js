const { Router } = require('express');
const { register, login, googleLogin, getMe, updateProfile } = require('../controllers/authController');
const { auth } = require('../middleware/auth');

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.post('/google', googleLogin);
router.get('/me', auth, getMe);
router.put('/profile', auth, updateProfile);

module.exports = router;
