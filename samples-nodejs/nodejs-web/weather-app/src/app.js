const path = require('path')
const express = require('express')
const hbs = require('hbs')

const geocode = require('./utils/geocode')
const forecast = require('./utils/weatherdata')

const app  = express()
const port = process.env.PORT || 3000

// Define Paths for express config
const publicDirectoryPath =  path.join(__dirname, '../public');
const viewsPath = path.join(__dirname, '../templates/views')
const partialsPath = path.join(__dirname, '../templates/partials')

// Setup handlebars engine and views location
app.set('view engine','hbs')
app.set('views', viewsPath)
hbs.registerPartials(partialsPath)

//Setup static directory to server
app.use(express.static(publicDirectoryPath))

app.get('', (req, res) => {
    res.render('index', {
        title: 'Weather App',
        name: 'RoboKing Master'
    })
})

app.get('/about', (req, res) => {
    res.render('about', {
        title: 'About Me',
        name: 'RoboKing Master'
    })
})

app.get('/help', (req, res) => {
    res.render('help', {
        title: 'Help',
        helpText: 'This is help page',
        name: 'RoboKing Master'
    })
})

//app.com/weather
app.get('/weather', (req, res) => {
    if (!req.query.address) {
        return res.send({
            error: 'You must provide address'
        })
    }

    geocode(req.query.address, (error, data) => {
        if (error){
            return res.send( {error })
        } 
        console.log('✅ Getting Data For Retrived Coordinates:', data); 
        forecast(data.latitude, data.longitude, (error, forcastdata) => {
            if (error){
                return res.send({error})
            } 
            return res.send({
                forcast: forcastdata,
                location: data.location,
                address: req.query.address
            })
        })
    })
})

app.get('/help/*', (req, res) => {
    res.render('error', { 
        title: 'Help',       
        errorMsg: 'Help artical not found',
        name: 'Ritesh Kumar'      
    })
})

app.get('*', (req, res) => {
    res.render('404', {    
        title: '404',    
        errorMsg: 'Page not found' ,
        name: 'Ritesh Kumar'      
    })
})

// Expresss Server
app.listen(port, () => {
    console.log('Server is running on port '+ port)
})