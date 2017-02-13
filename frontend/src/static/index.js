'use strict';

require('./styles/index.css')

var Elm = require('../elm/Main.elm');
var mountNode = document.getElementById('main');

var app = Elm.Main.embed(mountNode);

//fileRequest = require('../js/filerequest');
