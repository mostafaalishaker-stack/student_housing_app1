const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Room = sequelize.define('Room', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  apartmentId: {
    type: DataTypes.UUID,
    allowNull: false,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  bedCount: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1,
    validate: { min: 1, max: 6 },
  },
  availableBeds: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1,
    validate: { min: 0 },
  },
  pricePerBed: {
    type: DataTypes.FLOAT,
    allowNull: false,
  },
  pricePerRoom: {
    type: DataTypes.FLOAT,
    allowNull: false,
  },
  furnished: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
});

module.exports = Room;
