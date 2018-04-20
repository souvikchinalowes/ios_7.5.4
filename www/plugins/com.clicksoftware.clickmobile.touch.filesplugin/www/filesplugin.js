cordova.define("com.clicksoftware.clickmobile.touch.filesplugin.FilesPlugin", function(require, exports, module) {
cordova.define("com.clicksoftware.clickmobile.touch.FilesPlugin.filesplugin", function (require, exports, module) {
    var exec = require('cordova/exec');

    var FilesPlugin = function () {
    };

	FilesPlugin.prototype.openWith = function (path, successCallback, errorCallback) {
//		if (errorCallback == null) { errorCallback = function () { } }
//        if (typeof errorCallback != "function") {
//            console.log("FilesPlugin.openWith failure: failure parameter not a function");
//            return
//        }

//        if (typeof successCallback != "function") {
//            console.log("FilesPlugin.openWith failure: success callback parameter must be a function");
//            return
//        }
		exec(successCallback, errorCallback, "FilesPlugin", "openWith", [path]);
	};

	FilesPlugin.prototype.writeBinaryData = function (fileName, data, position, successCallback, errorCallback) {
		if (errorCallback == null) { errorCallback = function () { } }
        if (typeof errorCallback != "function") {
            console.log("FilesPlugin.writeBinaryData failure: failure parameter not a function");
            return
        }

        if (typeof successCallback != "function") {
            console.log("FilesPlugin.writeBinaryData failure: success callback parameter must be a function");
            return
        }
		exec(successCallback, errorCallback, "FilesPlugin", "writeBinaryData", [fileName, data, position]);
	};

    if (!window.plugins) {
        window.plugins = {};
    }

    if (!window.plugins.FilesPlugin) {
        window.plugins.FilesPlugin = new FilesPlugin();
    }

    if (module.exports) {
        module.exports = FilesPlugin;
    }

});

});
