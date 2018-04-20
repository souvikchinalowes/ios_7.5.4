cordova.define("com.clicksoftware.clickmobile.touch.localpushnotificationplugin.LocalPushNotificationPlugin", function(require, exports, module) {
cordova.define("com.clicksoftware.clickmobile.touch.localpushnotificationplugin.localpushnotificationplugin", function(require, exports, module) { cordova.define("com.clicksoftware.clickmobile.touch.localpushnotificationplugin.localpushnotificationplugin", function (require, exports, module) {
    var exec = require('cordova/exec');

    var LocalPushNotificationPlugin = function () {
    };

	LocalPushNotificationPlugin.prototype.lPNSSetMaxmimumNumberOfNotificationID = function (options, successCallback, errorCallback) {
		if (errorCallback == null) { errorCallback = function () { } }
        if (typeof errorCallback != "function") {
            console.log("LocalPushNotificationPlugin.lPNSSetMaxmimumNumberOfNotificationID failure: failure parameter not a function");
            return
        }

        if (typeof successCallback != "function") {
            console.log("LocalPushNotificationPlugin.lPNSSetMaxmimumNumberOfNotificationID failure: success callback parameter must be a function");
            return
        }
		
		var params = [options];
		
		exec(successCallback, errorCallback, "LocalPushNotificationPlugin", "lPNSSetMaxmimumNumberOfNotificationID", params);
	};

	LocalPushNotificationPlugin.prototype.lPNSCreateNewNotification = function (options, successCallback, errorCallback) {
		if (errorCallback == null) { errorCallback = function () { } }
        if (typeof errorCallback != "function") {
            console.log("LocalPushNotificationPlugin.lPNSCreateNewNotification failure: failure parameter not a function");
            return
        }

        if (typeof successCallback != "function") {
            console.log("LocalPushNotificationPlugin.lPNSCreateNewNotification failure: success callback parameter must be a function");
            return
        }
		
		var params = [];

		params.push(options[0]); // id
		params.push(options[1] || "message"); // message
		//params.push(options[2] || "subtitle"); // subtitle
		params.push(options[2] || "ticker"); // ticker
		params.push(options[3]); //minutes
		params.push(options[4]); //context
		params.push(options[5]); //created DateTime 
		
		exec(successCallback, errorCallback, "LocalPushNotificationPlugin", "lPNSCreateNewNotification", params);
	};
	
	LocalPushNotificationPlugin.prototype.lPNSCancelSpecificNotification = function (options, successCallback, errorCallback) {
		if (errorCallback == null) { errorCallback = function () { } }
        if (typeof errorCallback != "function") {
            console.log("LocalPushNotificationPlugin.lPNSCancelSpecificNotification failure: failure parameter not a function");
            return
        }

        if (typeof successCallback != "function") {
            console.log("LocalPushNotificationPlugin.lPNSCancelSpecificNotification failure: success callback parameter must be a function");
            return
        }
		
		var params = [options];
		
		exec(successCallback, errorCallback, "LocalPushNotificationPlugin", "lPNSCancelSpecificNotification", params);
	};

	LocalPushNotificationPlugin.prototype.lPNSCancelAllNotifications = function (options, successCallback, errorCallback) {
		if (errorCallback == null) { errorCallback = function () { } }
        if (typeof errorCallback != "function") {
            console.log("LocalPushNotificationPlugin.lPNSCancelAllNotifications failure: failure parameter not a function");
            return
        }

        if (typeof successCallback != "function") {
            console.log("LocalPushNotificationPlugin.lPNSCancelAllNotifications failure: success callback parameter must be a function");
            return
        }
		
		var params = [];
		params.push(options[0]);
		params.push(options[1]);
		
		exec(successCallback, errorCallback, "LocalPushNotificationPlugin", "lPNSCancelAllNotifications", params);
	};

	LocalPushNotificationPlugin.prototype.lPNSGetAllPendingNotifications = function (options, successCallback, errorCallback) {
		if (errorCallback == null) { errorCallback = function () { } }
        if (typeof errorCallback != "function") {
            console.log("LocalPushNotificationPlugin.lPNSGetAllPendingNotifications failure: failure parameter not a function");
            return
        }

        if (typeof successCallback != "function") {
            console.log("LocalPushNotificationPlugin.lPNSGetAllPendingNotifications failure: success callback parameter must be a function");
            return
        }
		
		var params = [];
		params.push(options[0]);
		params.push(options[1]);
		
		exec(successCallback, errorCallback, "LocalPushNotificationPlugin", "lPNSGetAllPendingNotifications", params);
	};

	LocalPushNotificationPlugin.prototype.lPNSGetUnusedIdsList = function (successCallback, errorCallback) {
		if (errorCallback == null) { errorCallback = function () { } }
        if (typeof errorCallback != "function") {
            console.log("LocalPushNotificationPlugin.lPNSGetUnusedIdsList failure: failure parameter not a function");
            return
        }

        if (typeof successCallback != "function") {
            console.log("LocalPushNotificationPlugin.lPNSGetUnusedIdsList failure: success callback parameter must be a function");
            return
        }
		
		exec(successCallback, errorCallback, "LocalPushNotificationPlugin", "lPNSGetUnusedIdsList", [""]);
	};

    if (!window.plugins) {
        window.plugins = {};
    }

    if (!window.plugins.LocalPushNotificationPlugin) {
        window.plugins.LocalPushNotificationPlugin = new LocalPushNotificationPlugin();
    }

    if (module.exports) {
        module.exports = LocalPushNotificationPlugin;
    }

});
});

});
