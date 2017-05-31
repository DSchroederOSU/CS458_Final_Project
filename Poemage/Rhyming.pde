//////////////////////Rhyme with rules///////////////////////////////////////

ArrayList<String> getPermutations(ArrayList< ArrayList<String> > data){
 ArrayList<String> prev = new ArrayList<String>(); 
 ArrayList<String> res = new ArrayList<String>(); 
 ArrayList<String> res2 = new ArrayList<String>(); 
 if(data.size() == 0){
   return res;
 }
 prev = data.get(0);
 if(data.size() == 1){
   res2.clear();
 for(int i = 0; i < data.get(0).size(); i++){  
  String[] check = split(data.get(0).get(i), "_");
  int freq = Collections.frequency(Arrays.asList(check), "null");
  if((float(freq)/float(check.length)) >= 0.5){
        //take out
  }else{
    res2.add(data.get(0).get(i));
  }
 }
 return res2;
 }
 for(int a = 0; a < data.size()-1; a++){ //through rows
 res.clear(); 
 //println(a+":"+prev);
      for(int b = 0; b < prev.size(); b++){ //through colums
        for(int c = 0; c < data.get(a+1).size(); c++){
          res.add(prev.get(b)+"_"+data.get(a+1).get(c));
          //println(res);
          //need to make sure not too many nulls
        }
      }
     //println(res);
     prev.clear();
     prev.addAll(res);
    }
    res2.clear();
    for(int i = 0; i < res.size(); i++){
      String[] check = split(res.get(i), "_");
      int freq = Collections.frequency(Arrays.asList(check), "null");
      if((float(freq)/float(check.length)) >= 0.5){
        //take out
      }else{
        /*if(combineRules){
        res2.add(res.get(i));
        }else{
        res2.add(res.get(i).replaceAll("_",""));
        }*/
        res2.add(res.get(i).replaceAll("_",""));
      }
    }
   //println(res); 
 return res2; 
}


//////////////////////Rhyme with rules 2///////////////////////////////////////

ArrayList<String> rhymePairRule2(Word _wrd1, Word _wrd2, rhymerule _rule, int w1num, int w2num, boolean isbimatch) {
  

  int comments = 1;

  Syllable[] syll1, syll2; 
  String onset1, nucleus1, coda1, onset2, nucleus2, coda2, stress1, stress2, next1, next2, nextOnset1, nextOnset2, combined1, combined2, leadingOnset1, leadingOnset2;
  //String[] rhyme = new String[0];
  
 ArrayList<String> rhyme = new ArrayList<String>();

  String str1 = new String(_wrd1.getLetters());
  String str2 = new String(_wrd2.getLetters());

  char[] wrd1 = _wrd1.getLetters();
  char[] wrd2 = _wrd2.getLetters();

  String eye1 = eyeRhyme(wrd1);
  String eye2 = eyeRhyme(wrd2);

  //syll1 = _wrd1.getSyllsFromArrayList(_wrd1.pronNum);
  //syll2 = _wrd2.getSyllsFromArrayList(_wrd2.pronNum);
  
  syll1 = _wrd1.getSylls();
  syll2 = _wrd2.getSylls();

  //println(syll1[0].returnString(syll1[0].getFullSyll())+syll1[0]._stress);
  //println(syll2[0].returnString(syll2[0].getFullSyll())+syll2[0]._stress);

  int s1 = syll1.length;
  int s2 = syll2.length;
  int comLength = (s1 <= s2) ? s1 : s2;
  int loc1, loc2, num1, num2; //locations of syllable in words
  
  ArrayList<String> tmp = new ArrayList<String>();
  ArrayList<String> tmp2 = new ArrayList<String>();
  
  if(comment){
  println("checking "+str1+"/"+str2);
  }

     //println("match size "+_rule.matches.size());
     if(comment){
     println(str1);
     }
     tmp = _rule.getMatches(syll1,wrd1,1,w1num,isbimatch, _wrd1);
     if(comment){
     println(str2);
     }
     tmp2 = _rule.getMatches(syll2,wrd2,2,w2num,isbimatch, _wrd2);
     
     tmp.retainAll(tmp2);
     
     tmp2.clear();
     for(int it = 0; it < tmp.size(); it++){
      if(tmp.get(it).length() > 0 && !tmp2.contains(tmp.get(it))){
       tmp2.add(tmp.get(it)); 
      }
     }
     if(comment){
     println("matches: "+tmp2 + _rule.noMatch);
     }
     if(tmp2.size() == 0 && _rule.noMatch){
      tmp2.add("noMatch"); 
     }
     
    rhyme = tmp2;
  
  return rhyme;
}


