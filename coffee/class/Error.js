// Generated by CoffeeScript 1.6.2
var Error;

Error = (function() {
  Error.prototype.logGroup = 'Error';

  Error.prototype.errorTypes = {
    1: 'usingOktellClient',
    2: 'loginPass',
    3: 'unavailable'
  };

  function Error(errorEl, oktell) {
    var _this = this;

    this.el = errorEl;
    oktell.on('connecting', function() {
      return _this.hide();
    });
    oktell.on('disconnect', function(reason) {
      _this.log('disconnect with reason ' + reason.code + ' ' + reason.message);
      if (reason.code === 12) {
        return _this.show(3, oktell.getMyInfo().login);
      }
    });
    oktell.on('connectError', function(error) {
      _this.log('connect error ' + error.errorCode + ' ' + error.errorMessage);
      switch (error.errorCode) {
        case 12:
          return _this.show(1, oktell.getMyInfo().login);
        case 13:
          return _this.show(2, oktell.getMyInfo().login);
      }
    });
  }

  Error.prototype.show = function(errorType, username) {
    var type, _ref, _ref1;

    if (!this.errorTypes[errorType]) {
      return false;
    }
    this.log('show ' + errorType);
    type = this.errorTypes[errorType];
    this.el.find('p:eq(0)').text(this.langs[type].header.replace('%username%', username));
    this.el.find('p:eq(1)').text(((_ref = this.langs[type].message) != null ? _ref.replace('%username%', username) : void 0) || '');
    this.el.find('p:eq(3)').text(((_ref1 = this.langs[type].message2) != null ? _ref1.replace('%username%', username) : void 0) || '');
    return this.el.fadeIn(200);
  };

  Error.prototype.hide = function() {
    return this.el.fadeOut(200);
  };

  return Error;

})();