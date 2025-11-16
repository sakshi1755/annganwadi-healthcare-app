const User = require('../models/User');
const Anganwadi = require('../models/Anganwadi');
const Profile = require('../models/Profile');

async function initializeTestData() {
    try {
        const existingUser = await User.findOne({ userId: 'test_user_1' });
        if (existingUser) {
            console.log('Test data already exists.');
            return;
        }

   

        // Create test users
        const testUsers = [
            {
                userId: 'test_user_1',
                name: 'Priya Sharma',
                email: 'priya.sharma@test.com',
                role: 'worker',
                assignedAnganwadiId: 'AWC001'
            },
            {
                userId: 'test_admin_1',
                name: 'Admin Patel',
                email: 'admin.patel@test.com',
                role: 'admin'
            }
        ];
        await User.insertMany(testUsers);

        console.log('✅ Test data initialized!');
    } catch (error) {
        console.error('Error initializing test data:', error);
    }
}

module.exports = initializeTestData;