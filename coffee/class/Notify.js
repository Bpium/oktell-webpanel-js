// Generated by CoffeeScript 1.6.2
var Notify,
  __slice = [].slice;

Notify = (function() {
  function Notify(title, autoHide, message, group, onClick) {
    var notify,
      _this = this;

    if (autoHide == null) {
      autoHide = 0;
    }
    if (!(typeof title === 'string' && title) || window.webkitNotifications.checkPermission() !== 0) {
      return;
    }
    if (typeof message === 'function') {
      onClick = message;
      message = '';
      group = null;
    } else if (typeof group === 'function') {
      onClick = group;
      group = null;
    }
    notify = window.webkitNotifications.createNotification('favicon.ico', title, message || '');
    if (group) {
      notify.tag = group;
    }
    notify.show();
    autoHide = parseInt(autoHide);
    if (autoHide) {
      setTimeout(function() {
        return notify.close();
      }, autoHide * 1000);
    }
    notify.onclick = function() {
      var args, e;

      e = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (typeof window.focus === "function") {
        window.focus();
      }
      notify.close();
      if (typeof onClick === 'function') {
        return onClick.apply(window, []);
      }
    };
    this.close = function() {
      return notify != null ? typeof notify.close === "function" ? notify.close() : void 0 : void 0;
    };
  }

  return Notify;

})();
