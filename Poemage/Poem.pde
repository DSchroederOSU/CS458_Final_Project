class Poem {

  String _title;
  String _author;
  Line[] _lines;

  Poem( String title, String author, Line[] l ) {
    _title = title;
    _author = author;
    _lines = l;
  }

  String getTitle() {
    return _title;
  }

  String getAuthor() {
    return _author;
  }

  Line getLine( int i ) {
    return _lines[i];
  }

  Line[] getAllLines() {
    return _lines;
  }

  int getNumLines() {
    return _lines.length;
  }
}


//---------------------//
//
class Line {
  Word[] _words;
  int lnum;

  Line( String[] words, int num ) {
    lnum = num;
    _words = new Word[words.length];
    for ( int i = 0; i < words.length; i++ ) {
      _words[i] = new Word( words[i], i, lnum);
    }
  }

  Word[] getWords() {
    return _words;
  }

  Word getWord( int i ) {
    return _words[i];
  }

  int getNumWords() {
    return _words.length;
  }
}

//---------------------//
//
class Word {
  int _loc; //maybe not necessary
  int _line;
  String _word;
  String _displayWord;
  char[] _letters;
  float x, y, xw;    //for changing pronunciation
  boolean isWord = true;
  int wrdcount = 0;
  Syllable[] _syllables;
  int[] _stressedVowels;
  Syllable[][] _2DSyllables;    //maybe easier
  node _node;
  int nodeId;
  boolean ws = false;

  int _pronunciations;
  int pronNum;
  boolean _exists = true; 
  boolean _lts = false;
  int selected = -1;
  float _x;
  float _y;
  boolean hover = false;
  //String POS;
  Phoneme[] _phonemes;
  String _phonetics = "";
  ArrayList< ArrayList<Phoneme> > phonemeArray;
  ArrayList< ArrayList<Syllable> > syllableArray;
  ArrayList<String> currBiMatch;
  ArrayList<String> currRes;

  /*Word( String word) {
   _word = word;
   analyzePhonemes();
   }*/

  Word( String word, int loc, int line) {
    wrdcount = idCount;
    //pronNum = pronNumbers[wrdcount];
    pronNum = 0;
    if (pronNum != 0) {
      println(wrdcount+" "+word+" "+pronNum);
    }
    _displayWord = word; 
    /*if(word.length() > 0 && Character.isWhitespace(word.charAt(0))){
      println("yep");
       ws = true; 
    }*/
    
    if (word.length() == 0 || Character.isWhitespace(word.charAt(0))) {
      isWord = false;
      ws = true;
    }    //for speedup, only process ig isWord = true
    word = word.toLowerCase().replaceAll("[\\]\\[.,;:()?!-]", "");
    word = word.replaceAll("\u2019","'");
    word = word.replaceAll("\u2014","");
    _word = word;
    _loc = loc;
    _line = line;
    _letters = word.toCharArray();
    phonemeArray = new ArrayList< ArrayList<Phoneme> >();
    syllableArray = new ArrayList< ArrayList<Syllable> >();
    processWord(word);
    idCount++;  //increment count
  }
  
  void shuffle(){
   if(syllableArray.size() == 1) return;
   //int before = pronNum;
   int r = (int)random(syllableArray.size());
   /*if(_displayWord.equals("wind")){
     println(before+" : "+r);
   }*/
   pronNum = r;
  }
  
  float getNodeX(int m){
    return nodeLocs.get(nodeId).getX(m);
  }
  
  float getNodeX2(int m){
    return nodeLocs.get(nodeId).getX(m)+textWidth(_displayWord)/2;
  }
  
  float getNodeX(){
    return nodeLocs.get(nodeId).getX();
  }
  
  float getNodeX2(){
    return nodeLocs.get(nodeId).getX()+textWidth(_displayWord)/2;
  }
  
  float getNodeY(){
    return nodeLocs.get(nodeId).getY();
  }
  
  void addtoNode(pointer ptr){
    nodeLocs.get(nodeId).allmembers.add(ptr);
  }

