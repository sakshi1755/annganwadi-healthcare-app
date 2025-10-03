const Profile = require('../models/Profile');
const Anganwadi = require('../models/Anganwadi');
const User = require('../models/User');

exports.getDashboardStats = async (req, res) => {
    try {
        const totalProfiles = await Profile.countDocuments();
        const totalAnganwadis = await Anganwadi.countDocuments();
        const totalWorkers = await User.countDocuments({ role: 'worker' });
        
        const healthStatusCounts = await Profile.aggregate([
            { $group: { _id: '$healthStatus', count: { $sum: 1 } } }
        ]);

        const recentProfiles = await Profile.find()
            .sort({ createdAt: -1 })
            .limit(5);

        res.json({
            success: true,
            stats: {
                totalProfiles,
                totalAnganwadis,
                totalWorkers,
                healthStatusCounts,
                recentProfiles
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};