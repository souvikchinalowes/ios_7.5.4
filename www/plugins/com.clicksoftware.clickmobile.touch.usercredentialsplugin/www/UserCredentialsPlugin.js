cordova.define("com.clicksoftware.clickmobile.touch.usercredentialsplugin.UserCredentialsPlugin", function(require, exports, module) {
cordova.define("com.clicksoftware.clickmobile.touch.usercredentialsplugin.usercredentialsplugin", function(require, exports, module) { cordova.define("com.clicksoftware.clickmobile.touch.usercredentialsplugin.usercredentialsplugin", function (require, exports, module) {
    var exec = require('cordova/exec');

    var UserCredentialsPlugin = function () {
    };

    UserCredentialsPlugin.prototype.setUserCredentials = function (successCallback, errorCallback, _userName, _deviceType, _deviceID) {
        if (errorCallback == null) { errorCallback = function () { } }
        if (typeof errorCallback != "function") {
            console.log("UserCredentialsPlugin.setUserCredentials failure: failure parameter not a function");
            return
        }

        if (typeof successCallback != "function") {
            console.log("UserCredentialsPlugin.setUserCredentials failure: success callback parameter must be a function");
            return
        }
        exec(successCallback, errorCallback, "UserCredentialsPlugin", "setUserCredentials", [{ userName: _userName, deviceType: _deviceType, deviceID: _deviceID}]);
    };

    if (!window.plugins) {
        window.plugins = {};
    }

    if (!window.plugins.userCredentialsPlugin) {
        window.plugins.userCredentialsPlugin = new UserCredentialsPlugin();
    }

    if (module.exports) {
        module.exports = UserCredentialsPlugin;
    }

});
});

});
