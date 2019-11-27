const express = require('express');
const mysql = require('mysql');
const app = express();

// establishes connection to database
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'password',
  database: 'team73',
});

db.connect((error) => {
  if (error) {
    console.log("Database connection failed! 👇🏼");
    console.log(" > " + error.sqlMessage);
    process.exit(0);
  }
});

// ex: fetches password of a user given their username
app.get('/password/:username', (req, res) => {
  const sql = `SELECT password FROM user WHERE username = ?`;
  db.query(sql, [req.params.username], (error, result) => {
    for (let i = 0; i < result.length; i++)
      console.log(result[i].password);
  });
  res.end();
});

app.listen('3000', () => {
  console.log('CS4400: Atlanta Movie Project 🎉\n');
});
