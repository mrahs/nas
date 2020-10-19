vCardParser = function(str) {
	var regex = {
		vcard: /BEGIN:VCARD[\s\S]*?END:VCARD/g,
		address: /\bADR;(?:TYPE=)?([^:]*):([^;]*);([^;]*);([^;]*);([^;]*);([^;]*);([^;]*);(.*)/,
		anniversary: /\bANNIVERSARY:(\d*)/,
		bday: /\bBDAY:(.*)/,
		event: /\bX-ANDROID-CUSTOM:vnd\.android\.cursor\.item\/contact_event;([^;]*);([^;]*);([^;]*);.*/, /* date,type,custom_title */
		cats: /\bCATEGORIES:(\w,?)*/,
		class: /\bCLASS:(\w)*/,
		email: /\bEMAIL;(?:TYPE=)?([^:]*):(.*)/,
		fullname: /\bFN(?:;CHARSET=([^;:]*))?(?:;ENCODING=([^:]*))?:(.*)/,
		gender: /\bGENDER:(.*)/,
		geo: /\bGEO:([\d\.\-\+]*[;,][\d\.\-\+]*)/,
		im: /\bIMPP:(.*?):(.*)/,
		ims: [
			/\bX-(AIM):(.*)/,
			/\bX-(ICQ):(.*)/,
			/\bX-(JABBER):(.*)/,
			/\bX-(MSN):(.*)/,
			/\bX-(YAHOO):(.*)/,
			/\bX-(TWITTER):(.*)/,
			/\bX-((?:GOOGLE-TALK)|(?:GTALK)):(.*)/,
			/\bX-((?:SKYPE)|(?:SKYPE-USERNAME)):(.*)/,
			/\bX-(GADUGADU):(.*)/,
		],
		im_x: /\bX-([^:;]*)(?:;[^:]*)?:(.*)/,
		key: null,
		lang: /\bLANG:(.*)/,
		label: null,
		logo: null, /* Same as photo */
		name: /\bN(?:;CHARSET=([^;:]*))?(?:;ENCODING=([^:]*))?:([^;]*);([^;]*);([^;]*);([^;]*);(.*)/,
		nickname: /\bNICKNAME:(\w,?)*/,
		nickname_x: /\bX-ANDROID-CUSTOM:vnd\.android\.cursor\.item\/nickname;([^;]*);([^;]*);([^;]*);.*/, /* nickname,type,custom_title */
		note: /\bNOTE(?:;CHARSET=([^;:]*))?(?:;ENCODING=([^:]*))?:(.*)/,
		org: /\bORG:(.*)/,
		photo_url: /\bPHOTO;(?:(?:MEDIA)?TYPE=)?([^:;]*):(.*)/, /* URL[type,url] */
		photo_enc_type: /\bPHOTO;ENCODING=([^;]*);(?:TYPE=)?([^:]*):((?:\S*\r?\n )*\S*?\r?\n\r?\n)/, /* Encoded[enctype,type,data] */
		photo_type_enc: /\bPHOTO;(?:TYPE=)?([^;]*);ENCODING=([^:]*):((?:\S*\r?\n )*\S*?\r?\n\r?\n)/, /* Encoded[type,enctype,data] */
		photo_data: /\bPHOTO:data:([^;]*);([^,]*),((?:\S*\r?\n )*\S*?\r?\n\r?\n)/, /* Data URI[type,enctype,data] */
		rev: /\bREV:([\d{8}T\d{6}Z]*)/,
		role: /\bROLE:(.*)/,
		sound: null, /* Same as photo */
		source: /\bSOURCE:(.*)/,
		tel: /\bTEL;(?:TYPE=)?([^:]*):(.*)/,
		title: /\bTITLE:(.*)/g,
		tz: null,
		uid: null,
		url: /\bURL:(.*)/g,
		net: /\bX-SIP:(.*)/
	};

	var vCardStrArr = str.match(regex.vcard);
	var vCards = {}, vCard, vCardStr;
	var match, subMatch, matchedParts, unknownParts = [];
	var i,j,k;

	vCards.index = 0;
	for (i = 0; i < vCardStrArr.length; i++) {
		vCardStr = vCardStrArr[i];
		vCard = {};
		matchedParts = [];

		// address
		vCard.addresses = [];
		match = vCardStr.match(new RegExp(regex.address.source, 'g'));
		if (match !== null) {
			for(j = 0; j < match.length; j++) {
				matchedParts.push(match[j]);
				subMatch = match[j].match(regex.address);
				vCard.addresses.push({
					type: subMatch[1],
					pobox: subMatch[2],
					neighborhood: subMatch[3],
					street: subMatch[4],
					city: subMatch[5],
					state: subMatch[6],
					zipcode: subMatch[7],
					country: subMatch[8]
				});
			}
		}

		// event
		vCard.events = [];
		match = vCardStr.match(new RegExp(regex.event.source, 'g'));
		if (match !== null) {
			for(j = 0; j < match.length; j++) {
				matchedParts.push(match[j]);
				subMatch = match[j].match(regex.event);
				vCard.events.push({
					'date': subMatch[1],
					'type': subMatch[2],
					'title': subMatch[2] === '1' ? 'Birthday' : subMatch[2] === '2' ? 'Anniversary' : subMatch[3]
				});
			}
		}

		// anniversary
		match = vCardStr.match(regex.anniversary);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.events.push({
				'date': match[1],
				'type': '2',
				'title': 'Anniversary'
			});
		}

		// birthday
		match = vCardStr.match(regex.bday);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.events.push({
				'date': match[1],
				'type': '1',
				'title': 'Birthday'
			});
		}

		// categories
		vCard.cats = [];
		match = vCardStr.match(regex.cats);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.cats = match[1].split[','];
		}

		// class
		vCard.class = '';
		match = vCardStr.match(regex.class);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.class = match[1];
		}

		// emails
		vCard.emails = [];
		match = vCardStr.match(new RegExp(regex.email.source, 'g'));
		if (match !== null) {
			for(j = 0; j < match.length; j++) {
				matchedParts.push(match[j]);
				subMatch = match[j].match(regex.email);
				vCard.emails.push({'type':subMatch[1], 'address':subMatch[2]});
			}
		}

		// fullname
		vCard.fullname = {
			'name': '',
			'charset': '',
			'enctype': ''
		};
		match = vCardStr.match(regex.fullname);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.fullname.charset = match[1];
			vCard.fullname.enctype = match[2];
			vCard.fullname.name = match[3];
		}

		// gender
		vCard.gender = '';
		match = vCardStr.match(regex.gender);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.gender = match[1];
		}

		// geo
		vCard.geo = '';
		match = vCardStr.match(regex.geo);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.geo = match[1];
		}

		// ims
		vCard.ims = [];
		if ((match = vCardStr.match(new RegExp(regex.im.source, 'g'))) !== null) {
			vCard.ims = [];
			for(j = 0; j < match.length; j++) {
				matchedParts.push(match[j]);
				subMatch = match[j].match(regex.im);
				vCard.ims.push({
					'service': subMatch[1],
					'alias': subMatch[2]
				});
			}
		} else {
			for(j = 0; j < regex.ims.length; j++) {
				match = vCardStr.match(new RegExp(regex.ims[j].source, 'g'));
				if (match !== null) {
					for (k = 0; k < match.length; k++) {
						matchedParts.push(match[k]);
						subMatch = match[k].match(regex.ims[j]);
						vCard.ims.push({
							'service': subMatch[1],
							'alias': subMatch[2]
						});
					}
				}
			}
		}

		// language
		vCard.lang = '';
		match = vCardStr.match(regex.lang);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.lang = match[1];
		}

		// logo TODO

		// name
		vCard.name = {
			'charset': '',
			'enctype': '',
			last: '',
			first: '',
			middle: '',
			prefix: '',
			suffix: ''
		};
		match = vCardStr.match(regex.name);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.name.charset = match[1];
			vCard.name.enctype = match[2];
			vCard.name.last = match[3];
			vCard.name.first = match[4];
			vCard.name.middle = match[5];
			vCard.name.prefix = match[6];
			vCard.name.suffix = match[7];
		}

		// nickname
		vCard.nicknames = '';
		match = vCardStr.match(regex.nickname);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.nicknames = match[1].split[','];
		}

		// note
		vCard.note = {
			'text': '',
			'charset': '',
			'enctype': ''
		};
		match = vCardStr.match(regex.note);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.note.charset = match[1];
			vCard.note.enctype = match[2];
			vCard.note.text = match[3].replace(/\n /g, '').trim();
		}

		// org
		vCard.orgs = [];
		match = vCardStr.match(new RegExp(regex.org.source, 'g'));
		if (match !== null) {
			for(j = 0; j < match.length; j++) {
				subMatch = match[j].match(regex.org);
				if (subMatch === null) {
					continue;	
				}
				matchedParts.push(match[j]);
				var parts = subMatch[1].split(';');
				if (parts.length === 3) {
					vCard.orgs.push({'company':parts[0], 'team':parts[1], 'title':parts[2]});
				} else {
					vCard.orgs.push({'company':parts[0], 'team':'', 'title':''});
				}
			}
		}

		// photo
		vCard.photo = {
			type: '',
			enctype: '',
			data: '',
			url: ''
		};
		if ((match = vCardStr.match(regex.photo_url)) !== null) {
			matchedParts.push(match[0]);
			vCard.photo.type = match[1];
			vCard.photo.url = match[2];
		} else if (
			(match = vCardStr.match(regex.photo_data)) !== null ||
			(match = vCardStr.match(regex.photo_type_enc)) !== null) {
			matchedParts.push(match[0]);
			vCard.photo.type = match[1];
			vCard.photo.enctype = match[2];
			vCard.photo.data = match[3].replace(/\n /g, '').trim();
		} else if ((match = vCardStr.match(regex.photo_enc_type)) !== null) {
			matchedParts.push(match[0]);
			vCard.photo.enctype = match[1];
			vCard.photo.type = match[2];
			vCard.photo.data = match[3].replace(/\n /g, '').trim();
		}

		// revision
		vCard.rev = '';
		match = vCardStr.match(regex.rev);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.rev = match[1];
		}

		// role
		vCard.role = '';
		match = vCardStr.match(regex.role);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.role = match[1];
		}

		// source
		vCard.source = '';
		match = vCardStr.match(regex.source);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.source = match[1];
		}

		// phones
		vCard.phones = [];
		match = vCardStr.match(new RegExp(regex.tel.source, 'g'));
		if (match !== null) {
			for(j = 0; j < match.length; j++) {
				matchedParts.push(match[j]);
				subMatch = match[j].match(regex.tel);
				vCard.phones.push({
					'type': subMatch[1].replace(';PREF', ''), 
					'number': subMatch[2],
					'preferred': subMatch[1].indexOf('PREF') >= 0
				});
			}
		}

		// title
		match = vCardStr.match(regex.title, 'g');
		if (match !== null) {
			for(j = 0; j < match.length; j++) {
				matchedParts.push(match[j]);
				vCard.orgs[j].title = match[j].substr(6);
			}
		}

		// urls
		vCard.urls = [];
		match = vCardStr.match(regex.url);
		if (match !== null) {
			for(j = 0; j < match.length; j++) {
				matchedParts.push(match[j]);
				vCard.urls.push(match[j].substr(4));
			}
		}

		// net
		vCard.net = '';
		match = vCardStr.match(regex.net);
		if (match !== null) {
			matchedParts.push(match[0]);
			vCard.net = match[1];
		}

		vCards[vCards.index] = vCard;
		vCards.index++;

		vCardStr = vCardStr.replace('BEGIN:VCARD', '');
		vCardStr = vCardStr.replace('END:VCARD', '');
		vCardStr = vCardStr.replace(/VERSION:.*/, '');
		for (j = 0; j < matchedParts.length; j++) {
			vCardStr = vCardStr.replace(matchedParts[j], '');
		}
		vCardStr = vCardStr.trim();
		if (vCardStr.length > 0) {
			unknownParts.push(vCardStr);
		}
	}

	return {
		vCards: vCards,
		unknownParts: unknownParts.filter(this.utils.filterUnique)
	};
};