const axios = require('axios');

const geocode = (address, callback) => {
    const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(address)}&format=json`;

    console.log('🔍 Geocode URL:', url); // Debug: Show full URL

    axios.get(url, {
        headers: {
            'User-Agent': 'notes-app/1.0'
        }
    })
    .then(response => {
        const data = response.data;

        console.log('📦 Raw Geocode Response:', JSON.stringify(data, null, 2)); // Debug: Full response

        if (Array.isArray(data) && data.length > 0) {
            const result = {
                longitude: data[0].lon,
                latitude: data[0].lat,
                location: data[0].display_name
            };

            console.log('✅ Extracted Coordinates:', result); // Debug: Final result

            callback(undefined, result);
        } else {
            console.warn('⚠️ No results found in response.');
            callback('Unable to find location. Try another search.', undefined);
        }
    })
    .catch(error => {
        console.error('❌ Geocode API Error:', error.message);
        callback('Unable to connect to location services!', undefined);
    });
};

module.exports = geocode;
