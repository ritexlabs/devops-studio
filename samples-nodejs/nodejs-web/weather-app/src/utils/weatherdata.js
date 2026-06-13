require('dotenv').config();
const axios = require('axios');

const weatherdata = (latitude, longitude, callback) => {
    const api_key = process.env.WEATHERSTACK_APIKEY;
    const url = `http://api.weatherstack.com/current?access_key=${api_key}&query=${latitude},${longitude}&units=m`;

    axios.get(url)
        .then(response => {
            const body = response.data;

            console.log('📦 Raw Weather API Response:', JSON.stringify(body, null, 2)); // Debug: Full response

            if (body.error) {
                callback('Unable to find location. Try another search.', undefined);
            } else {
                callback(undefined, {
                    data: body.current
                    // You can customize this further if needed:
                    // summary: `At ${body.current.observation_time}, ${body.current.weather_descriptions[0]}. It's currently ${body.current.temperature}°C, feels like ${body.current.feelslike}°C. Precipitation: ${body.current.precip}%`
                });
            }
        })
        .catch(error => {
            console.error('❌ Weather API Error:', error.message);
            callback('Unable to connect to weather service!', undefined);
        });
};

module.exports = weatherdata;
