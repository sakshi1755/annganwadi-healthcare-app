const mongoose = require('mongoose');

const AnganwadiSchema = new mongoose.Schema({
    anganwadiId: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    location: { type: String, required: true },
    village: { type: String },
    district: { type: String },
    workerIds: [{ type: String }],
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Anganwadi', AnganwadiSchema);