  void processWord(String word) {
    word = trim(word);
    String tmp = "";
    String ltsTmp = "";
    ArrayList<String> tmpArray = new ArrayList<String>();    //potential space sink
    //ArrayList<String> customProns = new ArrayList<String>(); 
    ArrayList<Syllable> tmpSylls = new ArrayList<Syllable>();

    //check if word exists
    tmp = _cmuMap.getFirstPhoneme(word).replaceAll("_", " ");
    if (tmp == "?" && (word.trim().length() == 0 || lts.syllabifiedPhones(word.trim()).equals("null"))) {    //memory suck! fixed this! calculates twice each time
      _exists = false;

      //println("using LTS on '"+word+"' : " + lts.syllabifiedPhones(word));
      //return;
    } else {                  //only proceed if word exists. loop through all pronunciations

      if (tmp == "?") {
        //tmpArray.clear();
        //tmpArray.add(ltsTmp);
        tmpArray.addAll(lts.LTSphones(word.trim()));
        _lts = true;
      } else {
        tmpArray.clear();
        //customProns.clear();
        tmpArray.addAll(_cmuMap.getPhonemes(word));
        //println(tmp);
        _pronunciations = tmpArray.size();
        //println(_pronunciations);
      }
      if (customPron[wrdcount] != null && customPron[wrdcount].length() > 0) {
        //check is valid
        //println("tmpArray: "+tmpArray+" "+_cmuMap.getPhonemes(word));
        //println("Custom Pron:"+customPron[wrdcount]);
        //Arrays.asList(customPron[wrdcount].split(":"));
        //customProns.addAll(Arrays.asList(customPron[wrdcount].split(":"));
        //tmpArray.addAll(customProns);
        tmpArray.addAll(Arrays.asList(customPron[wrdcount].split(":"))); 
        println("tmpArray: "+tmpArray);
        //}
      }
      _2DSyllables = new Syllable[tmpArray.size()][];
      _stressedVowels = new int[tmpArray.size()];
      //processProns(tmpArray);
      for (int sz = 0; sz < tmpArray.size (); sz++) {

        try {
        tmp = tmpArray.get(sz).replaceAll("_", " ");
        String[] tmp0 = tmp.split(":");
        if (tmp0.length == 2) {
          _pronunciations = int(tmp0[1]);
        } else {              
          _pronunciations = 0;
        }
        String tmp1 = tmp0[0];
        int sv = 0; //if something like and - will use first syllable
        analyzePhonemes(trim(tmp1));
        String[] sylls = tmp1.split("-");
        _syllables = new Syllable[sylls.length];
        //tmpSylls.clear();
        syllableArray.add(new ArrayList<Syllable>());
        for (int i =0; i < sylls.length; i++) {
          //println("Syll" + i + ": ");
          Syllable _syll = new Syllable(trim(sylls[i]), _pMap, i);
          if (_syll._stress.equals("1")) {
            sv = i; 
            //find char in word.
          }
          _syllables[i] = _syll;
          syllableArray.get(syllableArray.size()-1).add(_syll);
          _syll.returnString(_syll.getFullSyll());  //what's this part? eek...
        }
        //syllableArray.add(tmpSylls);    //add pronunciation
        _stressedVowels[sz] = sv;
        _2DSyllables[sz] = _syllables;  //may not work...
        //println(tmp1);
        //println(_pronunciations);
        } /*catch(){ //catch null pointer exception and Not found...
          
        }*/finally {
         
         }
      }
    } //end of else
  }

  /*void processProns(ArrayList<String> tmpArray){
   for (int sz = 0; sz < tmpArray.size(); sz++) {
   
   try {
   String tmp = tmpArray.get(sz).replaceAll("_", " ");
   String[] tmp0 = tmp.split(":");
   if (tmp0.length == 2) {
   _pronunciations = int(tmp0[1]);
   } 
   else {              
   _pronunciations = 0;
   }
   String tmp1 = tmp0[0];
   int sv = 0; //if something like and - will use first syllable
   analyzePhonemes(trim(tmp1));
   String[] sylls = tmp1.split("-");
   _syllables = new Syllable[sylls.length];
   //tmpSylls.clear();
   syllableArray.add(new ArrayList<Syllable>());
   for (int i =0; i < sylls.length; i++) {
   //println("Syll" + i + ": ");
   Syllable _syll = new Syllable(trim(sylls[i]), _pMap, i);
   if(_syll._stress.equals("1")){
   sv = i; 
   //find char in word.
   }
   _syllables[i] = _syll;
   syllableArray.get(syllableArray.size()-1).add(_syll);
   _syll.returnString(_syll.getFullSyll());  //what's this part? eek...
   }
   //syllableArray.add(tmpSylls);    //add pronunciation
   _stressedVowels[sz] = sv;
   _2DSyllables[sz] = _syllables;  //may not work...
   //println(tmp1);
   //println(_pronunciations);
   } finally {
   
   }
   }
   }*/

