const User = require('../models/User');

exports.login = async (req, res) => {
    try {
        const { idToken, email, name, selectedRole } = req.body;

        // Test mode check
        let userId, userName, userEmail;

        if (!idToken) {
            console.log('🧪 TEST MODE: Simulating login');
            
            if (email === 'priya.sharma@test.com') {
                userId = 'test_user_1';
                userName = 'Priya Sharma';
                userEmail = 'priya.sharma@test.com';
            } else if (email === 'admin.patel@test.com') {
                userId = 'test_admin_1';
                userName = 'Admin Patel';
                userEmail = 'admin.patel@test.com';
            } else {
                return res.status(400).json({ 
                    success: false, 
                    message: 'Invalid test user' 
                });
            }
        } else {
            userId = email.replace('@', '_').replace('.', '_');
            userName = name;
            userEmail = email;
        }

        const role = selectedRole === 'administrator' ? 'admin' : 'worker';

        let user = await User.findOne({ userId });

        if (!user) {
            user = new User({
                userId,
                name: userName,
                email: userEmail,
                role,
                assignedAnganwadiId: role === 'worker' ? 'AWC001' : null
            });
            await user.save();
            console.log(`✅ New user created: ${userName}`);
        } else {
            user.lastLogin = new Date();
            await user.save();
            console.log(`✅ User logged in: ${userName}`);
        }

        res.status(200).json({
            success: true,
            message: 'Login successful',
            role: user.role,
            userId: user.userId,
            anganwadiId: user.assignedAnganwadiId,
            name: user.name
        });

    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

exports.getUserProfile = async (req, res) => {
    try {
        const user = await User.findOne({ userId: req.params.userId });
        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }
        res.json({ success: true, user });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};