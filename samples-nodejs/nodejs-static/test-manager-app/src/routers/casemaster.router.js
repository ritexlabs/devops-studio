const express = require('express')
const multer = require('multer')
const XLSX = require('xlsx')
const { ObjectID } = require('mongodb')

const CaseMaster = require('../models/casemaster.model')
const auth = require('../middleware/auth.middleware')

const router = new express.Router()

router.post('/cases', auth, async (req, res) => {    
    const casemaster = new CaseMaster({
        ...req.body
    })

    try{
        await casemaster.save()
        res.status(201).send({ casemaster })
    }catch(error){        
        res.status(400).send(error)
    }
})

router.get('/cases', auth, async (req, res) => {
    const match = {}
    const sort = {}
    try{
        const testcases = await CaseMaster.find()
        res.send(testcases)
    }catch(error){
        res.status(500).send(error)
    }
})

const upload = multer({
    limits: {
        fileSize: 10000000
    },
    fileFilter(req, file, cb) {
        if(!file.originalname.match(/\.(xlsx)$/)) {
            return cb(new Error('Please upload test master xlsx sheet'))
        }        
        cb(undefined, true)        
    }
})

router.post('/cases/load', upload.single('casemaster'), async (req, res) => {    
    try{
        const testcases = await CaseMaster.countDocuments()
        if(testcases <= 0){
            console.log('Loading test cases')
            const workbook = XLSX.read(req.file.buffer); 
            let result = {}
            workbook.SheetNames.forEach((sheetName) => {
                let rowa = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], {header: 1})
                if (rowa.length) result = rowa
            })   
        
            for (var i=0; i<result.length; i++){
                let casemaster = new CaseMaster({
                    caseNumber: result[i][0],
                    moduleName: result[i][1],
                    caseShortDesc: result[i][2],
                    caseDetails: result[i][3]
                })
        
                await casemaster.save()
            }        
            res.status(200).send({ msg: 'Test cases uploaded successfuly'})
        }else{
            res.status(400).send({ msg:'Please delete existing testcases before loading'})
        }

    }catch(error){
        res.status(500).send(error)
    }    
}, (error, req, res, next) => {
    res.status(400).send({error: error.message})
})

module.exports = router