const mongoose = require('mongoose')
const validator = require('validator')

const caseMasterSchema = mongoose.Schema({
    caseNumber: { 
        type: Number,
        required: true,
        unique: true,
        default: 0
    },
    moduleName: {
        type: String,
        required: true,
        maxlength: 20,
        trim: true
    },
    caseStatus: {
        type: String,
        trim: true,
        required: true,
        default: 'Pending',
        maxlength: 10,
    },
    caseShortDesc: {
        type: String,
        required: true,
        trim: true,
        maxlength: 100
    },
    caseDetails: {
        type: String,
        trim: true
    },
    owner: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    }
}, {
    timestamps: true
})

// Custom function for generating new case id
caseMasterSchema.statics.getNewCaseId = async () => {
    var newCaseId = 0
    const lastCase = await CaseMasterSchema.find().sort({caseNumber: -1}).limit(1)
    if (!lastCase) {
        let newCaseId = 0
    }

    if(lastCase[0]){
        let newCaseId = lastCase[0].caseId + 1
    }
    return newCaseId
}

const CaseMasterSchema = mongoose.model('CaseMaster', caseMasterSchema)

module.exports = CaseMasterSchema