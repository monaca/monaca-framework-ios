/**
 * Monacaクラス
 * 
 *  require phonegap.js
 *
 * @author Hiroki NAKAGAWA <info@asial.co.jp>
 * @author Mitsunori KUBOTA <info@asial.co.jp>
 * @date   2011/12/21
 */
window.monaca = window.monaca || {ui : {}};

(function(PhoneGap) {
    var isAndroid = (/android/gi).test(navigator.appVersion);
    
    monaca.ui.updateStyle = function(id, name, value) {
        if (typeof id == "string") {
            PhoneGap.exec(function(a) { alert(a); } , function(a) { alert(a); }, "mobi.monaca.nativecomponent", "update", arguments);
        } else {
            for (var i = 0; i < id.length; i++) {
                PhoneGap.exec(null, null, "mobi.monaca.nativecomponent", "update", [id[i], name, value]);
            }
        }
    };
    
    monaca.ui.retrieveStyle = function() {
        PhoneGap.exec(arguments[arguments.length-1], null, "mobi.monaca.nativecomponent", "retrieve", arguments);
    };
    
    if (isAndroid) {
        monaca.ui.retrieveStyle = function(id, name, success, failure) {
            PhoneGap.exec(
                function(style) { success(style[name]); } || function() { }, 
                failure || function() { }, 
                "MonacaNativeUI", 
                "retrieve", 
                [id]
            );
        };
            
        monaca.ui.updateStyle = function(id, name, value, success, failure) {
            var style = {};
            style[name] = value;
            
            PhoneGap.exec(
                success || function() { }, 
                failure || function() { }, 
                "MonacaNativeUI", 
                "update", 
                [id, style]
            );
        };
        
        /** 
         * Do update bulkily the styles of native component's style.
         * 
         * Example:
         *  MonacaNativeUI.updateStyleBulkily([
         *      {
         *          ids : ["hoge", fuga"],
         *          style : {
         *              disable : true
         *          }
         *      },
         *      {
         *          id : "hoge",
         *          style : {
         *              text : "piyo"
         *          }
         *      }
         *  ], function() { ... });
         * 
         */
        monaca.ui.updateStyleBulkily = function(queries, success, failure) {
            for (var i = 0; i < queries.length; i++) {
                if (!queries[i].ids && queries[i].id) {
                    queries[i].ids = [queries[i].id];
                }
            }
            PhoneGap.exec(
                success || function() { }, 
                failure || function() { }, 
                "MonacaNativeUI", 
                "updateBulkily", 
                [queries]
            );
        };
        
        monaca.ui.info = function(success, failure) {
            PhoneGap.exec(
                success || function() { }, 
                failure || function() { }, 
                "MonacaNativeUI", 
                "info", 
                []
            );
        };
    }   
    
    /**
     * PhoneGapを用いた遷移クラス
     * 
     * @author Yoshiki NAKAGAWA <info@asial.co.jp>
     * @author Kazushi IGAWA <info@asial.co.jp>
     * @date   2011/11/17
     */
    monaca.transit = {
        namespace: "Transit",

        DEFAULT_BG_IMAGE: 'images/bg/webview/bgi.jpg',
        DEFAULT_BG_IMAGE_ANDROID: 'images/bg/webview/bga.png',

        /**
        * phonegap view を開く
        */
        push: function(fileName, options) {
            options = options || {};
            options.bg = options.bg || this.DEFAULT_BG_IMAGE || '';

            PhoneGap.exec(null, null, this.namespace, "push", [fileName, options]);
        },
        /**
        * pushした画面を閉じる
        * onRefresh, onPopメソッドをコールバック
        */
        pop: function(options) {
            PhoneGap.exec(null, null, this.namespace, "pop", [options]);
        },
        /**
        * modalにてphonegap viewを開く
        */
        modal: function(fileName, options) {
            options = options || {};
            options.bg = options.bg || this.DEFAULT_BG_IMAGE || '';

            PhoneGap.exec(null, null, this.namespace, "modal", [fileName, options]);
        },
        /**
        * modalした画面を閉じる
        * onRefresh, onDismissメソッドをコールバック
        */
        dismiss: function(options) {
            PhoneGap.exec(null, null, this.namespace, "dismiss", [options]);
        },
        /**
        * TOP画面へ遷移する
        */
        home: function(options) {
            options = options || {};
            PhoneGap.exec(null, null, this.namespace, "home", [options]);
        },
        /**
        * 情報をクリアする
        */
        clear: function() {

        },
        /**
        * 指定URLを端末のブラウザで起動する
        */
        browse: function(url) {
            PhoneGap.exec(null, null, this.namespace, "browse", [url]);
        },

        /** 指定URLをリンク遷移する */
        link : function(url, options) {
            PhoneGap.exec(null, null, this.namespace, "link", [url, options]);
        },

        /** 一番上以外の画面を削除する */
        clearWithoutTop : function(){
            PhoneGap.exec(null, null, this.namespace, "clearWithoutTop", [0]);
        }
    };
 })(window.cordova ? cordova : (window.Cordova ? Cordova : (window.PhoneGap ? PhoneGap : {})));