  /*ArrayList<String> isValid(String words){
   //check agrees with syllabified arphabet
   ArrayList<String> tmp = new ArrayList<String>(Arrays.asList(words.split(":"));
   return tmp;
   }*/

  void analyzePhonemes(String word) {
    String s, stmp, punc;
    String[] p;
    //String Defs = "";

    if ( word.length() != 0 ) {
      /*if (_word.indexOf(".") == _word.length()-1 || _word.indexOf(",") == _word.length()-1 || _word.indexOf(";") == _word.length()-1
       || _word.indexOf(":") == _word.length()-1 || _word.indexOf("-") == _word.length()-1) {
       punc = _word.substring(_word.length()-1);
       s = _cmuMap.getFirstPhoneme( _word );
       } 
       else {
       s = _cmuMap.getFirstPhoneme( _word );
       }*/

      //s = RiTa.getPhonemes( _word );

      s = word;
      s = s.replaceAll("-", "");
      //println(s);
      p = splitTokens( s, " " );
      //println(p);
      _phonemes = new Phoneme[p.length];

      for ( int i = 0; i < p.length; i++ ) {
        //println(p[i]);
        _phonemes[i] = new Phoneme(p[i], _pMap);
        _phonetics += _phonemes[i]._ppv;
      }
    } else {
      _phonemes = null;
    }
  }

  String getPhonetics(Phoneme[] tmp) {
    String tmpStr = "";
    for (int i = 0; i < tmp.length; i++) {
      tmpStr += tmp[i]._ppv;
    } 
    return tmpStr = "";
  }

  String getWord() {
    return _word;
  }

  String getDisplayWord() {
    return _displayWord;
  }

  char[] getLetters() {
    return _letters;
  }

  Syllable[] getSylls() {
    //return _syllables;
    if (pronNum < _2DSyllables.length) {
      return _2DSyllables[pronNum];
    } else { 
      return _2DSyllables[0];
    }
  }

  int getStressedVowel() {
    if (pronNum < _stressedVowels.length) {
      return _stressedVowels[pronNum];
    } else { 
      return 0;
    }
  }

  Syllable[] getSylls(int which) {
    //return _syllables;
    if (_2DSyllables.length > which) {
      return _2DSyllables[which-1];
    } else {
      return _2DSyllables[_2DSyllables.length - 1];
    }
  }

  Syllable[] getSyllsFromArrayList(int which) {
    //return _syllables;
    if (syllableArray.size() > which) {
      return syllableArray.get(which-1).toArray(new Syllable[syllableArray.get(which-1).size()]);
    } else {
      return syllableArray.get(syllableArray.size()-1).toArray(new Syllable[syllableArray.get(syllableArray.size()-1).size()]);
    }
  }

  int getPronunciations() {
    return _pronunciations;
  }

  int getNumPhonemes() {
    return _phonemes.length;
  }

  Phoneme getPhoneme( int i ) {
    return _phonemes[i];
  }

  boolean doesPhonemeExistInWord( String p ) {
    for ( int i = 0; i < _phonemes.length; i++ ) {
      if ( _phonemes[i].getPhoneme().equalsIgnoreCase(p) ) return true;
    }
    return false;
  }
  
  Word getNext(int i){
   //println("getting next"); 
   if(_poem._lines[_line]._words.length > _loc+i){
    //println(_poem._lines[_line]._words[_loc+i]._displayWord); 
    return _poem._lines[_line]._words[_loc+i];
   } else {
    return null; 
   }
  }
  
