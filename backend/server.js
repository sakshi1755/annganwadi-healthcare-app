// // const express = require('express');
// // const mongoose = require('mongoose');
// // const bodyParser = require('body-parser');

// // // !!! REPLACE THIS WITH YOUR ACTUAL MONGODB CONNECTION STRING !!!
// // const MONGO_URI = 'mongodb://localhost:27017/anganwadi_app_db'; 
// // // !!! FOR ATLAS: use 'mongodb+srv://user:password@cluster.mongodb.net/anganwadi_app_db'

// // // --- MongoDB Schema and Model ---

// // const UserSchema = new mongoose.Schema({
// //     userId: { type: String, required: true, unique: true },
// //     name: { type: String, required: true },
// //     email: { type: String, required: true, unique: true },
// //     role: { type: String, enum: ['admin', 'worker'], required: true },
// //     anganwadiId: { type: String, default: null }, // Worker's assigned center ID
// //     lastLogin: { type: Date, default: Date.now }
// // });

// // const User = mongoose.model('User', UserSchema);

// // // --- Express App Setup ---

// // const app = express();
// // app.use(bodyParser.json());

// // // --- Database Connection ---

// // mongoose.connect(MONGO_URI)
// //     .then(() => console.log('MongoDB successfully connected!'))
// //     .catch(err => console.error('MongoDB connection error:', err));


// // // --- API Endpoint: Login and User Creation (Non-Secure) ---

// // app.post('/api/login', async (req, res) => {
// //     try {
// //         const { userId, name, email, role, anganwadiId } = req.body;

// //         // 1. Validate required fields
// //         if (!userId || !name || !email || !role) {
// //             return res.status(400).json({ success: false, message: 'Missing required user data.' });
// //         }

// //         // 2. Determine anganwadiId (if role is worker, use the provided ID, otherwise null)
// //         const effectiveAnganwadiId = (role === 'worker') ? anganwadiId : null;

// //         // 3. Upsert Logic: Find user by userId, and update or create them.
// //         const result = await User.findOneAndUpdate(
// //             { userId: userId }, // Query: find user by ID
// //             { 
// //                 $set: { 
// //                     name, 
// //                     email, 
// //                     role: role.toLowerCase(), // Ensure role is lowercase
// //                     anganwadiId: effectiveAnganwadiId,
// //                     lastLogin: new Date() 
// //                 } 
// //             },
// //             { 
// //                 upsert: true, // Create the document if it doesn't exist
// //                 new: true     // Return the updated/created document
// //             }
// //         );

// //         console.log(`User Logged In/Updated: ${result.name} with role ${result.role}`);

// //         // 4. Send a success response back to the Flutter app
// //         res.status(200).json({ 
// //             success: true, 
// //             message: 'Login successful and user data saved/updated.',
// //             role: result.role,
// //             userId: result.userId,
// //             anganwadiId: result.anganwadiId
// //         });

// //     } catch (error) {
// //         console.error('Login processing error:', error);
// //         res.status(500).json({ success: false, message: 'Server error during login/upsert.' });
// //     }
// // });

// // // --- Server Start ---
// // const PORT = 3000;
// // app.listen(PORT, () => {
// //     console.log(`Express server running on http://localhost:${PORT}`);
// // });

// const express = require('express');
// const mongoose = require('mongoose');
// const bodyParser = require('body-parser');
// const cors = require('cors');

// // !!! REPLACE THIS WITH YOUR ACTUAL MONGODB CONNECTION STRING !!!
// const MONGO_URI = 'mongodb://localhost:27017/anganwadi_app_db'; 
// // !!! FOR ATLAS: use 'mongodb+srv://user:password@cluster.mongodb.net/anganwadi_app_db'

// // --- MongoDB Schemas and Models ---

// // User Schema
// const UserSchema = new mongoose.Schema({
//     userId: { type: String, required: true, unique: true },
//     name: { type: String, required: true },
//     email: { type: String, required: true, unique: true },
//     role: { type: String, enum: ['admin', 'worker'], required: true },
//     assignedAnganwadiId: { type: String, default: null },
//     lastLogin: { type: Date, default: Date.now },
//     createdAt: { type: Date, default: Date.now }
// });

