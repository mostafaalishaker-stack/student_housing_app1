require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const { sequelize } = require('./models');

const authRoutes = require('./routes/auth');
const apartmentRoutes = require('./routes/apartments');
const bookingRoutes = require('./routes/bookings');

const app = express();
const PORT = process.env.PORT || 3000;

const uploadsDir = process.env.VERCEL
  ? '/tmp/uploads'
  : path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

app.use(cors({
  origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : '*',
  credentials: true,
}));
app.use(express.json());
app.use('/uploads', express.static(uploadsDir));

const dashboardDir = path.join(__dirname, '..', '..');
app.use(express.static(dashboardDir));

app.use('/api/auth', authRoutes);
app.use('/api/apartments', apartmentRoutes);
app.use('/api/bookings', bookingRoutes);

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/', (req, res) => {
  res.redirect('/dashboard.html');
});

// Sync DB on demand (lazy, won't block startup)
let syncPromise = null;
async function syncDb() {
  if (!syncPromise) {
    syncPromise = (async () => {
      try {
        await sequelize.sync();
        console.log('✅ Database synced');
      } catch (error) {
        console.error('❌ Database sync failed:', error.message);
        syncPromise = null; // allow retry
      }
    })();
  }
  return syncPromise;
}

// Auto-start only if not imported by Vercel
if (require.main === module) {
  syncDb().then(() => {
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Server running on port ${PORT}`);
      console.log(`📋 Environment: ${process.env.NODE_ENV || 'development'}`);
    });
  });
}

module.exports = { app, syncDb };
