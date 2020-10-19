/**
  vCardParser v1.0.0
  Based on:
    [http://www.imc.org/pdi/vcard-21.doc]
    RFC 1521
    RFC 2234
    RFC 2425
    RFC 2426
    RFC 4770
  Author: Anas H. Sulaiman (AHS.PW)
  Notes:
    Requires all lines to be unfolded.
      This is easily done using replace(/\r?\n[ \t]+/g, '').replace(/\n\n/g, '\n').
    Intended to produce a JavaScript object representation of the vCard file.
      Therefore, NOT suitable to check standard compliance.
*/

/*
vcards = [
  {
    bgroup: '',
    egroup: '',
    property_obj: {
      group: '',
      params: [{
        name: '',
        value: ''
      }],
      value: ''
    },
    array_of_property_obj: []
  }
];
 */
vCards =
  vcards:vCard* {
    return vcards;
  }

vCard =
  bgroup:(Group '.')? 'BEGIN'i ':' 'VCARD'i CRLF+
  lines:ContentLine+
  egroup:(Group '.')? 'END'i  ':' 'VCARD'i CRLF* {
    var vcard = {};
    var name;
    var value;

    vcard.bgroup = bgroup ? bgroup[0] : '';
    vcard.egroup = egroup ? egroup[0] : '';

    if (!lines) {
      return vcard;
    }

    lines.forEach(function(line){
      if (!vcard[line.name]) {
        vcard[line.name] = line.value;
      } else if (Array.isArray(vcard[line.name])) {
        vcard[line.name].push(line.value);
      } else {
        vcard[line.name] = [vcard[line.name], line.value];
      }
    });

    return vcard;
  }

Group =
  (Alpha / Digit / '-')+ {
    return text();
  }

ContentLine =
  g:(Group '.')? name:Name params:(';' Param)* ':' value:Value? CRLF+ {
    var ps = [];
    if (params) {
      ps = params.map(function(p){return p[1];});
    }
    return {
      'name': name.toLowerCase(),
      'value': {
        'group': g ? g[0] : '',
        'params': ps,
        'value': value || ''
      }
    };
  }

Name =
  !'end'i NotColonSemi+ {
    return text();
  }

Param =
  KnownParam {
    return {
      'name': '',
      'value': text()
    };
  }
  /
  pname:ParamName pvalue:('=' (ParamValue (',' ParamValue)*))? {
    var name = pname;
    var value = [];
    if (pvalue) {
      value.push(pvalue[1][0]);
      if (pvalue[1][1]) {
        value = value.concat(pvalue[1][1].map(function(v){return v[1];}));
      }
    } else {
      name = '';
      value = pname;
    }

    return {
      'name': name,
      'value': value
    };
  }

ParamName =
  NotColonSemiEqual+ {
    return text();
  }

ParamValue =
  NotColonSemiComma+ {
    return text();
  }

Value =
  NotCrlf+ (CRLF '=' NotCrlf+)* {
    return text();
  }

XWord =
  'x-'i (Alpha / Digit / '-')+ {
    return text();
  }

KnownParam =
  'DOM'i         / 'INTL'i      / 'POSTAL'i   / 'PARCEL'i    / 'HOME'i    /
  'WORK'i        / 'PREF'i      / 'VOICE'i    / 'FAX'i       / 'MSG'i     /
  'CELL'i        / 'PAGER'i     / 'BBS'i      / 'MODEM'i     / 'CAR'i     /
  'ISDN'i        / 'VIDEO'i     / 'AOL'i      / 'APPLELINK'i / 'ATTMAIL'i /
  'CIS'i         / 'EWORLD'i    / 'INTERNET'i / 'IBMMAIL'i   / 'MCIMAIL'i /
  'POWERSHARE'i  / 'PRODIGY'i   / 'TLX'i      / 'X400'i      / 'GIF'i     /
  'CGM'i         / 'WMF'i       / 'BMP'i      / 'MET'i       / 'PMB'i     /
  'DIB'i         / 'PICT'i      / 'TIFF'i     / 'PDF'i       / 'PS'i      /
  'JPEG'i        / 'QTIME'i     / 'MPEG'i     / 'MPEG2'i     / 'AVI'i     /
  'WAVE'i        / 'AIFF'i      / 'PCM'i      / 'X509'i      / 'PGP'i

KnownName =
  'adr'i   / 'agent'i / 'bday'i    / 'categories'i  / 'class'i  / 'email'i /
  'fn'i    / 'geo'i     / 'impp'i        / 'key'i    / 'label'i /
  'logo'i  / 'mailer'i  / 'nickname'i    / 'name'i   / 'note'i  /
  'n'i     / 'org'i     / 'photo'i       / 'prodid'i / 'profile'i /
  'rev'i   / 'role'i    / 'sort-string'i / 'sound'i  / 'source'i /
  'tel'i   / 'title'i   / 'tz'i          / 'uid'i    / 'url'i /
  'version'i

CR =
  '\r'

LF =
  '\n'

CRLF =
  CR? LF

Digit =
  [0-9]

Alpha =
  [A-Z] / [a-z]

NotCrlf =
  [^\n\r]

NotColonSemi =
  [^:;\n\r]

NotColonSemiEqual =
  [^:;=\n\r]

NotColonSemiComma =
  [^:;,\n\r]
