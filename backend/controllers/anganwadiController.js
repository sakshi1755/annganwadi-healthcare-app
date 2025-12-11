const Anganwadi = require('../models/Anganwadi');

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

        const isNumeric = /^\d+$/.test(query);
        
        let searchCriteria;
        
        if (searchBy === 'code') {
            const codeConditions = [];
            
            if (isNumeric) {
                // Search as string (exact and partial)
                codeConditions.push(
                    { AWC_Code: query }, // Exact string match
                    { AWC_Code: { $regex: `^${query}` } }, // Starts with (string)
                    { Project_Code: query },
                    { Project_Code: { $regex: `^${query}` } },
                    { Sector_Code: query },
                    { Sector_Code: { $regex: `^${query}` } }
                );
                
                // CRITICAL: Also search as number (for imported CSV data)
                const numQuery = Number(query);
                codeConditions.push(
                    { AWC_Code: numQuery }, // Exact number match
                    { Project_Code: numQuery },
                    { Sector_Code: numQuery }
                );
                
                // For partial number matching, convert to string in query
                codeConditions.push(
                    { $expr: { $regexMatch: { input: { $toString: "$AWC_Code" }, regex: `^${query}` } } },
                    { $expr: { $regexMatch: { input: { $toString: "$Project_Code" }, regex: `^${query}` } } },
                    { $expr: { $regexMatch: { input: { $toString: "$Sector_Code" }, regex: `^${query}` } } }
                );
            } else {
                // Text search for non-numeric queries
                const searchRegex = new RegExp(query, 'i');
                codeConditions.push(
                    { AWC_Code: searchRegex },
                    { Project_Code: searchRegex },
                    { Sector_Code: searchRegex }
                );
            }
            
            searchCriteria = { $or: codeConditions };
            
        } else if (searchBy === 'name') {
            const searchRegex = new RegExp(query, 'i');
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
            const searchRegex = new RegExp(query, 'i');
            const allConditions = [
                { AWC_Name: searchRegex },
                { Sector_name: searchRegex },
                { District_Name: searchRegex },
                { Project_Name: searchRegex }
            ];
            
            if (isNumeric) {
                const numQuery = Number(query);
                allConditions.push(
                    // String searches
                    { AWC_Code: query },
                    { AWC_Code: { $regex: `^${query}` } },
                    { Project_Code: query },
                    { Project_Code: { $regex: `^${query}` } },
                    { Sector_Code: query },
                    { Sector_Code: { $regex: `^${query}` } },
                    // Number searches
                    { AWC_Code: numQuery },
                    { Project_Code: numQuery },
                    { Sector_Code: numQuery },
                    // Convert number to string and search
                    { $expr: { $regexMatch: { input: { $toString: "$AWC_Code" }, regex: `^${query}` } } },
                    { $expr: { $regexMatch: { input: { $toString: "$Project_Code" }, regex: `^${query}` } } },
                    { $expr: { $regexMatch: { input: { $toString: "$Sector_Code" }, regex: `^${query}` } } }
                );
            } else {
                allConditions.push(
                    { AWC_Code: searchRegex },
                    { Project_Code: searchRegex },
                    { Sector_Code: searchRegex }
                );
            }
            
            searchCriteria = { $or: allConditions };
        }

        console.log('🔍 Search Query:', query);
        console.log('📋 Search By:', searchBy);
        console.log('🔢 Is Numeric:', isNumeric);

        const results = await Anganwadi.find(searchCriteria)
            .limit(parseInt(limit))
            .lean();

        console.log('✅ Results found:', results.length);
        
        if (results.length > 0) {
            console.log('📄 Sample result:', {
                AWC_Code: results[0].AWC_Code,
                AWC_Code_type: typeof results[0].AWC_Code,
                AWC_Name: results[0].AWC_Name
            });
        }

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
        console.error('❌ Search error:', error);
        res.status(500).json({ 
            success: false, 
            message: error.message 
        });
    }
};

exports.getAnganwadiByCode = async (req, res) => {
    try {
        const { code } = req.params;
        const isNumeric = /^\d+$/.test(code);
        
        const searchConditions = [
            { AWC_Code: code }, // String match
            { Project_Code: code }
        ];
        
        if (isNumeric) {
            const numCode = Number(code);
            searchConditions.push(
                { AWC_Code: numCode }, // Number match
                { Project_Code: numCode }
            );
        }
        
        const anganwadi = await Anganwadi.findOne({
            $or: searchConditions
        }).lean();
        
        if (!anganwadi) {
            return res.status(404).json({ 
                success: false, 
                message: 'Anganwadi not found' 
            });
        }
        
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

exports.getAllAnganwadis = async (req, res) => {
    try {
        const anganwadis = await Anganwadi.find().lean();
        
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

exports.getAnganwadisBySector = async (req, res) => {
    try {
        const { sector } = req.params;
        const anganwadis = await Anganwadi.find({
            Sector_name: sector
        }).lean();
        
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