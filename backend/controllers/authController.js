const mongoose = require('mongoose');
const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const {v4: uuidv4} = require('uuid');
const Anganwadi = require('../models/Anganwadi');

const generateToken = (awcCode, role) => {
    return jwt.sign(
        {awcCode, role},
        process.env.JWT_SECRET,
        {expiresIn: '7d'} // Added expiry
    );
};

exports.login = async(req, res) => {
    try {
        const {username, password, role} = req.body;
        
        console.log('🔐 Login attempt:', {username, role});
        
        if (!username || !password || !role) {
            return res.status(400).json({
                success: false,
                message: 'Username, password and role are required'
            });
        }

        // Try to find anganwadi by username (handle both string and number)
        const isNumeric = /^\d+$/.test(username);
        let searchQuery;
        
        if (isNumeric) {
            // Search as BOTH string AND number (database has numbers)
            searchQuery = {
                $or: [
                    { AWC_Code: username },           // String
                    { AWC_Code: Number(username) },   // Number (THIS is what's in DB)
                    { AWC_Code: parseInt(username) }  // Also try parseInt
                ]
            };
        } else {
            searchQuery = { AWC_Code: username };
        }

        console.log('🔍 Searching with query:', JSON.stringify(searchQuery));
        console.log('🔍 Input username:', username, 'Type:', typeof username);
        console.log('🔍 Converted to Number:', Number(username), 'Type:', typeof Number(username));

        const anganwadi = await Anganwadi.findOne(searchQuery);
        
        console.log('📍 Anganwadi found:', anganwadi ? 'YES' : 'NO');
        
        if (!anganwadi) {
            // DEBUG: Check what AWC codes exist
            const sampleCodes = await Anganwadi.find({}).limit(5).select('AWC_Code');
            console.log('💡 Sample AWC_Codes in DB:', sampleCodes.map(a => ({
                code: a.AWC_Code, 
                type: typeof a.AWC_Code
            })));
            
            return res.status(404).json({
                success: false,
                message: `Anganwadi code '${username}' not found. Please check your AWC Code.`
            });
        }

        console.log('✅ Found Anganwadi:', {
            code: anganwadi.AWC_Code,
            name: anganwadi.AWC_Name
        });

        // Verify password
        if (!process.env.SHARED_WORKER_PASSWORD_HASH) {
            console.error('❌ SHARED_WORKER_PASSWORD_HASH not set in .env');
            return res.status(500).json({
                success: false,
                message: 'Server configuration error'
            });
        }

        const isMatch = await bcrypt.compare(password, process.env.SHARED_WORKER_PASSWORD_HASH);
        
        console.log('🔑 Password match:', isMatch);
        
        if (!isMatch) {
            return res.status(401).json({
                success: false,
                message: 'Invalid password'
            });
        }

        // Find or create user
        let user = await User.findOne({username: username});
        
        if (!user) {
            console.log('👤 Creating new user');
            user = new User({
                userId: uuidv4(),
                username: username,
                password: process.env.SHARED_WORKER_PASSWORD_HASH,
                role: role,
                assignedAnganwadiCode: String(anganwadi.AWC_Code)
            });
            await user.save();
        } else {
            console.log('👤 Updating existing user');
            user.lastLogin = new Date();
            await user.save();
        }

        const token = generateToken(String(anganwadi.AWC_Code), role);
        
        console.log('✅ Login successful for:', anganwadi.AWC_Name);
        
        res.status(200).json({
            success: true,
            message: 'Login successful',
            token,
            user: {
                userId: user.userId,
                awcCode: String(anganwadi.AWC_Code),
                awcName: anganwadi.AWC_Name,
                sectorName: anganwadi.Sector_name,
                districtName: anganwadi.District_Name,
                Project_Name: anganwadi.Project_Name,
                role: user.role
            }
        });
    } catch(err) {
        console.error('❌ Login error:', err);
        res.status(500).json({
            success: false,
            message: 'Server error: ' + err.message
        });
    }
};

exports.logout = async (req, res) => {
    try {
        res.json({ 
            success: true, 
            message: 'Logged out successfully' 
        });
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            message: 'Server error' 
        });
    }
};

exports.getUserProfile = async (req, res) => {
    try {
        const user = await User.findOne({ userId: req.params.userId });
        if (!user) {
            return res.status(404).json({ 
                success: false, 
                message: 'User not found' 
            });
        }
        res.json({ success: true, user });
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            message: error.message 
        });
    }
};