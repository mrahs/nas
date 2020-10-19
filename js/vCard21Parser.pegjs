/**
  vCard21Parser v1.0.0
  Based on:
    [http://www.imc.org/pdi/vcard-21.doc]
    RFC 1521
  Author: Anas H. Sulaiman (AHS.PW)
  Notes:
    Requires all lines to be unfolded.
      This is easily done using replace(/\r?\n[ \t]+/g, '').replace(/\n\n/g, '\n').
    Intended to produce a JavaScript object representation of the vCard file.
      Therefore, NOT suitable to check standard compliance. 
*/

vCards =
  WSLS? first:vCard rest:(WSLS? vCard)* WSLS? {
    var vCards = [first];
    if (rest) {
      Array.forEach(rest, function(v){
        vCards.push(v[1]);
      });
    }
    return vCards;
  }
  
vCard =
  'BEGIN'i WS? ':' WS? 'VCARD'i WS? CRLF+ items:Item* CRLF* 'END'i WS? ':' WS? 'VCARD'i {
    var vCard = {};
    var itemName;
    var itemValue;

    if (items) {
      Array.forEach(items, function(v){
        itemName = Object.keys(v)[0];
        itemValue = v[itemName];

        if (!vCard[itemName]) {
          vCard[itemName] = itemValue;
        } else if (Array.isArray(vCard[itemName])) {
          vCard[itemName].push(itemValue);
        } else {
          vCard[itemName] = [vCard[itemName], itemValue];
        }
      });
    }

    return vCard;
  }
    
Item =
  g:(Groups '.')? itemName:ItemName   params:Params? ':' val:Value         CRLF {
    var item = {};
    item[itemName.toLowerCase()] = {
      'groups': g ? g[0] : [],
      'params': params || [],
      'val': val
    };
    return item;
  } /
  g:(Groups '.')? 'ADR'i              params:Params? ':' val:AddressParts  CRLF {
    return {
      'adr': {
        'groups': g? g[0] : [],
        'params': params || [],
        'val': val
      }
    };
  } /
  g:(Groups '.')? 'ORG'i              params:Params? ':' val:OrgParts      CRLF {
    return {
      'org': {
        'groups': g? g[0] : [],
        'params': params || [],
        'val': val
      }
    };
  } /
  g:(Groups '.')? 'N'i                params:Params? ':' val:NameParts     CRLF {
    return {
      'n': {
        'groups': g? g[0] : [],
        'params': params || [],
        'val': val
      }
    };
  } /
  g:(Groups '.')? 'AGENT'i            params:Params? ':' val:vCard         CRLF {
    return {
      'agent': {
        'groups': g? g[0] : [],
        'params': params || [],
        'val': val
      }
    };
  }
  
Groups =
  first:Word rest:('.' Word)* {
    var groups = [first];
    if (rest) {
      Array.forEach(rest, function(v){
        groups.push(v[1]);
      });
    }

    return groups;
  }
  
ItemName =
  'LOGO'i  / 'PHOTO'i   / 'LABEL'i   / 'FN'i      / 'TITLE'i / 
  'SOUND'i / 'VERSION'i / 'TEL'i     / 'EMAIL'i   / 'TZ'i    / 
  'GEO'i   / 'NOTE'i    / 'URL'i     / 'BDAY'i    / 'ROLE'i  / 
  'REV'i   / 'UID'i     / 'KEY'i     / 'MAILER'i  / XWord

Params =
  ';' WS? first:Param rest:(WS? ';' WS? Param)* {
    var params = [first];
    if (rest) {
      Array.forEach(rest, function(v){
        params.push(v[3]);
      });
    }

    return params;
  }
  
Param =
  'TYPE'i      WS? '='   WS? val:PTypeVal      {return {'name': 'type',    'val': val}} /
  'VALUE'i     WS? '='   WS? val:PValueVal     {return {'name': 'value',   'val': val}} /
  'ENCODING'i  WS? '='   WS? val:PEncodingVal  {return {'name': 'encoding','val': val}} /
  'CHARSET'i   WS? '='   WS? val:CharsetVal    {return {'name': 'charset', 'val': val}} /
  'LANGUAGE'i  WS? '='   WS? val:LangVal       {return {'name': 'lang',    'val': val}} /
  name:XWord   WS? '='   WS? val:Word          {return {'name': name,      'val': val}} /
  val:KnownType                               {return {'name': 'known',   'val': val}}
  
PTypeVal =
  KnownType / XWord
  
PValueVal =
  'INLINE'i / 'URL'i / 'CONTENT-ID'i / 'CID'i / XWord
  
