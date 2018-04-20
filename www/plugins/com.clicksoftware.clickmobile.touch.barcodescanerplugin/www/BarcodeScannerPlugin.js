cordova.define("com.clicksoftware.clickmobile.touch.barcodescanerplugin.BarcodeScanerPlugin", function(require, exports, module) {
    var exec = require('cordova/exec');

     var BarcodeScannerPlugin = function () {
    };

    BarcodeScannerPlugin.prototype.scan = function (successCallback, errorCallback) {
        if (errorCallback == null) { errorCallback = function () { } }
        if (typeof errorCallback != "function") {
            console.log("BarcodeScannerPlugin.scanningBarcode failure: failure parameter not a function");
            return
        }

        if (typeof successCallback != "function") {
            console.log("BarcodeScannerPlugin.scanningBarcode failure: success callback parameter must be a function");
            return
        }
        exec(successCallback, errorCallback, "BarcodeScanerPlugin", "scanningBarcode", [""]);
    };

    if (!window.plugins) {
        window.plugins = {};
    }

    if (!window.plugins.barcodeScanner) {
        window.plugins.barcodeScanner = new BarcodeScannerPlugin();
    }

    if (module.exports) {
        module.exports = window.plugins.barcodeScanner;
    }

});
