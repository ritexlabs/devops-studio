const express = require('express')
const Task = require('../models/task')
const auth = require('../middleware/auth')

const router = new express.Router()

router.post('/tasks', auth, async (req, res) => {
    const task = new Task({
        ...req.body,        //Copy data
        owner: req.user._id
    })

    try{
        await task.save();
        res.status(201).send(task)
    }catch(error){
        res.status(400).send(error)
    }
})

// GET /tasks?completed=true
// GET /task?limits=10&skip=0 Support for pagination limit and skip 
// GET /tasks?sortBy=createdAt_asc or /tasks?sortBy=createdAt_desc
router.get('/tasks', auth, async (req, res) => {   
    const match = {}
    const sort = {}

    if (req.query.completed) {
        match.completed = req.query.completed === 'true'
    }

    if (req.query.sortBy) {
        const parts = req.query.sortBy.split('_')
        sort[parts[0]] = parts[1] === 'desc' ? -1 : 1
    }

    try{
        await req.user.populate({
            path: 'tasks',
            match,
            options: {
                limit: parseInt(req.query.limit),
                skip: parseInt(req.query.skip),
                sort
            }
        }).execPopulate()
        res.send(req.user.tasks)
    }catch(error){
        res.status(500).send(error)
    }
})

router.get('/tasks/:id', auth, async (req, res) => {    
    try{
        const task = await Task.findOne({ _id: req.params.id, owner: req.user._id})

        if(!task){
            return res.status(404).send()
        }
        res.send(task)
    }catch(error){
        res.status(500).send(error)
    }
})

router.patch('/tasks/:id', auth, async (req, res) => {
    const updates = Object.keys(req.body)
    const allowedUpdate = ['completed', 'description']
    const isValidOperation = updates.every((updates) => allowedUpdate.includes(updates))

    if(!isValidOperation){
        return res.status(400).send('Error: Invalid updates!')
    }

    try{
        const task = await Task.findOne({ _id: req.params.id, owner: req.user._id})

        if(!task){
            return res.status(404).send('Error: Task not found for given id!')
        }

        updates.forEach((update) => task[update] = req.body[update])
        await task.save()
        res.send(task)
    }catch(error){
        res.status(500).send(error)
    }
})

router.delete('/tasks/:id', auth, async (req, res) => {
    try{
        const task = await Task.findOneAndDelete({ _id: req.params.id, owner: req.user._id})
        if(!task){
            return res.status(404).send()
        }
        res.send(task)
    }catch(error){
        res.status(500).send(error)
    }
})

module.exports = router