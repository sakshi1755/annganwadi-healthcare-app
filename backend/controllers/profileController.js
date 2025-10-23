const Profile = require('../models/Profile');

exports.createProfile = async (req, res) => {
    try {
        const { name, dob, gender, guardianName, village, anganwadiId, createdByUserId } = req.body;

        if (!name || !dob || !gender || !guardianName || !village || !anganwadiId || !createdByUserId) {
            return res.status(400).json({ success: false, message: 'Missing required fields' });
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
            anganwadiId,
            createdByUserId,
            photos: []
        });

        await profile.save();
        console.log(`✅ Profile created: ${name}`);

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
        
        if (anganwadiId) query.anganwadiId = anganwadiId;
        if (village) query.village = village;
        if (healthStatus) query.healthStatus = healthStatus;
        if (startDate || endDate) {
            query.createdAt = {};
            if (startDate) query.createdAt.$gte = new Date(startDate);
            if (endDate) query.createdAt.$lte = new Date(endDate);
        }

        const profiles = await Profile.find(query).sort({ createdAt: -1 });
        res.json({ success: true, profiles, count: profiles.length });
    } catch (error) {
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