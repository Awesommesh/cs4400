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
  console.log('Atlanta Movie Project 🎉');
});

const db = mysql.createConnection({
  host: '127.0.0.1',
  user: 'root',
  password: 'Amitgull@7',
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
               '/functionality/visit_history.html',    '/functionality/manage_user.html',
               '/functionality/manage_company.html',   '/functionality/create_movie.html',
               '/functionality/create_theater.html',   '/functionality/company_detail.html'];

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

app.all('*/static/imgs/*', (req, res) => {
  console.log(req);
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

app.get('/index.html', (req, res)=> {
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
      } else if (results[0].isAdmin && results[0].isCustomer == 1) {
        res.redirect('functionality/admin-customer.html');
      } else if (results[0].isCustomer == 1) {
        res.redirect('functionality/customer.html');
      } else if (results[0].isManager == 1) {
        res.redirect('functionality/manager.html');
      } else if (results[0].isAdmin == 1) {
        res.redirect('functionality/admin.html');
      } else {
        res.redirect('functionality/user.html');
      }
    } else {
      var msg = [{err: ""}];
      if (results.length > 0 && results[0].status != 'Approved') {
        msg[0].err = "Attempted login's user status not approved!";
        res.redirect('/index.html?'+JSON.stringify(msg));
      } else {
        msg[0].err = "Incorrect Username or Password!";
        res.redirect('/index.html?'+JSON.stringify(msg));
      }
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
    max_duration = 100000;
  }
  if(min_release_date==''){
    min_release_date='1000-01-01';
  }
  if(max_release_date=='') {
    max_release_date='9999-01-01';
  }
  if(min_play_date=='') {
    min_play_date='1000-01-01';
  }
  if(max_play_date=='') {
    max_play_date = '9999-01-01';
  }
  if(!not_played_movie_only) {
    not_played_movie_only = false;
  } else {
    not_played_movie_only = true;
  }
  let sql = 'CALL manager_filter_th(?, ?, ?, ?, ?, ?, ?, ?, ?)';
  console.log([req.session.username, movie_name, min_duration, max_duration, min_release_date, max_release_date,
    min_play_date, max_play_date, not_played_movie_only]);
  db.query(sql, [req.session.username, movie_name, min_duration, max_duration, min_release_date, max_release_date,
    min_play_date, max_play_date, not_played_movie_only], (error, results) => {
    if (results == undefined || results.affectedRows == 0) {
      console.log("Invalid input to filter movies in theater!");
      console.log(results);
      res.redirect('/functionality/theater_overview.html');
    } else {
      let sqlResults = 'SELECT * FROM ManFilterTh';
      db.query(sqlResults, (error, results) => {
        res.redirect('/functionality/theater_overview.html?'+JSON.stringify(results));  //Terrible Terrible way of doing things but what can you do XD
      });
    }
  });
});

app.post("/explore_movie", (req, res) => {
  var {movName, comName, city, state, min_play_date, max_play_date} = req.body;
  if(min_play_date=='') {
    min_play_date='1000-01-01';
  }
  if(max_play_date=='') {
    max_play_date = '9999-01-01';
  }
  var mov_name, com_name;
  if (movName=="ALL") {
    mov_name = movName;
    let sqlGetCompanyName = 'SELECT comName FROM company';
    db.query(sqlGetCompanyName, (error, results) => {
      com_name = results[comName].comName;
      let sql = 'CALL customer_filter_mov(?, ?, ?, ?, ?, ?)';
      db.query(sql, [mov_name, com_name, city, state, min_play_date, max_play_date], (error, results) => {
        if (results == undefined) {
          console.log("Invalid input to filter movie!");
        }
      });
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
        db.query(sql, [mov_name, com_name, city, state, min_play_date, max_play_date], (error, results) => {
          if (results == undefined) {
            console.log("Invalid input to filter movie!");
          }
        });
        let sqlResults = 'SELECT * FROM CosFilterMovie';
        db.query(sqlResults, (error, results) => {
          res.redirect('/functionality/explore_movie.html?' + JSON.stringify(results));
        });
      });
    });
  }
});