  Word getPrev(int i){
   if(_loc-i >=0){
    return _poem._lines[_line]._words[_loc-i];
   } else {
    return null; 
   }
  }



  String printWrd() {
    String str = "";
    for (int i = 0; i < _syllables.length; i++) {
      if (i > 0)
        str += " - ";
      str += _syllables[i].returnString(_syllables[i].getFullSyll());
    }
    return str + " (" + _pronunciations + ") ";
  }

  void hover() {
    if (mouseX >= (_x+31) && mouseX <= _x+textWidth(_displayWord+31) && mouseY >= (_y-20+35) && mouseY <= (_y+20+45)) {
      hover = true;
    } else {
      hover = false;
    }
  }

  void select() {
    if (mouseX >= (_x+31) && mouseX <= _x+textWidth(_displayWord+31) && mouseY >= (_y-20+35) && mouseY <= (_y+20+45)) {
      selected = -selected;
    }
  }
}


//---------------------//
//
class Phoneme {
  char _type; //c: consonant, v: vowel 
  String _voice;
  String _place; //bilabial, labio-dental, lingua-dental, lingua-alveolar, lingua-palatal, lingua-velar, glottal 
  String _chars; //actual letters
  String _phone; //liquid, fricative, etc...
  String _stress; //0, 1, 2 (none, primary, secondary). only for vowell
  //add things like mouth placement, length, pitch, etc later... 
  String _vlength;
  String _phoneme;
  String _ppv = "";
  String _Pp = ""; //manner and place
  String _Pv = ""; //manner and voice
  String _pv = ""; //place and voice

  String[] mpv = new String[3];

  //String m = ""; //manner
  //String p = ""; //place
  //String v = ""; //voice



  /*Phoneme( String p) {
   _phoneme = p;
   }*/

  Phoneme(String _phoneme, pMap _pMap) { 
    //println("Constructing phoneme");
    if (_phoneme.indexOf("0") != -1 || _phoneme.indexOf("2") != -1 || _phoneme.indexOf("1") != -1 ) {
      _stress = _phoneme.substring(_phoneme.length() - 1);
      //println(_stress); 
      _phoneme = _phoneme.substring(0, _phoneme.length() - 1);
      //println(_phoneme);
    }

    _chars = _phoneme;
    //println("Phoneme:"+_phoneme);
    String[] tmp = split(_pMap.getPhone(_phoneme), ":");
    //_phone = _pMap.getPhone(_phoneme);
    _phone = tmp[0];

    //get type
    if ( _phone.equals("vowel") || _phone.equals("V")) {
      _type = 'v';
      _vlength = tmp[3];
    } else {
      _type = 'c';
    }

    if (tmp.length >= 3) {
      _voice = tmp[1];
      _place = tmp[2];
    }

    _ppv = _phone + _voice + _place;
    _Pp = _phone + _place;
    _Pv = _phone + _voice;
    _pv = _place + _voice;
    mpv[0] = _phone;
    mpv[1] = _place;
    mpv[2] = _voice;


    //println("chars: " + _chars);
    //println("phone: " + _phone);
    //println("type: " + _type);
    //println("stress: " + _stress);
  }

  char getType() {
    return _type;
  }
  String getChars() {
    return _chars;
  }
  String getPhone() {
    return _phone;
  }
  String getStress() {
    return _stress;
  }
  String getPhoneme() {
    return _chars;
  }
}


//---------------------//
//syllable class
class Syllable {
  int _index;        //syll # in word
  String _stress;       //passed from nucleus
  int nIndex = 0;       //array index of the nucleus. 
  Phoneme[] _onset = new Phoneme[0];
  Phoneme _nucleus;
  Phoneme[] _coda = new Phoneme[0];
  Phoneme[] _fullSyll = new Phoneme[0];
  String _phonetics = "";
  String _codaPpv = "";
  String _onsetPpv = "";
  String _nucleusPpv = "";
  String _codaPv = "";
  String _onsetPv = "";
  String _nucleusPv = "";
  String _codaPp = "";
  String _onsetPp = "";
  String _nucleusPp = "";
  String _codapv = "";
  String _onsetpv = "";
  String _nucleuspv = "";
  String _syllString = "";

