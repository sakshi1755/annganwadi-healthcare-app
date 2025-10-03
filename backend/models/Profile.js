const mongoose = require('mongoose');

const ProfileSchema = new mongoose.Schema({
    profileId: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    dob: { type: Date, required: true },
    age: { type: Number },
    gender: { type: String, enum: ['male', 'female', 'other'], required: true },
    guardianName: { type: String, required: true },
    village: { type: String, required: true },
    healthStatus: { 
        type: String, 
        enum: ['healthy', 'malnourished', 'at_risk', 'needs_attention'], 
        default: 'healthy' 
    },
    anganwadiId: { type: String, required: true },
    createdByUserId: { type: String, required: true },
    photos: [{
        photoId: { type: String, required: true },
        photoUrl: { type: String, required: true },
        predictionResult: { type: String },
        predictionConfidence: { type: Number },
        uploadedAt: { type: Date, default: Date.now }
    }],
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Profile', ProfileSchema);