app.post('/explore_theater', (req,  res)=> {
  var {thName, comName, city, state} = req.body;
  var th_name, com_name;
  if (thName=="ALL") {
    th_name = thName;
    let sqlGetCompanyName = 'SELECT comName FROM company';
    db.query(sqlGetCompanyName, (error, results) => {
      com_name = results[comName].comName;
      let sql = 'CALL user_filter_th(?, ?, ?, ?)';
      db.query(sql, [th_name, com_name, city, state], (error, results) => {
        if (results == undefined) {
          console.log("Invalid input to filter theater!");
        }
      });
      let sqlResults = 'SELECT * FROM UserFilterTh';
      db.query(sqlResults, (error, results) => {
        res.redirect('/functionality/explore_theater.html?' + JSON.stringify(results));
      });
    });
  } else {
    let sqlGetMovieName = 'SELECT thName FROM theater';
    db.query(sqlGetMovieName, (error, results) => {
      th_name = results[thName].thName;
      let sqlGetCompanyName = 'SELECT comName FROM company';
      db.query(sqlGetCompanyName, (error, results) => {
        com_name = results[comName].comName;
        let sql = 'CALL user_filter_th(?, ?, ?, ?)';
        db.query(sql, [th_name, com_name, city, state], (error, results) => {
          if (results == undefined) {
            console.log("Invalid input to filter theater!");
          }
        });
        let sqlResults = 'SELECT * FROM UserFilterTh';
        db.query(sqlResults, (error, results) => {
          res.redirect('/functionality/explore_theater.html?' + JSON.stringify(results));
        });
      });
    });
  }
});

app.post('/visit_history', (req, res)=> {
  var {comName, min_visit_date, max_visit_date} = req.body;
  if(min_visit_date=='') {
    min_visit_date='1000-01-01';
  }
  if(max_visit_date=='') {
    max_visit_date = '9999-01-01';
  }
  var com_name;
  let sqlGetCompanyName = 'SELECT comName FROM company';
  db.query(sqlGetCompanyName, (error, results) => {
    com_name = results[comName].comName;
    const sql = 'CALL user_filter_visitHistory(?, ?, ?)';
    db.query(sql, [req.session.username, min_visit_date, max_visit_date], (error, req) =>{
      if (results == undefined) {
        console.log("Invalid input to filter visit history!");
      }
    });
    const sqlResults = "SELECT * FROM UserVisitHistory WHERE comName=\""+com_name+"\"";
    db.query(sqlResults, (error, results)=> {
      res.redirect('/functionality/visit_history.html?' + JSON.stringify(results));
    });
  });
});

app.post('/manage_user', (req, res) => {
  var {username, status, sortBy, sortDir} = req.body;
  let sql = 'CALL admin_filter_user(?, ?, ?, ?)';
  db.query(sql, [username, status, sortBy, sortDir], (error, results) => {});
  let sqlResults = 'SELECT * FROM AdFilterUser';
  db.query(sqlResults, (error, results) => {
    res.redirect('/functionality/manage_user.html?' + JSON.stringify(results));
  });
});

