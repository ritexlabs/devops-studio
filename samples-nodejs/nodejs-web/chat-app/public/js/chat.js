const socket = io()

// Elements
const $messageForm = document.querySelector('#messageForm')
const $messageFormInput = $messageForm.querySelector('input')
const $messageFormButton = $messageForm.querySelector('button')

const $sendLocationButton = document.querySelector('#send-location')
const $messages = document.querySelector('#messages')

//Templates
const $messageTemplate = document.querySelector('#message-template').innerHTML
const $locationTemplate = document.querySelector('#location-template').innerHTML
const $sidebarTemplate = document.querySelector('#sidebar-template').innerHTML

//Options
const { username, room } = Qs.parse(location.search, {ignoreQueryPrefix: true})
const autoscroll = () => {
    // New message element
    const $newMessage = $messages.lastElementChild

    // height of the new message
    const newMessageStyle = getComputedStyle($newMessage)
    const newMesageMargin = parseInt(newMessageStyle.marginBottom)
    const newMessageHeight = $newMessage.offsetHeight + newMesageMargin

    // Visible height
    const visibleHeight = $messages.offsetHeight

    // Height if messages container
    const containerHeight = $messages.scrollHeight
    const scrollOffset = $messages.scrollTop + visibleHeight

    if(containerHeight - newMessageHeight <= scrollOffset) {
        $messages.scrollTop = $messages.scrollHeight
    }
}

socket.on('message', (message) => {
    console.log(message)
    const html = Mustache.render($messageTemplate, {
        username: message.username,
        message: message.text,
        createdAt: moment(message.createdAt).format('h:mm a')
    })
    $messages.insertAdjacentHTML('beforeend', html)

    autoscroll()
})

socket.on('locationMessage', (locationurl) => {
    console.log(locationurl)
    const html = Mustache.render($locationTemplate, {
        username: locationurl.user,
        url: locationurl.url,
        createdAt: moment(locationurl.createdAt).format('h:mm a')
    })
    $messages.insertAdjacentHTML('beforeend', html)

    autoscroll()
})

socket.on('roomData', ({ room, users }) => {
    console.log(room, users)
    const html = Mustache.render($sidebarTemplate, {
        room,
        users
    })
    document.querySelector('#sidebar').innerHTML = html
})

$messageForm.addEventListener('submit', (e) => {
    e.preventDefault()

    $messageFormButton.setAttribute('disabled', 'disabled')

    const message = e.target.elements.message.value
    socket.emit('sendMessage', message, (error) => {
        // Enable button after sent message
        $messageFormButton.removeAttribute('disabled')
        $messageFormInput.value = ''
        $messageFormInput.focus()

        if(error){
            return console.log(error)
        }
        console.log('The message delivered')
    })
})

//Fetch geo location
$sendLocationButton.addEventListener('click', (e) => {
    e.preventDefault()

    if (!navigator.geolocation) {
        return alert('Geolocation is not supported by your browser')
    }

    $sendLocationButton.setAttribute('disabled', 'disabled')

    navigator.geolocation.getCurrentPosition((position) => {
        //console.log(position)
        socket.emit('sendLocation', { 
            latitude: position.coords.latitude, 
            longitude: position.coords.longitude
        }, () => {
            $sendLocationButton.removeAttribute('disabled')
            console.log('Location sent!')
        })
    })
})

socket.emit('join', { username, room }, (error) => {
    if(error){
        alert(error)
        location.href = '/'
    }
})