PEncodingVal =
  '7BIT'i / '8BIT'i / 'QUOTED-PRINTABLE'i / 'BASE64'i / XWord

CharsetVal =
  [a-zA-Z0-9-]+ {
    return text();
  }
  
LangVal =
  [a-zA-Z]+ ('-' [a-zA-Z]+)* {
    return text();
  }
  
KnownType =
  'DOM'i         / 'INTL'i      / 'POSTAL'i   / 'PARCEL'i    / 'HOME'i    / 
  'WORK'i        / 'PREF'i      / 'VOICE'i    / 'FAX'i       / 'MSG'i     / 
  'CELL'i        / 'PAGER'i     / 'BBS'i      / 'MODEM'i     / 'CAR'i     / 
  'ISDN'i        / 'VIDEO'i     / 'AOL'i      / 'APPLELINK'i / 'ATTMAIL'i / 
  'CIS'i         / 'EWORLD'i    / 'INTERNET'i / 'IBMMAIL'i   / 'MCIMAIL'i /
	'POWERSHARE'i  / 'PRODIGY'i   / 'TLX'i      / 'X400'i      / 'GIF'i     / 
	'CGM'i         / 'WMF'i       / 'BMP'i      / 'MET'i       / 'PMB'i     / 
	'DIB'i         / 'PICT'i      / 'TIFF'i     / 'PDF'i       / 'PS'i      / 
	'JPEG'i        / 'QTIME'i     / 'MPEG'i     / 'MPEG2'i     / 'AVI'i     /
	'WAVE'i        / 'AIFF'i      / 'PCM'i      / 'X509'i      / 'PGP'i     /
  'X-IRMC-N' /* Unlike the spec, Android uses this as a known custom type */
  
Value =
  QuotedPrintableBase64Bit7
    /* PEG.js does not backtrack; hence, this combined rule */

AddressParts =
  pobox:NotSemi ';' ext:NotSemi ';' street:NotSemi ';' local:NotSemi ';' region:NotSemi ';' postcode:NotSemi ';' country:NotSemi {
    return {
      'pobox': pobox,
      'ext': ext,
      'street': street,
      'local': local,
      'region': region,
      'postcode': postcode,
      'country': country
    };
  }
    /* PO Box, Extended Addr, Street, Locality, Region, Postal Code, Country Name */

OrgParts =
  org:NotSemi units:(';' NotSemi)* {
    return {
      'org': org,
      'units': units ? units.map(function(v){return v[1];}) : []
    };
  }
    /* First is organization name, rest are units. */

NameParts =
  last:NotSemi ';' first:NotSemi ';' middle:NotSemi ';' prefix:NotSemi ';' suffix:NotSemi {
    return {
      'last': last,
      'first': first,
      'middle': middle,
      'prefix': prefix,
      'suffix': suffix
    };
  }
    /* Family, Given, Middle, Prefix, Suffix */
  
CR =
  [\r]

LF =
  [\n]
  
CRLF =
  CR? LF

SPACE =
  ' '

HTAB =
  [\t]
  
WS =
  (SPACE / HTAB)+
  
WSLS =
  (SPACE / HTAB / CRLF)+
  
DIGIT =
  [0-9]
  
WordChar =
  [!"#$%&'()*+/0-9;<>?@A-Z\^_`a-z{|}~-]
    /* Printable us-ascii characters  except [ ]=:., */
  
Word =
  WordChar+ {
    return text();
  }
  
XWord =
  'X-'i [!"#$%&'()*+/0-9<>?@A-Z\^_`a-z{|}~-]+ {
    return text();
  }
    /* Printable us-ascii characters  except [ ]=:;., */
    /* Unlike the spec, this also excludes semicolon. PEG.js quantifiers are greedy. */
  
NotSemi =
  [^;\r\n]* '\\;'? [^;\r\n]* {
    return text();
  }
    /* Any character except for ';', which can be included by escaping it with '\' */
  
Bit7 =
  (WordChar / [\[\]=:., ])+ {
    return text();
  }
    /* Printable 7-bit us-ascii characters. */
  
QuotedPrintable =
  PText+ ('=' CRLF PText+)* {
    return text();
  }
  
PText =
  Octet / (WordChar / [\[\]:.,]) {
    return text();
  }
  
Octet =
  '=' (DIGIT / 'A' / 'B' / 'C' / 'D' / 'E' / 'F') (DIGIT / 'A' / 'B' / 'C' / 'D' / 'E' / 'F') {
    return text();
  }
  
Base64 =
  [A-Za-z0-9+/=]+ {
    return text();
  }
  
QuotedPrintableBase64Bit7 =
  Bit7 (CRLF '=' Bit7)* {
    return text();
  }