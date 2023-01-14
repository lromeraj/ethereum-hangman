const path = require('path')
const express = require('express')
const app = express()
const port = 5002

app.use(express.static('public'))

/*
app.get( '/', (req, res) => {
  res.sendFile( path.join( __dirname, 'public/index.html' ) )
})
*/

app.listen(port, () => {
  console.log(`Hangman app listening on port ${ port }`)
})
