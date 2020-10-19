/**
  vCard31Parser v1.0.0
  Based on:
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

vCardEntity =
	vcards:vCard* {
		return vcards;
	}

vCard =
	bgroup:(Group '.')? 'BEGIN'i ':' 'VCARD'i CRLF+
	lines:ContentLine+ 
	egroup:(Group '.')? 'END'i 	':' 'VCARD'i CRLF+ {
		var vcard = {};
		var name;
		var value;
		
		vcard.bgroup = bgroup || '';
		vcard.egroup = egroup || '';

		if (!lines) {
			return vcard;
		}

		Array.forEach(lines, function(line){
			name = Object.keys(line)[0];
			value = line[name];

			if (!vcard[name]) {
        vcard[name] = value;
      } else if (Array.isArray(vcard[name])) {
        vcard[name].push(value);
      } else {
        vcard[name] = [vcard[name], value];
      }
		});

		return vcard;
	}


ContentLine =
	g:(Group '.')? name:Name params:(';' Param)* ':' value:Value CRLF {
		var line = {};
		line[name.toLowerCase()] = {
			'group': g ? g[0] : '',
			'params': params || [],
			'value': value
		};

		return line;
	}

Group =
	(Alpha / Digit / '-')+ {
		return text();
	}

Name =
	XName / IanaToken {
		return text();
	}

IanaToken =
	(Alpha / Digit / '-')+
	/* identifier registered with IANA */ {
		return text();
	}

XName =
	'x-'i (Alpha / Digit / '-')+ {
		return text();
	}

Param =
	pname:'X-IRMC-N' '=' pvalue:'' {
		return {
			'name': pname,
			'value': pvalue
		};
	} 
	/* Unlike the spec, this parameter appears in Android vCard file. */
	/
	pname:ParamName  '=' pvalue:(ParamValue (',' ParamValue)*) {
		var arr = [pvalue[0]];
		if (pvalue[1]) {
			Array.forEach(pvalue[1], function(v){
				arr.push(v[1]);
			});
		}

		return {
			'name': pname,
			'value': arr
		};
	}

ParamName =
	XName / IanaToken {
		return text();
	}

ParamValue =
	Ptext / QuotedString {
		return text();
	}

Ptext =
	SafeChar* {
		return text();
	}

Value =
	ValueChar* {
		return text();
	}

QuotedString =
	DQuote QSafeChar* DQuote {
		return text();
	}

NonAscii =
	[\x80-\xFF]

QSafeChar =
	WSP / '\x21' / [\x23-\x7E] / NonAscii
	/* Any character except CTLs and DQuote */

SafeChar =
	WSP / '\x21' / [\x23-2B] / [\x2D-\x39] / [\x3C-\x7E] / NonAscii
	/*  Any character except CTLs, DQuote, ";", ":", "," */

ValueChar =
	WSP / VChar / NonAscii
	/* Any textual character */

Alpha =
	[\x41-\x5A] / [\x61-\x7A]
	/* A-Z / a-z */

CR =
	'\x0D'

LF =
	'\x0A'

CRLF =
	CR? LF

Digit =
	[\x30-\x39]
	/* 0-9 */

DQuote =
	'\x22'
	/* " */

HTAB =
	'\x09'
	/* horizontal tab */

SP =
	'\x20'

WSP =
	SP / HTAB
	/* white space */

VChar =
	[\x21-\x7E]
	/* visible (printing) characters */