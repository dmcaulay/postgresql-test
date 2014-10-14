var async = require('async');
var pg = require('pg');

var conString = "postgres://localhost/json_test";

pg.connect(conString, function(err, client, release) {
  if (err) return console.error('error fetching client from pool', err);

  var handleErr = function(log, err) { 
    release();
    console.log(log, err);
  };

  var create = "CREATE TABLE IF NOT EXISTS books ( id SERIAL PRIMARY KEY, data json )";
  client.query(create, function(err) {
    if (err) return handleErr('error creating the table', err);

    var books = [
      {name: "Book the First", author: {first_name: "Bob", last_name: "White" } },
      {name: "Book the Second", author: {first_name: "Charles", last_name: "Xavier" } },
      {name: "Book the Third", author: {first_name: "Jim", last_name: "Brown" } }
    ];

    async.each(books, function(book, callback) {
      client.query("INSERT INTO books (data) VALUES ($1)", [book], callback);
    }, function(err) {
      if (err) return handleErr('error inserting book', err);
      client.query("SELECT id, data->'author'->>'first_name' as author_first_name FROM books", function(err, result) {
        if (err) return handleErr('error selecting books', err);
        release();
        console.log(result.rows);
      });
    });
  });
});

