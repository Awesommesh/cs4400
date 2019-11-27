const express = require('express');
const mysql = require('mysql');
var bodyParser = require('body-parser');
const fs = require('fs');
var app = express();
const path = require('path');
app.use(bodyParser.urlencoded({ extended: true }));

// establishes connection to database
const db = mysql.createConnection({
  host: '127.0.0.1',
  user: 'root',
  password: 'passwordg',
  database: 'team73',
  multipleStatements: true,
});

db.connect((error) => {
  if (error) {
    console.log("Database connection failed! 👇🏼");
    console.log(" > " + error);
    process.exit(0);
  }
});

const readFile = (filePath, res, contentType) => {
  fs.readFile(filePath, {},(err, content) => {
    if (err) {
      if (err.code == 'ENOENT') {
        res.end(`Server Error: ${err.code}`);
      } else {
        console.log(err.code);
        res.end(`Server Error: ${err.code}`);
      }
    } else {
      res.writeHead(200, {'Content-Type': contentType});
      res.end(content, 'utf8');
    }
  });
};

const getContentType = (filePath) => {
  let extname =  path.extname(filePath);

  let contentType = 'text/html';
  switch(extname) {
    case '.js':
      contentType = 'text/javascript';
      break;
    case '.css':
      contentType = 'text/css';
      break;
    case '.php':
      contentType = 'text/php';
      break;
    case '.json':
      contentType = 'application/json';
      break;
    case '.png':
      contentType = 'image/png';
      break;
    case '.jpg':
      contentType = 'image/jpg';
      break;
    case '.ttf':
      contentType = 'text/ttf';
  }
  return contentType;
};

app.all('*/css/*', (req, res) => {
  let filePath = path.join('./app', req.path);
  var contentType = getContentType(filePath)
  readFile(filePath, res, contentType);
});
/* Reference for calling SQL procedures in mysql
let sql = `call user_login(?, ?); SELECT * FROM UserLogin;`;

db.query(sql, ['calcultron', '333333333'], (error, results) => {
  if (error) {
    return console.error(error.message);
  }
  console.log(results);
}); */

// Login page
app.get('/', (req, res)=>{
  console.log(req.originalUrl);
  let filePath = 'app/templates/index.html';
  var contentType = getContentType(filePath);
  readFile(filePath, res, contentType);
});

app.post('/index.html', (req, res) => {
  const {username, password} = req.body;
  let sql = `call user_login(?, ?); SELECT * FROM UserLogin;`;
  db.query(sql, [username, password], (error, results) => {
    if (error) {
      return console.error(error.message);
    }
    if (results[1].length != 0) {
      const user = results[1][0];
      if (user.isCustomer == 1) {
        if (user.isManager == 1) {
          res.redirect('/app/templates/registration/manager-customer.html');
        } else {
          res.redirect('/app/templates/registration/customer.html');
        }
      } else if (user.isManager == 1) {
        res.redirect('/app/templates/registration/manager.html');
      } else {
        res.redirect('/app/templates/registration/user.html');
      }
    } else {
      res.redirect('/');
    }
  });
});

/* Testing app.get functionality
// ex: fetches password of a user given their username
app.get('/password/:username', (req, res) => {
  const sql = `SELECT password FROM user WHERE username = ?`;
  db.query(sql, [req.params.username], (error, result) => {
    for (let i = 0; i < result.length; i++)
      console.log(result[i].password);
  });
});*/

app.listen('3000', () => {
  console.log('CS4400: Atlanta Movie Project 🎉\n');
});
