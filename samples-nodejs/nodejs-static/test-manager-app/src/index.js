require('dotenv').config()

const app = require('./app')
const port = process.env.PORT

//Runnign server
app.listen(port, () => {
    console.log('Server running on port '+port)
})

