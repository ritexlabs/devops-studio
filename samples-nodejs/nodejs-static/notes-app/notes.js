const chalk = require('chalk')
const fs = require('fs')

const getNotes = (title) => {
    const notes = loadNotes()
    const duplicateNote = notes.find((note) => note.title === title)
    if(duplicateNote) {
        console.log(chalk.white.inverse(duplicateNote.title))
        console.log('\t' + chalk.blue(duplicateNote.body))
    }else{
        console.log(chalk.red.inverse('Note not found!'))
    }
}

const listNotes = () => {
    const notes = loadNotes()
    console.log(chalk.blue('=====Your notes===='))
    notes.forEach((element) => {
        console.log('Title: '+element.title)
        console.log('\tBody: '+element.title)
        console.log('-----------------------------------')
    })
}

const removeNote = (title) => {
    const notes = loadNotes()
    const notesToKeep = notes.filter((note) => note.title !== title)
    
    if(notes.length > notesToKeep.length ) {        
        saveNotes(notesToKeep)
        console.log(chalk.green.inverse('Note removed!'))
    } else {
        console.log(chalk.red.inverse('Note not found!'))
    }
}

const addNote = (title, body) => {
    const notes = loadNotes()

    const duplicateNote = notes.find((note) => note.title === title)

    debugger

    if(!duplicateNote) {
        notes.push({
            title: title,
            body: body
        })    
        saveNotes(notes)
        console.log(chalk.green.inverse('New note added'))
    } else {
        console.log(chalk.red.inverse('Note title taken'))
    }
}

const loadNotes = () => {
    try{
        const dataBuffer = fs.readFileSync('notes.json')
        const dataJSON = dataBuffer.toString()
        return JSON.parse(dataJSON)
    }catch(e){
        return []
    }
}

const saveNotes = (notes) => {
    const dataJSON = JSON.stringify(notes)
    fs.writeFileSync('notes.json', dataJSON)
}

module.exports = {
    getNotes: getNotes,
    addNote: addNote,
    removeNote: removeNote,
    listNotes: listNotes
}
    
    