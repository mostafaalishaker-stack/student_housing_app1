const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Apartment = sequelize.define('Apartment', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  price: {
    type: DataTypes.FLOAT,
    allowNull: false,
  },
  location: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  district: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  bedrooms: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
  },
  bathrooms: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
  },
  area: {
    type: DataTypes.FLOAT,
    allowNull: true,
  },
  images: {
    type: DataTypes.TEXT,
    defaultValue: '[]',
    get() {
      const raw = this.getDataValue('images');
      try { return JSON.parse(raw); } catch { return []; }
    },
    set(val) {
      this.setDataValue('images', JSON.stringify(val));
    }
  },
  amenities: {
    type: DataTypes.TEXT,
    defaultValue: '[]',
    get() {
      const raw = this.getDataValue('amenities');
      try { return JSON.parse(raw); } catch { return []; }
    },
    set(val) {
      this.setDataValue('amenities', JSON.stringify(val));
    }
  },
  available: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  gender: {
    type: DataTypes.ENUM('any', 'male', 'female'),
    defaultValue: 'any',
  },
  furnished: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  totalRooms: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
  },
  totalBeds: {
    type: DataTypes.INTEGER,
    defaultValue: 2,
  },
  availableRooms: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
  },
  availableBeds: {
    type: DataTypes.INTEGER,
    defaultValue: 2,
  },
  pricePerRoom: {
    type: DataTypes.FLOAT,
    allowNull: true,
  },
  pricePerBed: {
    type: DataTypes.FLOAT,
    allowNull: true,
  },
  allowRoomBooking: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  allowBedBooking: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  roomConfig: {
    type: DataTypes.TEXT,
    defaultValue: '[]',
    get() {
      const raw = this.getDataValue('roomConfig');
      try { return JSON.parse(raw); } catch { return []; }
    },
    set(val) {
      this.setDataValue('roomConfig', JSON.stringify(val));
    }
  },
});

module.exports = Apartment;