  //constructor
  Syllable(String _syllable, pMap _pMap, int _ind) {
    _syllString = _syllable;
    _index = _ind;
    String[] tmp = split(_syllable, " ");
    for (int i = 0; i < tmp.length; i++) {      //create and fill phoneme vec
      //_fullSyll = new phoneme[tmp.length];
      Phoneme _phoneme = new Phoneme(tmp[i], _pMap);
      _fullSyll = (Phoneme[])append(_fullSyll, _phoneme);
      if (nIndex == 1) {
        _coda = (Phoneme[])append(_coda, _phoneme);
        _codaPpv += _phoneme._ppv;
        _codaPp += _phoneme._Pp;
        _codaPv += _phoneme._Pv;
        _codapv += _phoneme._pv;

        //println("coda: "+ _phoneme.getChars());
      }
      if (_phoneme.getType() == 'v') {
        _nucleus = _phoneme;
        _nucleusPpv = _phoneme._ppv;
        _nucleusPv = _phoneme._Pv;
        _nucleusPp = _phoneme._Pp;
        _nucleuspv = _phoneme._pv;
        _stress = _phoneme.getStress();
        //println("nucleus: " + _phoneme.getChars());
        //println("stress: " + _stress);
        nIndex = 1;
      }
      if (nIndex == 0) {
        _onset = (Phoneme[])append(_onset, _phoneme);
        _onsetPpv += _phoneme._ppv;
        _onsetPv += _phoneme._Pv;
        _onsetPp += _phoneme._Pp;
        _onsetpv += _phoneme._pv;
        //println("Onset: " + _phoneme.getChars());
      }
    }
  }

  Phoneme[] getFullSyll() {
    return _fullSyll;
  }
  Phoneme[] getOnset() {
    return _onset;
  }

  String getFullSyllStr() {
    return returnString(_fullSyll);
  }

  String getOnsetStruct(String parts) {
    String res = "";
    for (int i = 0; i < _onset.length; i++) {
      for (int j = 0; j < parts.length (); j++) {
        int p = (parts.charAt(j) == 'm') ? 0 : (parts.charAt(j) == 'p') ? 1 : 2 ;
        res += ""+_onset[i].mpv[p];
      }
    }
    return res.replaceAll(" ", "");
  }

  String getNucleusStruct(String parts) {
    String res = "";
    for (int j = 0; j < parts.length (); j++) {
      int p = (parts.charAt(j) == 'm') ? 0 : (parts.charAt(j) == 'p') ? 1 : 2 ;
      res += ""+_nucleus.mpv[p];
    }
    return res.replaceAll(" ", "");
  }

  String getCodaStruct(String parts) {
    String res = "";
    for (int i = 0; i < _coda.length; i++) {
      for (int j = 0; j < parts.length (); j++) {
        int p = (parts.charAt(j) == 'm') ? 0 : (parts.charAt(j) == 'p') ? 1 : 2 ;
        res += ""+_coda[i].mpv[p];
      }
    }
    return res.replaceAll(" ", "");
  }

  Phoneme getLeadingOnset() {
    return _onset[0];
  }

  Phoneme[] getCoda() {
    return _coda;
  }
  Phoneme getNucleus() {
    return _nucleus;
  }
  String getStress() {
    return _stress;
  }
  int getIndex() {
    return _index;
  }
  String returnString(Phoneme[] _phonemeArray) {
    String str = "";
    for (int i = 0; i < _phonemeArray.length; i++) {
      str += _phonemeArray[i].getChars() + "";  //spacing between chars...
    }
    //println(str);
    return str;
  }

  String returnStringsp(Phoneme[] _phonemeArray) {
    String str = "";
    for (int i = 0; i < _phonemeArray.length; i++) {
      if (i > 0) {
        str += " ";
      }
      str += _phonemeArray[i].getChars() + "";  //spacing between phonemes...
      if (_phonemeArray[i] == _nucleus) {
        str += _stress;
      }
    }
    //println(str);
    return str;
  }

  String returnString(Phoneme _phoneme) {
    return ""+_phoneme.getChars();
  }
}

