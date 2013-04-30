// Generated by CoffeeScript 1.6.2
var Department;

Department = (function() {
  function Department(id, name) {
    this.lastFilteredUsers = [];
    this.isSorted = false;
    this.visible = true;
    this.users = [];
    this.id = id && id !== '00000000-0000-0000-0000-000000000000' ? id : this.withoutDepName;
    this.name = this.id === this.withoutDepName || !name ? this.langs.panel.withoutDepartment : name;
  }

  Department.prototype.getEl = function() {
    return this.el || (this.el = $(this.template.replace(/\{\{department}\}/g, escapeHtml(this.name))));
  };

  Department.prototype.getContainer = function() {
    return this.el.find('tbody');
  };

  Department.prototype.getInfo = function() {
    return this.name + ' ' + this.id;
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

  Department.prototype.getUsers = function(filter, showOffline) {
    var exactMatch, u, users, _i, _j, _len, _len1, _ref, _ref1;

    if (!this.isSorted) {
      this.sortUsers();
    }
    users = [];
    exactMatch = false;
    if (filter === '') {
      if (showOffline) {
        users = [].concat(this.users);
      } else {
        _ref = this.users;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          u = _ref[_i];
          if (u.state !== 0) {
            users.push(u);
          }
        }
      }
    } else {
      _ref1 = this.users;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        u = _ref1[_j];
        if (u.isFiltered(filter, showOffline)) {
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
