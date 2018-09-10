var argscheck = require('cordova/argscheck'),
utils = require('cordova/utils'),
exec = require('cordova/exec');

var PLUGIN_NAME = "PassRecording";

var PassRecording = function() {};

function isFunction(obj) {
    return !!(obj && obj.constructor && obj.call && obj.apply);
};



PassRecording.passRecordingMethod = function(onSuccess, onError) {
    exec(onSuccess, onError, PLUGIN_NAME, "passRecordingMethod", []);
};



module.exports = PassRecording;