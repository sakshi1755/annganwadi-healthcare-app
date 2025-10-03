const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    userId: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    role: { type: String, enum: ['admin', 'worker'], required: true },
    assignedAnganwadiId: { type: String, default: null },
    lastLogin: { type: Date, default: Date.now },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('User', UserSchema);