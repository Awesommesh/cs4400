const bodyParser = require('body-parser');
const express = require('express');
const mysql = require('mysql');
const path = require('path');
const fs = require('fs');
const app = express();

app.use(bodyParser.urlencoded({ extended: true }));

/*
 * As per the instructions, our database is named 'team73'. The server will be hosted
 * on port 3000, and the user/password attributes below should be changed to match your
 * local information, as the program's execution will fail otherwise.
 */
 app.listen('3000', () => {
   console.log('[PORT:3000] Atlanta Movie Project 🎉\n');
 });

const db = mysql.createConnection({
  host: '127.0.0.1',
  user: 'root',
  password: 'password',
  database: 'team73'
});

db.connect((error) => {
  if (error) {
    console.log("Database connection failed! 👇🏼");
    console.log(" > " + error);
    process.exit(0);
  }
});

/*
 * Below lies a collection of general-purpose functions necessary for the application's
 * exeuction. Any future implementations that do not directly relate to a particular
 * HTML page should be placed here.
 *
 */
 app.all('*/css/*', (req, res) => {
   let filePath = path.join('./app', req.path);
   let contentType = fileType(filePath)
   readFile(filePath, res, contentType);
 });

function readFile(filePath, res, contentType) {
  fs.readFile(filePath, {}, (error, content) => {
    if (error)
      res.end(`Service Error: ${error.code}`);
    res.writeHead(200, { 'Content-Type': contentType });
    res.end(content, 'utf8');
  });
}

function fileType(filePath) {
  switch (path.extname(filePath)) {
    case '.json':
      return 'application/json';
    case '.js':
      return 'text/javascript';
    case '.css':
      return 'text/css';
    case '.php':
      return 'text/php';
    case '.png':
      return 'image/png';
    case '.jpg':
      return 'image/jpg';
    case '.ttf':
      return 'text/ttf';
    default:
      return 'text/html';
  }
}

/*
 * SCREEN 1: LOGIN
 *
 *  1. This is a login page that all users use to log into the app.
 *  2. Upon successful login, the user should be taken to the appropriate functionality screen.
 *  3. Upon invalid login, the app should notify the user, and the user should be allowed to retry.
 */
app.get('/', (req, res)=>{
  let filePath = 'app/templates/index.html';
  let contentType = fileType(filePath);
  readFile(filePath, res, contentType);
});

app.post('/index.html', (req, res) => {
  let create = `CALL user_login(?, ?)`;
  let { username, password } = req.body;
  db.query(create, [username, password], (error, results) => {});

  let access = `SELECT * FROM UserLogin`;
  db.query(access, (error, results) => {
    if (results.length > 0) {
      if (results[0].isManager == 1 && results[0].isCustomer == 1) {
        res.redirect('/app/templates/registration/manager-customer.html');
      } else if (results[0].isCustomer == 1) {
        res.redirect('/app/templates/registration/customer.html');
      } else if (results[0].isManager == 1) {
        res.redirect('/app/templates/registration/manager.html');
      } else {
        res.redirect('/app/templates/registration/user.html');
      }
    } else {
      res.redirect('/');
    }
  });
});
