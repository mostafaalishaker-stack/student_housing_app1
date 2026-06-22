require('dotenv').config();
const { sequelize, User, Apartment } = require('./models');

const districts = [
  'الحي الأول', 'الحي الثاني', 'الحي الثالث', 'الحي الرابع',
  'الحي الخامس', 'الحي السادس', 'الحي السابع', 'الحي الثامن',
  'الجامعة', 'المدينة الجامعية'
];

const amenitiesList = [
  'WiFi', 'تكييف', 'مطبخ', 'ثلاجة', 'غسالة', 'تلفزيون',
  'مفروش', 'سخان', 'مروحة', 'شرفة', 'مصعد', 'موقف سيارات',
  'أمن', 'كاميرات مراقبة', 'صيانة', 'تنظيف'
];

const sampleTitles = [
  'شقة مفروشة للطلاب قريبة من الجامعة',
  'غرفة في شقة مشتركة - أسيوط الجديدة',
  'شقة خاصة للطالب - هادئة ومريحة',
  'استوديو مفروش بالكامل',
  'شقة ٣ غرف نوم قريبة من الخدمات',
  'غرفة مفردة في شقة فاخرة',
  'شقة للطلاب - الحي الثالث',
  'شقة عائلية صغيرة - مفروشة',
];

async function seed() {
  await sequelize.sync({ force: true });

  const admin = await User.create({
    name: 'مشرف النظام',
    email: 'admin@admun.com',
    password: 'mostafaali12',
    phone: '01000000000',
    role: 'admin',
    university: 'جامعة أسيوط',
  });

  const student = await User.create({
    name: 'أحمد الطالب',
    email: 'ahmed@test.com',
    password: 'student123',
    phone: '01111111111',
    role: 'student',
    university: 'جامعة أسيوط',
  });

  const apartments = [];
  for (let i = 0; i < 20; i++) {
    const genderOptions = ['any', 'male', 'female'];
    const numRooms = 1 + Math.floor(Math.random() * 4);
    const roomConfig = Array.from({length: numRooms}, () => 1 + Math.floor(Math.random() * 3));
    const totalRooms = roomConfig.length;
    const totalBeds = roomConfig.reduce((a,b) => a+b, 0);
    const basePrice = 500 + Math.floor(Math.random() * 3000);
    const roomPrice = Math.round(basePrice / totalRooms);
    const bedPrice = Math.round(roomPrice / 2);
    apartments.push({
      title: sampleTitles[i % sampleTitles.length],
      description: `شقة ممتازة للطلاب في ${districts[i % districts.length]} بمساحة مناسبة وإطلالة جميلة. قريبة من الجامعة والخدمات. السعر يشمل الصيانة والخدمات.\n\nخيارات الحجز:\n• الشقة كاملة: ${basePrice} ج.م/شهر\n• غرفة: ${roomPrice} ج.م/شهر\n• سرير: ${bedPrice} ج.م/شهر`,
      price: basePrice,
      location: districts[i % districts.length],
      district: districts[i % districts.length],
      bedrooms: totalRooms,
      bathrooms: 1 + Math.floor(Math.random() * 2),
      area: 50 + Math.floor(Math.random() * 150),
      amenities: amenitiesList.sort(() => Math.random() - 0.5).slice(0, 3 + Math.floor(Math.random() * 5)),
      available: true,
      gender: genderOptions[Math.floor(Math.random() * genderOptions.length)],
      furnished: Math.random() > 0.3,
      totalRooms,
      totalBeds,
      availableRooms: totalRooms,
      availableBeds: totalBeds,
      pricePerRoom: roomPrice,
      pricePerBed: bedPrice,
      allowRoomBooking: true,
      allowBedBooking: true,
      roomConfig,
      images: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=600',
      ],
    });
  }

  await Apartment.bulkCreate(apartments);

  console.log('✅ Database seeded!');
  console.log(`   Admin: admin@admun.com / mostafaali12`);
  console.log(`   Student: ahmed@test.com / student123`);
  console.log(`   Created ${apartments.length} apartments`);

  process.exit(0);
}

seed().catch((err) => {
  console.error(err);
  process.exit(1);
});
