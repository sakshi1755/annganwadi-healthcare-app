const FormData = require('form-data');
const axios = require('axios');

const ML_API_URL = 'http://localhost:8000'; // Your FastAPI ML model URL

async function predictHeight(imageBuffers, ageInMonths) {
    try {
        const formData = new FormData();
        
        // Add all 4 images
        imageBuffers.forEach((buffer, index) => {
            formData.append('files', buffer, `image_${index}.jpg`);
        });
        
        // Add age
        formData.append('age_in_months', ageInMonths.toString());

        const response = await axios.post(
            `${ML_API_URL}/predict_height/`,
            formData,
            {
                headers: formData.getHeaders(),
                timeout: 30000 // 30 seconds
            }
        );

        return {
            success: true,
            predictedHeight: response.data.predicted_height_cm
        };
    } catch (error) {
        console.error('ML API Error:', error.response?.data || error.message);
        return {
            success: false,
            error: error.response?.data?.detail || 'Height prediction failed'
        };
    }
}

module.exports = { predictHeight };