// const User = mongoose.model('User', UserSchema);

// // Anganwadi Center Schema
// const AnganwadiSchema = new mongoose.Schema({
//     anganwadiId: { type: String, required: true, unique: true },
//     name: { type: String, required: true },
//     location: { type: String, required: true },
//     village: { type: String },
//     district: { type: String },
//     workerIds: [{ type: String }],
//     createdAt: { type: Date, default: Date.now }
// });

// const Anganwadi = mongoose.model('Anganwadi', AnganwadiSchema);

// // Profile Schema (Children/Individuals)
// const ProfileSchema = new mongoose.Schema({
//     profileId: { type: String, required: true, unique: true },
//     name: { type: String, required: true },
//     dob: { type: Date, required: true },
//     age: { type: Number },
//     gender: { type: String, enum: ['male', 'female', 'other'], required: true },
//     guardianName: { type: String, required: true },
//     village: { type: String, required: true },
//     healthStatus: { type: String, enum: ['healthy', 'malnourished', 'at_risk', 'needs_attention'], default: 'healthy' },
//     anganwadiId: { type: String, required: true },
//     createdByUserId: { type: String, required: true },
//     photos: [{
//         photoId: { type: String, required: true },
//         photoUrl: { type: String, required: true },
//         predictionResult: { type: String },
//         predictionConfidence: { type: Number },
//         uploadedAt: { type: Date, default: Date.now }
//     }],
//     createdAt: { type: Date, default: Date.now },
//     updatedAt: { type: Date, default: Date.now }
// });

// const Profile = mongoose.model('Profile', ProfileSchema);

// // --- Express App Setup ---

// const app = express();
// app.use(cors());
// app.use(bodyParser.json());

// // --- Database Connection ---

// mongoose.connect(MONGO_URI)
//     .then(() => {
//         console.log('MongoDB successfully connected!');
//         initializeTestData();
//     })
//     .catch(err => console.error('MongoDB connection error:', err));

// // --- Initialize Test Data ---

// async function initializeTestData() {
//     try {
//         // Check if test data already exists
//         const existingUser = await User.findOne({ userId: 'test_user_1' });
//         if (existingUser) {
//             console.log('Test data already exists. Skipping initialization.');
//             return;
//         }

//         // Create test Anganwadi centers
//         const testAnganwadis = [
//             {
//                 anganwadiId: 'AWC001',
//                 name: 'Sunshine Anganwadi Center',
//                 location: 'Mumbai North',
//                 village: 'Andheri',
//                 district: 'Mumbai',
//                 workerIds: ['test_user_1']
//             },
//             {
//                 anganwadiId: 'AWC002',
//                 name: 'Happy Kids Anganwadi',
//                 location: 'Mumbai South',
//                 village: 'Bandra',
//                 district: 'Mumbai',
//                 workerIds: []
//             }
//         ];

//         await Anganwadi.insertMany(testAnganwadis);

//         // Create test users
//         const testUsers = [
//             {
//                 userId: 'test_user_1',
//                 name: 'Priya Sharma',
//                 email: 'priya.sharma@test.com',
//                 role: 'worker',
//                 assignedAnganwadiId: 'AWC001'
//             },
//             {
//                 userId: 'test_admin_1',
//                 name: 'Admin Patel',
//                 email: 'admin.patel@test.com',
//                 role: 'admin',
//                 assignedAnganwadiId: null
//             }
//         ];

//         await User.insertMany(testUsers);

