const sequelize = require('../config/database');
const User = require('./User');
const Apartment = require('./Apartment');
const Room = require('./Room');
const Booking = require('./Booking');

User.hasMany(Booking, { foreignKey: 'userId' });
Booking.belongsTo(User, { foreignKey: 'userId' });

Apartment.hasMany(Booking, { foreignKey: 'apartmentId' });
Booking.belongsTo(Apartment, { foreignKey: 'apartmentId' });

Apartment.hasMany(Room, { foreignKey: 'apartmentId' });
Room.belongsTo(Apartment, { foreignKey: 'apartmentId' });

Room.hasMany(Booking, { foreignKey: 'roomId' });
Booking.belongsTo(Room, { foreignKey: 'roomId' });

module.exports = { sequelize, User, Apartment, Room, Booking };
