cordova.define("com.clicksoftware.clickmobile.touch.runninginbackgroundplugin.RunningInBackgroundPlugin", function(require, exports, module) {
    var exec = require('cordova/exec');

     var RunningInBackgroundPlugin = function () {
     };

    RunningInBackgroundPlugin.prototype.getGpsMode = function (successCallback, errorCallback) {
        if (errorCallback == null) { errorCallback = function () { } }
        if (typeof errorCallback != "function") {
            console.log("RunningInBackgroundPlugin failure: failure parameter not a function");
            return
        }

        if (typeof successCallback != "function") {
            console.log("RunningInBackgroundPlugin failure: success callback parameter must be a function");
            return
        }
        exec(successCallback, errorCallback, "RunningInBackground", "getGpsMode", [""]);
    };

    RunningInBackgroundPlugin.prototype.setPhonegapKeepRunning = function (successCallback, errorCallback) {
        if (errorCallback == null) { errorCallback = function () { } }
        if (typeof errorCallback != "function") {
            console.log("RunningInBackgroundPlugin failure: failure parameter not a function");
            return
        }

        if (typeof successCallback != "function") {
            console.log("RunningInBackgroundPlugin failure: success callback parameter must be a function");
            return
        }
        exec(successCallback, errorCallback, "RunningInBackground", "setPhonegapKeepRunning", [""]);
    };

    if (!window.plugins) {
        window.plugins = {};
    }

    if (!window.plugins.RunningInBackground) {
        window.plugins.RunningInBackground = new RunningInBackgroundPlugin();
    }

    if (module.exports) {
        module.exports = window.plugins.RunningInBackground;
    }

});