//         // Create test profiles
//         const testProfiles = [
//             {
//                 profileId: 'PROF001',
//                 name: 'Aarav Kumar',
//                 dob: new Date('2020-03-15'),
//                 age: 5,
//                 gender: 'male',
//                 guardianName: 'Rajesh Kumar',
//                 village: 'Andheri',
//                 healthStatus: 'healthy',
//                 anganwadiId: 'AWC001',
//                 createdByUserId: 'test_user_1',
//                 photos: [
//                     {
//                         photoId: 'PH001',
//                         photoUrl: 'https://example.com/photo1.jpg',
//                         predictionResult: 'healthy',
//                         predictionConfidence: 0.92,
//                         uploadedAt: new Date()
//                     }
//                 ]
//             },
//             {
//                 profileId: 'PROF002',
//                 name: 'Ananya Singh',
//                 dob: new Date('2019-08-22'),
//                 age: 6,
//                 gender: 'female',
//                 guardianName: 'Sunita Singh',
//                 village: 'Andheri',
//                 healthStatus: 'at_risk',
//                 anganwadiId: 'AWC001',
//                 createdByUserId: 'test_user_1',
//                 photos: []
//             }
//         ];

//         await Profile.insertMany(testProfiles);

//         console.log('✅ Test data initialized successfully!');
//         console.log('Test Worker: priya.sharma@test.com (userId: test_user_1)');
//         console.log('Test Admin: admin.patel@test.com (userId: test_admin_1)');
//     } catch (error) {
//         console.error('Error initializing test data:', error);
//     }
// }

// // --- API Endpoints ---

// // 1. Login/Register Endpoint (Modified for Test Mode)
// app.post('/api/login', async (req, res) => {
//     try {
//         const { idToken, email, name, selectedRole } = req.body;

//         // TEST MODE: If no idToken, treat as test login
//         let userId, userName, userEmail;

//         if (!idToken) {
//             // Test mode - simulate login
//             console.log('🧪 TEST MODE: Simulating login without Google Auth');
            
//             if (email === 'priya.sharma@test.com') {
//                 userId = 'test_user_1';
//                 userName = 'Priya Sharma';
//                 userEmail = 'priya.sharma@test.com';
//             } else if (email === 'admin.patel@test.com') {
//                 userId = 'test_admin_1';
//                 userName = 'Admin Patel';
//                 userEmail = 'admin.patel@test.com';
//             } else {
//                 return res.status(400).json({ 
//                     success: false, 
//                     message: 'Invalid test user. Use priya.sharma@test.com or admin.patel@test.com' 
//                 });
//             }
//         } else {
//             // Real Google Sign-In mode (for future use)
//             // TODO: Verify idToken with Google
//             userId = email.replace('@', '_').replace('.', '_');
//             userName = name;
//             userEmail = email;
//         }

//         // Determine role
//         const role = selectedRole === 'administrator' ? 'admin' : 'worker';

//         // Find or create user
//         let user = await User.findOne({ userId });

//         if (!user) {
//             // Create new user
//             user = new User({
//                 userId,
//                 name: userName,
//                 email: userEmail,
//                 role,
//                 assignedAnganwadiId: role === 'worker' ? 'AWC001' : null
//             });
//             await user.save();
//             console.log(`✅ New user created: ${userName}`);
//         } else {
//             // Update existing user
//             user.lastLogin = new Date();
//             await user.save();
//             console.log(`✅ User logged in: ${userName}`);
//         }

//         res.status(200).json({
//             success: true,
//             message: 'Login successful',
//             role: user.role,
//             userId: user.userId,
//             anganwadiId: user.assignedAnganwadiId,
//             name: user.name
//         });

//     } catch (error) {
//         console.error('Login error:', error);
//         res.status(500).json({ success: false, message: 'Server error during login' });
//     }
// });

// // 2. Get User Profile
// app.get('/api/user/:userId', async (req, res) => {
//     try {
//         const user = await User.findOne({ userId: req.params.userId });
//         if (!user) {
//             return res.status(404).json({ success: false, message: 'User not found' });
//         }
//         res.json({ success: true, user });
//     } catch (error) {
//         res.status(500).json({ success: false, message: error.message });
//     }
// });

// // 3. Create Profile
// app.post('/api/profiles', async (req, res) => {
//     try {
//         const { name, dob, gender, guardianName, village, anganwadiId, createdByUserId } = req.body;

