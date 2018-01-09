;(() => {
  'use strict';

  const express      = require('express');
  const bodyParser   = require('body-parser');
  const cookieParser = require('cookie-parser');
  const path         = require('path');
  const logger       = require('morgan');
  const process      = require('process');
  const http         = require('http');
  const https        = require('https');
  const port         = process.env.PORT || 8000;
  const KOMODO_DB    = process.env.KOMODO_DB;
  const MongoClient  = require('mongodb').MongoClient;
  const assert       = require('assert')
  const fs           = require('fs')
  const cors         = require('cors')
  const app = express();

  const config = {
    key: fs.readFileSync('key.pem'),
    cert: fs.readFileSync('cert.pem')
  }

  const server = http.createServer(app);
  const httpsServer = https.createServer(config, app);

  const io = require('socket.io')(httpsServer)
  io.set('transports', ['websocket', 'polling'])

  MongoClient.connect(`mongodb://localhost:27017/${KOMODO_DB}`, function (err, db) {
    assert.equal(err, null)

    const cleanup = (exit_code) => {
      db.close()
      process.exit(exit_code)
    };

    process.on('exit', () => cleanup(0));
    process.on('SIGINT', () => cleanup(0));
    process.on('uncaughtException', () => cleanup(1));

    const api = require('./api')(db, io);

    app.use(logger('dev'))
      .use(bodyParser.json())
      .use(cors({ origin: 'http://localhost:8080' }))
      .use(cookieParser())
      .use(bodyParser.urlencoded({ extended: false }))
      .use('/api/', api)
      .set('port', port)
  });
  httpsServer.listen(443)
  console.log(`Serving on port 8080 and 443`);
})();
