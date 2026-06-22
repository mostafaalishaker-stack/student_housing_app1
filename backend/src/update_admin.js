require('dotenv').config();
const { sequelize, User } = require('./models');

(async () => {
  await sequelize.sync();
  await User.destroy({ where: { email: 'admin@sakan.com' } });
  const existing = await User.findOne({ where: { email: 'admin@admun.com' } });
  if (existing) {
    await existing.update({ password: 'mostafaali12', role: 'admin' });
    console.log('Updated existing admin@admun.com');
  } else {
    await User.create({
      name: 'مشرف النظام',
      email: 'admin@admun.com',
      password: 'mostafaali12',
      phone: '01000000000',
      role: 'admin',
      university: 'جامعة أسيوط',
    });
    console.log('Created new admin@admun.com');
  }
  const check = await User.findOne({ where: { email: 'admin@admun.com' } });
  console.log('OK:', check.email, 'role:', check.role);
  const old = await User.findOne({ where: { email: 'admin@sakan.com' } });
  console.log('Old admin deleted?', !old);
  await sequelize.close();
  process.exit(0);
})().catch(e => { console.error(e); process.exit(1); });
