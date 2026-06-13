require('dotenv').config()
const { json } = require('express')
const express = require('express')
require('./database/database')

const port = process.env.PORT
const app = express()

const userRouter = require('./routers/user.router')
const casemasterRouter = require('./routers/casemaster.router')
app.use(express.json())

app.use(userRouter)
app.use(casemasterRouter)

console.log('Welcome To Test Manager App')

module.exports = app