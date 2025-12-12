// const Profile = require('../models/Profile');

// exports.createProfile = async (req, res) => {
//     try {
//         const { name, dob, gender, guardianName, village, anganwadiId, createdByUserId } = req.body;

//         if (!name || !dob || !gender || !guardianName || !village || !anganwadiId || !createdByUserId) {
//             return res.status(400).json({ success: false, message: 'Missing required fields' });
//         }

//         const profileId = `PROF${Date.now()}`;
//         const dobDate = new Date(dob);
//         const age = new Date().getFullYear() - dobDate.getFullYear();

//         const profile = new Profile({
//             profileId,
//             name,
//             dob: dobDate,
//             age,
//             gender,
//             guardianName,
//             village,
//             anganwadiId,
//             createdByUserId,
//             photos: []
//         });

//         await profile.save();
//         console.log(`✅ Profile created: ${name}`);

//         res.status(201).json({ success: true, profile });
//     } catch (error) {
//         console.error('Profile creation error:', error);
//         res.status(500).json({ success: false, message: error.message });
//     }
// };

// exports.getAllProfiles = async (req, res) => {
//     try {
//         const { anganwadiId, village, healthStatus, startDate, endDate } = req.query;
        
//         let query = {};
        
//         if (anganwadiId) query.anganwadiId = anganwadiId;
//         if (village) query.village = village;
//         if (healthStatus) query.healthStatus = healthStatus;
//         if (startDate || endDate) {
//             query.createdAt = {};
//             if (startDate) query.createdAt.$gte = new Date(startDate);
//             if (endDate) query.createdAt.$lte = new Date(endDate);
//         }

//         const profiles = await Profile.find(query).sort({ createdAt: -1 });
//         res.json({ success: true, profiles, count: profiles.length });
//     } catch (error) {
//         res.status(500).json({ success: false, message: error.message });
//     }
// };

// exports.getProfileById = async (req, res) => {
//     try {
//         const profile = await Profile.findOne({ profileId: req.params.profileId });
//         if (!profile) {
//             return res.status(404).json({ success: false, message: 'Profile not found' });
//         }
//         res.json({ success: true, profile });
//     } catch (error) {
//         res.status(500).json({ success: false, message: error.message });
//     }
// };

// exports.updateProfile = async (req, res) => {
//     try {
//         const { name, dob, gender, guardianName, village, healthStatus } = req.body;
        
//         const updateData = { updatedAt: new Date() };
        
//         if (name) updateData.name = name;
//         if (dob) {
//             updateData.dob = new Date(dob);
//             updateData.age = new Date().getFullYear() - updateData.dob.getFullYear();
//         }
//         if (gender) updateData.gender = gender;
//         if (guardianName) updateData.guardianName = guardianName;
//         if (village) updateData.village = village;
//         if (healthStatus) updateData.healthStatus = healthStatus;

//         const profile = await Profile.findOneAndUpdate(
//             { profileId: req.params.profileId },
//             { $set: updateData },
//             { new: true }
//         );

//         if (!profile) {
//             return res.status(404).json({ success: false, message: 'Profile not found' });
//         }

//         res.json({ success: true, profile });
//     } catch (error) {
//         res.status(500).json({ success: false, message: error.message });
//     }
// };

// exports.deleteProfile = async (req, res) => {
//     try {
//         const profile = await Profile.findOneAndDelete({ profileId: req.params.profileId });
//         if (!profile) {
//             return res.status(404).json({ success: false, message: 'Profile not found' });
//         }
//         res.json({ success: true, message: 'Profile deleted successfully' });
//     } catch (error) {
//         res.status(500).json({ success: false, message: error.message });
//     }
// };

// exports.addPhoto = async (req, res) => {
//     try {
//         const { photoUrl, predictionResult, predictionConfidence } = req.body;

//         if (!photoUrl) {
//             return res.status(400).json({ success: false, message: 'Photo URL is required' });
//         }

//         const photoId = `PH${Date.now()}`;
//         const newPhoto = {
//             photoId,
//             photoUrl,
//             predictionResult: predictionResult || 'pending',
//             predictionConfidence: predictionConfidence || 0,
//             uploadedAt: new Date()
//         };

//         const profile = await Profile.findOneAndUpdate(
//             { profileId: req.params.profileId },
//             { 
//                 $push: { photos: newPhoto },
//                 $set: { updatedAt: new Date() }
//             },
//             { new: true }
//         );

