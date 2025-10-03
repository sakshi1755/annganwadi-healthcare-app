const express = require('express');
const router = express.Router();
const Anganwadi = require('../models/Anganwadi');

router.get('/', async (req, res) => {
    try {
        const anganwadis = await Anganwadi.find();
        res.json({ success: true, anganwadis, count: anganwadis.length });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

module.exports = router;