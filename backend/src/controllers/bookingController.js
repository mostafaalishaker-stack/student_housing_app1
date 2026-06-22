const Booking = require('../models/Booking');
const Apartment = require('../models/Apartment');
const whatsappService = require('../services/whatsappService');

exports.create = async (req, res) => {
  try {
    const { apartmentId, type, bedCount, viewingDate, viewingTime, startDate, endDate, message, roomId, roomIdx = 0, requesterName, whatsapp } = req.body;
    const apartment = await Apartment.findByPk(apartmentId);
    if (!apartment) {
      return res.status(404).json({ message: 'Apartment not found' });
    }
    if (!apartment.available && type !== 'viewing') {
      return res.status(400).json({ message: 'Apartment is not available' });
    }
    if (type === 'bed' && (!bedCount || bedCount < 1 || bedCount > 6)) {
      return res.status(400).json({ message: 'عدد الأسرّة يجب أن يكون بين 1 و 6' });
    }
    if (type === 'bed' && bedCount > apartment.availableBeds) {
      return res.status(400).json({ message: `العدد المطلوب أكبر من الأسرّة المتاحة (${apartment.availableBeds})` });
    }
    if (type === 'entire' && !apartment.available) {
      return res.status(400).json({ message: 'الشقة غير متاحة للحجز كامل' });
    }
    if (!requesterName || !requesterName.trim()) {
      return res.status(400).json({ message: 'الرجاء إدخال الاسم بالعربية' });
    }
    if (!whatsapp || !whatsapp.trim()) {
      return res.status(400).json({ message: 'الرجاء إدخال رقم واتساب للتواصل' });
    }
    const booking = await Booking.create({
      userId: req.user.id,
      apartmentId,
      type: type || 'entire',
      bedCount: type === 'bed' ? bedCount : null,
      viewingDate: type === 'viewing' ? viewingDate : null,
      viewingTime: type === 'viewing' ? viewingTime : null,
      roomId: type === 'room' ? (roomId || null) : null,
      startDate: type !== 'viewing' ? startDate : null,
      endDate: type !== 'viewing' ? endDate : null,
      message: message || '',
      requesterName: requesterName.trim(),
      whatsapp: whatsapp.trim(),
    });
    if (type === 'entire') {
      await apartment.update({ available: false, availableRooms: 0, availableBeds: 0 });
    } else if (type === 'room') {
      const bedsInRoom = (apartment.roomConfig && apartment.roomConfig[roomIdx]) || 1;
      await apartment.update({
        availableRooms: Math.max(0, apartment.availableRooms - 1),
        availableBeds: Math.max(0, apartment.availableBeds - bedsInRoom)
      });
    } else if (type === 'bed') {
      await apartment.update({ availableBeds: Math.max(0, apartment.availableBeds - bedCount) });
    }
    whatsappService.notifyBooking(booking, apartment).catch(() => {});
    res.status(201).json({ booking });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getMyBookings = async (req, res) => {
  try {
    const bookings = await Booking.findAll({
      where: { userId: req.user.id },
      include: [Apartment],
      order: [['createdAt', 'DESC']],
    });
    res.json({ bookings });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAll = async (req, res) => {
  try {
    const bookings = await Booking.findAll({
      include: [Apartment],
      order: [['createdAt', 'DESC']],
    });
    res.json({ bookings });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const booking = await Booking.findByPk(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }
    await booking.update({ status });
    res.json({ booking });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
