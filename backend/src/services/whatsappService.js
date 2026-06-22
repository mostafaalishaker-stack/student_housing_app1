const ULTRAMSG_API = 'https://api.ultramsg.com';

function isConfigured() {
  return !!(process.env.WHATSAPP_INSTANCE_ID && process.env.WHATSAPP_TOKEN && process.env.ADMIN_WHATSAPP);
}

function bookingTypeLabel(type) {
  const labels = { entire: 'الشقة كاملة', room: 'غرفة', bed: 'سرير', viewing: 'معاينة' };
  return labels[type] || type;
}

function buildMessage(booking, apartment) {
  let lines = [
    '━━━━━━━━━━━━━━━━━━━',
    '📋 *حجز جديد - سكنكم*',
    '━━━━━━━━━━━━━━━━━━━',
    '',
    `🏢 *الشقة*: ${apartment.title}`,
    `📍 *الموقع*: ${apartment.district} - ${apartment.location}`,
    `📌 *نوع الحجز*: ${bookingTypeLabel(booking.type)}`,
  ];
  if (booking.type === 'room') {
    const roomIdx = booking.message ? parseInt(booking.message.replace(/\D/g, '')) || 1 : 1;
    const beds = apartment.roomConfig && apartment.roomConfig[roomIdx - 1] ? apartment.roomConfig[roomIdx - 1] : '?';
    lines.push(`🚪 *رقم الغرفة*: ${roomIdx} (${beds} سرير)`);
  }
  if (booking.type === 'bed' && booking.bedCount) {
    lines.push(`🛏️ *عدد الأسرة*: ${booking.bedCount}`);
  }
  lines.push(...[
    '',
    '━━━━━━━━━━━━━━━━━━━',
    '*بيانات الحاجز*',
    `👤 *الاسم*: ${booking.requesterName}`,
    `📱 *واتساب*: ${booking.whatsapp}`,
    '',
    '━━━━━━━━━━━━━━━━━━━',
    'يرجى التواصل مع الحاجز لتأكيد الحجز',
  ]);
  return lines.join('\n');
}

async function sendWhatsApp(to, message) {
  if (!isConfigured()) {
    console.log('⚠️ WhatsApp not configured. Set WHATSAPP_INSTANCE_ID, WHATSAPP_TOKEN, ADMIN_WHATSAPP in .env');
    return { sent: false, reason: 'not_configured' };
  }
  try {
    const res = await fetch(`${ULTRAMSG_API}/${process.env.WHATSAPP_INSTANCE_ID}/messages/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        token: process.env.WHATSAPP_TOKEN,
        to: process.env.ADMIN_WHATSAPP,
        body: message,
      }),
    });
    const data = await res.json();
    if (data.sent) {
      console.log('✅ WhatsApp notification sent');
      return { sent: true };
    }
    console.error('❌ WhatsApp API error:', data);
    return { sent: false, reason: data.error || 'api_error' };
  } catch (err) {
    console.error('❌ WhatsApp send failed:', err.message);
    return { sent: false, reason: err.message };
  }
}

async function notifyBooking(booking, apartment) {
  const message = buildMessage(booking, apartment);
  return sendWhatsApp(process.env.ADMIN_WHATSAPP, message);
}

module.exports = { notifyBooking, isConfigured };
