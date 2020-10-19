vCards = 
  list:(vCard EOL?)* {
    var i;
    var vCards = [];
    for (i = 0; i < list.length; i++) {
      vCards.push(list[i][0]);
    }
      
  return vCards;
}
    
vCard =
  'BEGIN:VCARD' EOL fields:Field* 'END:VCARD' {
    var i, j, k, v;
    var vCard = {};
    for (i = 0; i < fields.length; i++) {
      if (fields[i][0] === null) {
        continue;
      }

      k = Object.keys(fields[i][0])[0];
      v = fields[i][0][k];

      if (k !== 'title') {
        if (!vCard[k]) {
          vCard[k] = v;
        } else if (Array.isArray(vCard[k])) {
          vCard[k].push(v);
        } else {
          vCard[k] = [vCard[k], v];
        }

        continue;
      }

      if (!vCard['org']) {
        continue;
      }

      if (Array.isArray(vCard['org'])) {
        for(j=0; j<vCard['org'].length; j++) {
          if (vCard['org'][j].title === '') {
            vCard['org'][j].title = v.title;
            break;
          }
        }
      } else {
        vCard['org'].title = v.title;
      }    
    }
        
  return vCard;
}
    
Field =
  EOL /
  Version EOL /
  Name EOL /
  Fullname EOL /
  Address EOL /
  Anniversary EOL /
  Birthday EOL /
  AndroidEvent EOL /
  Category EOL /
  Class EOL /
  Email EOL /
  Gender EOL /
  Geo EOL /
  IM EOL /
  IMX EOL /
  Lang EOL /
  Nickname EOL /
  AndroidNickname EOL /
  Note EOL /
  Org EOL /
  Title EOL /
  Rev EOL /
  Role EOL /
  Source EOL /
  Tel EOL /
  URL EOL /
  Net EOL /
  Photo EOL /
  Sound EOL /
  AndroidSound EOL
    
Version =
  'VERSION:' version:Float {
  return {'version': version};
}
    
Name =
  'N' charset:Charset? enctype:Enctype? ':' last:NotSemiColon ';' first:NotSemiColon ';' middle:NotSemiColon ';' prefix:NotSemiColon ';' suffix:NotSemiColon {
  return {'name':
    {
      'charset': charset || '',
      'enctype': enctype || '',
      'last': last,
      'first': first,
      'middle': middle,
      'prefix': prefix,
      'suffix': suffix
    }
  };
}

Fullname =
  'FN' charset:Charset? enctype:Enctype? ':' name:(Any (EOL QPWordMore)*) {
    return {'fullname':
      {
        'charset': charset || '',
        'enctype': enctype || '',
        'name': name[0] + name[1].map(function(v){return v[1];}).join('')
      }
  };
}

Address = 
  'ADR' type:Type? charset:Charset? enctype:Enctype? ':' pobox:NotSemiColon ';' neighborhood:NotSemiColon ';' street:NotSemiColon ';' city:NotSemiColon ';' state:NotSemiColon ';' zipcode:NotSemiColon ';' country:NotSemiColon {
  return {'address':
    {
      'type': type || '',
      'charset': charset || '',
      'enctype': enctype || '',
      'pobox': pobox,
      'neighborhood': neighborhood,
      'street': street,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'country': country
    }
  };
}

Anniversary = 
  'ANNIVERSARY:' date:Any {
  return {'event':
    {
      'date': date,
      'type': '',
      'title': 'anniversary'
    }
  };
}

Birthday =
  'BDAY:' date:Any {
  return {'event':
    {
      'date': date,
      'type': '',
      'title': 'birthday'
    }
  };
}

AndroidEvent = 
  'X-ANDROID-CUSTOM' charset:Charset? enctype:Enctype? ':vnd.android.cursor.item/contact_event;' date:NotSemiColon ';' type:NotSemiColon ';' title:NotSemiColon ';;;;;;;;;;;;' {
  return {'event':
    {
      'charset': charset || '',
      'enctype': enctype || '',
      'date': date,
      'type': type,
      'title': title
    }
  };
}

Category =
  'CATEGORIES:' catList:CSV {
    return {'category': catList};
  }

Class =
  'CLASS:' klass:Any {
    return {'class': klass};
  }

Email =
  'EMAIL' type:Type? ':' email:Any {
    return {
      'email': {
        'address': email,
        'type': type || ''
      }
    };
  }

Gender =
  'GENDER:' gender:Any {
    return {'gender': gender};
  }

Geo =
  'GEO:' geo:(Float ',' Float) {
    return {'geo': geo.join('')};
  }

IM =
  'IMPP:' service:NotColon ':' alias:NotColon {
    return {
      'im': {
        'service': service,
        'alias': alias
      }
    };
  }

IMX =
  'X-' service:('AIM'/'ICQ'/'JABBER'/'MSN'/'YAHOO'/'TWITTER'/'GOOGLE-TALK'/'GTALK'/'SKYPE-USERNAME'/'SKYPE'/'GADUGADU'/'QQ') Type? ':' alias:Any {
    return {
      'im': {
        'service': service,
        'alias': alias
      }
    };
  }

Lang =
  'LANG:' lang:Any {
    return {'lang': lang};
  }

Nickname =
  'NICKNAME:' nnameList:CSV {
    return {'nickname': nnameList};
  }

