const sgMail = require('@sendgrid/mail')

sgMail.setApiKey(process.env.SENDGRID_API_KEY)

const sendWelcomeEmail = async (email, name) => {
    const msg = {
        to: email,
        from: 'singhipst@gmail.com',
        subject: 'Thank you for joining in!',
        text: `Welcome to the app, ${name}. Let me know how you get along with the app`
    }
    await sgMail.send(msg)
    .then(() => {
        console.log('Email send to '+name)
    })
    .catch((error) => {
        console.log('Unable to send email '+error)
    })
}

const sendCancelationEmail = (email, name) => {
    const msg = {
        to: email,
        from: 'singhipst@gmail.com',
        subject: 'Sorry to see you go!',
        text: `Goodbye, ${name}. I hope to see you back somtime soon.`
    }
    sgMail.send(msg)
    .then(() => {
        console.log('Email send to '+name)
    })
    .catch((error) => {
        console.log('Unable to send email '+error)
    })
}

module.exports = {
    sendWelcomeEmail,
    sendCancelationEmail
}