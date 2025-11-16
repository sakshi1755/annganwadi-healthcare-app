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
    updatedAt: { type: Date, default: Date.now },
    // Add these fields after the existing fields
predictedHeight: { type: Number, default: null },
lastHeightUpdate: { type: Date, default: null },
predictedWeight: { type: Number, default: null },
bmi: { type: Number, default: null },
actualHeight: { type: Number, default: null },
actualWeight: { type: Number, default: null },
lastWeightUpdate: { type: Date, default: null },
lastActualHeightUpdate: { type: Date, default: null },
lastActualWeightUpdate: { type: Date, default: null }

});

module.exports = mongoose.model('Profile', ProfileSchema);