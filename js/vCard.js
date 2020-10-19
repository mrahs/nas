/**
 * Requires: quoted-printable.js
 */

var vCard = function() {};

vCard.prototype = {
  /////////////////////////////////////////////////////////////////////////////
  //// Utils
  /////////////////////////////////////////////////////////////////////////////
  _utils: {
    getIndex: function(id, max) {
      var index;
      if (typeof id === 'number') {
        index = ~~id; // truncate to integer
      } else if (typeof id === 'string') {
        try {
          index = parseInt(id);
        } catch (ignored) {
          index = -1;
        }
      } else {
        index = -1;
      }

      if (isNaN(index) || index < 0 || index >= max) {
        index = -1;
      }

      return index;
    },
    isValidTypes: function(types) {
      return Array.isArray(types) && types.filter(function(v){return typeof v === 'string';}).length == types.length;
    },
    decodeUtf8: function(str) {
        return decodeURIComponent(escape(str));
    },
    encodeUtf8: function(str) {
        return unescape(encodeURIComponent(str));
    },
    decodeQp: function(str) {
      if (typeof quotedPrintable === 'undefined') {
        return 'null';
      }
      quotedPrintable.decode(str);
    },
    encodeQp: function(str) {
      if (typeof quotedPrintable === 'undefined') {
        return 'null';
      }
      quotedPrintable.encode(str);
    },
    decodeUtf8Qp: function(str) {
        return this.decodeUtf8(this.decodeQp(str));
    },
    encodeUtf8Qp: function(str) {
        return this.encodeQp(this.encodeUtf8(str));
    },
    decode: function(val, charset, enctype) {
      if (typeof val !== 'string') {
        return '';
      }

      if (typeof enctype === 'string' && enctype.trim().toLowerCase() === 'quoted-printable') {
        val = this.decodeQp(val);
      }
      if (typeof charset === 'string' && charset.trim().toLowerCase() === 'utf8') {
        val = this.decodeUtf8(val);
      }
      return val;
    },
    encode: function(val, charset, enctype) {
      if (typeof val !== 'string') {
        return '';
      }

      if (typeof charset === 'string' && charset.trim().toLowerCase() === 'utf8') {
        val = this.encodeUtf8(val);
      }
      if (typeof enctype === 'string' && enctype.trim().toLowerCase() === 'quoted-printable') {
        val = this.encodeQp(val);
      }
      return val;
    }
  },
  /////////////////////////////////////////////////////////////////////////////
  //// Addresses
  /////////////////////////////////////////////////////////////////////////////
  adr: {
    _val: [],
    add: function(val, types, charset, enctype) {
      val = vCard._utils.decode(val, charset, enctype);

      var parts = val.split(';');
      if (parts.length < 7) return null;

      var newAdr = {
        pobox: parts[0],
        neighborhood: parts[1],
        street: parts[2],
        city: parts[3],
        state: parts[4],
        zipcode: parts[5],
        country: parts[6],
        types: []
      };

      if (vCard._utils.isValidTypes(types)) {
        newAdr.types = types;
      }

      this._val.push(newAdr);

      return newAdr;
    },
    get: function(id) {
      var index = vCard._utils.getIndex(id, this._adrs.length);
      return this._val[index];
    },
    all: function() {
      return this._val.slice(0);
    },
    del: function(id) {
      var index = vCard._utils.getIndex(id, this._adrs.length);
      return this._val.splice(index,index);
    }
  },
  bday: {
    _val: new Date(0),
    get: function() {
      return new Date(this._val.getTime());
    },
    set: function(newVal) {
      if (newVal instanceof Date) {
        this._val.setTime(newVal.getTime());
      } else if (typeof newVal === 'string') {
        var parts = newVal.match(/^(\d{4})-?(\d{2})-?(\d{2})$/);
        var tmpDate = new Date();
        if (parts.length >= 4) {
          tmpDate.setFullYear(parseInt(parts[1]));
          tmpDate.setMonth(parseInt(parts[2]) -1);
          tmpDate.setDate(parseInt(parts[3]));

          if (this._format(tmpDate) === newVal || this._format(tmpDate, '-') === newVal) {
            // valid date
            this._val = tmpDate;
          }
        }
      }

      return this._val;
    },
    _format: function(date, del) {
      if (!(date instanceof Date)) {
        return '';
      }
      if (typeof del !== 'string') {
        del = '';
      }

      var y = date.getFullYear();
      var m = date.getMonth() + 1;
      var d = date.getDay();

      return ('0000' + y).substr(-4) + del + ('00' + m).substr(-2) + del + ('00' + d).substr(-2);
    }
  },
  get bgroup () {
    if (typeof this._bgroup !== 'string') {
      this._bgroup = '';
    }

    return this._bgroup;
  },
  set bgroup (val) {
    if (typeof val !== 'string') {
      return this._bgroup;
    }

    this._bgroup = val;
    return this._bgroup;
  },
  get egroup () {
    if (typeof this._egroup !== 'string') {
      this._egroup = '';
    }

    return this._egroup;
  },
  set egroup (val) {
    if (typeof val !== 'string') {
      return this.egroup;
    }

    this._egroup = val;
    return this._egroup;
  },
  email: {
    _val: [],
    add: function(val, types, charset, enctype) {
      val = vCard._utils.decode(val, charset, enctype);
      if (val === '') return null;

      var newEmail = {
        adr: val,
        types: []
      };

      if (vCard._utils.isValidTypes(types)) {
        newEmail.types = types;
      }

      this._val.push(newEmail);

      return newEmail;
    },
    get: function(id) {
      var index = vCard._utils.getIndex(id);
      return this._val[index];
    },
    all: function() {
      return this._val.slice(0);
    },
    del: function(id) {
      var index = vCard._utils.getIndex(id);
      return this._val.splice(index,index);
    }
  },
  fn: {
    _val: '',
    set: function(val, charset, enctype) {
      val = vCard._utils.decode(val, charset, enctype);
      if (val !== '') {
        this._val = val;
      }

      return this._val;
    },
    get: function() {
      return this._val;
    }
  },
  n: {
    _val: {},
    set: function(val, charset, enctype) {
      val = vCard._utils.decode(val, charset, enctype);


    },
    get: function() {
      return this._val;
    }
  }
};
