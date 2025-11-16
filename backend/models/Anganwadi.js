// const mongoose = require('mongoose');

// const AnganwadiSchema = new mongoose.Schema({
//     anganwadiId: { type: String, required: true, unique: true },
//     name: { type: String, required: true },
//     location: { type: String, required: true },
//     village: { type: String },
//     district: { type: String },
//     workerIds: [{ type: String }],
//     createdAt: { type: Date, default: Date.now }
// });

// module.exports = mongoose.model('Anganwadi', AnganwadiSchema);
const mongoose = require('mongoose');

const AnganwadiSchema = new mongoose.Schema({
    // CSV fields (primary)
    DistrictID: { type: String },
    District_Name: { type: String, index: true },
    Project_Code: { type: String, index: true },
    Project_Name: { type: String, index: true },
    Sector_Code: { type: String, index: true },
    Sector_name: { type: String, index: true },
    AWC_Code: { type: String, required: true, unique: true, index: true },
    AWC_Name: { type: String, required: true },
    AWC_TYPE: { type: String },
    
    // Legacy fields (optional, for backward compatibility)
    anganwadiId: { type: String, sparse: true }, // sparse allows multiple nulls
    name: { type: String },
    location: { type: String },
    village: { type: String },
    district: { type: String },
    workerIds: [{ type: String }],
    
    createdAt: { type: Date, default: Date.now }
});

// Create text index for autocomplete search
AnganwadiSchema.index({ 
    AWC_Name: 'text', 
    Sector_name: 'text',
    District_Name: 'text',
    Project_Name: 'text'
});

// Compound indexes for faster queries
AnganwadiSchema.index({ District_Name: 1, Sector_name: 1 });
AnganwadiSchema.index({ AWC_Code: 1 });

module.exports = mongoose.model('Anganwadi', AnganwadiSchema);