//         if (!profile) {
//             return res.status(404).json({ success: false, message: 'Profile not found' });
//         }

//         res.status(201).json({ success: true, photo: newPhoto, profile });
//     } catch (error) {
//         res.status(500).json({ success: false, message: error.message });
//     }
// };

// exports.updateActualHeight = async(req,res)=>{
//     try{
//         const { actualHeight } = req.body;
//         if(actualHeight==null){
//             return res.status(400).json({ success: false, message: 'Actual height is required' });
//         }
//         const updateData={ actualHeight, lastActualHeightUpdate: new Date(), updatedAt: new Date() };
//         const profile =await Profile.findOneAndUpdate(
//             { profileId: req.params.profileId },
//             { $set: updateData },
//             { new: true }

//         );
//         if (!profile) {
//             return res.status(404).json({ success: false, message: 'Profile not found' });
//         }
//         res.json({ success: true, profile });
//     }catch(error){
//         res.status(500).json({ success: false, message: error.message });
//     }
// }
// exports.getModelAccuracy = async (req, res) => {
//     try {
//         const profiles = await Profile.find({
//             predictedHeight: { $ne: null },
//             actualHeight: { $ne: null },
//             predictedWeight: { $ne: null },
//             actualWeight: { $ne: null }
//         });

//         if (profiles.length === 0) {
//             return res.json({
//                 success: true,
//                 message: 'No data available for accuracy calculation',
//                 totalProfiles: 0
//             });
//         }

//         let totalHeightError = 0;
//         let totalWeightError = 0;
//         let heightAccuracies = [];
//         let weightAccuracies = [];

//         profiles.forEach(profile => {
//             // Height metrics
//             const heightError = Math.abs(profile.predictedHeight - profile.actualHeight);
//             const heightErrorPercent = (heightError / profile.actualHeight) * 100;
//             const heightAccuracy = 100 - heightErrorPercent;
            
//             totalHeightError += heightError;
//             heightAccuracies.push(heightAccuracy);

//             // Weight metrics
//             const weightError = Math.abs(profile.predictedWeight - profile.actualWeight);
//             const weightErrorPercent = (weightError / profile.actualWeight) * 100;
//             const weightAccuracy = 100 - weightErrorPercent;
            
//             totalWeightError += weightError;
//             weightAccuracies.push(weightAccuracy);
//         });

//         // Calculate statistics
//         const avgHeightError = totalHeightError / profiles.length;
//         const avgHeightAccuracy = heightAccuracies.reduce((a, b) => a + b, 0) / heightAccuracies.length;
        
//         const avgWeightError = totalWeightError / profiles.length;
//         const avgWeightAccuracy = weightAccuracies.reduce((a, b) => a + b, 0) / weightAccuracies.length;

//         // MAE (Mean Absolute Error)
//         const heightMAE = avgHeightError;
//         const weightMAE = avgWeightError;

//         // MAPE (Mean Absolute Percentage Error)
//         const heightMAPE = 100 - avgHeightAccuracy;
//         const weightMAPE = 100 - avgWeightAccuracy;

//         res.json({
//             success: true,
//             totalProfiles: profiles.length,
//             height: {
//                 averageAccuracy: avgHeightAccuracy.toFixed(2),
//                 averageError: avgHeightError.toFixed(2),
//                 MAE: heightMAE.toFixed(2),
//                 MAPE: heightMAPE.toFixed(2),
//                 unit: 'cm'
//             },
//             weight: {
//                 averageAccuracy: avgWeightAccuracy.toFixed(2),
//                 averageError: (avgWeightError / 1000).toFixed(2),
//                 MAE: (weightMAE / 1000).toFixed(2),
//                 MAPE: weightMAPE.toFixed(2),
//                 unit: 'kg'
//             }
//         });

//     } catch (error) {
//         res.status(500).json({ success: false, message: error.message });
//     }
// };
// exports.updateActualWeight=async(req,res)=>{
//     try{
//         const { actualWeight } = req.body;
//         if(actualWeight==null){
//             return res.status(400).json({ success: false, message: 'Actual weight is required' });
//         }
//         const updateData={ actualWeight, lastActualWeightUpdate: new Date(), updatedAt: new Date() };
//         const profile =await Profile.findOneAndUpdate(
//             { profileId: req.params.profileId },
//             { $set: updateData },
//             { new: true }