//         if (!name || !dob || !gender || !guardianName || !village || !anganwadiId || !createdByUserId) {
//             return res.status(400).json({ success: false, message: 'Missing required fields' });
//         }

//         const profileId = `PROF${Date.now()}`;
//         const dobDate = new Date(dob);
//         const age = new Date().getFullYear() - dobDate.getFullYear();

//         const profile = new Profile({
//             profileId,
//             name,
//             dob: dobDate,
//             age,
//             gender,
//             guardianName,
//             village,
//             anganwadiId,
//             createdByUserId,
//             photos: []
//         });

//         await profile.save();
//         console.log(`✅ Profile created: ${name}`);

//         res.status(201).json({ success: true, profile });
//     } catch (error) {
//         console.error('Profile creation error:', error);
//         res.status(500).json({ success: false, message: error.message });
//     }
// });

// // 4. Get All Profiles (with filters)
// app.get('/api/profiles', async (req, res) => {
//     try {
//         const { anganwadiId, village, healthStatus, startDate, endDate } = req.query;
        
//         let query = {};
        
//         if (anganwadiId) query.anganwadiId = anganwadiId;
//         if (village) query.village = village;
//         if (healthStatus) query.healthStatus = healthStatus;
//         if (startDate || endDate) {
//             query.createdAt = {};
//             if (startDate) query.createdAt.$gte = new Date(startDate);
//             if (endDate) query.createdAt.$lte = new Date(endDate);
//         }

//         const profiles = await Profile.find(query).sort({ createdAt: -1 });
//         res.json({ success: true, profiles, count: profiles.length });
//     } catch (error) {
//         res.status(500).json({ success: false, message: error.message });
//     }
// });

// // 5. Get Single Profile
// app.get('/api/profiles/:profileId', async (req, res) => {
//     try {
//         const profile = await Profile.findOne({ profileId: req.params.profileId });
//         if (!profile) {
//             return res.status(404).json({ success: false, message: 'Profile not found' });
//         }
//         res.json({ success: true, profile });
//     } catch (error) {
//         res.status(500).json({ success: false, message: error.message });
//     }
// });

// // 6. Update Profile
// app.put('/api/profiles/:profileId', async (req, res) => {
//     try {
//         const { name, dob, gender, guardianName, village, healthStatus } = req.body;
        
//         const updateData = {
//             updatedAt: new Date()
//         };
        
//         if (name) updateData.name = name;
//         if (dob) {
//             updateData.dob = new Date(dob);
//             updateData.age = new Date().getFullYear() - updateData.dob.getFullYear();
//         }
//         if (gender) updateData.gender = gender;
//         if (guardianName) updateData.guardianName = guardianName;
//         if (village) updateData.village = village;
//         if (healthStatus) updateData.healthStatus = healthStatus;

//         const profile = await Profile.findOneAndUpdate(
//             { profileId: req.params.profileId },
//             { $set: updateData },
//             { new: true }
//         );

//         if (!profile) {
//             return res.status(404).json({ success: false, message: 'Profile not found' });
//         }

//         res.json({ success: true, profile });
//     } catch (error) {
//         res.status(500).json({ success: false, message: error.message });
//     }
// });

// // 7. Add Photo to Profile
// app.post('/api/profiles/:profileId/photos', async (req, res) => {
//     try {
//         const { photoUrl, predictionResult, predictionConfidence } = req.body;

//         if (!photoUrl) {
//             return res.status(400).json({ success: false, message: 'Photo URL is required' });
//         }

//         const photoId = `PH${Date.now()}`;
//         const newPhoto = {
//             photoId,
//             photoUrl,
//             predictionResult: predictionResult || 'pending',
//             predictionConfidence: predictionConfidence || 0,
//             uploadedAt: new Date()
//         };

//         const profile = await Profile.findOneAndUpdate(
//             { profileId: req.params.profileId },
//             { 
//                 $push: { photos: newPhoto },
//                 $set: { updatedAt: new Date() }
//             },
//             { new: true }
//         );

