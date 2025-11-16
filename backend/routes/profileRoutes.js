const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');

router.post('/', profileController.createProfile);
router.get('/', profileController.getAllProfiles);
router.get('/:profileId', profileController.getProfileById);
router.put('/:profileId', profileController.updateProfile);
router.delete('/:profileId', profileController.deleteProfile);
router.post('/:profileId/photos', profileController.addPhoto);
router.post('/:profileId/actualHeight', profileController.updateActualHeight);
router.post('/:profileId/actualWeight', profileController.updateActualWeight);
router.get('/model-accuracy', profileController.getModelAccuracy);

module.exports = router;