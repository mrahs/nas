vCardFile =
  WSLS? vCard+ WSLS?
  
vCard =
  'BEGIN' WS? ':' WS? 'VCARD' WS? CRLF+ Items CRLF* 'END' WS? ':' WS? 'VCARD'

Items =
  Items CRLF* Item /
  Item
  
Item =
  (Groups '.')? Name    Params? ':' Value CRLF /
  (Groups '.')? 'ADR'   Params? ':' AddressParts CRLF /
  (Groups '.')? 'ORG'   Params? ':' OrgParts CRLF /
  (Groups '.')? 'N'     Params? ':' NameParts CRLF /
  (Groups '.')? 'AGENT' Params? ':' vCard CRLF

Params =
  ';' WS? ParamList
  
ParamList =
  ParamList WS? ';' WS? Param /
  Param

Param =
  'TYPE' WS? '=' WS? PTypeVal /
  'VALUE' WS? '=' WS? PValueVal /
  'ENCODING' WS? '=' WS? PEncodingVal /
  'CHARSET' WS? '=' WS? CharsetVal /
  'LANGUAGE' WS? '=' WS? LangVal /
  'X-' Word WS? '=' WS? Word+ /
  KnownType

Groups =
  Groups '.' Word+ /
  Word+


Name =
  'LOGO' / 'PHOTO' / 'LABEL' / 'FN' / 'TITLE' / 
  'SOUND' / 'VERSION' / 'TEL' / 'EMAIL' / 'TZ' / 'GEO' / 'NOTE' / 
  'URL' / 'BDAY' / 'ROLE' / 'REV' / 'UID' / 'KEY' / 'MAILER' / 'X-' Word


CR =
  [\r]

LF =
  [\n]
  
CRLF =
  CR LF

SPACE =
  [ ]

HTAB =
  [\t]
  
WS =
  (SPACE / HTAB)+
  
WSLS =
  (SPACE / HTAB / CRLF)+
  
Word =
  [!"#$%&'()*+/0-9;<>?@A-Z\^_`a-z{|}~-]
  
Value =
  Bit7 / QuotedPrintable / Base64
  
Bit7 =
  (Word / [=:., ] / [\[\]])+

QuotedPrintable =
  (((PText / SPACE / HTAB)* PText)? '='? CRLF)+
  
PText =
  Octet / (Word / [:.,] / [\[\]])+
  
Octet =
  '=' (DIGIT / 'A' / 'B' / 'C' / 'D' / 'E' / 'F') (DIGIT / 'A' / 'B' / 'C' / 'D' / 'E' / 'F')
  
DIGIT =
  [0-9]
  
Base64 =
  [A-Za-z0-9+/=]+
  
PTypeVal =
  KnownType / 'X-' Word+
  
PValueVal =
  'INLINE' / 'URL' / 'CONTENT-ID' / 'CID' / 'X-' Word+

PEncodingVal =
  '7BIT' / '8BIT' / 'QUOTED-PRINTABLE' / 'BASE64' / 'X-' Word+
  
CharsetVal =
  Word+
  
LangVal =
  [a-zA-Z] ('-' [a-zA-Z])*
  
AddressParts =
  NotSemi ';' NotSemi ';' NotSemi ';' NotSemi ';' NotSemi ';' NotSemi ';' NotSemi // PO Box, Extended Addr, Street, Locality, Region, Postal Code, Country Name

OrgParts =
  (NotSemi ';')* NotSemi // First is organization name, rest is units

NameParts =
  NotSemi ';' NotSemi ';' NotSemi ';' NotSemi ';' NotSemi // Family, Given, Middle, Prefix, Suffix
  
NotSemi =
  ([^;]* ('\;' / '\\' CRLF))* [^;]*
  
KnownType =
  'DOM' / 'INTL' / 'POSTAL' / 'PARCEL' / 'HOME' / 'WORK'  /
	'PREF' / 'VOICE' / 'FAX' / 'MSG' / 'CELL' / 'PAGER'     /
	'BBS' / 'MODEM' / 'CAR' / 'ISDN' / 'VIDEO'              /
	'AOL' / 'APPLELINK' / 'ATTMAIL' / 'CIS' / 'EWORLD'      /
	'INTERNET' / 'IBMMAIL' / 'MCIMAIL'                      /
	'POWERSHARE' / 'PRODIGY' / 'TLX' / 'X400'               /
	'GIF' / 'CGM' / 'WMF' / 'BMP' / 'MET' / 'PMB' / 'DIB'   /
	'PICT' / 'TIFF' / 'PDF' / 'PS' / 'JPEG' / 'QTIME'       /
	'MPEG' / 'MPEG2' / 'AVI'                                /
	'WAVE' / 'AIFF' / 'PCM'                                 /
	'X509' / 'PGP'