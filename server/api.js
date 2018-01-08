'use strict';

const express = require('express');
const router = new express.Router();
const crypto = require('crypto');

const { ObjectID } = require('mongodb');
const assert = require('assert');

const request = require('request');
const jwt = require('jsonwebtoken');

const apiKey = process.env.COLLABO_API_KEY;
const jwtSecret = process.env.COLLABO_JWT_SECRET || 'secret';

module.exports = function (db, io) {

};
