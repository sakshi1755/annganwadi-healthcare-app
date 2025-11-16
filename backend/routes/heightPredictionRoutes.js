const express = require('express');
const router = express.Router();
const multer = require('multer');
const { predictHeight, predictWeight } = require('../services/mlService');
const Profile = require('../models/Profile');

// Configure multer - no fileFilter, we'll validate manually
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB per file
});

router.post('/predict', upload.array('images', 4), async (req, res) => {
    try {
        const { profileId, ageInMonths, gender } = req.body;
        
        console.log('Received prediction request:', {
            profileId,
            ageInMonths,
            filesCount: req.files?.length
        });
        
        // Validate inputs
       // Validate inputs
        if (!profileId || !ageInMonths || !gender) {
            return res.status(400).json({
                success: false,
                message: 'profileId, ageInMonths, and gender are required'
            });
        }

        if (!['m', 'f', 'male', 'female'].includes(gender.toLowerCase())) {
            return res.status(400).json({
                success: false,
                message: 'gender must be "m", "f", "male", or "female"'
            });
        }

        if (!req.files || req.files.length !== 4) {
            return res.status(400).json({
                success: false,
                message: `Exactly 4 images are required. Received: ${req.files?.length || 0}`
            });
        }

        // Validate that files are actually images
        for (let i = 0; i < req.files.length; i++) {
            const file = req.files[i];
            const buffer = file.buffer;
            
            // Check for common image file signatures (magic numbers)
            const isJPEG = buffer[0] === 0xFF && buffer[1] === 0xD8 && buffer[2] === 0xFF;
            const isPNG = buffer[0] === 0x89 && buffer[1] === 0x50 && buffer[2] === 0x4E && buffer[3] === 0x47;
            const isGIF = buffer[0] === 0x47 && buffer[1] === 0x49 && buffer[2] === 0x46;
            
            if (!isJPEG && !isPNG && !isGIF) {
                console.log(`File ${i} validation failed:`, {
                    originalname: file.originalname,
                    mimetype: file.mimetype,
                    firstBytes: [buffer[0], buffer[1], buffer[2], buffer[3]]
                });
                return res.status(400).json({
                    success: false,
                    message: `Image ${i + 1} is not a valid image file`
                });
            }
        }

        console.log('All images validated successfully');

        // Get image buffers
        const imageBuffers = req.files.map(file => file.buffer);

        // Call ML API
        console.log('Calling ML API...');
        // Normalize gender to 'm' or 'f'
        const normalizedGender = gender.toLowerCase().startsWith('m') ? 'm' : 'f';
        const prediction = await predictHeight(imageBuffers, parseFloat(ageInMonths), normalizedGender);

        if (!prediction.success) {
            console.error('ML API error:', prediction.error);
            return res.status(500).json({
                success: false,
                message: prediction.error
            });
        }

        console.log('Prediction successful:', prediction.predictedHeight);

        // Update profile with predicted height
        const profile = await Profile.findOneAndUpdate(
            { profileId },
            {
                $set: {
                    predictedHeight: prediction.predictedHeight,
                    lastHeightUpdate: new Date(),
                    updatedAt: new Date()
                }
            },
            { new: true }
        );

        if (!profile) {
            return res.status(404).json({
                success: false,
                message: 'Profile not found'
            });
        }

        console.log('Profile updated successfully');

        res.json({
            success: true,
            predictedHeight: prediction.predictedHeight,
            profile
        });

    } catch (error) {
        console.error('Height prediction error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Internal server error'
        });
    }
});
router.post('/predict-weight', async (req, res) => {
    try {
        const { profileId, heightCm, ageInMonths, gender } = req.body;
        
        // Validate inputs
        if (!profileId || !heightCm || !ageInMonths || !gender) {
            return res.status(400).json({
                success: false,
                message: 'profileId, heightCm, ageInMonths, and gender are required'
            });
        }

        if (!['m', 'f', 'male', 'female'].includes(gender.toLowerCase())) {
            return res.status(400).json({
                success: false,
                message: 'gender must be "m", "f", "male", or "female"'
            });
        }

        console.log('Calling weight ML API...');
        
        const normalizedGender = gender.toLowerCase().startsWith('m') ? 'm' : 'f';
        const prediction = await predictWeight(
            parseFloat(heightCm), 
            parseFloat(ageInMonths),
            normalizedGender
        );

        if (!prediction.success) {
            console.error('Weight ML API error:', prediction.error);
            return res.status(500).json({
                success: false,
                message: prediction.error
            });
        }

        console.log('Weight prediction successful:', prediction.predictedWeight);

        // Calculate BMI: weight(kg) / height(m)²
        const weightKg = prediction.predictedWeight / 1000; // grams to kg
        const heightM = heightCm / 100; // cm to meters
        const bmi = weightKg / (heightM * heightM);

        // Update profile
        const profile = await Profile.findOneAndUpdate(
            { profileId },
            {
                $set: {
                    predictedWeight: prediction.predictedWeight,
                    bmi: bmi,
                    lastWeightUpdate: new Date(),
                    updatedAt: new Date()
                }
            },
            { new: true }
        );

        if (!profile) {
            return res.status(404).json({
                success: false,
                message: 'Profile not found'
            });
        }

        console.log('Profile updated with weight and BMI');

        res.json({
            success: true,
            predictedWeight: prediction.predictedWeight,
            bmi: bmi,
            profile
        });

    } catch (error) {
        console.error('Weight prediction error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Internal server error'
        });
    }
});
module.exports = router;