cordova.define("com.clicksoftware.clickmobile.touch.PNPlugin.PNPlugin", function(require, exports, module) {
var exec = require('cordova/exec');

var PushNotification = function() {
};

PushNotification.prototype.register = function(successCallback, errorCallback, options) {
    if (errorCallback == null) { errorCallback = function() {}}

    if (typeof errorCallback != "function")  {
        console.log("PushNotification.register failure: failure parameter not a function");
        return;
    }

    if (typeof successCallback != "function") {
        console.log("PushNotification.register failure: success callback parameter must be a function");
        return;
    }

	exec(successCallback, errorCallback, "PNPlugin", "register", [options]);
};

PushNotification.prototype.unregister = function(successCallback, errorCallback) {
    if (errorCallback == null) { errorCallback = function() {}}

    if (typeof errorCallback != "function")  {
        console.log("PushNotification.unregister failure: failure parameter not a function");
        return;
    }

    if (typeof successCallback != "function") {
        console.log("PushNotification.unregister failure: success callback parameter must be a function");
        return;
    }

     exec(successCallback, errorCallback, "PNPlugin", "unregister", []);
};
 
 
PushNotification.prototype.setApplicationIconBadgeNumber = function(successCallback, errorCallback, badge) {
    if (errorCallback == null) { errorCallback = function() {}}

    if (typeof errorCallback != "function")  {
        console.log("PushNotification.setApplicationIconBadgeNumber failure: failure parameter not a function");
        return;
    }

    if (typeof successCallback != "function") {
        console.log("PushNotification.setApplicationIconBadgeNumber failure: success callback parameter must be a function");
        return;
    }

    exec(successCallback, errorCallback, "PNPlugin", "setApplicationIconBadgeNumber", [{badge: badge}]);
};

if(!window.plugins) {
    window.plugins = {};
}
if (!window.plugins.pushNotification) {
    window.plugins.pushNotification = new PushNotification();
}

if (module.exports) {
  module.exports = PushNotification;
}

});
