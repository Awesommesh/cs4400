const bodyParser = require('body-parser');
const express = require('express');
const mysql = require('mysql');
const path = require('path');
const fs = require('fs');
const app = express();

app.use(bodyParser.urlencoded({ extended: true }));

var session = require('express-session')({
  name: 'sid',
  resave: false,
  saveUninitialized: false,
  secret: 'stupidSecret4400', //Session secret
  cookie: {
    maxAge: 1000 * 60 * 60 * 2, //TWO HOURS
    sameSite: true,
  }
});
app.use(session);
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
  password: 'Password',
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
 */
const pages = ['/functionality/admin-customer.html',   '/functionality/admin.html',
               '/functionality/customer.html',         '/functionality/manager-customer.html',
               '/functionality/manager.html',          '/functionality/user.html',
               '/registration/manager-customer.html',  '/registration/customer.html',
               '/registration/user.html',              '/registration/manager.html',
               '/registration/navigation.html',        '/functionality/theater_overview.html',
               '/functionality/explore_movie.html',    '/functionality/explore_theater.html',
               '/functionality/schedule_movie.html',   '/functionality/view_history.html',
               '/functionality/visit_history.html'];

for (let i = 0; i < pages.length; i++) {
  app.get(pages[i], (req, res) => {
    let filePath = 'app/templates' + pages[i];
    let contentType = fileType(filePath);
    readFile(filePath, res, contentType);
  });
}

app.get('/functionality/funcNav', (req, res) => {
  if (req.session.isCustomer) {
    if (req.session.isAdmin) {
      res.redirect('/functionality/admin-customer.html');
    } else if (req.session.isManager) {
      res.redirect('/functionality/manager-customer.html');
    } else {
      res.redirect('/functionality/customer.html');
    }
  } else if (req.session.isAdmin) {
    res.redirect('/functionality/admin.html');
  } else if (req.session.isManager) {
    res.redirect('/functionality/manager.html');
  } else {
    res.redirect('/functionality/user.html');
  }
});

