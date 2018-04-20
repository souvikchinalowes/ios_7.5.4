cordova.define("com.clicksoftware.clickmobile.touch.settingsplugin.SettingsPlugin", function(require, exports, module) {
    var exec = require('cordova/exec');

     var SettingsPlugin = function () {
     };

    if (!window.plugins) {
        window.plugins = {};
    }

    if (!window.plugins.Settings) {
        window.plugins.Settings = new SettingsPlugin();
    }

    if (module.exports) {
        module.exports = window.plugins.Settings;
    }

});
