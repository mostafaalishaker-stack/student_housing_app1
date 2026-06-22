const { Op } = require('sequelize');
const Apartment = require('../models/Apartment');
const path = require('path');
const fs = require('fs');

exports.getAll = async (req, res) => {
  try {
    const { district, minPrice, maxPrice, bedrooms, gender, furnished, search, bookingType } = req.query;
    const where = { available: true };
    if (bookingType === 'bed') where.allowBedBooking = true;
    if (bookingType === 'room') where.allowRoomBooking = true;
    if (district) where.district = district;
    if (minPrice) where.price = { ...where.price, [Op.gte]: parseFloat(minPrice) };
    if (maxPrice) where.price = { ...where.price, [Op.lte]: parseFloat(maxPrice) };
    if (bedrooms) where.bedrooms = parseInt(bedrooms);
    if (gender && gender !== 'any') where.gender = gender;
    if (furnished === 'true') where.furnished = true;
    if (search) {
      where[Op.or] = [
        { title: { [Op.like]: `%${search}%` } },
        { description: { [Op.like]: `%${search}%` } },
        { location: { [Op.like]: `%${search}%` } },
      ];
    }
    const apartments = await Apartment.findAll({ where, order: [['createdAt', 'DESC']] });
    res.json({ apartments });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getById = async (req, res) => {
  try {
    const apartment = await Apartment.findByPk(req.params.id);
    if (!apartment) {
      return res.status(404).json({ message: 'Apartment not found' });
    }
    res.json({ apartment });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.create = async (req, res) => {
  try {
    const data = req.body;
    if (data.amenities && typeof data.amenities === 'string') {
      data.amenities = JSON.parse(data.amenities);
    }
    const apartment = await Apartment.create(data);
    res.status(201).json({ apartment });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.update = async (req, res) => {
  try {
    const apartment = await Apartment.findByPk(req.params.id);
    if (!apartment) {
      return res.status(404).json({ message: 'Apartment not found' });
    }
    const data = req.body;
    if (data.amenities && typeof data.amenities === 'string') {
      data.amenities = JSON.parse(data.amenities);
    }
    await apartment.update(data);
    res.json({ apartment });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.delete = async (req, res) => {
  try {
    const apartment = await Apartment.findByPk(req.params.id);
    if (!apartment) {
      return res.status(404).json({ message: 'Apartment not found' });
    }
    await apartment.destroy();
    res.json({ message: 'Apartment deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.uploadImages = async (req, res) => {
  try {
    const apartment = await Apartment.findByPk(req.params.id);
    if (!apartment) {
      return res.status(404).json({ message: 'Apartment not found' });
    }
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: 'No files uploaded' });
    }
    const urls = req.files.map(f => `/uploads/${f.filename}`);
    const images = [...apartment.images, ...urls];
    await apartment.update({ images });
    res.json({ apartment });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getDistricts = async (req, res) => {
  try {
    const districts = await Apartment.findAll({
      attributes: ['district'],
      group: ['district'],
    });
    res.json({ districts: districts.map(d => d.district).filter(Boolean) });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
