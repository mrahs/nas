var NAS = NAS || {};

NAS.utils = NAS.utils || {};

NAS.utils.filterUnique = function(value, index, self) {
	return self.indexOf(value) === index;
};

NAS.setVCards = NAS.setVCards || function(vCards) {
	
};

NAS._ = function(str) {
	if (str.indexOf('X-') === 0) {
		return str.replace('X-', '');
	}

	var strings = {
		'': '',
		'CELL': 'Mobile',
		'HOME': 'Home',
		'WORK': 'Work',
		'SKYPE-USERNAME': 'Skype',
		'SKYPE': 'Skype',
		'JABBER': 'Jabber',
		'YAHOO': 'Yahoo',
		'QQ': 'QQ',
		'ICQ': 'ICQ',
		'GOOGLE-TALK': 'Hangouts',
		'GTALK': 'Hangouts'
	};

	return strings[str] || '';
};