//         )
//         if(!profile){
//             return res.status(404).json({ success: false, message: 'Profile not found' });
//         }
//         res.json({ success: true, profile });
//     }catch(error){
//         res.status(500).json({ success: false, message: error.message });
//     }
// }

const Profile = require('../models/Profile');

exports.createProfile = async (req, res) => {
    try {
        const { name, dob, gender, guardianName, village, anganwadiId, createdByUserId } = req.body;

        if (!name || !dob || !gender || !guardianName || !village || !anganwadiId || !createdByUserId) {
            return res.status(400).json({ 
                success: false, 
                message: 'Missing required fields. Anganwadi ID is required.' 
            });
        }

        const profileId = `PROF${Date.now()}`;
        const dobDate = new Date(dob);
        const age = new Date().getFullYear() - dobDate.getFullYear();

        const profile = new Profile({
            profileId,
            name,
            dob: dobDate,
            age,
            gender,
            guardianName,
            village,
            anganwadiId: String(anganwadiId), // Ensure it's stored as string
            createdByUserId,
            photos: []
        });

        await profile.save();
        console.log(`✅ Profile created: ${name} for Anganwadi: ${anganwadiId}`);

        res.status(201).json({ success: true, profile });
    } catch (error) {
        console.error('Profile creation error:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.getAllProfiles = async (req, res) => {
    try {
        const { anganwadiId, village, healthStatus, startDate, endDate } = req.query;
        
        let query = {};
        
        // ✅ CRITICAL: Filter by Anganwadi ID (which is the AWC Code)
        if (anganwadiId) {
            query.anganwadiId = String(anganwadiId);
            console.log(`🔍 Filtering profiles for Anganwadi: ${anganwadiId}`);
        }
        
        if (village) query.village = village;
        if (healthStatus) query.healthStatus = healthStatus;
        if (startDate || endDate) {
            query.createdAt = {};
            if (startDate) query.createdAt.$gte = new Date(startDate);
            if (endDate) query.createdAt.$lte = new Date(endDate);
        }

        console.log('📋 Query:', JSON.stringify(query));

        const profiles = await Profile.find(query).sort({ createdAt: -1 });
        
        console.log(`✅ Found ${profiles.length} profiles`);
        
        res.json({ success: true, profiles, count: profiles.length });
    } catch (error) {
        console.error('Error fetching profiles:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.getProfileById = async (req, res) => {
    try {
        const profile = await Profile.findOne({ profileId: req.params.profileId });
        if (!profile) {
            return res.status(404).json({ success: false, message: 'Profile not found' });
        }
        res.json({ success: true, profile });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.updateProfile = async (req, res) => {
    try {
        const { name, dob, gender, guardianName, village, healthStatus } = req.body;
        
        const updateData = { updatedAt: new Date() };
        
        if (name) updateData.name = name;
        if (dob) {
            updateData.dob = new Date(dob);
            updateData.age = new Date().getFullYear() - updateData.dob.getFullYear();
        }
        if (gender) updateData.gender = gender;
        if (guardianName) updateData.guardianName = guardianName;
        if (village) updateData.village = village;
        if (healthStatus) updateData.healthStatus = healthStatus;

        const profile = await Profile.findOneAndUpdate(
            { profileId: req.params.profileId },
            { $set: updateData },
            { new: true }
        );

        if (!profile) {
            return res.status(404).json({ success: false, message: 'Profile not found' });
        }

        res.json({ success: true, profile });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.deleteProfile = async (req, res) => {
    try {
        const profile = await Profile.findOneAndDelete({ profileId: req.params.profileId });
        if (!profile) {
            return res.status(404).json({ success: false, message: 'Profile not found' });
        }
        res.json({ success: true, message: 'Profile deleted successfully' });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.addPhoto = async (req, res) => {
    try {
        const { photoUrl, predictionResult, predictionConfidence } = req.body;

        if (!photoUrl) {
            return res.status(400).json({ success: false, message: 'Photo URL is required' });
        }

        const photoId = `PH${Date.now()}`;
        const newPhoto = {
            photoId,
            photoUrl,
            predictionResult: predictionResult || 'pending',
            predictionConfidence: predictionConfidence || 0,
            uploadedAt: new Date()
        };

        const profile = await Profile.findOneAndUpdate(
            { profileId: req.params.profileId },
            { 
                $push: { photos: newPhoto },
                $set: { updatedAt: new Date() }
            },
            { new: true }
        );

        if (!profile) {
            return res.status(404).json({ success: false, message: 'Profile not found' });
        }

        res.status(201).json({ success: true, photo: newPhoto, profile });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.updateActualHeight = async(req, res) => {
    try {
        const { actualHeight } = req.body;
        if (actualHeight == null) {
            return res.status(400).json({ success: false, message: 'Actual height is required' });
        }
        const updateData = { 
            actualHeight, 
            lastActualHeightUpdate: new Date(), 
            updatedAt: new Date() 
        };
        const profile = await Profile.findOneAndUpdate(
            { profileId: req.params.profileId },
            { $set: updateData },
            { new: true }
        );
        if (!profile) {
            return res.status(404).json({ success: false, message: 'Profile not found' });
        }
        res.json({ success: true, profile });
    } catch(error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.updateActualWeight = async(req, res) => {
    try {
        const { actualWeight } = req.body;
        if (actualWeight == null) {
            return res.status(400).json({ success: false, message: 'Actual weight is required' });
        }
        const updateData = { 
            actualWeight, 
            lastActualWeightUpdate: new Date(), 
            updatedAt: new Date() 
        };
        const profile = await Profile.findOneAndUpdate(
            { profileId: req.params.profileId },
            { $set: updateData },
            { new: true }
        );
        if (!profile) {
            return res.status(404).json({ success: false, message: 'Profile not found' });
        }
        res.json({ success: true, profile });
    } catch(error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.getModelAccuracy = async (req, res) => {
    try {
        const { anganwadiId } = req.query;
        
        let query = {
            predictedHeight: { $ne: null },
            actualHeight: { $ne: null },
            predictedWeight: { $ne: null },
            actualWeight: { $ne: null }
        };
        
        // Filter by Anganwadi if provided
        if (anganwadiId) {
            query.anganwadiId = String(anganwadiId);
        }

        const profiles = await Profile.find(query);

        if (profiles.length === 0) {
            return res.json({
                success: true,
                message: 'No data available for accuracy calculation',
                totalProfiles: 0
            });
        }

        let totalHeightError = 0;
        let totalWeightError = 0;
        let heightAccuracies = [];
        let weightAccuracies = [];

        profiles.forEach(profile => {
            const heightError = Math.abs(profile.predictedHeight - profile.actualHeight);
            const heightErrorPercent = (heightError / profile.actualHeight) * 100;
            const heightAccuracy = 100 - heightErrorPercent;
            
            totalHeightError += heightError;
            heightAccuracies.push(heightAccuracy);

            const weightError = Math.abs(profile.predictedWeight - profile.actualWeight);
            const weightErrorPercent = (weightError / profile.actualWeight) * 100;
            const weightAccuracy = 100 - weightErrorPercent;
            
            totalWeightError += weightError;
            weightAccuracies.push(weightAccuracy);
        });

        const avgHeightError = totalHeightError / profiles.length;
        const avgHeightAccuracy = heightAccuracies.reduce((a, b) => a + b, 0) / heightAccuracies.length;
        
        const avgWeightError = totalWeightError / profiles.length;
        const avgWeightAccuracy = weightAccuracies.reduce((a, b) => a + b, 0) / weightAccuracies.length;

        const heightMAE = avgHeightError;
        const weightMAE = avgWeightError;
        const heightMAPE = 100 - avgHeightAccuracy;
        const weightMAPE = 100 - avgWeightAccuracy;

        res.json({
            success: true,
            totalProfiles: profiles.length,
            anganwadiId: anganwadiId || 'all',
            height: {
                averageAccuracy: avgHeightAccuracy.toFixed(2),
                averageError: avgHeightError.toFixed(2),
                MAE: heightMAE.toFixed(2),
                MAPE: heightMAPE.toFixed(2),
                unit: 'cm'
            },
            weight: {
                averageAccuracy: avgWeightAccuracy.toFixed(2),
                averageError: (avgWeightError / 1000).toFixed(2),
                MAE: (weightMAE / 1000).toFixed(2),
                MAPE: weightMAPE.toFixed(2),
                unit: 'kg'
            }
        });

    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};