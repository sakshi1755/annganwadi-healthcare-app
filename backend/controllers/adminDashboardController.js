const Profile = require('../models/Profile');
const Anganwadi = require('../models/Anganwadi');
const User = require('../models/User');

// Get network overview stats
exports.getNetworkOverview = async (req, res) => {
    try {
        // Count total unique anganwadis from profiles
        const totalCenters = await Profile.distinct('anganwadiId').then(ids => ids.length);
        
        // Count total children
        const totalChildren = await Profile.countDocuments();

        res.json({
            success: true,
            data: {
                totalCenters,
                totalChildren
            }
        });
    } catch (error) {
        console.error('Network overview error:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Get all anganwadi centers with stats
exports.getAnganwadiCenters = async (req, res) => {
    try {
        // Get all profiles grouped by anganwadiId
        const centerStats = await Profile.aggregate([
            {
                $group: {
                    _id: '$anganwadiId',
                    childrenCount: { $sum: 1 },
                    recentUpload: { $max: '$updatedAt' }
                }
            },
            {
                $sort: { childrenCount: -1 }
            }
        ]);

        // Get anganwadi details
        const centersWithDetails = await Promise.all(
            centerStats.map(async (stat) => {
                const anganwadi = await Anganwadi.findOne({ 
                    AWC_Code: stat._id 
                }).lean();

                if (!anganwadi) {
                    return {
                        anganwadiId: stat._id,
                        name: `Center ${stat._id}`,
                        district: 'Unknown',
                        sector: 'Unknown',
                        childrenCount: stat.childrenCount,
                        isActive: true,
                        recentUpload: stat.recentUpload
                    };
                }

                // Check if active (has uploads in last 30 days)
                const thirtyDaysAgo = new Date();
                thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
                const isActive = stat.recentUpload >= thirtyDaysAgo;

                return {
                    anganwadiId: String(anganwadi.AWC_Code),
                    name: String(anganwadi.AWC_Name || 'Unknown Center'),
                    district: String(anganwadi.District_Name || ''),
                    sector: String(anganwadi.Sector_name || ''),
                    childrenCount: stat.childrenCount,
                    isActive: isActive,
                    recentUpload: stat.recentUpload
                };
            })
        );

        res.json({
            success: true,
            centers: centersWithDetails
        });
    } catch (error) {
        console.error('Centers fetch error:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Get detailed report for a specific center
exports.getCenterReport = async (req, res) => {
    try {
        const { anganwadiId } = req.params;

        // Get all profiles for this center
        const profiles = await Profile.find({ anganwadiId }).lean();

        if (profiles.length === 0) {
            return res.json({
                success: true,
                report: {
                    anganwadiId,
                    totalChildren: 0,
                    recentUploads: 0,
                    avgHeight: 0,
                    avgWeight: 0,
                    healthyGrowthRate: 0,
                    underweightCount: 0,
                    followUpRequired: 0,
                    lastUpdated: null
                }
            });
        }

        // Calculate statistics
        const totalChildren = profiles.length;
        
        // Recent uploads (last 7 days)
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
        const recentUploads = profiles.filter(p => 
            p.photos && p.photos.some(photo => photo.uploadedAt >= sevenDaysAgo)
        ).length;

        // Calculate average height and weight
        const profilesWithHeight = profiles.filter(p => p.predictedHeight || p.actualHeight);
        const avgHeight = profilesWithHeight.length > 0
            ? profilesWithHeight.reduce((sum, p) => sum + (p.actualHeight || p.predictedHeight || 0), 0) / profilesWithHeight.length
            : 0;

        const profilesWithWeight = profiles.filter(p => p.predictedWeight || p.actualWeight);
        const avgWeight = profilesWithWeight.length > 0
            ? profilesWithWeight.reduce((sum, p) => sum + (p.actualWeight || p.predictedWeight || 0), 0) / profilesWithWeight.length
            : 0;

        // Health status counts
        const healthyCount = profiles.filter(p => p.healthStatus === 'healthy').length;
        const healthyGrowthRate = totalChildren > 0 ? (healthyCount / totalChildren) * 100 : 0;

        const underweightCount = profiles.filter(p => 
            p.healthStatus === 'malnourished' || p.healthStatus === 'underweight'
        ).length;

        const followUpRequired = profiles.filter(p => 
            p.healthStatus === 'at_risk' || p.healthStatus === 'needs_attention'
        ).length;

        // Get last updated time
        const lastUpdated = profiles.reduce((latest, p) => {
            const pUpdate = new Date(p.updatedAt);
            return pUpdate > latest ? pUpdate : latest;
        }, new Date(0));

        res.json({
            success: true,
            report: {
                anganwadiId,
                totalChildren,
                recentUploads,
                avgHeight: avgHeight.toFixed(1),
                avgWeight: (avgWeight / 1000).toFixed(1), // Convert grams to kg
                healthyGrowthRate: healthyGrowthRate.toFixed(0),
                underweightCount,
                followUpRequired,
                lastUpdated
            }
        });
    } catch (error) {
        console.error('Center report error:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};