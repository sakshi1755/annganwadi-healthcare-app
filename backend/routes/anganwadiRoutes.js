const express = require('express');
const router = express.Router();
const Anganwadi = require('../models/Anganwadi');
const anganwadiController = require('../controllers/anganwadiController');

router.get('/', async (req, res) => {
    try {
        const anganwadis = await Anganwadi.find();
        res.json({ success: true, anganwadis, count: anganwadis.length });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});


router.get('/search', anganwadiController.searchAnganwadis);
router.get('/details/:code', anganwadiController.getAnganwadiByCode);

module.exports = router;