const express = require('express');
const router = express.Router();
const adminDashboardController = require('../controllers/adminDashboardController');

// Get network overview (total centers and children)
router.get('/overview', adminDashboardController.getNetworkOverview);

// Get all anganwadi centers with statistics
router.get('/centers', adminDashboardController.getAnganwadiCenters);

// Get detailed report for a specific center
router.get('/centers/:anganwadiId/report', adminDashboardController.getCenterReport);

module.exports = router;