app.post('/manage_company', (req, res) => {
  var {comName, min_city, max_city, min_theater, max_theater, min_employee, max_employee, sortBy, sortDir} = req.body;
  var com_name;
  if (min_city == '') {
    min_city = 0;
  }
  if (min_theater == '') {
    min_theater = 0;
  }
  if (min_employee == '') {
    min_employee = 0;
  }
  if (max_city == '') {
    max_city = ""+10000;
  }
  if (max_theater == '') {
    max_theater = ""+10000;
  }
  if (max_employee == '') {
    max_employee = ""+100000000;
  }
  if (comName == "ALL") {
    com_name = comName;
    let sql = 'CALL admin_filter_company(?, ?, ?, ?, ?, ?, ?, ?, ?)';
    db.query(sql, [com_name, min_city, max_city, min_theater, max_theater, min_employee, max_employee, sortBy, sortDir], (error, results) => {
      if (results == undefined) {
        console.log("Invalid input to filter company!");
      }
    });
    let sqlResults = 'SELECT * FROM AdFilterCom';
    db.query(sqlResults, (error, results) => {
      res.redirect('/functionality/manage_company.html?' + JSON.stringify(results));
    });
  } else {
    let sqlGetCompanyName = 'SELECT comName FROM company';
    db.query(sqlGetCompanyName, (error, results) => {
      com_name = results[comName].comName;
      let sql = 'CALL admin_filter_company(?, ?, ?, ?, ?, ?, ?, ?, ?)';
      db.query(sql, [com_name, min_city, max_city, min_theater, max_theater, min_employee, max_employee, sortBy, sortDir], (error, results) => {
      });
      let sqlResults = 'SELECT * FROM AdFilterCom';
      db.query(sqlResults, (error, results) => {
        res.redirect('/functionality/manage_company.html?' + JSON.stringify(results));
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

app.get('/theaterList/', (req, res)=> {
  let sql = 'SELECT thName FROM theater';
  db.query(sql, (error, results)=> {
    res.json(results);
  });
});

app.get('/managerList/', (req, res)=> {
  let sql = 'SELECT User.firstname, User.lastname FROM user WHERE username IN (SELECT username FROM manager WHERE comName = "4400 Theater Company") AND username NOT IN (SELECT manUsername FROM theater)';
  db.query(sql, (error, results)=> {
    res.json(results);
  });
});

app.get('/managerList/:resetInd', (req, res)=> {
  var com_name;
  let sqlGetCompanyName = 'SELECT comName FROM company';
  db.query(sqlGetCompanyName, (error, results) => {
    com_name = results[req.params.resetInd].comName;
    let sql = 'SELECT User.firstname, User.lastname FROM user WHERE username IN (SELECT username FROM manager WHERE comName = "'+com_name+'") AND username NOT IN (SELECT manUsername FROM theater)';
    db.query(sql, (error, results)=> {
      res.json(results);
    });
  });
});

app.get('/viewHistory', (req, res)=> {
  let sql = "CALL customer_view_history(?)";
  db.query(sql, [req.session.username], (error, results)=> {});
  let sqlResults = "SELECT * FROM CosViewHistory"
  db.query(sqlResults, (error, results)=>{
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
      if (results == undefined) {
        console.log("Invalid input to schedule movie!");
      }
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
    let sqlGetRowData = 'SELECT * FROM CosFilterMovie';
    db.query(sqlGetRowData, (error, results) => {
      if (row < results.length && row >= 0) {
        var row_data = results[row];
        let sql = 'CALL customer_view_mov(?, ?, ?, ?, ?, ?)';
        db.query(sql, [view_creditCard, row_data.movName, row_data.movReleaseDate, row_data.thName,
          row_data.comName, row_data.movPlayDate], (error, results)=> {
          res.redirect("/functionality/explore_movie.html");
        });
      } else {
        console.log("Invalid row selected!");
      }
    });
  });
});

app.post('/visit_theater', (req, res) => {
  var {row, visitDate} = req.body;

  let sqlGetRowData = 'SELECT * FROM UserFilterTh';
  db.query(sqlGetRowData, (error, results) => {
    if (row < results.length && row >= 0) {
      var row_data = results[row];
      let sql = 'CALL user_visit_th(?, ?, ?, ?)';
      db.query(sql, [row_data.thName, row_data.comName, visitDate, req.session.username], (error, results)=> {
        if (results == undefined) {
          console.log("Invalid input to log visit!");
        }
        res.redirect("/functionality/explore_theater.html");
      });
    } else {
      console.log("Invalid row selected!")
    }
  });
});

app.post('/affect_user', (req, res) => {
  var {username, accept, decline} = req.body;
  if (accept == "true") {
    const sql = 'CALL admin_approve_user(?)';
    db.query(sql, [username], (error, results) => {});
  } else {
    const sql = 'CALL admin_decline_user(?)';
    db.query(sql, [username], (error, results) => {});
  }
  res.redirect('/functionality/manage_user.html');
});

app.post('/detail_company', (req, res) => {
  var {comName} = req.body;
  comName = comName.trim();
  var sql = 'CALL admin_view_comDetail_emp(?)';
  db.query(sql, [comName], (error, results) => {});
  sql = 'CALL admin_view_comDetail_th(?)';
  db.query(sql, [comName], (error, results) => {});
  var emp, th;
  sql = 'SELECT * FROM AdComDetailEmp';
  db.query(sql, (error, results) => {
    emp = JSON.stringify(results);
    sql = 'SELECT * FROM AdComDetailTh';
    db.query(sql, (error, results) => {
      th = JSON.stringify(results);
      const stringAppend = '[' + '{"comName":"' + comName + '"},' + emp + ',' + th + ']';
      res.redirect('/functionality/company_detail.html?'+stringAppend);
    });
  });
});

app.post('/create_theater', (req, res)=> {
  var {name, comName, address, city, state, zipcode, capacity, manIndex} = req.body;
  var com_name, manUsername;
  let sqlGetCompanyName = 'SELECT comName FROM company';
  db.query(sqlGetCompanyName, (error, results) => {
    com_name = results[comName].comName;
    let getManUserSQL = 'SELECT username FROM manager WHERE username NOT IN (SELECT manUsername FROM theater) AND comName="'+com_name+'"';
    db.query(getManUserSQL, (error, results) => {
      manUsername = results[manIndex].username;
      let sql = "CALL admin_create_theater(?, ?, ?, ?, ?, ?, ?, ?)";
      db.query(sql, [name, com_name, address, city, state, zipcode, capacity, manUsername], (error, results)  => {
        if (results == undefined || results.affectedRows == 0) {
          console.log("Invalid input to create theater!");
        }
        res.redirect('/functionality/create_theater.html');
      });
    });
  });
});

app.post('/create_movie', (req, res) => {
  const {name, duration, release_date}=req.body;
  let sql = 'CALL admin_create_mov(?, ?, ?)';
  db.query(sql, [name, duration, release_date], (error, results) => {
    if (results == undefined) {
      console.log("Invalid input to create movie!");
    }
    res.redirect('/functionality/create_movie.html');
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
  let { fname, lname, username, password, confirm } = req.body;
  let sql = 'CALL user_register(?, ?, ?, ?)';

  if (password === confirm && password.length >= 8) {
    db.query(sql, [username, password, fname, lname], (error, results) => {
      if (results.affectedRows > 0){
        console.log("Successful Registration");
        res.redirect('/');
      } else
        res.redirect('/registration/user.html');
    });
  } else {
    res.redirect('/registration/user.html');
  }
});

app.post('/register_manager', (req, res) => {
  let { fname, lname, username, comName, password, confirm, address, city, state, zipcode } = req.body;
  var com_name;
  let sqlGetCompanyName = 'SELECT comName FROM company';
  db.query(sqlGetCompanyName, (error, results) => {
    com_name = results[comName].comName;
    let sql = 'CALL manager_only_register(?, ?, ?, ?, ?, ?, ?, ?, ?)';
    if (password === confirm && password.length >= 8 && zipcode.length == 5) {
      console.log([username, password, fname, lname, com_name, address, city, state, zipcode]);
      db.query(sql, [username, password, fname, lname, com_name, address, city, state, zipcode], (error, results) => {
        if (results == undefined) {
          console.log("Invalid input to Manager-Only Registration!");
          res.redirect('/registration/manager.html');
        } else {
          if (results.affectedRows > 0) {
            console.log("Successful Registration");
            res.redirect('/');
          } else
            res.redirect('/registration/manager.html');
        }
      });
    } else {
      res.redirect('/registration/manager.html');
    }
  });
});

app.post('/register_manager_customer', (req, res) => {
  let {fname, lname, username, comName, password, confirm, address, city, state, zipcode, credit1, credit2, credit3, credit4, credit5} = req.body;
  var com_name;
  let sqlGetCompanyName = 'SELECT comName FROM company';
  var credits = [false, false, false, false, false];
  let checkIsUnique = 'SELECT creditCardNum FROM customercreditcard WHERE creditCardNum='+credit1;
  db.query(checkIsUnique, (error, results)=> {
    if (results == undefined || results.affectedRows > 0) {
      console.log("Inputted 1st Credit Card # is already registered!");
      res.redirect('/registration/customer.html');
    } else {
      credits[0] = credit1.length == 16 && isValidCreditCardNum(credit1);
      checkIsUnique = 'SELECT creditCardNum FROM customercreditcard WHERE creditCardNum='+credit2;
      db.query(checkIsUnique, (error, results)=> {
        if (results == undefined || results.affectedRows > 0) {
          console.log("Inputted 2nd Credit Card # is already registered!");
          if (credit2.length == 16 && isValidCreditCardNum(credit2)) {
            res.redirect('/registration/customer.html');
          }
        } else {
          credits[1] = credit2.length == 16 && isValidCreditCardNum(credit2);
        }
        checkIsUnique = 'SELECT creditCardNum FROM customercreditcard WHERE creditCardNum='+credit3;
        db.query(checkIsUnique, (error, results)=> {
          if (results == undefined || results.affectedRows > 0) {
            console.log("Inputted 3rd Credit Card # is already registered!");
            if (credit3.length == 16 && isValidCreditCardNum(credit3)) {
              res.redirect('/registration/customer.html');
            }
          } else {
            credits[2] = credit3.length == 16 && isValidCreditCardNum(credit3);
          }
          checkIsUnique = 'SELECT creditCardNum FROM customercreditcard WHERE creditCardNum='+credit4;
          db.query(checkIsUnique, (error, results)=> {
            if (results == undefined || results.affectedRows > 0) {
              console.log("Inputted 4th Credit Card # is already registered!");
              if (credit4.length == 16 && isValidCreditCardNum(credit4)) {
                res.redirect('/registration/customer.html');
              }
            } else {
              credits[3] = credit4.length == 16 && isValidCreditCardNum(credit4);
            }
            checkIsUnique = 'SELECT creditCardNum FROM customercreditcard WHERE creditCardNum='+credit5;
            db.query(checkIsUnique, (error, results)=> {
              if (results == undefined || results.affectedRows > 0) {
                console.log("Inputted 5th Credit Card # is already registered!");
                if (credit5.length == 16 && isValidCreditCardNum(credit5)) {
                  res.redirect('/registration/customer.html');
                }
              } else {
                credits[4] = credit5.length == 16 && isValidCreditCardNum(credit5);
              }
              db.query(sqlGetCompanyName, (error, results) => {
                com_name = results[comName].comName;
                let sql = 'CALL manager_customer_register(?, ?, ?, ?, ?, ?, ?, ?, ?)';
                if (password === confirm && password.length >= 8 && zipcode.length == 5 && credits[0]) {
                  db.query(sql, [username, password, fname, lname, com_name, address, city, state, zipcode], (error, results) => {
                    if (results == undefined) {
                      console.log("Invalid input to Manager-Customer Registration!");
                      res.redirect('/registration/manager-customer.html');
                    } else {
                      if (results.affectedRows > 0) {
                        var addCreditCard = 'CALL manager_customer_add_creditcard(?, ?)';
                        db.query(addCreditCard, [username, credit1], (error, results) => {
                          console.log(results);
                          if (results == undefined) {
                            console.log('Invalid Inputted Credit Card Number!');
                          }
                        });
                        if (credits[1]) {
                          db.query(addCreditCard, [username, credit2], (error, results) => {
                            if (results == undefined) {
                              console.log('Invalid Inputted Credit Card Number!');
                            }
                          });
                        }
                        if (credits[2]) {
                          db.query(addCreditCard, [username, credit3], (error, results) => {
                            if (results == undefined) {
                              console.log('Invalid Inputted Credit Card Number!');
                            }
                          });
                        }
                        if (credits[3]) {
                          db.query(addCreditCard, [username, credit4], (error, results) => {
                            if (results == undefined) {
                              console.log('Invalid Inputted Credit Card Number!');
                            }
                          });
                        }
                        if (credits[4]) {
                          db.query(addCreditCard, [username, credit5], (error, results) => {
                            if (results == undefined) {
                              console.log('Invalid Inputted Credit Card Number!');
                            }
                          });
                        }
                        console.log("Successful Registration");
                        res.redirect('/');
                      } else {
                        console.log('Invalid Input to Manager-Customer Registration!');
                        res.redirect('/registration/manager-customer.html');
                      }
                    }
                  });
                } else {
                  console.log('Invalid Input to Manager-Customer Registration! Make sure that the 1st Credit Card # is valid!');
                  res.redirect('/registration/manager-customer.html');
                }
              });
            });
          });
        });
      });
    }
  });
});

app.post('/register_customer', (req, res) => {
  let {fname, lname, username, password, confirm, credit1, credit2, credit3, credit4, credit5} = req.body;
  var credits = [false, false, false, false, false];
  let checkIsUnique = 'SELECT creditCardNum FROM customercreditcard WHERE creditCardNum='+credit1;
  db.query(checkIsUnique, (error, results)=> {
    if (results == undefined || results.affectedRows > 0) {
      console.log("Inputted 1st Credit Card # is already registered!");
      res.redirect('/registration/customer.html');
    } else {
      credits[0] = credit1.length == 16 && isValidCreditCardNum(credit1);
      checkIsUnique = 'SELECT creditCardNum FROM customercreditcard WHERE creditCardNum='+credit2;
      db.query(checkIsUnique, (error, results)=> {
        if (results == undefined || results.affectedRows > 0) {
          console.log("Inputted 2nd Credit Card # is already registered!");
          if (credit2.length == 16 && isValidCreditCardNum(credit2)) {
            res.redirect('/registration/customer.html');
          }
        } else {
          credits[1] = credit2.length == 16 && isValidCreditCardNum(credit2);
        }
        checkIsUnique = 'SELECT creditCardNum FROM customercreditcard WHERE creditCardNum='+credit3;
        db.query(checkIsUnique, (error, results)=> {
          if (results == undefined || results.affectedRows > 0) {
            console.log("Inputted 3rd Credit Card # is already registered!");
            if (credit3.length == 16 && isValidCreditCardNum(credit3)) {
              res.redirect('/registration/customer.html');
            }
          } else {
            credits[2] = credit3.length == 16 && isValidCreditCardNum(credit3);
          }
          checkIsUnique = 'SELECT creditCardNum FROM customercreditcard WHERE creditCardNum='+credit4;
          db.query(checkIsUnique, (error, results)=> {
            if (results == undefined || results.affectedRows > 0) {
              console.log("Inputted 4th Credit Card # is already registered!");
              if (credit4.length == 16 && isValidCreditCardNum(credit4)) {
                res.redirect('/registration/customer.html');
              }
            } else {
              credits[3] = credit4.length == 16 && isValidCreditCardNum(credit4);
            }
            checkIsUnique = 'SELECT creditCardNum FROM customercreditcard WHERE creditCardNum='+credit5;
            db.query(checkIsUnique, (error, results)=> {
              if (results == undefined || results.affectedRows > 0) {
                console.log("Inputted 5th Credit Card # is already registered!");
                if (credit5.length == 16 && isValidCreditCardNum(credit5)) {
                  res.redirect('/registration/customer.html');
                }
              } else {
                credits[4] = credit5.length == 16 && isValidCreditCardNum(credit5);
              }
              let sql = 'CALL customer_only_register(?, ?, ?, ?)';
              if (password === confirm && password.length >= 8 && credits[0]) {
                db.query(sql, [username, password, fname, lname], (error, results) => {
                  if (results == undefined) {
                    console.log("Invalid input to Customer-Only Registration!");
                    res.redirect('/registration/customer.html');
                  } else {
                    if (results.affectedRows > 0) {
                      var addCreditCard = 'CALL manager_customer_add_creditcard(?, ?)';
                      db.query(addCreditCard, [username, credit1], (error, results) => {
                        console.log(results);
                        if (results == undefined) {
                          console.log('Invalid Inputted Credit Card Number!');
                        }
                      });
                      if (credits[1]) {
                        db.query(addCreditCard, [username, credit2], (error, results) => {
                          if (results == undefined) {
                            console.log('Invalid Inputted Credit Card Number!');
                          }
                        });
                      }
                      if (credits[2]) {
                        db.query(addCreditCard, [username, credit3], (error, results) => {
                          if (results == undefined) {
                            console.log('Invalid Inputted Credit Card Number!');
                          }
                        });
                      }
                      if (credits[3]) {
                        db.query(addCreditCard, [username, credit4], (error, results) => {
                          if (results == undefined) {
                            console.log('Invalid Inputted Credit Card Number!');
                          }
                        });
                      }
                      if (credits[4]) {
                        db.query(addCreditCard, [username, credit5], (error, results) => {
                          if (results == undefined) {
                            console.log('Invalid Inputted Credit Card Number!');
                          }
                        });
                      }
                      console.log("Successful Registration. Ignore errors directly above^");
                      res.redirect('/');
                    } else {
                      console.log('Invalid Input to Customer-Only Registration!');
                      res.redirect('/registration/customer.html');
                    }
                  }
                });
              } else {
                console.log('Invalid Input to Customer-Only Registration! Make sure that the 1st Credit Card # is valid!');
                res.redirect('/registration/customer.html');
              }
            });
          });
        });
      });
    }
  });
});

function isValidCreditCardNum(creditCardNum) {
  for (var i = 0; i < creditCardNum.length; i++) {
    if(isNaN(creditCardNum.charAt(i))) {
      return false;
    }
  }
  return true;
}