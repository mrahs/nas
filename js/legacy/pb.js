if (typeof String.prototype.startsWith != 'function') {
  String.prototype.startsWith = function (str){
    return this.lastIndexOf(str, 0) === 0;
  };
}

var pbContacts = null;
var pbFilteredContacts = null;
var PbContact = function() {
	this._n = '';
	this._fn = '';
	this._tel = [];
	this._email = [];
	this._url = [];
	this._photo = '';

	this.setN = function(n) {
		this._n = n;
	};
	this.setFn = function(fn) {
		this._fn = fn;
	};
	this.addTel = function(tel) {
		this._tel.push(tel);
	};
	this.addEmail = function(email) {
		this._email.push(email);
	};
	this.addUrl = function(url) {
		this._url.push(url);
	};
	this.setPhoto = function(photo) {
		this._photo = photo;
	};
};

var pbParseVcf = function(vcf) {
	var lines = vcf.replace('\r\n', '\n').split('\n');
	var contacts = [];
	var contact = null;
	var i = 0;

	var handleEntry = function(entry) {
		if (entry.startsWith('BEGIN:')) {
			contact = new PbContact();
		} else if (entry.startsWith('END:')) {
			contacts.push(contact);
		} else if (entry.startsWith('N:')) {
			contact.setN(entry.slice(2));
		} else if (entry.startsWith('FN:')) {
			contact.setFn(entry.slice(3));
		} else if (entry.startsWith('TEL;')) {
			contact.addTel(entry.slice(4));
		} else if (entry.startsWith('EMAIL;')) {
			contact.addEmail(entry.slice(6));
		} else if (entry.startsWith('URL:')) {
			contact.addUrl(entry.slice(4));
		} else if (entry.startsWith('PHOTO;')) {
			contact.setPhoto(entry.slice(6));
		}
	};

	var getNextEntry = function() {
		if (i >= lines.length) {
			return null;
		}

		var entry = lines[i];
		++i;
		while (i < lines.length && lines[i].startsWith(' ')) {
			entry += '\n' + lines[i];
			++i;
		}

		return entry;
	};

	var nextEntry; 
	while ((nextEntry = getNextEntry())) {
		handleEntry(nextEntry);
	}

	return contacts;
};

var pbFormatAsVcf = function(contacts) {

};

var pbFilterList = function(query) {

};

var pbUpdateList = function(contacts) {

};

var pbAdjustHeights = function(){
	var $pbList = $('.pb-list');
	$pbList.height(window.innerHeight - $pbList.offset().top);
	var $pbOnwShow = $('.pb-one-show');
	$pbOnwShow.height(window.innerHeight - $pbOnwShow.offset().top);
};



$(document).ready(function(){
	pbAdjustHeights();
});