
console.log('Client side javascript file is loaded')

const weatherForm = document.querySelector('form')
const search = document.querySelector('input')
const messageOne = document.querySelector('#message-1')
const messageTwo = document.querySelector('#message-2')

messageOne.textContent = ''
messageTwo.textContent = ''

weatherForm.addEventListener('submit', (event) => {
    event.preventDefault()
    const location = search.value
    console.log(location)
    fetch('/weather?address='+ location).then((response) => {
        response.json().then((data) => {
            if(data.error){
                messageOne.textContent = data.error
            }else{
                console.log(data.forcast)
                msg = 'At ' + data.forcast.data.observation_time + ' in '+ location +', It\'s ' + data.forcast.data.temperature
                msg += ' degree and feels like ' + data.forcast.data.feelslike
                msg += '. There is ' + data.forcast.data.precip + '% chances of rain.'
                messageOne.textContent = data.location
                messageTwo.textContent = msg              
            }
        })
    })    
})