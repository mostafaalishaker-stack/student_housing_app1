const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');
const User = require('../models/User');

const generateToken = (user) => {
  return jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN,
  });
};

exports.register = async (req, res) => {
  try {
    const { name, email, password, phone, university } = req.body;
    const existing = await User.findOne({ where: { email } });
    if (existing) {
      return res.status(400).json({ message: 'Email already registered' });
    }
    const user = await User.create({ name, email, password, phone, university, role: 'student' });
    const token = generateToken(user);
    res.status(201).json({ user, token });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }
    const token = generateToken(user);
    res.json({ user, token });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.googleLogin = async (req, res) => {
  try {
    const { idToken, clientId } = req.body;
    if (!idToken) {
      return res.status(400).json({ message: 'ID token is required' });
    }
    const googleClient = new OAuth2Client(clientId || process.env.GOOGLE_CLIENT_ID);
    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience: clientId || process.env.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    const { email, name, picture, sub } = payload;
    let user = await User.findOne({ where: { email } });
    if (!user) {
      const randomPass = Math.random().toString(36).slice(-12);
      user = await User.create({
        name: name || email.split('@')[0],
        email,
        password: randomPass,
        role: 'student',
      });
    }
    const token = generateToken(user);
    res.json({ user, token, picture });
  } catch (error) {
    res.status(401).json({ message: 'Invalid Google token', error: error.message });
  }
};

exports.getMe = async (req, res) => {
  res.json({ user: req.user });
};

exports.updateProfile = async (req, res) => {
  try {
    const { name, phone, university } = req.body;
    await req.user.update({ name, phone, university });
    res.json({ user: req.user });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
