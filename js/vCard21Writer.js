/**
  vCard21Writer v1.0.0
  Based on:
    [http://www.imc.org/pdi/vcard-21.doc]
    RFC 1521
  Author: Anas H. Sulaiman (AHS.PW)
  Requries: [https://github.com/mathiasbynens/quoted-printable]
  Notes:
  	All values are encoded to utf-8 quoted-printable, regardless if that is required.
*/

vCard21Writer = (function(){
	"use strict";

	var knownTypes = [
		'DOM'         , 'INTL'      , 'POSTAL'   ,'PARCEL'    , 'HOME'    , 
	  'WORK'        , 'PREF'      , 'VOICE'    ,'FAX'       , 'MSG'     , 
	  'CELL'        , 'PAGER'     , 'BBS'      ,'MODEM'     , 'CAR'     , 
	  'ISDN'        , 'VIDEO'     , 'AOL'      ,'APPLELINK' , 'ATTMAIL' , 
	  'CIS'         , 'EWORLD'    , 'INTERNET' ,'IBMMAIL'   , 'MCIMAIL' ,
		'POWERSHARE'  , 'PRODIGY'   , 'TLX'      ,'X400'      , 'GIF'     , 
		'CGM'         , 'WMF'       , 'BMP'      ,'MET'       , 'PMB'     , 
		'DIB'         , 'PICT'      , 'TIFF'     ,'PDF'       , 'PS'      , 
		'JPEG'        , 'QTIME'     , 'MPEG'     ,'MPEG2'     , 'AVI'     ,
		'WAVE'        , 'AIFF'      , 'PCM'      ,'X509'      , 'PGP'    	
	];

	var enctypes = [
		'7BIT',
		'8BIT',
		'QUOTED-PRINTABLE',
		'BASE64'
	];

	var names = [
													'LABEL'   , 'FN'      , 'TITLE' , 
	  					'VERSION' , 'TEL'     , 'EMAIL'   , 'TZ'    , 
	  'GEO'   , 'NOTE'    , 'URL'     , 'BDAY'    , 'ROLE'  ,
	  'REV'   , 'UID'     , 'KEY'     , 'MAILER'
  ];

  var mediaNames = [
  	'LOGO'  , 'PHOTO'   , 'SOUND'
  ];

  function utf8Encode(str) {
      return unescape(encodeURIComponent(str));
  }

  function encode(str) {
      return quotedPrintable.encode(utf8Encode(str));
  }

	function getBegin() {
		return 'BEGIN:VCARD';
	}
 
	function getEnd() {
		return 'END:VCARD';
	}

	function getVcardDelimiter() {
		return '\n';
	}

	function getItemDelimiter() {
		return '\n';
	}

	function getItem(groups, name, val) {
		if (!Array.isArray(groups)) {
			throw new Exception('groups must be Array');
		}

		if (name === null || name === undefined || name === '') {
			throw new Exception('name must not be empty');
		}

		name = name.toUpperCase();
		if (mediaNames.indexOf(name) >= 0) {
			throw new Exception(name + ' must be formatted using getMediaItem method');
		}

		if (names.indexOf(name) < 0) {
			throw new Exception('name is invalid');
		}

		if (val === null || val === undefined || val === '') {
			throw new Exception('val must not be empty');
		}

		if (name === 'ADR') {
			if (typeof val !== 'object') {
				throw new Exception('Address value must be an object');
			}

			val = 
				encode(val.pobox) 		+ ';' + 
				encode(val.ext) 			+ ';' + 
				encode(val.street) 		+ ';' + 
				encode(val.local) 		+ ';' + 
				encode(val.region) 		+ ';' + 
				encode(val.postcode) 	+ ';' + 
				encode(val.country);
		} else if (name === 'ORG') {
			if (typeof val !== 'object') {
				throw new Exception('Address value must be an object');
			}

			val = encode(val.org) + 
				(val.units.length === 0 ? '' : ';' + val.units.map(function(v){return encode(v);}).join(';'));
		} else if (name === 'N') {
			if (typeof val !== 'object') {
				throw new Exception('Address value must be an object');
			}

			val = 
				encode(val.last) 		+ ';' + 
				encode(val.first) 	+ ';' + 
				encode(val.middle) 	+ ';' + 
				encode(val.prefix) 	+ ';' + 
				encode(val.suffix);
		} else {
			val = encode(val);
		}


		var g = groups.join('.');
		var p = 'CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE';

		var line = 
			(g === '' ? '' : g + '.') + 
			name +
			(p === '' ? '' : ';' + p) +
			':' +
			val;

		if (line.length > 74) {
			line = line
				.split(/(.{74})/)
				.filter(function(v){return v !== '';})
				.join('=\n');
		}
		return line;
	}

	function getMediaItem(groups, name, enctype, mediatype, val) {
		if (!Array.isArray(groups)) {
			throw new Exception('groups must be Array');
		}

		if (name === null || name === undefined || name === '') {
			throw new Exception('name must not be empty');
		}

		name = name.toUpperCase();
		if (mediaNames.indexOf(name) < 0) {
			throw new Exception('name is invalid');
		}

		if (val === null || val === undefined || val === '') {
			throw new Exception('val must not be empty');
		}

		if (enctype === null || enctype === undefined || enctype === '') {
			throw new Exception('enctype must not be empty');
		}

		enctype = enctype.toUpperCase();
		if (enctypes.indexOf(enctype) < 0 && enctype.indexOf('X-') !== 0) {
			throw new Exception('enctype is invalid');
		}

		if (mediatype === null || mediatype === undefined || mediatype === '') {
			throw new Exception('mediatype must not be empty');
		}

		mediatype = mediatype.toUpperCase();
		if (knownTypes.indexOf(mediatype) < 0 && mediatype.indexOf('X-') !== 0) {
			throw new Exception('mediatype is invalid');
		}

		var item = 
			name + ';ENCODING=' + enctype + ';' +
			(knownTypes.indexOf(mediatype) < 0 ? 'TYPE=' : '') + mediatype + 
			':' +
			val;
		if (item.length > 74) {
			item = item
				.split(/(.{74})/)
				.filter(function(v){return v !== '';})
				.join('\n ') + 
				'\n\n';
		}

		return item;
	}

	return {
		'getBegin': getBegin,
		'getEnd': getEnd,
		'getVcardDelimiter': getVcardDelimiter,
		'getItemDelimiter': getItemDelimiter,
		'getItem': getItem,
		'getMediaItem': getMediaItem
	}
})();