//         if (!profile) {
//             return res.status(404).json({ success: false, message: 'Profile not found' });
//         }

//         res.status(201).json({ success: true, photo: newPhoto, profile });
//     } catch (error) {
//         res.status(500).json({ success: false, message: error.message });
//     }
// });

// // 8. Get All Anganwadis
// app.get('/api/anganwadis', async (req, res) => {
//     try {
//         const anganwadis = await Anganwadi.find();
//         res.json({ success: true, anganwadis, count: anganwadis.length });
//     } catch (error) {
//         res.status(500).json({ success: false, message: error.message });
//     }
// });

// // 9. Get Dashboard Statistics (Admin)
// app.get('/api/dashboard/stats', async (req, res) => {
//     try {
//         const totalProfiles = await Profile.countDocuments();
//         const totalAnganwadis = await Anganwadi.countDocuments();
//         const totalWorkers = await User.countDocuments({ role: 'worker' });
        
//         const healthStatusCounts = await Profile.aggregate([
//             { $group: { _id: '$healthStatus', count: { $sum: 1 } } }
//         ]);

//         const recentProfiles = await Profile.find()
//             .sort({ createdAt: -1 })
//             .limit(5);

//         res.json({
//             success: true,
//             stats: {
//                 totalProfiles,
//                 totalAnganwadis,
//                 totalWorkers,
//                 healthStatusCounts,
//                 recentProfiles
//             }
//         });
//     } catch (error) {
//         res.status(500).json({ success: false, message: error.message });
//     }
// });

// // 10. Delete Profile
// app.delete('/api/profiles/:profileId', async (req, res) => {
//     try {
//         const profile = await Profile.findOneAndDelete({ profileId: req.params.profileId });
//         if (!profile) {
//             return res.status(404).json({ success: false, message: 'Profile not found' });
//         }
//         res.json({ success: true, message: 'Profile deleted successfully' });
//     } catch (error) {
//         res.status(500).json({ success: false, message: error.message });
//     }
// });

// // Health check endpoint
// app.get('/health', (req, res) => {
//     res.json({ status: 'OK', timestamp: new Date() });
// });

// // --- Server Start ---
// const PORT = process.env.PORT || 3000;
// app.listen(PORT, () => {
//     console.log(`🚀 Express server running on http://localhost:${PORT}`);
//     console.log(`📊 MongoDB connected to: ${MONGO_URI}`);
//     console.log('\n📝 Test Credentials:');
//     console.log('   Worker: priya.sharma@test.com');
//     console.log('   Admin:  admin.patel@test.com');
// });

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const connectDB = require('./config/database');
const initializeTestData = require('./utils/testData');
const errorHandler = require('./middleware/errorHandler');


// Import routes
const heightPredictionRoutes = require('./routes/heightPredictionRoutes');
const authRoutes = require('./routes/authRoutes');
const profileRoutes = require('./routes/profileRoutes');
const anganwadiRoutes = require('./routes/anganwadiRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const adminDashboardRoutes = require('./routes/adminDashboardRoutes');

// Initialize Express app
const app = express();

// Middleware
app.use(cors());

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Connect to MongoDB
connectDB().then(() => {
    initializeTestData();
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        timestamp: new Date(),
        environment: process.env.NODE_ENV 
    });
});

// API Routes
app.use('/api', authRoutes);
app.use('/api/profiles', profileRoutes);
app.use('/api/anganwadis', anganwadiRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/height', heightPredictionRoutes);
app.use('/api/admin', adminDashboardRoutes);

// 404 Handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: 'Route not found'
    });
});

// Error Handler (must be last)
app.use(errorHandler);

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
    console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`💾 Database: ${process.env.MONGO_URI}`);
    console.log('\n📝 Test Credentials:');
    console.log('   Worker: priya.sharma@test.com');
    console.log('   Admin:  admin.patel@test.com\n');
});

module.exports = app;