const { Router } = require('express');
const { auth, adminOnly } = require('../middleware/auth');
const { create, getMyBookings, getAll, updateStatus } = require('../controllers/bookingController');

const router = Router();

router.post('/', auth, create);
router.get('/my', auth, getMyBookings);
router.get('/', auth, adminOnly, getAll);
router.put('/:id/status', auth, adminOnly, updateStatus);

module.exports = router;