AndroidNickname =
  'X-ANDROID-CUSTOM' charset:Charset? enctype:Enctype? ':vnd.android.cursor.item/nickname;' nname:NotSemiColon ';' type:NotSemiColon ';' title:NotSemiColon ';;;;;;;;;;;;' {
  return {
    'nickname': {
      'nname': nname,
      'charset': charset || '',
      'enctype': enctype || ''
    }
  };
}

Note =
  'NOTE' charset:Charset? enctype:Enctype? ':' text:(Any (EOL QPWordMore)*) {
    return {'note':
      {
        'charset': charset || '',
        'enctype': enctype || '',
        'text': text[0] + text[1].map(function(v){return v[1];}).join('')
      }
  };
}

Org =
  'ORG' charset:Charset? enctype:Enctype? ':' org:Any {
    return {
      'org': {
        'charset': charset || '',
        'enctype': enctype || '',
        'org': org,
        'team': '',
        'title': ''
      }
    };
  }

Title =
  'TITLE' charset:Charset? enctype:Enctype? ':' title:Any {
    return {
      'title': {
        'title': title,
        'charset': charset || '',
        'enctype': enctype || ''
      }
    };
  }

Rev =
  'REV:' rev:Any {
    return {'rev': rev};
  }

Role =
  'ROLE:' role:Any {
    return {'role': role};
  }

Source =
  'SOURCE:' source:Any {
    return {'source': source};
  }

Tel =
  'TEL' type:Type? ':' tel:Any {
    return {
      'tel': {
        'number': tel,
        'type': type || ''
      }
    };
  }

URL =
  'URL:' url:Any {
    return {'url': url};
  }

Net =
  'X-SIP:' net:Any {
    return {'net': net};
  }

Photo =
  'PHOTO' media:Media_Url { return {'photo': media} } / 
  'PHOTO' media:Media_Data { return {'photo': media} } / 
  'PHOTO' media:Media_Enctype_MediaType { return {'photo': media} } / 
  'PHOTO' media:Media_MediaType_Enctype { return {'photo': media} }

Sound =
  'SOUND' media:Media_Url { return {'sound': media} } / 
  'SOUND' media:Media_Data { return {'sound': media} } / 
  'SOUND' media:Media_Enctype_MediaType { return {'sound': media} } / 
  'SOUND' media:Media_MediaType_Enctype { return {'sound': media} }

AndroidSound =
  'SOUND;X-IRMC-N:;;;;' {
    return {'ignored': text()};
  }

Media_Url =
  mediatype:Mediatype ':' url:Any {
    return {
      'mediatype': mediatype[2] || '',
      'url': url,
      'enctype': '',
      'data': ''
    };
  }

Media_Data =
  ':data:' mediatype:NotColonOrSemi ';' enctype:NotComma ','  data:(Any (EOL (Media_More EOL)*)?) {
    return {
      'mediatype': mediatype,
      'url': '',
      'enctype': enctype,
      'data': data[0] + (data[1] ? data[1][1].map(function(v){return v[0];}).join('') : '')
    }; 
  }

Media_Enctype_MediaType =
  enctype:Enctype mediatype:(';' ('MEDIA'? 'TYPE=')? NotColonOrSemi) ':' data:(Any (EOL (Media_More EOL)*)?) {
    return {
      'mediatype': mediatype[2] || '',
      'url': '',
      'enctype': enctype,
      'data': data[0] + (data[1] ? data[1][1].map(function(v){return v[0];}).join('') : '')
    }; 
  }

Media_MediaType_Enctype =
  mediatype:(';' ('MEDIA'? 'TYPE=')? NotColonOrSemi) enctype:Enctype ':' data:(Any (EOL (Media_More EOL)*)?) {
    return {
      'mediatype': mediatype[2] || '',
      'url': '',
      'enctype': enctype,
      'data': data[0] + (data[1] ? data[1][1].map(function(v){return v[0];}).join('') : '')
    }; 
  }

Media_More =
  ' ' more:Any {
    return more;
  }

Type =
  ';' 'TYPE='? type:(NotColonOrSemi (';' NotColonOrSemi)?) {
  return type[0] + (type[1] ? ';'+type[1][1] : '');
}

Mediatype =
  ';' ('MEDIA'? 'TYPE=')? mediatype:NotColonOrSemi {
    return mediatype;
  }

Charset =
  ';CHARSET=' charset:NotColonOrSemi {
  return charset;
}

Enctype =
  ';ENCODING=' enctype:NotColonOrSemi {
  return enctype;
}

CSV =
  csv:(NotComma (',' NotComma)*) {
    if (csv[1].length === 0) {
      return [csv[0]];
    }

    var res = [csv[0]];
    Array.forEach(csv[1], function(v){res.push(v[1]);});
    return res;
  }

NotColon = 
  [^:\n\r]* {
    return text();
}

NotSemiColon =
  [^;\n\r]* {
    return text();
  }

NotColonOrSemi =
  [^;:\n\r]* {
    return text();
  }

NotComma =
  [^,\n\r]* {
    return text();
  }

Any =
  [^\n\r]* {
    return text();
  }

QPWordMore =
  '=' word:Any {
  return word;
}

EOL = 
  [\r]?[\n]
    
Float =
  [+-]?[0-9]+([.][0-9]+)? {
  return text();
}