app.all('*/css/*', (req, res) => {
  let filePath = path.join('./app', req.path);
  let contentType = fileType(filePath);
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
 * =================
 *  SCREEN 1: LOGIN
 * =================
 *   1. This is a login page that all users use to log into the app.
 *   2. Upon successful login, the user should be taken to the appropriate functionality screen.
 *   3. Upon invalid login, the app should notify the user, and the user should be allowed to retry.
 */
app.get('/', (req, res) => {
  const { username } = req.session;
  let filePath = 'app/templates/index.html';
  let contentType = fileType(filePath);
  readFile(filePath, res, contentType);
});

app.post('/login', (req, res) => {
  let create = `CALL user_login(?, ?)`;
  let { username, password } = req.body;
  db.query(create, [username, password], (error, results) => {});

  let access = `SELECT * FROM UserLogin`;
  db.query(access, (error, results) => {
    if (results.length > 0 && results[0].status == 'Approved') {
      req.session.username = results[0].username;
      req.session.isAdmin = results[0].isAdmin;
      req.session.isManager = results[0].isManager;
      req.session.isCustomer = results[0].isCustomer;
      if (results[0].isManager == 1 && results[0].isCustomer == 1) {
        res.redirect('functionality/manager-customer.html');
      } else if (results[0].isCustomer == 1) {
        res.redirect('functionality/customer.html');
      } else if (results[0].isManager == 1) {
        res.redirect('functionality/manager.html');
      } else {
        res.redirect('functionality/user.html');
      }
    } else {
      res.redirect('/');
    }
  });
});

app.post('/theater_overview', (req, res) => {
  var {movie_name, min_duration, max_duration, min_release_date, max_release_date, min_play_date,
    max_play_date, not_played_movie_only} = req.body;
  if(min_duration=='') {
    min_duration = 0;
  }
  if(max_duration=='') {
    const maxDuration = 'SELECT MAX(duration) FROM movie';
    db.query(maxDuration, (error, results) => {
      max_duration = results[0];
    });
  }
  if(min_release_date==''){
    min_release_date='1000-01-01';
  }
  if(max_release_date=='') {
    const maxReleaseDate = 'SELECT MAX(movReleaseDate) FROM movie';
    db.query(maxReleaseDate, (error, results) => {
      max_release_date = results[0];
    });
  }
  if(min_play_date=='') {
    min_play_date='1000-01-01';
  }
  if(max_play_date=='') {
    const maxPlayDate = 'SELECT MAX(movPlayDate) FROM movieplay';
    db.query(maxPlayDate, (error, results) => {
      max_play_date = results[0];
    });
  }
  if(!not_played_movie_only) {
    not_played_movie_only = false;
  } else {
    not_played_movie_only = true;
  }
  let sql = 'CALL manager_filter_th(?, ?, ?, ?, ?, ?, ?, ?)';
  db.query(sql, [movie_name, min_duration, max_duration, min_release_date, max_release_date,
    min_play_date, max_play_date, not_played_movie_only], (error, results) => {});
  let sqlResults = 'SELECT * FROM ManFilterTh';
  db.query(sqlResults, (error, results) => {
    res.redirect('/functionality/theater_overview.html?'+JSON.stringify(results));  //Terrible Terrible way of doing things but what can you do XD
  });
});

app.post("/explore_movie", (req, res) => {
  var {movName, comName, city, state, min_play_date, max_play_date} = req.body;
  if(min_play_date=='') {
    min_play_date='1000-01-01';
  }
  if(max_play_date=='') {
    const maxPlayDate = 'SELECT MAX(movPlayDate) AS playDate FROM movieplay';
    db.query(maxPlayDate, (error, results) => {
      max_play_date = results[0].playDate;
    });
  }
  var mov_name, com_name;
  if (movName=="ALL") {
    mov_name = movName;
    let sqlGetCompanyName = 'SELECT comName FROM company';
    db.query(sqlGetCompanyName, (error, results) => {
      com_name = results[comName].comName;
      let sql = 'CALL customer_filter_mov(?, ?, ?, ?, ?, ?)';
      db.query(sql, [mov_name, com_name, city, state, min_play_date, max_play_date], (error, results) => {});
      let sqlResults = 'SELECT * FROM CosFilterMovie';
      db.query(sqlResults, (error, results) => {
        res.redirect('/functionality/explore_movie.html?' + JSON.stringify(results));
      });
    });
  } else {
    let sqlGetMovieName = 'SELECT movName FROM movie';
    db.query(sqlGetMovieName, (error, results) => {
      mov_name = results[movName].movName;
      let sqlGetCompanyName = 'SELECT comName FROM company';
      db.query(sqlGetCompanyName, (error, results) => {
        com_name = results[comName].comName;
        let sql = 'CALL customer_filter_mov(?, ?, ?, ?, ?, ?)';
        db.query(sql, [mov_name, com_name, city, state, min_play_date, max_play_date], (error, results) => {});
        let sqlResults = 'SELECT * FROM CosFilterMovie';
        db.query(sqlResults, (error, results) => {
          res.redirect('/functionality/explore_movie.html?' + JSON.stringify(results));
        });
      });
    });
  }
});


app.get('/movieList/', (req, res)=> {
  let sql = 'SELECT movName FROM movie';
  db.query(sql, (error, results)=> {
    res.json(results);
  });
});

app.get('/companyList/', (req, res)=> {
  let sql = 'SELECT comName FROM company';
  db.query(sql, (error, results)=> {
    res.json(results);
  });
});

app.get('/creditCardList', (req, res)=> {
  let sql = "SELECT creditCardNum FROM customercreditcard WHERE username=\""+req.session.username+"\"";
  db.query(sql, (error, results)=> {
    res.json(results);
  });
});

app.post('/schedule_movie', (req, res) => {
  var {movName, mov_release_date, mov_play_date} = req.body;
  let sqlGetMovieName = 'SELECT movName FROM movie';
  var mov_name;
  db.query(sqlGetMovieName, (error, results)=> {
    mov_name = results[movName].movName;
    let sql = 'CALL manager_schedule_mov(?, ?, ?, ?)';
    db.query(sql, [req.session.username, mov_name, mov_release_date, mov_play_date], (error, results) => {
      res.redirect('/functionality/schedule_movie.html');
    });
  });
});

app.post('/view_movie', (req, res) => {
  var {row, creditCardNum} = req.body;
  var view_creditCard;
  let sqlGetCreditCardNum = "SELECT creditCardNum FROM customercreditcard WHERE username=\""+req.session.username+"\"";
  db.query(sqlGetCreditCardNum, (error, results) => {
    view_creditCard = results[creditCardNum].creditCardNum;
  });

  let sqlGetRowData = 'SELECT * FROM CosFilterMovie';
  db.query(sqlGetRowData, (error, results) => {
    var row_data= results[row];
    let sql = 'CALL customer_view_mov(?, ?, ?, ?, ?, ?)';
    console.log([view_creditCard, row_data.movName, row_data.movReleaseDate, row_data.thName, row_data.comName, row_data.movPlayDate]);
    db.query(sql, [view_creditCard, row_data.movName, row_data.movReleaseDate, row_data.thName,
      row_data.comName, row_data.movPlayDate], (error, results)=> {
      console.log(results);
    });
  });
});

 /*
  * ===========================
  *  SCREENS 3-6: REGISTRATION
  * ===========================
  *   1. “Usernames” are unique among all users.
  *   2. “Password” must have at least 8 characters.
  *   3. “Password” and “confirm password” should match
  *   4. Store the hashed password in the database, not the plain text one.
  */
app.post('/register_user', (req, res) => {
  // to-do!
});

app.post('/register_manager', (req, res) => {
  // to-do!
});

app.post('/register_customer', (req, res) => {
  // to-do!
});

app.post('/register_manager_customer', (req, res) => {
  // to-do!
});
