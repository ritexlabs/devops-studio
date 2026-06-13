const users = []

const camelize = (str) => {
    return str.split(' ')
       .map(a => a.trim())
       .map(a => a[0].toUpperCase() + a.substring(1))
       .join("")
 }

// Add user into chat
const addUser = ({id, username, room}) => {
    // Clean the data
    username = camelize(username.trim().toLowerCase())
    room = camelize(room.trim().toLowerCase())

    // validate the user data
    if (!username || !room) {
        return {
            error: 'User name and room are required!'
        }
    }

    // Chek for existing username
    const existingUser = users.find((user) => {
        return user.room === room && user.username === username
    })

    // Validate user name
    if (existingUser){
        return {
            error: 'Username is in use'
        }
    }

    // Store user 
    const user = { id, username, room }   
    users.push(user)
    return { user }
}

// Remove user
const removeUser = (id) => {
    const index = users.findIndex((user) => user.id === id)

    if(index !== -1){
        return users.splice(index, 1)[0]
    }
}
// get user
const getUser = (id) => {
    return users.find((user) => user.id === id)
}


// getuseres in room
const getUseresInRoom = (room) => {
    return users.filter((user) => user.room == room)
}

module.exports = {
   addUser,
   removeUser,
   getUser,
   getUseresInRoom 
}