const Anganwadi = require('../models/Anganwadi');

// Search Anganwadis with autocomplete - HANDLES CSV DATA
exports.searchAnganwadis = async (req, res) => {
    try {
        const { query, searchBy = 'all', limit = 10 } = req.query;
        
        if (!query || query.trim().length < 2) {
            return res.json({ 
                success: true, 
                results: [],
                message: 'Query must be at least 2 characters' 
            });
        }

        const searchRegex = new RegExp(query, 'i');
        let searchCriteria;

        if (searchBy === 'code') {
            searchCriteria = {
                $or: [
                    { AWC_Code: searchRegex },
                    { Project_Code: searchRegex },
                    { Sector_Code: searchRegex }
                ]
            };
        } else if (searchBy === 'name') {
            searchCriteria = {
                $or: [
                    { AWC_Name: searchRegex },
                    { Sector_name: searchRegex },
                    { District_Name: searchRegex },
                    { Project_Name: searchRegex }
                ]
            };
        } else {
            // Search all fields
            searchCriteria = {
                $or: [
                    { AWC_Code: searchRegex },
                    { AWC_Name: searchRegex },
                    { Sector_name: searchRegex },
                    { District_Name: searchRegex },
                    { Project_Code: searchRegex },
                    { Project_Name: searchRegex }
                ]
            };
        }

        const results = await Anganwadi.find(searchCriteria)
            .limit(parseInt(limit))
            .lean();

        // Format results - CONVERT NUMBERS TO STRINGS
        const formattedResults = results.map(item => ({
            AWC_Code: String(item.AWC_Code || ''),
            AWC_Name: String(item.AWC_Name || 'Unknown'),
            Sector_name: String(item.Sector_name || ''),
            District_Name: String(item.District_Name || ''),
            Project_Name: String(item.Project_Name || '')
        }));

        res.json({ 
            success: true, 
            results: formattedResults, 
            count: formattedResults.length 
        });
    } catch (error) {
        console.error('Search error:', error);
        res.status(500).json({ 
            success: false, 
            message: error.message 
        });
    }
};

// Get Anganwadi by Code - HANDLES CSV DATA
exports.getAnganwadiByCode = async (req, res) => {
    try {
        const { code } = req.params;
        
        const anganwadi = await Anganwadi.findOne({
            $or: [
                { AWC_Code: code },
                { AWC_Code: parseInt(code) }, // Try as number too
                { Project_Code: code },
                { Project_Code: parseInt(code) }
            ]
        }).lean();
        
        if (!anganwadi) {
            return res.status(404).json({ 
                success: false, 
                message: 'Anganwadi not found' 
            });
        }
        
        // Convert all fields to strings
        const formatted = {
            ...anganwadi,
            AWC_Code: String(anganwadi.AWC_Code || ''),
            Project_Code: String(anganwadi.Project_Code || ''),
            Sector_Code: String(anganwadi.Sector_Code || ''),
            DistrictID: String(anganwadi.DistrictID || ''),
            District_Name: String(anganwadi.District_Name || ''),
            Project_Name: String(anganwadi.Project_Name || ''),
            Sector_name: String(anganwadi.Sector_name || ''),
            AWC_Name: String(anganwadi.AWC_Name || ''),
            AWC_TYPE: String(anganwadi.AWC_TYPE || '')
        };
        
        res.json({ success: true, data: formatted });
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            message: error.message 
        });
    }
};

// Get all anganwadis
exports.getAllAnganwadis = async (req, res) => {
    try {
        const anganwadis = await Anganwadi.find().lean();
        
        // Convert numeric fields to strings
        const formatted = anganwadis.map(item => ({
            ...item,
            AWC_Code: String(item.AWC_Code || ''),
            Project_Code: String(item.Project_Code || ''),
            Sector_Code: String(item.Sector_Code || ''),
            DistrictID: String(item.DistrictID || '')
        }));
        
        res.json({ success: true, anganwadis: formatted, count: formatted.length });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Get all districts
exports.getDistricts = async (req, res) => {
    try {
        const districts = await Anganwadi.distinct('District_Name');
        const allDistricts = districts.filter(d => d).map(d => String(d));
        res.json({ 
            success: true, 
            districts: allDistricts.sort() 
        });
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            message: error.message 
        });
    }
};

// Get sectors by district
exports.getSectorsByDistrict = async (req, res) => {
    try {
        const { district } = req.params;
        const sectors = await Anganwadi.distinct('Sector_name', { District_Name: district });
        const allSectors = sectors.filter(s => s).map(s => String(s));
        res.json({ 
            success: true, 
            sectors: allSectors.sort() 
        });
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            message: error.message 
        });
    }
};

// Get anganwadis by sector
exports.getAnganwadisBySector = async (req, res) => {
    try {
        const { sector } = req.params;
        const anganwadis = await Anganwadi.find({
            Sector_name: sector
        }).lean();
        
        // Convert numeric fields to strings
        const formatted = anganwadis.map(item => ({
            ...item,
            AWC_Code: String(item.AWC_Code || ''),
            Project_Code: String(item.Project_Code || ''),
            Sector_Code: String(item.Sector_Code || ''),
            DistrictID: String(item.DistrictID || '')
        }));
        
        res.json({ 
            success: true, 
            anganwadis: formatted 
        });
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            message: error.message 
        });
    }
};