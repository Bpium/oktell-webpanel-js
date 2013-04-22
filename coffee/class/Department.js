// Generated by CoffeeScript 1.6.2
var Department;

Department = (function() {
  function Department(id, name) {
    this.isSorted = false;
    this.visible = true;
    this.users = [];
    this.id = id && id !== '00000000-0000-0000-0000-000000000000' ? id : this.withoutDepName;
    this.name = this.id === this.withoutDepName || !name ? this.langs.panel.withoutDepartment : name;
  }

  Department.prototype.getEl = function() {
    return this.el || (this.el = $(this.template.replace(/\{\{department}\}/g, escapeHtml(this.name))));
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

  Department.prototype.getUsers = function(filter) {
    var exactMatch, u, users, _i, _len, _ref;

    if (!this.isSorted) {
      this.sortUsers();
    }
    users = [];
    exactMatch = false;
    if (filter === '') {
      users = [].concat(this.users);
    } else {
      _ref = this.users;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        u = _ref[_i];
        if (u.isFiltered(filter)) {
          users.push(u);
          if (u.number === filter && !exactMatch) {
            exactMatch = u;
          }
        }
      }
    }
    return [users, exactMatch];
  };

  Department.prototype.sortUsers = function() {};

  Department.prototype.addUser = function(user) {
    return this.users.push(user);
  };

  return Department;

})();
