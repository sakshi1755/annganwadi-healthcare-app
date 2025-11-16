const mongoose = require('mongoose');
require('dotenv').config();

const Anganwadi = require('./models/Anganwadi');

mongoose.connect(process.env.MONGO_URI)
    .then(async () => {
        console.log('Connected to MongoDB');
        
        // Check total count
        const total = await Anganwadi.countDocuments();
        console.log(`\n📊 Total Anganwadi records: ${total}`);
        
        // Show first 3 records to see field names
        const samples = await Anganwadi.find().limit(3).lean();
        console.log('\n📋 Sample records:');
        samples.forEach((record, index) => {
            console.log(`\n--- Record ${index + 1} ---`);
            console.log(JSON.stringify(record, null, 2));
        });
        
        // Try searching for "Baghma"
        const searchResults = await Anganwadi.find({
            $or: [
                { AWC_Name: /Baghma/i },
                { AWC_Code: /Baghma/i }
            ]
        }).limit(5).lean();
        
        console.log(`\n🔍 Search results for "Baghma": ${searchResults.length} found`);
        searchResults.forEach(r => {
            console.log(`  - ${r.AWC_Name} (${r.AWC_Code})`);
        });
        
        process.exit(0);
    })
    .catch(err => {
        console.error('❌ Error:', err);
        process.exit(1);
    });