ArrayList<String> rhymePairRuleB(ArrayList<String> res, Word _wrd1, Word _wrd2, rhymerule _rule, int w2num, boolean isbimatch) {
  int comments = 1;
  Syllable[] syll1, syll2; 

  ArrayList<String> rhyme = new ArrayList<String>();
  String str2 = new String(_wrd2.getLetters());
  char[] wrd2 = _wrd2.getLetters();
  syll2 = _wrd2.getSylls();
  int s2 = syll2.length;
  int loc1, loc2, num1, num2; //locations of syllable in words
  ArrayList<String> tmp2 = new ArrayList<String>();
  ArrayList<String> tmp3 = new ArrayList<String>();
  ArrayList<String> tmp4 = new ArrayList<String>();
  
  ArrayList<String> commonRules = new ArrayList<String>();
     
  tmp3.addAll(res);
  
  if(comment){
    println(str2);
  }
     if(isbimatch){
       tmp2 = _rule.getMatches(syll2,wrd2,1,w2num,isbimatch, _wrd2);
     }else{
       tmp2 = _rule.getMatches(syll2,wrd2,2,w2num,isbimatch, _wrd2);
     }
     for(int i = 0; i < tmp2.size(); i++){
       tmp2.set(i,tmp2.get(i).replaceAll("_null_", ""));
     }    
     
     /*if(res.size() > 0){
     println("1: "+res);
     println("2: "+tmp2);
     }*/
     
     tmp4 = tmp2; 
     tmp3.retainAll(tmp2); 
     tmp2.clear();
     for(int it = 0; it < tmp3.size(); it++){
      if(tmp3.get(it).length() > 0 && !tmp2.contains(tmp3.get(it))){
       tmp2.add(tmp3.get(it)); 
      }
     }
     if(comment){
     println("matches: "+tmp2 + _rule.noMatch);
     }
     if(tmp2.size() == 0 && _rule.noMatch){
      tmp2.add("noMatch"); 
     }else if(tmp2.size() > 0 && _rule.noMatch){
      tmp2.clear(); 
     }
     
     if(_rule.mix == 1){
      if(_wrd1._word.equals(_wrd2._word)){
        tmp2.clear();
      }
     }
     
     if(tmp2.size() > 0){
       if(isbimatch){
      _wrd1.currBiMatch = tmp3;
      _wrd2.currBiMatch = tmp4;
       }else{
      _wrd1.currRes = tmp3;
      _wrd2.currRes = tmp4;
       } 
     }
     
    rhyme = tmp2;
  return rhyme;
}

ArrayList<String> rhymePairRuleSingle(Word _wrd1, rhymerule _rule, int w1num, boolean isbimatch) {
  int comments = 1;
  Syllable[] syll1, syll2;   
  ArrayList<String> rhyme = new ArrayList<String>();
  String str1 = new String(_wrd1.getLetters());
  char[] wrd1 = _wrd1.getLetters();
  syll1 = _wrd1.getSylls();

  int s1 = syll1.length;
  int loc1, loc2, num1, num2; //locations of syllable in words

  ArrayList<String> tmp = new ArrayList<String>();  
  if(comment){
  println("checking "+str1);
  }
  
     if(comment){
     println(str1);
     }
     if(isbimatch){
       tmp = _rule.getMatches(syll1,wrd1,2,w1num,isbimatch, _wrd1);
     }else{
       tmp = _rule.getMatches(syll1,wrd1,1,w1num,isbimatch, _wrd1);
     }
     for(int i = 0; i < tmp.size(); i++){
       tmp.set(i,tmp.get(i).replaceAll("_null_", ""));
     }
    rhyme = tmp;
  return rhyme;
}

//old material
///////////////////////////////RHYMING FUNCTIONS/////////////////////////////////

String reverseString(String str) {
  char[] chars = new char[str.length()];
  for (int i = 0; i < str.length (); i++) {
    chars[i] = str.charAt(i);
  }
  chars = reverse(chars);
  String str2 = new String(chars);
  return str2;
}

String eyeRhyme(char[] wrd) {
  String impStr = "";
  int on = 0;
  for (int i = 0; i < wrd.length; i++) {
    char[] c = {
      wrd[i]
    };  
    String cStr = new String(c);
    boolean isVowel = "aeiou".indexOf(cStr.toLowerCase()) != -1;
    boolean isConsonant = "bcdfghjklmnpqrstvwxyz".indexOf(cStr.toLowerCase()) != -1;
    if (isVowel) {
      on = 1;
      impStr += cStr;
    } else if (isConsonant) {
      if (on == 1) {
        impStr += cStr;
      }
    }
  }
  return impStr;
}
