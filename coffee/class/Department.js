// Generated by CoffeeScript 1.6.2
var Department;

Department = (function() {
  Department.prototype.logGroup = 'Department';

  function Department(id, name) {
    this.usersVisibilityCss = 'invisibleDep';
    this.lastFilteredUsers = [];
    this.isSorted = false;
    this.visible = true;
    this.users = [];
    this.id = id && id !== '00000000-0000-0000-0000-000000000000' ? id : this.withoutDepName;
    this.name = this.id === this.withoutDepName || !name ? this.langs.panel.withoutDepartment : name;
    this.isOpen = this.config().departmentVisibility[this.id] != null ? this.config().departmentVisibility[this.id] : true;
  }

  Department.prototype.getEl = function(usersVisible) {
    if (!this.el) {
      this.el = $(this.template.replace(/\{\{department}\}/g, escapeHtml(this.name)));
    }
    if (usersVisible) {
      this._oldIsOpen = this.isOpen;
      this.showUsers(true, true);
    } else {
      this.showUsers(this._oldIsOpen != null ? this._oldIsOpen : this.isOpen);
    }
    this.el.data('department', this);
    return this.el;
  };

  Department.prototype.getContainer = function() {
    return this.el.find('tbody');
  };

  Department.prototype.showUsers = function(val, notSave) {
    var c;

    if (typeof val === 'undefined') {
      val = !this.isOpen;
    }
    if (!this.hideEl) {
      this.hideEl = this.el.find('table');
    }
    this.hideEl.stop(true, true);
    if (!notSave) {
      this.isOpen = val;
      c = this.config();
      c.departmentVisibility[this.id] = this.isOpen;
      this.config(c);
    }
    if (val) {
      this.el.toggleClass(this.usersVisibilityCss, false);
      return this.hideEl.show();
    } else {
      this.el.toggleClass(this.usersVisibilityCss, true);
      return this.hideEl.hide();
    }
  };

  Department.prototype.getInfo = function() {
    return this.name + ' ' + this.id;
  };

  Department.prototype.clearUsers = function() {
    return this.users = [];
  };

  Department.prototype.show = function(withAnimation) {
    if (!this.el || this.visible) {
      return;
    }
    if (withAnimation) {
      this.el.slideDown(200);
    } else {
      this.el.show();
    }
    return this.visible = true;
  };

  Department.prototype.hide = function(withAnimation) {
    if (!this.el || !this.visible) {
      return;
    }
    if (withAnimation) {
      this.el.slideUp(200);
    } else {
      this.el.hide();
    }
    return this.visible = false;
  };

  Department.prototype.getUsers = function(filter, showOffline, filterLang) {
    var exactMatch, u, users, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;

    if (!this.isSorted) {
      this.sortUsers();
    }
    users = [];
    exactMatch = false;
    if (filter === '') {
      if (showOffline) {
        _ref = this.users;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          u = _ref[_i];
          u.setSelection();
          users.push(u);
        }
      } else {
        _ref1 = this.users;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          u = _ref1[_j];
          if (u.state !== 0) {
            u.setSelection();
            users.push(u);
          }
        }
      }
    } else {
      _ref2 = this.users;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        u = _ref2[_k];
        if (u.isFiltered(filter, showOffline, filterLang)) {
          users.push(u);
          if (u.number === filter && !exactMatch) {
            exactMatch = u;
          }
        }
      }
    }
    this.lastFilteredUsers = users;
    return [users, exactMatch];
  };

  Department.prototype.sortUsers = function() {
    return this.users.sort(this.sortFn);
  };

  Department.prototype.sortFn = function(a, b) {
    if (a.nameLower > b.nameLower) {
      return 1;
    } else if (a.nameLower < b.nameLower) {
      return -1;
    } else {
      if (a.number > b.number) {
        return 1;
      } else if (a.number < b.number) {
        return -1;
      } else {
        return 0;
      }
    }
  };

  Department.prototype.addUser = function(user) {
    if (user.number) {
      return this.users.push(user);
    }
  };

  return Department;

})();
