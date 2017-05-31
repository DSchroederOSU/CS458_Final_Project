//RhymeDesign classes
//rhymerule
//matchU

class rhymerule {
  String name;
  int type = 2; //0 is syll, 1 is chars...if nothing, go with sylls.
  String strRule;
  boolean bimatch = false;
  boolean noMatch = false;
  int crossWrd = 0;
  int bcrossWrd = 0;
  String rule = "";
  int stressedSyll = 0;
  String matchingStr = "";
  String matchingSylls = "";
  String stresses = "";
  int l, r;
  ArrayList<String> sylls = new ArrayList<String>();
  ArrayList<String> syllsNoP = new ArrayList<String>();
  ArrayList<String> phones = new ArrayList<String>();
  ArrayList<String> charClusters = new ArrayList<String>();
  ArrayList< ArrayList<Integer> > ellipses = new ArrayList< ArrayList<Integer> >();
  ArrayList< ArrayList<matchU> > matches = new ArrayList< ArrayList<matchU> >(); //2d for "ors"
  ArrayList< ArrayList<matchU> > bimatches = new ArrayList< ArrayList<matchU> >();
  
  ArrayList< ArrayList<matchU> > currmatches = new ArrayList< ArrayList<matchU> >();
  
  ArrayList<matchU> orSeg = new ArrayList<matchU>(); //temporarily holds "ors"

  String textValue = "";
  int mix;

  rhymerule(String _rule) {
    strRule = _rule;
    //name = "custom "+rules.size();
    processRule3();
    if(comment){
    printRule2();
    }
  }
  rhymerule(String _name, String _rule) {
    strRule = _rule; 
    name = _name;
    processRule3();
    if(comment){
    printRule2();
    }
  }

  void processRule3() {
    String[] bitmp = split(strRule, '&'); 
    String seg = "";
    int t, stress, ind_b, ind_e, bn, en, numEs, _word;
    boolean struct = false;
    String subt = "";
    if (bitmp.length == 2) {
      bimatch = true;
      if(comment)
      println("bimatch!");
    }
    for (int i = 0; i < bitmp.length; i++) {
      int w = 0;
      boolean advWrd = false;
      String[] segWords = split(bitmp[i], ":"); //iterate through multiple words  
      if(segWords.length > 1 && i == 0){
       println("cross word!");
       crossWrd = segWords.length-1;
      }else if(segWords.length > 1 && i > 0){
       println("b cross word!");
       bcrossWrd = segWords.length-1;
      }   
      boolean segOn = false;
      //for(int w = 0; w < segWords.length; w++){      
      seg = bitmp[i].replaceAll("\\.\\.\\.", ".").replaceAll(" ", "");
      if(comment)
      println(seg);  
      //String[] rSplit = split(seg, '-');
      //String seg2 = seg.replaceAll("[\\[\\]*!|']", "").replaceAll("_\\{.+?\\}", "");
      int c = 0; 
      int B = 0;
      ellipses.clear();
      for(int ii = 0; ii < segWords.length; ii++){
      segWords[ii] = segWords[ii].replaceAll("\\.\\.\\.", ".").replaceAll(" ", "");
      ellipses.add(new ArrayList<Integer>()); 
      c = 0; 
      while (segWords[ii].indexOf (".", c) != -1) {
        c = segWords[ii].indexOf(".", c);
        ellipses.get(ii).add(c);
        c += 1;
      }
      }
      //numEs = ellipses.size();
      int syllnum = 0;
      int charnum = 0;
      //boolean segOn = false;
      boolean orOn = false;  //for [O] | [C]
      boolean addOr = false;
      boolean tildeOn = false; //for ~[C]
      struct = false;
      boolean req = false;  //for O` and C`
      //_word = 0;
      int advancej = 0;
      int wrdB = 0;
      for (int j = 0; j < seg.length (); j++) {
       String[] rSplit = split(segWords[w], '-');
       String seg2 = segWords[w].replaceAll("[\\[\\]*!|']", "").replaceAll("_\\{.+?\\}", "");
       numEs = ellipses.get(w).size();
       
        advancej = 0;
        req = false;
        if(j == 0 && seg.charAt(j) == '!'){
          noMatch = true;
          continue;
        } else if(seg.charAt(j) == ':'){
          w++;
          //next word! reset syllnum / charnum
          syllnum = 0;
          charnum = 0;
          wrdB = j;
          continue;
        } else if (seg.charAt(j) == '[') {
          segOn = true;
          continue;
        } else if (seg.charAt(j) == ']') {
          segOn = false;
          if (orOn) {
            //addOr = true;
            genOrPerms(i);
            orOn = false;
          } 
          if (tildeOn) {
            tildeOn = false;
          }
          continue;
        } else if (seg.charAt(j) == '-') {
          syllnum++;
          continue;
        } else if (seg.charAt(j) == '|') {
          orOn = true;
          continue;
        } else if (seg.charAt(j) == '~' || seg.charAt(j) == '`') {
          //tildeOn = true;
          continue;
        } else if(seg.charAt(j) == '\'' || seg.charAt(j) == '^' || seg.charAt(j) == '*'){
          //this will be taken into account later
          continue; 
        } else {
          t = (seg.charAt(j) == 'O' || seg.charAt(j) == 'N' || seg.charAt(j) == 'C') ? 0 : (seg.charAt(j) == '.') ? 2 : 1;
          if (t == 2){ //ellipse
           String segt = seg.replaceAll("_\\{.+?\\}", "");
            type = (seg.indexOf("A") != -1 || seg.indexOf("B") != -1 || seg.indexOf("Y") != -1 || anylowercase(segt)) ? 1 : 0; //or if lowercase...
            subt = ""+seg.charAt(j);
            struct = false;
            stress = 10;
            if(type == 1 && segOn){
            if (seg.length() > seg.indexOf(']', j)+1) {
              char cht = seg.charAt(seg.indexOf(']', j)+1);
              mix = (cht == '*') ? 1 : 0;
            } else {
              mix = 0;
            }
            } else {
             mix = 10; 
            }
            
          } else if (t == 0) { //sylls!
            type = 0;
            stress = (rSplit[syllnum].indexOf('\'') != -1) ? 1 : (rSplit[syllnum].indexOf('^') != -1) ? 2 : 0 ;
            if ((seg.length()>j+1 && seg.charAt(j+1) == '_') || (seg.length()>j+2 && seg.charAt(j+1) == '`' && seg.charAt(j+2) == '_') ) {
              //extract struct rule
              struct = true;
              //structStr = seg.substring(seg.indexOf('{',j)+1,seg.indexOf('}',j));
              advancej = seg.indexOf('}', j);
              
              if(seg.substring(j, seg.indexOf('}', j)+1).indexOf("`") != -1){
                req = true;
              }
              subt = ""+seg.substring(j, seg.indexOf('}', j)+1).replace("`","");
              if(comment)
              println(subt);
            } else {
              if(seg.length()>j+1 && seg.charAt(j+1) == '`' && (seg.charAt(j) == 'O' || seg.charAt(j) == 'C')){
              req = true;
              //advancej = 1;
              }
              struct = false;
              subt = ""+seg.charAt(j);
            }
            mix = 10;
            //subt = ""+seg.charAt(j);
          } else if (t==1) { //chars!
           type = 1;
            stress = 10; 
            if(!segOn){
            mix = 10;
            subt = ""+seg.charAt(j);
            }else{
            if (seg.length() > seg.indexOf(']', j)+1) {
              char cht = seg.charAt(seg.indexOf(']', j)+1);
              mix = (cht == '*') ? 1 : 0;
            } else {
              mix = 0;
            }
            
            int A = ( seg.indexOf(']', j) < seg.indexOf('.', j)) ? seg.indexOf(']', j) : (seg.indexOf('.', j) < 0) ? seg.indexOf(']', j) : seg.indexOf('.', j);
            subt = seg.substring(j, A); //get character rhyme seg, e.g. AABA - will make things easier
            B = subt.replaceAll("_\\{.+?\\}", "").replaceAll("'", "").length();
            advancej = A-1; //skip to end
            //advancej = seg.indexOf('.', j)-1;
          if(comment)  
          println("subt: "+subt + " " + subt.replaceAll("_\\{.+?\\}", ""));

            if (subt.indexOf('_') != -1) { //pass structural rhyme onto match function
              struct = true;
            } else {
              struct = false;
            }
            }
          } else {
            struct = false;
            stress = 10;
            mix = 10;
            subt = "";
          }
          
          ind_b = (t == 0) ? syllnum : charnum;
          ind_e = (t == 0) ? rSplit.length - syllnum - 1 : seg2.length()-charnum-1; //but what about structure.
          if(comment){
          println("b: "+ind_b);
          println("e: "+ind_e);
          }
          
          //for ellipses
          if(t == 2 && type == 0){
              ind_b = syllnum;
              ind_e = rSplit.length - syllnum - 1;
              if(comment)
              println("rsplit: "+subt+ " "+rSplit.length);
          }else if(t == 2 && type == 1){
              ind_b = charnum;
              ind_e = seg2.length()-charnum-1;
          }

          bn = en = 0;
          for (int k = 0; k < ellipses.get(w).size (); k++) {  //just look at outside the braket
            if (ellipses.get(w).get(k) < j-wrdB) {
              bn++;
            } else if (ellipses.get(w).get(k) > j-wrdB) {
              en++;
            }
          }
          
          if (i == 0) {
            if (addOr) {  //generate permutations
              addOr = false; //only want to do once!
              //genOrPerms(i);
              /*for(int l = 0; l < matches.size(); l++){
              matches.get(l).add(new matchU(t, ind_b, ind_e, bn, en, numEs, subt, stress, mix, struct, tildeOn, segOn));
              }*/
            } else if(orOn && segOn){
              orSeg.add(new matchU(t, ind_b, ind_e, bn, en, numEs, subt, stress, mix, struct, tildeOn, segOn, w,req));
            } else {
              //println("adding match "+seg+" t: "+ t +", ind_b: "+ ind_b +", ind_e: "+ ind_e +", bn: "+ bn +", en: "+ en +", sebt: "+ subt +", stress: "+ stress +", mix: "+ mix);
              if(matches.size() == 0){
              matches.add(new ArrayList<matchU>()); 
              }
              for(int l = 0; l < matches.size(); l++){
              matches.get(l).add(new matchU(t, ind_b, ind_e, bn, en, numEs, subt, stress, mix, struct, tildeOn, segOn, w, req));
              }
            }
          } else if (i == 1) {
            if (addOr) { //generate permuations
              addOr = false;
              //genOrPerms(i);
              /*for(int l = 0; l < bimatches.size(); l++){
              bimatches.get(l).add(new matchU(t, ind_b, ind_e, bn, en, numEs, subt, stress, mix, struct, tildeOn, segOn));
              }*/
            }  else if(orOn && segOn){
               orSeg.add(new matchU(t, ind_b, ind_e, bn, en, numEs, subt, stress, mix, struct, tildeOn, segOn, w, req));
            } else {
              if(bimatches.size() == 0){
              bimatches.add(new ArrayList<matchU>());
              }
              for(int l = 0; l < bimatches.size(); l++){ //add to each. 
              bimatches.get(bimatches.size()-1).add(new matchU(t, ind_b, ind_e, bn, en, numEs, subt, stress, mix, struct, tildeOn, segOn, w, req));
              }
            }
          }
        }
        if (advancej > 0) {
          if(comment)
          println(advancej-j + " " + B);
          //charnum += advancej-j+1; //may be wrong
          charnum += B;
          j = advancej;
        } else {
          charnum++;
        }
        
        if(t == 1 && subt.indexOf(":") != -1){ //cross word in mix
          w++;
          charnum = subt.length() - (subt.indexOf(":")+1);
          if(charnum < 0)charnum = 0;
        }
        
      } //seglength
      
      //} //end word match
      
    } //end bimatch loop
  }
  
  boolean anylowercase(String str){
    boolean res = false;
    for(int i = 0; i < str.length(); i++){
      if(Character.isLowerCase(str.charAt(i)))
      res = true;
    }
    return res;
  }
  
  void genOrPerms(int i){
    //make "either or both" combinations - e.g. if [ONC]-[O]|N[C] need to generate:
    //[ONC]-[O]NC (either) [ONC]-ON[C] (either) [ONC]-[O]N[C] (both)
    //get "or" segment from OrSeg
    if(i == 0){ //matches
    for(int l = 0; l < matches.size(); l+=3){
     //duplicate twice
     matches.add(l+1, new ArrayList<matchU>());
     matches.add(l+1, new ArrayList<matchU>());
     
     for(int k = 0; k < matches.get(l).size(); k++){
      matches.get(l+1).add(new matchU(matches.get(l).get(k)));
      matches.get(l+2).add(new matchU(matches.get(l).get(k)));
     }
    
     //both
     matches.get(l).addAll(orSeg);
     //only first or
     int go = 0;
     for(int k = 0; k < matches.get(l+1).size(); k++){ //turn last rhymeseg off
      if(matches.get(l+1).get(k).rhymeSeg){
        if(go == 0){
         go = 1; 
         matches.get(l+1).get(k).rhymeSeg = false;
        }else{
        matches.get(l+1).get(k).rhymeSeg = false;
        }
      }else{ //rhymeSegOff
        if(go == 1)
          break;
      }
     }
     matches.get(l+1).addAll(orSeg);
     
     //copy orSeg - must be a better way!
     
     //only second or
     for(int k = 0; k < orSeg.size(); k++){
      matches.get(l+2).add(new matchU(orSeg.get(k)));
      //modify copy
      matches.get(l+2).get(matches.get(l+2).size()-1).rhymeSeg = false;
     }
     //l += 1;
    }
    }else if(i == 1){ //bimatches
      for(int l = 0; l < bimatches.size(); l++){
     //duplicate twice
     bimatches.add(l+1, new ArrayList<matchU>()); 
     bimatches.add(l+1, new ArrayList<matchU>()); 
     
      for(int k = 0; k < bimatches.get(l).size(); k++){
      bimatches.get(l+1).add(new matchU(bimatches.get(l).get(k)));
      bimatches.get(l+2).add(new matchU(bimatches.get(l).get(k)));
     }
     
     //both
     bimatches.get(l).addAll(orSeg);
     //only first or
     int go = 0;
     for(int k = 0; k < bimatches.get(l+1).size(); k++){ //turn last rhymeseg off
      if(bimatches.get(l+1).get(k).rhymeSeg){
        if(go == 0){
         go++; 
        }else{
        bimatches.get(l+1).get(k).rhymeSeg = false;
        }
      }else{ //rhymeSegOff
        if(go == 1)
          break;
      }
     } 
     bimatches.get(l+1).addAll(orSeg);
     //only second or
     for(int k = 0; k < orSeg.size(); k++){
       bimatches.get(l+2).add(new matchU(orSeg.get(k)));
      //modify copy
      bimatches.get(l+2).get(bimatches.get(l+2).size()-1).rhymeSeg = false;
     } 
     l += 2;
    }
    }
    orSeg.clear();
  }

  void processRule2() {
    //if its a char string, I think we'll need to count the entire thing as one match 
    ArrayList<Integer> ellipses = new ArrayList<Integer>();
    String seg = "";
    int t, ind_b, ind_e, bn, en, stress, mix, numEs, bra, ket, last;
    boolean struct = false;
    String subt = "";
    //String structStr = "";
    //String subtStr;
    //split into diff rhyme segments (e.g. semirhyme)
    String[] bitmp = split(strRule, '&'); 
    if (bitmp.length == 2) {
      bimatch = true;
      if(comment)
      println("bimatch!");
    }
    for (int i = 0; i < bitmp.length; i++) {
      ellipses.clear();
      //println(bitmp[i]);
      seg = bitmp[i].replaceAll("\\.\\.\\.", ".").replaceAll(" ", "");
      //println(seg);
      String[] rSplit = split(bitmp[i], '-');
      //index all ellipses to reference later
      String seg2 = seg.replaceAll("[\\[\\]*]", "");
      int c = 0; 
      while (seg.indexOf (".", c) != -1) {
        c = seg.indexOf(".", c);
        ellipses.add(c);
        c += 3;
      }
      numEs = ellipses.size();
      //println("ellipses: "+ellipses);
      int syllnum = 0;
      int charnum = 0;
      bra = ket = 0;
      boolean segOn = false;
      boolean orOn = false;  //for [O] | [C]
      boolean tildeOn = false; //for ~[C]
      boolean ellipseOn = false;
      boolean ellipseOutOn = false; 
      int lastChar = -1;
      int lastSyll = -1;
      struct = false;
      int advancej = 0;
      //iterate through each character
      for (int j = 0; j < seg.length (); j++) {
        advancej = 0;
        //structStr = "";
        if (seg.charAt(j) == '[') {
          //println("on");
          segOn = true;
          //charnum++;
          //tmpSeg = seg.substring(j+1,seg.indexOf(']',j));
          bra = j;
          ket = (seg.indexOf(']', j) != -1 && seg.indexOf(']', j) > j) ?  seg.indexOf(']', j) : j;
          if (ket == j) {
            println("no close bracket");
          }
          continue;
        } else if (seg.charAt(j) == ']') {
          //println("off");
          segOn = false;
          //tmpSeg = "";
          if (orOn) {
            orOn = false;
          } 
          if (tildeOn) {
            tildeOn = false;
          }
          //charnum++;
          continue;
        } else if (seg.charAt(j) == '-') {
          syllnum++;
          //charnum++;
          continue;
        } else if (seg.charAt(j) == '.') {
          if (segOn) {
            ellipseOn = true;
          } else {
            ellipseOutOn = true;
          }
          continue; //have to figure out how to match ...'s
        } else if (seg.charAt(j) == '|') {
          orOn = true;
          continue;
        } else if (seg.charAt(j) == '~') {
          //tildeOn = true;
          continue;
        }
        if (segOn && (seg.charAt(j) != '\'' && seg.charAt(j) != '^')) {
          //matchU(int t, int ind_b, int ind_e, int _bn, int _en, String subt, int _stress)
          t = (seg.charAt(j) == 'O' || seg.charAt(j) == 'N' || seg.charAt(j) == 'C') ? 0 : (seg.charAt(j) == '.') ? 2 : 1;
          //println("t "+t); 
          if (t == 0) { //sylls!
            type = 0;
            stress = (rSplit[syllnum].indexOf('\'') != -1) ? 1 : (rSplit[syllnum].indexOf('^') != -1) ? 2 : 0 ;
            if (seg.charAt(j+1) == '_') {
              //extract struct rule
              struct = true;
              //structStr = seg.substring(seg.indexOf('{',j)+1,seg.indexOf('}',j));
              advancej = seg.indexOf('}', j);
              subt = ""+seg.substring(j, seg.indexOf('}', j)+1);
              if(comment)
              println(subt);
            } else {
              struct = false;
              subt = ""+seg.charAt(j);
            }
            mix = 10;
            //subt = ""+seg.charAt(j);
          } else if (t==1) { //chars!
            type = 1;
            stress = 10; 
            if (seg.length() > seg.indexOf(']', j)+1) {
              char cht = seg.charAt(seg.indexOf(']', j)+1);
              mix = (cht == '*') ? 1 : 0;
            } else {
              mix = 0;
            }
            //println(j+" "+seg.indexOf(']',j));
            subt = seg.substring(j, seg.indexOf(']', j)); //get character rhyme seg, e.g. AABA - will make things easier
            //println(subt);
            /*if(seg.charAt(j-1) == '.'){
             subt = ""+ seg.charAt(j-1)+subt;
             }*/
            advancej = seg.indexOf(']', j)-1; //skip to end
            //println("Advance "+seg.charAt(advancej));
            if (subt.indexOf('_') != -1) { //pass structural rhyme onto match function
              struct = true;
            } else {
              struct = false;
            }
          } else {
            struct = false;
            stress = 10;
            mix = 10;
            subt = "";
          }
          ind_b = (t == 0) ? syllnum : charnum;
          ind_e = (t == 0) ? rSplit.length - syllnum - 1 : seg2.length()-charnum-1;
          last = (t == 0) ? lastSyll : lastChar;

          bn = en = 0;
          for (int k = 0; k < ellipses.size (); k++) {  //just look at outside the braket
            if (ellipses.get(k) < j /*&& ellipses.get(k) < bra*/) {
              bn++;
            } else if (ellipses.get(k) > j /*&& ellipses.get(k) > ket*/) {
              en++;
            }
          }
          if (i == 0) {
            if (orOn) {  //add to previous segment
              matches.get(matches.size()-1).add(new matchU(t, ind_b, ind_e, bn, en, subt, stress, mix, numEs, struct, tildeOn, last, ellipseOn, ellipseOutOn));
            } else {
              //println("adding match "+seg+" t: "+ t +", ind_b: "+ ind_b +", ind_e: "+ ind_e +", bn: "+ bn +", en: "+ en +", sebt: "+ subt +", stress: "+ stress +", mix: "+ mix);
              matches.add(new ArrayList<matchU>()); 
              matches.get(matches.size()-1).add(new matchU(t, ind_b, ind_e, bn, en, subt, stress, mix, numEs, struct, tildeOn, last, ellipseOn, ellipseOutOn));
            }
          } else if (i == 1) {
            if (orOn) {
              bimatches.get(bimatches.size()-1).add(new matchU(t, ind_b, ind_e, bn, en, subt, stress, mix, numEs, struct, tildeOn, last, ellipseOn, ellipseOutOn));
            } else {
              bimatches.add(new ArrayList<matchU>());
              bimatches.get(bimatches.size()-1).add(new matchU(t, ind_b, ind_e, bn, en, subt, stress, mix, numEs, struct, tildeOn, last, ellipseOn, ellipseOutOn));
            }
          }
        }
        if (advancej > 0) {
          //println(advancej-j);
          charnum += advancej - j+1; //may be wrong
          j = advancej;
        } else {
          charnum++;
        }
        last = charnum;
        lastSyll = syllnum;
        ellipseOn = false;
        ellipseOutOn = false;
      }
    }
  }
  
  void printMatches(){
    for(int i = 0; i < currmatches.size(); i++){  //2d for "ors"
     for(int j = 0; j < currmatches.get(i).size(); j++){
           print(currmatches.get(i).get(j).subtype+" ("+currmatches.get(i).get(j).index_b+") ("+currmatches.get(i).get(j).index_e+")");
     }
     println("");
    }
  }
  
  ArrayList<String> getMatches(Syllable[] _syll, char[] _wrd, int wrdNum, int wInd, boolean isbimatch, Word _word){
    ArrayList<String> res = new ArrayList<String>(); //need to find all possible rhyming segments
    ArrayList<String> resTmp = new ArrayList<String>();
    //res.add("");//initiate
    String tmp = "";
    int index = 0;
    boolean wexists = true;
    boolean nexties = false;
    boolean initNext = false;
    //currmatches.clear();
    //wInd for cross-word rhymes
    if(bimatch && wrdNum == 2){ //search bimatch arraylist
     currmatches = bimatches;
    }else{
      currmatches = matches;
    }
    if(comment)
    printMatches();
    //currmatches = matches;
    for(int i = 0; i < currmatches.size(); i++){  //2d for "ors"
    resTmp.clear();
    //printRulei(i);
     for(int j = 0; j < currmatches.get(i).size(); j++){
     tmp = "";  
     wexists = true;
     //println("wrdNum: "+currmatches.get(i).get(j).word);
     //for cross word rhymes
     if(j > 0 && currmatches.get(i).get(j-1).word != currmatches.get(i).get(j).word){
      nexties = true; 
      Word tmpwrd = _word.getNext(currmatches.get(i).get(j).word);
      if(tmpwrd == null){
        //doesn't exist
        wexists = false;
      }else{
        if(comment)println("next word: "+tmpwrd._displayWord);
        wexists = true;
        _syll = tmpwrd.getSylls();
        _wrd = tmpwrd.getLetters();
        initNext = true;
      }
     }else{
      nexties = false; 
     }
     
     
     if((type == 0 || type == 2) && wexists){//sylls
       //build each level
       //println(i+" "+j);
       if(comment){
       println(currmatches.get(i).get(j).subtype);
       }
       //resTmp.add(buildSyll(i,j, res, _syll));
       //resTmp = buildSyll2(i,j, resTmp, _syll);
       resTmp = buildSyll(i,j, resTmp, _syll, wInd, isbimatch, _word, initNext);
       if(initNext == true)initNext = false;
       if(comment){
       println("After match "+i+","+j+" : "+res+" "+resTmp);
       }
     }else if(type == 1 && wexists){ //chars
      if(comment && nexties)println("building char for next: "+Arrays.toString(_wrd));
       resTmp = buildChar2(i,j,resTmp, _wrd, wInd, isbimatch, _word, nexties, initNext);
       if(initNext == true)initNext = false;
     }
    }
    //get rid of duplicates and update res
    res.addAll(resTmp);
    if(comment){
    println("res: "+i+" "+resTmp);
    }
    }
    
    for(int k = 0; k < res.size(); k++){
     //res.set(k, res.get(k).substring(0,res.get(k).indexOf("("))); 
     String tmp2 = res.get(k).substring(0,res.get(k).indexOf("("));
     //mix strings between []
     String sub1 = "";
     String mix1 = "";
     int safe = 0;
     while(tmp2.indexOf("[") != -1){
       sub1 = tmp2.substring(tmp2.indexOf("["), tmp2.indexOf("]")+1);
       //println("s: "+sub1);
       mix1 = sortAlpha(sub1.replaceAll("[\\[\\]]",""));
       //println("m: "+mix1);
       tmp2 = tmp2.replaceFirst("\\[.+?\\]",mix1); 
       //println("tmp2: "+tmp2);
       safe++;
       if(safe > 20){ //safety
        break; 
       }
     }
     
     res.set(k, tmp2); 
    }
    if(comment){
    println("res: "+res);
    }
    return res;
  }
  
  //using this one
  
  ArrayList<String> buildSyll(int msize, int mnum, ArrayList<String> res, Syllable[] _syll, int wInd, boolean isbimatch, Word _word, boolean initNext){
   //iterate on res.
   //println(wInd);
   int _type =  currmatches.get(msize).get(mnum).type;
   boolean rseg = currmatches.get(msize).get(mnum).rhymeSeg;
   int index;
   int start = 0;
   int stop = 0; 
   String track = "";
   boolean okgo = true;
   if((res.size() == 0 && /*msize == 0 &&*/ mnum == 0)/* || initNext*/){ //initiate
   initNext = false;
   //println("initiating...");
     if(_type == 2){ //ellipse - iterate through entire word. 
     //add zero option
     if(rseg){  //in rhyme segment - add string
          res.add("("+(-1)+")");
      }else{ //no in rhyme seg...just update index
          res.add("("+(-1)+")");
      }
     start = 0;
     stop = 0; 
     track = "";
     for(int j = 0; j < _syll.length; j++){
      stop = j; 
      okgo = true;
      track += _syll[j].getFullSyllStr();
      //check in correct dist...
      if(currmatches.get(msize).get(mnum).bn == 0 && currmatches.get(msize).get(mnum).en == 0 ){
            if(start != currmatches.get(msize).get(mnum).index_b ||  _syll.length - 1 - stop != currmatches.get(msize).get(mnum).index_e){
            if(comment){
              println("ellipse wrong dist "+start+" "+(_syll.length - 1)+" "+stop+" "+currmatches.get(msize).get(mnum).index_b+" "+currmatches.get(msize).get(mnum).index_e);
            }
            okgo = false;  
          }
          }else if(currmatches.get(msize).get(mnum).bn == 0){
            if(start != currmatches.get(msize).get(mnum).index_b ||  (_syll.length - 1) - stop < currmatches.get(msize).get(mnum).index_e-matches.get(msize).get(mnum).en){
             if(comment){
              println("ellipse wrong dist2");
             }
             okgo = false;
            }
          }else if(currmatches.get(msize).get(mnum).en == 0){
            if(stop != currmatches.get(msize).get(mnum).index_e ||  (_syll.length - 1) - start < currmatches.get(msize).get(mnum).index_b - currmatches.get(msize).get(mnum).bn){
            if(comment){
              println("ellipse wrong dist3"); 
            }
            okgo = false;
            }
          }
          
          //if legal
          if(okgo){
      if(rseg){  //in rhyme segment - add string
          res.add(track+"("+j+")");
      }else{ //no in rhyme seg...just update index
          res.add("("+j+")");
      }
      }
     }
     //println(res);
    } else if(_type == 0){ //sylls - this should only have one poss be res. 
      String m = "";
      //check if in same syllable as last - else advance
      int syllInd = 0;
      if(rseg){
        if(_syll.length > syllInd){
          m = currmatches.get(msize).get(mnum).getONC(_syll[syllInd]);
          //println("ONC m: "+m);
          if(m.length() == 0){
          }else{
          //check if correct distance from beg/end
          if(currmatches.get(msize).get(mnum).bn == 0 && currmatches.get(msize).get(mnum).en == 0 ){
            if(syllInd != currmatches.get(msize).get(mnum).index_b ||  _syll.length - 1 - syllInd != currmatches.get(msize).get(mnum).index_e){
             m = ""; 
             if(comment){
            println("wrong dist1 " + syllInd +" "+ currmatches.get(msize).get(mnum).index_b +" "+_syll.length+ " "+currmatches.get(msize).get(mnum).index_e);
            }
            }
          }else if(currmatches.get(msize).get(mnum).bn == 0){
            if(syllInd != currmatches.get(msize).get(mnum).index_b ||  (_syll.length - 1) - syllInd < currmatches.get(msize).get(mnum).index_e-currmatches.get(msize).get(mnum).en){
             m = ""; 
             if(comment){
             println("wrong dist2" + syllInd +" "+ currmatches.get(msize).get(mnum).index_b +" "+_syll.length+ " "+currmatches.get(msize).get(mnum).index_e + " "+currmatches.get(msize).get(mnum).en);
             }  
          }
          }else if(currmatches.get(msize).get(mnum).en == 0){
            if((_syll.length - 1) - syllInd != currmatches.get(msize).get(mnum).index_e ||  syllInd < currmatches.get(msize).get(mnum).index_b - currmatches.get(msize).get(mnum).bn){
             m = ""; 
             if(comment){
             println("wrong dist3" + syllInd +" "+currmatches.get(msize).get(mnum).index_e+" "+_syll.length +" "+ currmatches.get(msize).get(mnum).index_b +" "+ currmatches.get(msize).get(mnum).bn);
             }  
          }
          }
          }
        }else{
        }
        if(m.length() == 0){
          //println("nada - first pass");
          //if match breaks, delete entire string.
          //res.set(i, null);
        } else {
          res.add(m+"("+syllInd+")");
          if(comment){
          println(res);
          }
        }
      }else{
       //just advance.
       res.add("("+syllInd+")");
      }
    }
    //println("again: "+res);
    while(res.remove(null)); //inefficient - but removes deadends
    //println("again: "+res);
   return res;
   }else{ //not initiating
   //println("proceeding...");
   if(comment){
   println("adding to"+res);
   }
   for(int i = 0; i < res.size(); i++){
    if(initNext){
     index = -1;
    }else{ 
    index = Integer.parseInt(res.get(i).replaceAll(".*\\(|\\).*", "")); //for this it's syllable index
    }
    /*if(index == -1){
     index = 0; 
    }*/
    res.set(i, res.get(i).substring(0,res.get(i).indexOf("(")));
    //res.set(i, res.get(i).replaceAll("[\\(\\)]",""));
    //println("res: "+res.get(i));
    if(_type == 2){ //ellipse - iterate through entire word.
     boolean first = true;
     start = index; 
     track = "";
     for(int j = index; j < _syll.length; j++){ //start at index to take no addition into account
      //for no addition
      /*if(j == index){
       if(rseg){
        res.set(i, res.get(i)+"("+j+")");
       }else{
        res.set(i, res.get(i)+"("+j+")");
       } 
        first = false;
        continue;
      }*/
      stop = j; 
      okgo = true;
      if(j > index){
      track += _syll[j].getFullSyllStr(); 
      }
      //check in correct dist...
      if(currmatches.get(msize).get(mnum).en == 0){
            if((_syll.length - 1) - stop != currmatches.get(msize).get(mnum).index_e){
              if(comment){
            println("ellipse wrong dist3 "+track+" "+stop+" "+currmatches.get(msize).get(mnum).index_e); 
              }
            okgo = false;
            }
          }else if((_syll.length - 1) - stop < currmatches.get(msize).get(mnum).index_e-currmatches.get(msize).get(mnum).en || (_syll.length - 1) - start < currmatches.get(msize).get(mnum).index_b - currmatches.get(msize).get(mnum).bn){
        if(comment){
            println("ellipse wrong dist");
        }
        okgo = false;
      }
      /*if(matches.get(msize).get(mnum).bn == 0 && matches.get(msize).get(mnum).en == 0 ){
            if(start != matches.get(msize).get(mnum).index_b ||  _syll.length - 1 - stop != matches.get(msize).get(mnum).index_e){
            println("ellipse wrong dist "+start+" "+(_syll.length - 1)+" "+stop+" "+matches.get(msize).get(mnum).index_b+" "+matches.get(msize).get(mnum).index_e);
            okgo = false;  
          }
          }else if(matches.get(msize).get(mnum).bn == 0){
            if(start != matches.get(msize).get(mnum).index_b ||  (_syll.length - 1) - stop < matches.get(msize).get(mnum).index_e-matches.get(msize).get(mnum).en){
             println("ellipse wrong dist2");
             okgo = false;
            }
          }else if(matches.get(msize).get(mnum).en == 0){
            if(stop != matches.get(msize).get(mnum).index_e ||  (_syll.length - 1) - start < matches.get(msize).get(mnum).index_b - matches.get(msize).get(mnum).bn){
            println("ellipse wrong dist3"); 
            okgo = false;
            }
          }*/
      
      
      if(okgo){
      if(rseg){  //in rhyme segment - add string
        /*if(j == index){
          res.set(i, res.get(i)+"("+j+")");
        }else{*/
          //res.add(i+1,res.get(i).substring(0,res.get(i).indexOf("("))+_syll[j].getFullSyllStr()+"("+j+")");
          if(first){
            res.set(i, res.get(i) + track+"("+j+")");
            first = false;
          }else{
          res.add(i+1,res.get(i).substring(0,res.get(i).indexOf("(")) + track+"("+j+")");
          i++; //advance once array element (to avoid repeats)
          }
       // }
      }else{ //no in rhyme seg...just update index
       /* if(j == index){
          res.set(i, res.get(i)+"("+j+")");
        }else{*/
        if(first){
          res.set(i, res.get(i)+"("+j+")");
          first = false;
        }else{
          res.add(i+1,res.get(i)+"("+j+")");
         i++; //advance once array element (to avoid repeats)
        }
        //}
      }
      }
     }
    }
    if(_type == 0){ //sylls - this should only have one poss be res. 
    //println("nextSyll");
      String m = "";
      //check if in same syllable as last - else advance
      
      int syllInd;
      if(index == -1){
       syllInd = 0; 
      }else{
      syllInd= ( mnum > 0 && currmatches.get(msize).get(mnum-1).index_b == currmatches.get(msize).get(mnum).index_b) ? index : index+1;
      }
      /*if(msize > 0){
      println("syllInd: "+syllInd + " " + index + " "+matches.get(msize-1).get(mnum).index_b+" "+matches.get(msize).get(mnum).index_b);
      }*/
      if(rseg){
        //println(_syll.length+" "+syllInd + " "+index+" "+mnum);//+matches.get(msize).get(mnum-1).index_b+" "+matches.get(msize).get(mnum).index_b);
        if(_syll.length > syllInd){
          m = currmatches.get(msize).get(mnum).getONC(_syll[syllInd]);
          if(comment){
          println("m: "+m);
          }
          //check if correct distance from beg/end
          if(currmatches.get(msize).get(mnum).bn == 0 && currmatches.get(msize).get(mnum).en == 0 ){
            if(syllInd != currmatches.get(msize).get(mnum).index_b ||  _syll.length - 1 - syllInd != currmatches.get(msize).get(mnum).index_e){
             m = ""; 
             if(comment)
             println("wrong dist 1");
            }
          }else if(currmatches.get(msize).get(mnum).bn == 0){
            if(syllInd != currmatches.get(msize).get(mnum).index_b ||  (_syll.length - 1) - syllInd < currmatches.get(msize).get(mnum).index_e-currmatches.get(msize).get(mnum).en){
             m = ""; 
             if(comment){
             println("wrong dist 2");
             }
            }
          }else if(currmatches.get(msize).get(mnum).en == 0){
            if((_syll.length - 1) - syllInd != currmatches.get(msize).get(mnum).index_e ||  syllInd < currmatches.get(msize).get(mnum).index_b - currmatches.get(msize).get(mnum).bn){
             m = ""; 
             if(comment){
             println("wrong dist3 " + syllInd +" "+currmatches.get(msize).get(mnum).index_e+" "+_syll.length +" "+ currmatches.get(msize).get(mnum).index_b +" "+ currmatches.get(msize).get(mnum).bn);
             }  
          }
          }
        }else{
        }
        if(m.length() == 0){
          //if match breaks, delete entire string.
          res.set(i, null);
        } else {
          res.set(i, res.get(i)+m+"("+syllInd+")");
        }
      }else{
       //just advance.
       res.set(i, res.get(i)+"("+syllInd+")");
      }
    }
   }
   }
   while(res.remove(null)); //inefficient - but removes deadends
   //println("again: "+res);
   initNext = false;
   return res;
  }
  
  
  ArrayList<String> buildSyll2(int msize, int mnum, ArrayList<String> res, Syllable[] _syll){
   //iterate on res.
   int _type =  currmatches.get(msize).get(mnum).type;
   boolean rseg = currmatches.get(msize).get(mnum).rhymeSeg;
   int index;
   int start = 0;
   int stop = 0; 
   String track = "";
   boolean okgo = true;
   if(res.size() == 0 && /*msize == 0 &&*/ mnum == 0){ //initiate
   //println("initiating...");
     if(_type == 2){ //ellipse - iterate through entire word. 
     //add zero option
     if(rseg){  //in rhyme segment - add string
          res.add("("+(-1)+")");
      }else{ //no in rhyme seg...just update index
          res.add("("+(-1)+")");
      }
     start = 0;
     stop = 0; 
     track = "";
     for(int j = 0; j < _syll.length; j++){
      stop = j; 
      okgo = true;
      track += _syll[j].getFullSyllStr();
      //check in correct dist...
      if(currmatches.get(msize).get(mnum).bn == 0 && currmatches.get(msize).get(mnum).en == 0 ){
            if(start != currmatches.get(msize).get(mnum).index_b ||  _syll.length - 1 - stop != currmatches.get(msize).get(mnum).index_e){
            if(comment)
              println("ellipse wrong dist "+start+" "+(_syll.length - 1)+" "+stop+" "+currmatches.get(msize).get(mnum).index_b+" "+currmatches.get(msize).get(mnum).index_e);
            okgo = false;  
          }
          }else if(currmatches.get(msize).get(mnum).bn == 0){
            if(start != currmatches.get(msize).get(mnum).index_b ||  (_syll.length - 1) - stop < currmatches.get(msize).get(mnum).index_e-matches.get(msize).get(mnum).en){
             if(comment)
              println("ellipse wrong dist2");
             okgo = false;
            }
          }else if(currmatches.get(msize).get(mnum).en == 0){
            if(stop != currmatches.get(msize).get(mnum).index_e ||  (_syll.length - 1) - start < currmatches.get(msize).get(mnum).index_b - currmatches.get(msize).get(mnum).bn){
            if(comment)
              println("ellipse wrong dist3"); 
            okgo = false;
            }
          }
          
          //if legal
          if(okgo){
      if(rseg){  //in rhyme segment - add string
          res.add(track+"("+j+")");
      }else{ //no in rhyme seg...just update index
          res.add("("+j+")");
      }
      }
     }
     //println(res);
    } else if(_type == 0){ //sylls - this should only have one poss be res. 
      String m = "";
      //check if in same syllable as last - else advance
      int syllInd = 0;
      if(rseg){
        if(_syll.length > syllInd){
          m = currmatches.get(msize).get(mnum).getONC(_syll[syllInd]);
          //println("ONC m: "+m);
          if(m.length() == 0){
          }else{
          //check if correct distance from beg/end
          if(currmatches.get(msize).get(mnum).bn == 0 && currmatches.get(msize).get(mnum).en == 0 ){
            if(syllInd != currmatches.get(msize).get(mnum).index_b ||  _syll.length - 1 - syllInd != currmatches.get(msize).get(mnum).index_e){
             m = ""; 
            println("wrong dist1 " + syllInd +" "+ currmatches.get(msize).get(mnum).index_b +" "+_syll.length+ " "+currmatches.get(msize).get(mnum).index_e);

            }
          }else if(currmatches.get(msize).get(mnum).bn == 0){
            if(syllInd != currmatches.get(msize).get(mnum).index_b ||  (_syll.length - 1) - syllInd < currmatches.get(msize).get(mnum).index_e-currmatches.get(msize).get(mnum).en){
             m = ""; 
             println("wrong dist2" + syllInd +" "+ currmatches.get(msize).get(mnum).index_b +" "+_syll.length+ " "+currmatches.get(msize).get(mnum).index_e + " "+currmatches.get(msize).get(mnum).en);
            }
          }else if(currmatches.get(msize).get(mnum).en == 0){
            if((_syll.length - 1) - syllInd != currmatches.get(msize).get(mnum).index_e ||  syllInd < currmatches.get(msize).get(mnum).index_b - currmatches.get(msize).get(mnum).bn){
             m = ""; 
             println("wrong dist3" + syllInd +" "+currmatches.get(msize).get(mnum).index_e+" "+_syll.length +" "+ currmatches.get(msize).get(mnum).index_b +" "+ currmatches.get(msize).get(mnum).bn);
            }
          }
          }
        }else{
        }
        if(m.length() == 0){
          //println("nada - first pass");
          //if match breaks, delete entire string.
          //res.set(i, null);
        } else {
          res.add(m+"("+syllInd+")");
          println(res);
        }
      }else{
       //just advance.
       //res.add("("+syllInd+")");
      }
    }
    //println("again: "+res);
    while(res.remove(null)); //inefficient - but removes deadends
    //println("again: "+res);
   return res;
   }else{ //not initiating
   //println("proceeding...");
   println("adding to"+res);
   for(int i = 0; i < res.size(); i++){
    index = Integer.parseInt(res.get(i).replaceAll(".*\\(|\\).*", "")); //for this it's syllable index
    res.set(i, res.get(i).substring(0,res.get(i).indexOf("(")));
    //res.set(i, res.get(i).replaceAll("[\\(\\)]",""));
    //println("res: "+res.get(i));
    if(_type == 2){ //ellipse - iterate through entire word.
     boolean first = true;
     start = index; 
     track = "";
     for(int j = index; j < _syll.length; j++){ //start at index to take no addition into account
      //for no addition
      /*if(j == index){
       if(rseg){
        res.set(i, res.get(i)+"("+j+")");
       }else{
        res.set(i, res.get(i)+"("+j+")");
       } 
        first = false;
        continue;
      }*/
      stop = j; 
      okgo = true;
      if(j > index){
      track += _syll[j].getFullSyllStr(); 
      }
      //check in correct dist...
      if(currmatches.get(msize).get(mnum).en == 0){
            if((_syll.length - 1) - stop != currmatches.get(msize).get(mnum).index_e){
            if(comment)
              println("ellipse wrong dist3 "+track+" "+stop+" "+currmatches.get(msize).get(mnum).index_e); 
            okgo = false;
            }
          }else if((_syll.length - 1) - stop < currmatches.get(msize).get(mnum).index_e-currmatches.get(msize).get(mnum).en || (_syll.length - 1) - start < currmatches.get(msize).get(mnum).index_b - currmatches.get(msize).get(mnum).bn){
        if(comment)
            println("ellipse wrong dist");
        okgo = false;
      }
      /*if(matches.get(msize).get(mnum).bn == 0 && matches.get(msize).get(mnum).en == 0 ){
            if(start != matches.get(msize).get(mnum).index_b ||  _syll.length - 1 - stop != matches.get(msize).get(mnum).index_e){
            println("ellipse wrong dist "+start+" "+(_syll.length - 1)+" "+stop+" "+matches.get(msize).get(mnum).index_b+" "+matches.get(msize).get(mnum).index_e);
            okgo = false;  
          }
          }else if(matches.get(msize).get(mnum).bn == 0){
            if(start != matches.get(msize).get(mnum).index_b ||  (_syll.length - 1) - stop < matches.get(msize).get(mnum).index_e-matches.get(msize).get(mnum).en){
             println("ellipse wrong dist2");
             okgo = false;
            }
          }else if(matches.get(msize).get(mnum).en == 0){
            if(stop != matches.get(msize).get(mnum).index_e ||  (_syll.length - 1) - start < matches.get(msize).get(mnum).index_b - matches.get(msize).get(mnum).bn){
            println("ellipse wrong dist3"); 
            okgo = false;
            }
          }*/
      
      
      if(okgo){
      if(rseg){  //in rhyme segment - add string
        /*if(j == index){
          res.set(i, res.get(i)+"("+j+")");
        }else{*/
          //res.add(i+1,res.get(i).substring(0,res.get(i).indexOf("("))+_syll[j].getFullSyllStr()+"("+j+")");
          if(first){
            res.set(i, res.get(i) + track+"("+j+")");
            first = false;
          }else{
          res.add(i+1,res.get(i).substring(0,res.get(i).indexOf("(")) + track+"("+j+")");
          i++; //advance once array element (to avoid repeats)
          }
       // }
      }else{ //no in rhyme seg...just update index
       /* if(j == index){
          res.set(i, res.get(i)+"("+j+")");
        }else{*/
        if(first){
          res.set(i, res.get(i)+"("+j+")");
          first = false;
        }else{
          res.add(i+1,res.get(i)+"("+j+")");
         i++; //advance once array element (to avoid repeats)
        }
        //}
      }
      }
     }
    }
    if(_type == 0){ //sylls - this should only have one poss be res. 
    //println("nextSyll");
      String m = "";
      //check if in same syllable as last - else advance
      
      int syllInd;
      if(index == -1){
       syllInd = 0; 
      }else{
      syllInd= ( mnum > 0 && currmatches.get(msize).get(mnum-1).index_b == currmatches.get(msize).get(mnum).index_b) ? index : index+1;
      }
      /*if(msize > 0){
      println("syllInd: "+syllInd + " " + index + " "+matches.get(msize-1).get(mnum).index_b+" "+matches.get(msize).get(mnum).index_b);
      }*/
      if(rseg){
        //println(_syll.length+" "+syllInd + " "+index+" "+mnum);//+matches.get(msize).get(mnum-1).index_b+" "+matches.get(msize).get(mnum).index_b);
        if(_syll.length > syllInd){
          m = currmatches.get(msize).get(mnum).getONC(_syll[syllInd]);
          println("m: "+m);
          //check if correct distance from beg/end
          if(currmatches.get(msize).get(mnum).bn == 0 && currmatches.get(msize).get(mnum).en == 0 ){
            if(syllInd != currmatches.get(msize).get(mnum).index_b ||  _syll.length - 1 - syllInd != currmatches.get(msize).get(mnum).index_e){
             m = ""; 
             if(comment)
             println("wrong dist 1");
            }
          }else if(currmatches.get(msize).get(mnum).bn == 0){
            if(syllInd != currmatches.get(msize).get(mnum).index_b ||  (_syll.length - 1) - syllInd < currmatches.get(msize).get(mnum).index_e-currmatches.get(msize).get(mnum).en){
             m = ""; 
             if(comment)
             println("wrong dist 2");
            }
          }else if(currmatches.get(msize).get(mnum).en == 0){
            if((_syll.length - 1) - syllInd != currmatches.get(msize).get(mnum).index_e ||  syllInd < currmatches.get(msize).get(mnum).index_b - currmatches.get(msize).get(mnum).bn){
             m = ""; 
             if(comment)
             println("wrong dist3 " + syllInd +" "+currmatches.get(msize).get(mnum).index_e+" "+_syll.length +" "+ currmatches.get(msize).get(mnum).index_b +" "+ currmatches.get(msize).get(mnum).bn);
            }
          }
        }else{
        }
        if(m.length() == 0){
          //if match breaks, delete entire string.
          res.set(i, null);
        } else {
          res.set(i, res.get(i)+m+"("+syllInd+")");
        }
      }else{
       //just advance.
       res.set(i, res.get(i)+"("+syllInd+")");
      }
    }
   }
   }
   while(res.remove(null)); //inefficient - but removes deadends
   //println("again: "+res);
   return res;
  }
  
  
  ArrayList<String> buildChar2(int msize, int mnum, ArrayList<String> res, char[] _wrd, int wInd, boolean isbimatch, Word _word, boolean nexties, boolean initNext){
   //nexties = false;
   //initNext = false;
    //iterate on res.
   //println(String.valueOf(_wrd));
   int _type =  currmatches.get(msize).get(mnum).type;
   boolean rseg = currmatches.get(msize).get(mnum).rhymeSeg;
   //for mixing
   String begMix = (rseg && currmatches.get(msize).get(mnum).mix == 1 && ((mnum > 0 && currmatches.get(msize).get(mnum-1).mix != 1) || (mnum == 0))) ? "[" : "";
   String endMix = (rseg && currmatches.get(msize).get(mnum).mix == 1 && ((mnum < currmatches.get(msize).size()-1 && currmatches.get(msize).get(mnum+1).mix != 1) || (mnum == currmatches.get(msize).size()-1))) ? "]" : "";
   int index;
   int start = 0;
   int stop = 0; 
   String track = "";
   boolean okgo = true;
   int firstA = 100;
   int firstB = 100;
   
   //calc first consonant + first vowel
   
   for(int g = 0; g < _wrd.length; g++){
     String s = ""+_wrd[g];
     if("aeiouy".indexOf(s.toLowerCase()) != -1){
      firstA = g;
      break; 
     }
   }
   
   for(int g = 0; g < _wrd.length; g++){
     String s = ""+_wrd[g];
     if("bcdfghjklmnpqrstvwxyz".indexOf(s.toLowerCase()) != -1){
      firstB = g;
      break; 
     }
   }
   
   if((res.size() == 0 && mnum == 0) /*|| initNext*/){ //initiate
   if(comment){
   println("initiating...");
   }
   if(initNext){println("next word :"+ _word.getDisplayWord());}
   //initNext = false; do this at the end
     if(_type == 2){ //ellipse - iterate through entire word. 
     //add zero option
     if(rseg){  //in rhyme segment - add string
          if(initNext){
            for(int i = 0; i < res.size(); i++){
              String tmpRes = res.get(i).substring(0,res.get(i).indexOf("("));
              res.set(i, tmpRes+begMix+"("+(-1)+")"+endMix);
            }
          }else{
          res.add(begMix+"("+(-1)+")"+endMix);
          }
      }else{ //no in rhyme seg...just update index
          if(initNext){
            for(int i = 0; i < res.size(); i++){
              String tmpRes = res.get(i).substring(0,res.get(i).indexOf("("));
              res.set(i, tmpRes+"("+(-1)+")");
            }
          }else{
          res.add("("+(-1)+")");
         }
      }
     start = 0;
     stop = 0; 
     track = "";
     for(int j = 0; j < _wrd.length; j++){
      stop = j; 
      okgo = true;
      track += _wrd[j];
      //check in correct dist...
      if(currmatches.get(msize).get(mnum).bn == 0 && currmatches.get(msize).get(mnum).en == 0 ){
            if(start != currmatches.get(msize).get(mnum).index_b ||  _wrd.length - 1 - stop != currmatches.get(msize).get(mnum).index_e){
            if(comment)
              println("ellipse wrong dist "+start+" "+(_wrd.length - 1)+" "+stop+" "+currmatches.get(msize).get(mnum).index_b+" "+currmatches.get(msize).get(mnum).index_e);
            okgo = false;  
          }
          }else if(currmatches.get(msize).get(mnum).bn == 0){
            if(start != currmatches.get(msize).get(mnum).index_b ||  (_wrd.length - 1) - stop < currmatches.get(msize).get(mnum).index_e-currmatches.get(msize).get(mnum).en){
             if(comment)
              println("ellipse wrong dist2");
             okgo = false;
            }
          }else if(currmatches.get(msize).get(mnum).en == 0){
            if(stop != currmatches.get(msize).get(mnum).index_e ||  (_wrd.length - 1) - start < currmatches.get(msize).get(mnum).index_b - currmatches.get(msize).get(mnum).bn){
            if(comment)
              println("ellipse wrong dist3"); 
            okgo = false;
            }
          }
          
          //if legal
          if(okgo){
      if(rseg){  //in rhyme segment - add string
          if(initNext){
            for(int i = 0; i < res.size(); i++){
            
            }
          }else{
          res.add(begMix+track+endMix+"("+j+")");
          }
      }else{ //no in rhyme seg...just update index
          if(initNext){
            
          }else{
          res.add("("+j+")");
         }
      }
      }
     }
     //println(res);
    } else if(_type == 1){ //chars
      String m = "";
      int charInd = 0;
      if(rseg){
        if(_wrd.length > charInd){
          m = currmatches.get(msize).get(mnum).getCluster2(_wrd, charInd, firstA, firstB); //gives the starting point
          if(m.length() == 0){
          }else{
          //check if correct distance from beg/end
          if(currmatches.get(msize).get(mnum).bn == 0 && currmatches.get(msize).get(mnum).en == 0 ){
            if(charInd != currmatches.get(msize).get(mnum).index_b ||  _wrd.length - 1 - charInd != currmatches.get(msize).get(mnum).index_e){
             m = ""; 
            if(comment)
            println("wrong dist1 " + charInd +" "+ currmatches.get(msize).get(mnum).index_b +" "+_wrd.length+ " "+currmatches.get(msize).get(mnum).index_e);

            }
          }else if(currmatches.get(msize).get(mnum).bn == 0){
            if(charInd != currmatches.get(msize).get(mnum).index_b ||  (_wrd.length - 1) - charInd < currmatches.get(msize).get(mnum).index_e-currmatches.get(msize).get(mnum).en){
             m = ""; 
             if(comment)
             println("wrong dist2" + charInd +" "+ currmatches.get(msize).get(mnum).index_b +" "+_wrd.length+ " "+currmatches.get(msize).get(mnum).index_e + " "+currmatches.get(msize).get(mnum).en);
            }
          }else if(currmatches.get(msize).get(mnum).en == 0){
            if((_wrd.length - 1) - charInd != currmatches.get(msize).get(mnum).index_e ||  charInd < currmatches.get(msize).get(mnum).index_b - currmatches.get(msize).get(mnum).bn){
             m = ""; 
             if(comment)
             println("wrong dist3" + charInd +" "+currmatches.get(msize).get(mnum).index_e+" "+_wrd.length +" "+ currmatches.get(msize).get(mnum).index_b +" "+ currmatches.get(msize).get(mnum).bn);
            }
          }
          }
        }else{
        }
        if(m.length() == 0){
        } else {
          if(initNext){
            
          }else{
          res.add(begMix+m+endMix+"("+(charInd+m.length()-1)+")");
          }
          if(comment){
          println(res);
          }
        }
      }else{
       //just advance.
       //res.add("("+syllInd+")");
       int ch2 = charInd + currmatches.get(msize).get(mnum).subtype.length()-1;
       if(initNext){
         
       }else{
       res.add("("+(charInd + ch2)+")");
       }
      }
    }
    //println("again: "+res);
    while(res.remove(null)); //inefficient - but removes deadends
    //println("again: "+res);
   initNext = false;
   return res;
   }else{ //not initiating
   if(comment){
   println("proceeding...");
   println("adding to"+res);
   }
   for(int i = 0; i < res.size(); i++){
     if(initNext){
       index = -1;
     }else{
      index = Integer.parseInt(res.get(i).replaceAll(".*\\(|\\).*", "")); //for this it's syllable index
     }
    if(index == -1){
      //index = 0;
      if(comment){
      println("res: "+res);
      }
    }
    //println(index);
    //res.set(i, res.get(i).substring(0,res.get(i).indexOf("(")));
    String tmpRes = res.get(i).substring(0,res.get(i).indexOf("("));
    if(comment)
    println("tmp: "+tmpRes);
    //res.set(i, res.get(i).replaceAll("[\\(\\)]",""));
    //println("res: "+res.get(i));
    if(_type == 2){ //ellipse - iterate through entire word.
     boolean first = true;
     //start = (nexties)? 0 : index; 
     start = index; 
     track = "";
     for(int j = index; j < _wrd.length; j++){ //start at index to take no addition into account
      stop = j; 
      okgo = true;
      if(j > index){
      track += _wrd[j]; 
      }
      //check in correct dist...
      if(currmatches.get(msize).get(mnum).en == 0){
            if((_wrd.length - 1) - stop != currmatches.get(msize).get(mnum).index_e){
              if(comment){
            println("ellipse wrong dist3 "+track+" "+stop+" "+currmatches.get(msize).get(mnum).index_e); 
              }
            okgo = false;
            }
          }else if((_wrd.length - 1) - stop < currmatches.get(msize).get(mnum).index_e-currmatches.get(msize).get(mnum).en || (_wrd.length - 1) - start < currmatches.get(msize).get(mnum).index_b - currmatches.get(msize).get(mnum).bn){
        if(comment){
            println("ellipse wrong dist");
        }
        okgo = false;
      }
      
      if(okgo){
      if(rseg){  //in rhyme segment - add string
          if(first){
            res.set(i, tmpRes+begMix+track+ endMix+"("+j+")");
            first = false;
          }else{
          //println("track: "+track);  
          res.add(i+1,tmpRes+begMix+ track+ endMix+"("+j+")");
          i++; //advance once array element (to avoid repeats)
          }
      }else{ //not in rhyme seg...just update index
        if(first){
          res.set(i, res.get(i).substring(0,res.get(i).indexOf("("))+"("+j+")");
          first = false;
        }else{
          res.add(i+1,res.get(i).substring(0,res.get(i).indexOf("("))+"("+j+")");
         i++; //advance once array element (to avoid repeats)
        }
      }
      }
     }
    }
    if(_type == 1){ //chars!
      String m = "";
      //int charInd = (nexties)? 0 : index+1;
      int charInd = index+1;
      if(comment){
      println("charInd: "+charInd);
      }
      if(rseg){
        if(_wrd.length > charInd){
          m = currmatches.get(msize).get(mnum).getCluster2(_wrd, charInd, firstA, firstB); //gives the starting point
          if(m.length() == 0){
          }else{
          //check if correct distance from beg/end
          if(currmatches.get(msize).get(mnum).bn == 0 && currmatches.get(msize).get(mnum).en == 0 ){
            if(charInd != currmatches.get(msize).get(mnum).index_b ||  _wrd.length - 1 - charInd != currmatches.get(msize).get(mnum).index_e){
             m = ""; 
             if(comment){
            println("wrong dist1 " + charInd +" "+ currmatches.get(msize).get(mnum).index_b +" "+_wrd.length+ " "+currmatches.get(msize).get(mnum).index_e);
             }

            }
          }else if(currmatches.get(msize).get(mnum).bn == 0){
            if(charInd != currmatches.get(msize).get(mnum).index_b ||  (_wrd.length - 1) - charInd < currmatches.get(msize).get(mnum).index_e-currmatches.get(msize).get(mnum).en){
             m = ""; 
             if(comment){
             println("wrong dist2 " + charInd +" "+ currmatches.get(msize).get(mnum).index_b +" "+_wrd.length+ " "+currmatches.get(msize).get(mnum).index_e + " "+currmatches.get(msize).get(mnum).en);
             }  
          }
          }else if(currmatches.get(msize).get(mnum).en == 0){
            if((_wrd.length - 1) - charInd != currmatches.get(msize).get(mnum).index_e ||  charInd < currmatches.get(msize).get(mnum).index_b - currmatches.get(msize).get(mnum).bn){
             m = ""; 
             if(comment){
             println("wrong dist3m " + charInd +" "+currmatches.get(msize).get(mnum).index_e+" "+_wrd.length +" "+ currmatches.get(msize).get(mnum).index_b +" "+ currmatches.get(msize).get(mnum).bn);
             }  
          }
          }
          }
        }else{
        }
        if(m.length() == 0){
          //if match breaks, delete entire string.
          res.set(i, null);
        } else {
          res.set(i, res.get(i).substring(0,res.get(i).indexOf("("))+begMix+m+endMix+"("+(charInd+m.length()-1)+")");
        }
      }else{
        int ch2 = currmatches.get(msize).get(mnum).subtype.length()-1;
       //just advance.
       res.set(i, res.get(i).substring(0,res.get(i).indexOf("("))+"("+(charInd+ch2)+")");
      }
    }
   }
   }
   while(res.remove(null)); //inefficient - but removes deadends
   //println("again: "+res);
   return res;
  }
  
  
  String sortAlpha(String subt){
    char[] p = subt.toCharArray();
    Arrays.sort(p);
    return new String(p);
  }
  
  
  ArrayList<String> buildChar(int msize, int mnum, ArrayList<String> res, char[] _wrd){
   //iterate on res. 
   for(int i = 0; i < res.size(); i++){
    int _type =  matches.get(msize).get(mnum).type;
    boolean rseg = matches.get(msize).get(mnum).rhymeSeg;
    int index = Integer.parseInt(res.get(i).replaceAll(".*\\(|\\).*", "")); //for this it's syllable index
    res.set(i, res.get(i).substring(0,res.get(i).indexOf("("))); //delete index
    if(_type == 2){ //ellipse - iterate through entire word. 
     for(int j = index+1; j < _wrd.length; j++){
      if(rseg){  //in rhyme segment - add string
        if(j == index+1){
          res.set(i, res.get(i)+_wrd[j]+"("+j+")");
        }else{
          res.add(i+1,res.get(i)+_wrd[j]+"("+j+")");
         i++; //advance once array element (to avoid repeats)
        }
      }else{ //no in rhyme seg...just update index
        if(j == index+1){
          res.set(i, res.get(i)+"("+j+")");
        }else{
          res.add(i+1,res.get(i)+"("+j+")");
         i++; //advance once array element (to avoid repeats)
        }
      }
     }
    }
    if(_type == 1){ //chars! either mixed or nonmixes 
      /*String m = "";
      //check if in same syllable as last - else advance
      int charInd = index+1;
      if(rseg){
        if(_wrd.length > charInd){
          //now we're dealing with subtypes. 
          
          m = matches.get(msize).get(mnum).getCluster2(_wrd);
          //check if correct distance from beg/end
          if(matches.get(msize).get(mnum).bn == 0 && matches.get(msize).get(mnum).bn == 0 ){
            if(charInd != matches.get(msize).get(mnum).index_b ||  _wrd.length - 1 - charInd != matches.get(msize).get(mnum).index_e){
             m = ""; 
            }
          }else if(matches.get(msize).get(mnum).bn == 0){
            if(charInd != matches.get(msize).get(mnum).index_b ||  (_wrd.length - 1) - charInd < matches.get(msize).get(mnum).index_e-matches.get(msize).get(mnum).en){
             m = ""; 
            }
          }else if(matches.get(msize).get(mnum).en == 0){
            if(charInd != matches.get(msize).get(mnum).index_e ||  (_wrd.length - 1) - charInd < matches.get(msize).get(mnum).index_b - matches.get(msize).get(mnum).bn){
             m = ""; 
            }
          }
        }else{
        }
        if(m.length() == 0){
          //if match breaks, delete entire string.
          res.set(i, "");
        } else {
          res.set(i, res.get(i)+m+"("+charInd+")");
        }
      }else{
       //just advance.
       res.set(i, res.get(i)+"("+charInd+")");
      }*/
    }
   }
   while(res.remove("")); //inefficient - but removes deadends
   return res;
  }
  
  
  void printRule3() {
   println(strRule);
    for (int i = 0; i < matches.size (); i++) {
      if(i > 0){
        matchingStr += " |";
      }
      for (int j = 0; j < matches.get (i).size(); j++) {
        matchingStr += " "+matches.get(i).get(j).subtype+"("+matches.get(i).get(j).rhymeSeg+")"+"("+matches.get(i).get(j).index_b+matches.get(i).get(j).bn+")"+"("+matches.get(i).get(j).index_e+matches.get(i).get(j).en+")w:"+matches.get(i).get(j).word;
      }
    }
    if (bimatch) {
      matchingStr += " & ";
      for (int i = 0; i < bimatches.size (); i++) {
        for (int j = 0; j < bimatches.get (i).size(); j++) {
          matchingStr += " "+bimatches.get(i).get(j).subtype+"("+bimatches.get(i).get(j).rhymeSeg+")"+"("+bimatches.get(i).get(j).index_b+bimatches.get(i).get(j).bn+")"+"("+bimatches.get(i).get(j).index_e+bimatches.get(i).get(j).en+")w:"+bimatches.get(i).get(j).word;
        }
      }
    }
    println("Matching String: "+matchingStr);
  }
  
  

void printRule2() {
  if(comment)
   println(strRule);
    for (int i = 0; i < matches.size (); i++) {
      if(i > 0){
        matchingStr += " |";
      }
      for (int j = 0; j < matches.get (i).size(); j++) {
        matchingStr += " "+matches.get(i).get(j).subtype+"("+matches.get(i).get(j).rhymeSeg+")"+"("+matches.get(i).get(j).index_b+matches.get(i).get(j).bn+")"+"("+matches.get(i).get(j).index_e+matches.get(i).get(j).en+")w:"+matches.get(i).get(j).word;
      }
    }
    if (bimatch) {
      matchingStr += " & ";
      for (int i = 0; i < bimatches.size (); i++) {
        for (int j = 0; j < bimatches.get (i).size(); j++) {
          matchingStr += " "+bimatches.get(i).get(j).subtype+"("+bimatches.get(i).get(j).rhymeSeg+")"+"("+bimatches.get(i).get(j).index_b+bimatches.get(i).get(j).bn+")"+"("+bimatches.get(i).get(j).index_e+bimatches.get(i).get(j).en+")w:"+bimatches.get(i).get(j).word;
        }
      }
    }
    if(comment)
    println("Matching String: "+matchingStr);
  }

void printRulei(int i) {
  if(comment)
   println(strRule);
   matchingStr = "";
      for (int j = 0; j < matches.get (i).size(); j++) {
        matchingStr += " "+matches.get(i).get(j).subtype+"("+matches.get(i).get(j).rhymeSeg+")"+"("+matches.get(i).get(j).index_b+matches.get(i).get(j).bn+")"+"("+matches.get(i).get(j).index_e+matches.get(i).get(j).en+")";
      }
    if (bimatch) {
      matchingStr += " & ";
        for (int j = 0; j < bimatches.get (i).size(); j++) {
          matchingStr += " "+bimatches.get(i).get(j).subtype+"("+bimatches.get(i).get(j).rhymeSeg+")"+"("+bimatches.get(i).get(j).index_b+bimatches.get(i).get(j).bn+")"+"("+bimatches.get(i).get(j).index_e+bimatches.get(i).get(j).en+")";
    }
    }
    if(comment)
    println("Matching String: "+matchingStr);
  }


  void printRule() {
    println(strRule);
    for (int i = 0; i < matches.size (); i++) {
      for (int j = 0; j < matches.get (i).size(); j++) {
        if (j>0)
          matchingStr += " | ";
        matchingStr += " "+matches.get(i).get(j).bn + matches.get(i).get(j).index_b + matches.get(i).get(j).subtype +  matches.get(i).get(j).en + matches.get(i).get(j).index_e + "("+matches.get(i).get(j).stress+")";
      }
    }
    if (bimatch) {
      matchingStr += " & ";
      for (int i = 0; i < bimatches.size (); i++) {
        for (int j = 0; j < bimatches.get (i).size(); j++) {
          if (j>0)
            matchingStr += " | ";
          matchingStr += " "+bimatches.get(i).get(j).bn + bimatches.get(i).get(j).index_b + bimatches.get(i).get(j).subtype +  bimatches.get(i).get(j).en + bimatches.get(i).get(j).index_e + "("+bimatches.get(i).get(j).stress+")";
        }
      }
    }
    if(comment)
    println("Matching String: "+matchingStr);
  }
  //decode rule
  /*void processRule() {
    String[] rSplit = split(strRule, '-'); //split syllables
    boolean mOn = false;
    matchingStr = "";
    stresses = "";
    String ts = "";
    String ts1 = "";
    String ts2 = "";
    String leftOver = "";
    sylls.clear();
    syllsNoP.clear();
    phones.clear();
    ellipses.clear();

    //first pass, register ellipses. 
    for (int i = 0; i<rSplit.length; i++) {
      if (rSplit[i].indexOf("...") != -1) {
        ellipses.add(i);
      }
    }

    for (int i = 0; i<rSplit.length; i++) {  //loop through syllables
      ts = ts1 = ts2 = "";
      leftOver = "";
      if(comment)
      println(rSplit[i]);

      if (rSplit[i].indexOf('\'') != -1) {
        stressedSyll = i;
      }
      if (mOn) {
        ts = rSplit[i];
        if (rSplit[i].indexOf(']') != -1) {
          mOn = false; 
          ts = rSplit[i].substring(0, rSplit[i].indexOf(']')+1);
        }
        matchingStr += "-" + ts;
        sylls.add(i+"("+ts.replaceAll("[\\[\\]\\']", "")+")");
        //add to syllsNoP
        //ts = ts.replaceAll("[\\[\\]\\']", "");
        ts = ts.replaceAll("[\\[\\]]", "");
        while (ts.indexOf ('p') != -1) {
          ts1 = (ts.indexOf('p')-1 == 0) ? "" : ts.substring(0, ts.indexOf('p')-1);
          ts2 = (ts.indexOf('p')+1 > ts.length()-1) ? "" : ts.substring(ts.indexOf('p')+1);
          ts = ts1 + ts2;
        }
        if (ts.length() > 0) {
          String b_num = ""+i;
          String e_num = ""+(rSplit.length-i-1);

          for (int k = 0; k < ellipses.size (); k++) {
            if (ellipses.get(k) < i) {
              b_num += "n";
            } else if (ellipses.get(k) > i) {
              e_num += "n";
            }
          }
          syllsNoP.add(b_num+"("+ts+")"+e_num);
        }
      } else {
        if (rSplit[i].indexOf('[') != -1) {
          ts = rSplit[i].substring(rSplit[i].indexOf('['));
          mOn = true;
          if (rSplit[i].indexOf(']') != -1) {
            mOn = false;
            ts = ts.substring(0, ts.indexOf(']')+1);
          }
          matchingStr += "" + ts;
          sylls.add(i+"("+ts.replaceAll("[\\[\\]\\']", "")+")");

          //ts = ts.replaceAll("[\\[\\]\\']", "");
          ts = ts.replaceAll("[\\[\\]]", "");
          while (ts.indexOf ('p') != -1) {
            ts1 = (ts.indexOf('p')-1 == 0) ? "" : ts.substring(0, ts.indexOf('p')-1);
            ts2 = (ts.indexOf('p')+1 > ts.length()-1) ? "" : ts.substring(ts.indexOf('p')+1);
            ts = ts1 + ts2;
          }
          if (ts.length() > 0) {
            String b_num = ""+i;
            String e_num = ""+(rSplit.length-i-1);

            for (int k = 0; k < ellipses.size (); k++) {
              if (ellipses.get(k) < i) {
                b_num += "n";
              } else if (ellipses.get(k) > i) {
                e_num += "n";
              }
            }
            syllsNoP.add(b_num+"("+ts+")"+e_num);
            //matches.add(new matched(ts, b_num, e_num));
          }
        }
      }
    }
    for (int j = 0; j < sylls.size (); j++) {
      stresses += " "+sylls.get(j); 
      if (sylls.get(j).indexOf('p') != -1) {
        String tsyll = sylls.get(j);
        String tp = tsyll.substring(0, 2);
        while (tsyll.indexOf ('p') != -1) {
          tp += ""+tsyll.charAt(tsyll.indexOf('p')-1);
          tsyll = tsyll.replaceFirst("p", "");
          if(comment)
          println(tsyll);
        }
        tp += ")";
        phones.add(tp);
      }
    }
    if(comment){
    println("New Rule");  
    println("rhyme: "+matchingStr);
    println("stressed syllable: "+stressedSyll);
    println("matching sylls: "+syllsNoP);
    println("matching phones (mouth placement): "+phones);
    }
  }*/


  String mString(int[] a) {
    String s = "";
    for (int i = 0; i < a.length; i++) {
      s += ""+a[i]+"+";
    }
    return s;
  }
};

class matchU {
  int type; //0 = syllable; 1 = character; 2 ellipse
  int index_b; //syllable/character index from begining of word
  int bn;
  int en; //0/1 means no/yes preceeding/trailing ellipses;
  int index_e; //syllable/character index from end of word
  int word; //for ':' 0 equals current rules > '0' means proceeding words - not this might run into issues when proceeding word is rhyming word.  
  String subtype; //for syllables O N C; for chars A B or Y
  int stress;  //either 0,1,2 for syllable (2 - either); null for chars
  int mix; //either 0/1 for no/yes for chars; null for sylls. 
  int nellipses;
  boolean struct; //true means phonetic rule for sylls; true means structural (vowel, consonant) for chars
  //ArrayList<String> structStr = new ArrayList<String>(); //to store the struct info
  boolean tilde; //for ~ (both sylls and letters).
  String[] structArray;
  int[] wArray;
  int last;  //distance from last object
  boolean ellipseOn, ellipseOutOn;  //to the right... handle the last after 
  int next;  //distance from last object
  boolean ellipseOnR, ellipseOutOnR;  //to the right... handle the last after 
  boolean rhymeSeg;
  int wrdNum;
  boolean req;
  boolean crossSubt = false;
  
  matchU(matchU m){
    type = m.type; 
    index_b = m.index_b; 
    bn = m.bn;
    index_e = m.index_e; 
    en = m.en;
    nellipses = m.nellipses;
    subtype = m.subtype;
    stress = m.stress;
    mix = m.mix;
    tilde = m.tilde;
    struct = m.struct;
    rhymeSeg = m.rhymeSeg;
    word = m.word;
    //process struct info
    structArray = new String[subtype.length()];
    //hopefully this can transfer too...
    //structArray = new String[subtype.length()]; //this will def be long enough 
    processStruct();
    
  }
  
  //Using this one!
  
  matchU(int t, int ind_b, int ind_e, int _bn, int _en, int numEs, String subt, int _stress, int _mix, boolean _struct, boolean _tilde, boolean _rhymeSeg, int _word, boolean _req) {
    //println("new match "+subt);
    type = t; 
    index_b = ind_b; 
    bn = _bn;
    index_e = ind_e; 
    en = _en;
    nellipses = numEs;
    subtype = subt;
    stress = _stress;
    mix = _mix;
    tilde = _tilde;
    struct = _struct;
    rhymeSeg = _rhymeSeg;
    word = _word;
    req = _req;
    //process struct info
    structArray = new String[subtype.length()]; //this will def be long enough 
    processStruct();
    if(t == 1 && subt.indexOf(":") != -1){
      processWStruct();
    }
  }
  
  
  //Used for "or" functions
  matchU(int t, int ind_b, int ind_e, int _bn, int _en, String subt, int _stress, int _mix, int numEs, boolean struct, boolean _tilde, int _last, boolean _ellipseOn, boolean _ellipseOutOn ) {
    type = t; 
    index_b = ind_b; 
    bn = _bn;
    index_e = ind_e; 
    en = _en;
    subtype = subt;
    stress = _stress;
    mix = _mix;
    nellipses = numEs;
    tilde = _tilde;
    last = _last;
    ellipseOn = _ellipseOn;
    ellipseOutOn = _ellipseOutOn;
    //next = _next;
    //ellipseOnr = _ellipseOnr;
    //ellipseOnOutr = _ellipseOnOutr;
    //process struct info
    structArray = new String[subtype.length()]; //this will def be long enough 
    processStruct();
  }
  
  void processWStruct(){
    wArray = new int[subtype.length()];
    crossSubt = true; 
  }
  
  void processStruct(){
    int ind = 0;
    String tmpStr = "";
    String checkStr = "";
    int ch = 0;
    int ad = 0;
    while(subtype.indexOf("_") != -1){ //struct info
     ad = 0;
     if(type == 1 && ch == 0){ //check if not first
     ch = subtype.indexOf("_")-1;
     }
     if(subtype.indexOf('{') != -1 && subtype.indexOf('}') != -1 && subtype.indexOf('{') < subtype.indexOf('}')){
         tmpStr = subtype.substring(subtype.indexOf('{')+1, subtype.indexOf('}')).toLowerCase();
         //println(tmpStr);
         //check if anything other than mvp - then illegal
         if(type == 0){ //only mvp allowed
         checkStr = tmpStr.replaceAll("[mvp]","");
         }else if(type == 1){ //only s (struct) allow
         checkStr = tmpStr.replaceAll("s","");
         }
         if(checkStr.length() > 0){
          println("Illegal Rule: "+ subtype);
         }else{
         //structStr.add(ch+"_"+tmpStr);
         structArray[ch] = tmpStr;
         }
         int last = subtype.indexOf('}');
         int next = subtype.indexOf('_',last);
         if(next != -1){
           ad = next-last-1;
         }
         subtype = subtype.replaceFirst("_\\{"+tmpStr+"\\}","");
       }else{
        break; 
       }
      ch+=ad;
    }
   if(comment)
   println(structArray);
  }

  ArrayList<String> getMatch(Syllable[] _syll, char[] _wrd) {
    ArrayList<String> res = new ArrayList<String>();
    Syllable tmp;
    String phTmp = "";
    //println("syll length "+_syll.length);
    if (type == 0) { //syllables!
      if ((index_b-nellipses) > _syll.length-1 || (index_e-nellipses) > _syll.length-1) {  //doesn't fit word. This should probably also be checked a step earlier
        println("too short!");
        return res;
      }
      if (en == 0 && bn == 0) {//no ellipses - either side (check that syllable is in correct location
      if(!getONC(_syll[index_b]).equals(getONC(_syll[_syll.length-1-index_e]))){
        println("syll locations do not coincide");
        return res;
      }else{
        phTmp = getONC(_syll[index_b]);
        if (phTmp.length() > 0) {
          res.add(phTmp);
        }
      }
        //}
        return res;
      } else if (bn == 0) { //no ellipses from beg - real val
        //println("from beg");
        //O[NC']-ONC-... -> check that syll is at least one in from the end...
        if(((_syll.length-1)-index_b)< (index_e-en)){
          println("Not far enough from end");
          return res;
        }
        
        phTmp = getONC(_syll[index_b]);
        
        if (phTmp.length() > 0) {
          res.add(phTmp);
        }
        return res;
      } else if (en == 0) { //no ellipse from end
        //println("from end");
        //println(index_e);
        if(((_syll.length-1)-index_e)<(index_b-bn)){
          println("Not far enough from beg");
          return res;
        }
        phTmp = getONC(_syll[_syll.length-1-index_e]);
        if (phTmp.length() > 0) {
          res.add(phTmp);
        }
        return res;
      } else {
        //println("ellipse on either side");
        //ellipse on either side
        if (stress == 1) { //find stressed syllable
          for (int j = 0; j < _syll.length; j++) {
            if (_syll[j]._stress.equals("1"))
              phTmp = getONC(_syll[j]);
          }
          if (phTmp.length() > 0) {
            res.add(phTmp);
          }
          return res;
        } else { //will have many different options - like with consonance/assonance
          for (int j = 0; j < _syll.length; j++) { //check each syllable for possibility
            //println(_syll[j].returnString(_syll[j].getFullSyll()));
            phTmp = getONC(_syll[j]);
            if (phTmp.length() > 0) {
              res.add(phTmp);
            }
          }
          return res;
        }
      }
    } else if (type == 1) { //chars!!!
      if(subtype.length() > _wrd.length){
       //println("word too short");
       return res; 
      }
      if(bn == 0 && en == 0){ //FINISH THIS PART!
        
      }else if(bn == 0){
        
      }else if(en == 0){
        
      }else{
      res = getCluster(_wrd);
      return res;//work on this next
      }
    } 
    return res;
  }
  
  
  //need to take mix into account
  //see if in finite location - if not, then include all possibilities - work location into this...
  ArrayList<String> getCluster(char[] _wrd){
   ArrayList<String> cluster = new ArrayList<String>();
   //ABcAY
   char tmp;
   String tmpMatch;
   
   if(mix == 0){
   for(int i = 0; i <= _wrd.length-subtype.length(); i++){
     //println("length: "+(_wrd.length-subtype.length()));
     tmpMatch = "";
     for(int j = 0; j < subtype.length(); j++){
       tmp = subtype.charAt(j);
       if(Character.isLowerCase(tmp)){ //check if actual character
         if(tmp == _wrd[i+j]){ //char match!
           tmpMatch += "" + _wrd[i+j];
         }else{
          break; //move to next loop 
         }
        } else if(tmp == 'A'){    //check if vowel
           if(isVowel(_wrd[i+j]) || Character.toUpperCase(_wrd[i+j]) == 'Y'){
            if(structArray[j] != null && structArray[j].equals("s")){
              tmpMatch += "V";
            }else{
            tmpMatch += "" + _wrd[i+j];
            }
           }else{
            break; 
           }
         } else if(tmp == 'B'){  //check if consonant
           if(!isVowel(_wrd[i+j])){
            if(structArray[j] != null && structArray[j].equals("s")){
              tmpMatch += "C";
            }else{
            tmpMatch += "" + _wrd[i+j];
            }
           }else{
            break; 
           }
         } else if(tmp == 'Y'){ //takes anything
           if(structArray[j] != null && structArray[j].equals("s")){
              String tt = (isVowel(_wrd[i+j])) ? "V" : "C";
              tmpMatch += "" + tt;
            }else{
            tmpMatch += "" + _wrd[i+j];
            }
         }
       }
       //println("let's see: "+tmpMatch);
       if(tmpMatch.length() == subtype.length()){
       cluster.add(tmpMatch);
       }
     }
   } else if(mix == 1){ //mix
   //println("Mix!");
     String wrdStr = new String(_wrd);
     for(int i = 0; i <= _wrd.length-subtype.length(); i++){
       tmpMatch =  wrdStr.substring(i,i+subtype.length());
       //println(tmpMatch);
       String res = "";
       String delete = tmpMatch;
       //println("tmp: "+tmpMatch);
       //loop through and delete each...do chars, A/B, Y
       String sSubtype = sortMix(subtype); 
       for(int j = 0; j < sSubtype.length(); j++){
       tmp = sSubtype.charAt(j);
       if(Character.isLowerCase(tmp)){ //check if actual character
         //println(tmp + " " + delete);
         //println("index of tmp "+ delete.indexOf(""+tmp));
         if(delete.indexOf(""+tmp) != -1){ //char match!
           delete = delete.replace(""+tmp,""); //removes first match
           res += tmp;
         }else{
          //println("breaking");
          break; //move to next loop 
         }
        } else if(tmp == 'A'){    //check if vowel
          int exists = 0;
           for(int k = 0; k < delete.length(); k++){
             if(isVowel(delete.charAt(k)) || Character.toUpperCase(delete.charAt(k)) == 'Y'){
              exists = 1;
              if(structArray[j] != null && structArray[j].equals("s")){
                res += "V";
              }else{
              res += ""+delete.charAt(k);
              }
              delete = delete.replace(""+delete.charAt(k),"");
              break;  
             }
           }
           if(exists == 0){
             break;
           }
         } else if(tmp == 'B'){  //check if consonant
           int exists = 0;
           for(int k = 0; k < delete.length(); k++){
             if(!isVowel(delete.charAt(k))){
              exists = 1;
              if(structArray[j] != null && structArray[j].equals("s")){
                res += "C";
              }else{
              res += ""+delete.charAt(k);
              }
              delete = delete.replace(""+delete.charAt(k),"");
              break;  
             }
           }
           if(exists == 0){
             break;
           }
         } else if(tmp == 'Y'){ //takes anything
           if(delete.length() > 0){
             if(structArray[j] != null && structArray[j].equals("s")){
               String tt = (isVowel(delete.charAt(0))) ? "V" : "C"; 
               res += tt;
              }else{
              res += ""+delete.charAt(0);
              }
           delete = delete.replace(""+delete.charAt(0),"");
           }else{
            break; 
           }
         } 
       }
       //if it makes it here, then it should be a match
       if (delete.equals("")){
        //alpahbetically sort tmpMatch
        //char[] chars = tmpMatch.toCharArray();
        char[] chars = res.toCharArray();
        Arrays.sort(chars);
        String match = new String(chars);
       cluster.add(match); 
       }
     }
   }
     return cluster;
  }
  
  String sortMix(String subt){
   //sort - lowercase chars, A/B, Y
   String lower = "";
   String lowers = "";
   String AB = "";
   String ABs = "";
   String Y = "";
   String Ys = "";
  for(int i = 0; i < subt.length(); i++){
    if(Character.isLowerCase(subt.charAt(i))){
      lower += ""+subt.charAt(i);
      if(structArray[i] != null && structArray[i].equals("s")){
        lowers += "s";
      }else{
        lowers += "N";
      }
    }else if(subt.charAt(i) == 'A' || subt.charAt(i) == 'B'){
      AB += ""+subt.charAt(i); 
      if(structArray[i] != null && structArray[i].equals("s")){
        ABs += "s";
      }else{
        ABs += "N";
      }
      
    }else if(subt.charAt(i) == 'Y'){
     Y += ""+subt.charAt(i); 
     if(structArray[i] != null && structArray[i].equals("s")){
        Ys += "s";
      }else{
        Ys += "N";
      }
    }
  } 
   
  String f = lower+AB+Y+"_"+lowers+ABs+Ys; //this add the structure
   return f; 
  }
  
  boolean isVowel(char ch){
    String aeiou = "AEIOUaeiou";
   return  aeiou.indexOf(ch) != -1;
  }

  String getONC(Syllable _syll) { 
    String res = "";
    if (stress == 0 || stress == 1) { //make sure stress coincides (if stress == 2, then either is fine)
      //println("syllStress "+_syll._stress+" , req stress"+stress);
      if (!_syll._stress.equals(""+stress))
        return res;
    }
    //println("type: "+subtype);
    
    if (subtype.charAt(0)=='O') {    //could write this more efficiently but wouldn't speed up time. 
    //check if _{mvp}
      if(structArray[0] != null){
        res = _syll.getOnsetStruct(structArray[0]); //for this, make sure all match. 
      }else{ 
        res = _syll.returnString(_syll._onset);
      }
    } else if (subtype.charAt(0)=='N') {
      if(structArray[0] != null){
        res = _syll.getNucleusStruct(structArray[0]);
      }else{
      res = _syll.returnString(_syll._nucleus);
      }
    } else if (subtype.charAt(0)=='C') {
       if(structArray[0] != null){
         res = _syll.getCodaStruct(structArray[0]);
         if(comment)
         println("coda struct: "+res);
       }else{
        res = _syll.returnString(_syll._coda);
       }
    } 
    if (res.length() == 0) {    //not all have onset, coda, etc...
    if((subtype.charAt(0)=='C' || subtype.charAt(0)=='O') && req){
        //check for required O or C
    }else{
      res = "_null_";
    }
    }
    return res;
  }
  
  
  String getCluster2(char[] _wrd, int start, int firstA, int firstB){ //add stressed vowel
   String cluster = "";
   //ABcAY
   char tmp;
   String tmpMatch;
   if(comment)
   println(String.valueOf(_wrd)+" "+start);
   //first check if too short
   if(_wrd.length - start < subtype.length()){
       return cluster;
   }

   if(mix == 0){
   for(int i = start; i <= start; i++){
     //println("length: "+(_wrd.length-subtype.length()));
     tmpMatch = "";
     for(int j = 0; j < subtype.length(); j++){
       
       if(subtype.charAt(j) == '\''){
        continue; //will get picked up in the next round 
       }
       tmp = subtype.charAt(j);
       if(Character.isLowerCase(tmp)){ //check if actual character
         if(tmp == _wrd[i+j]){ //char match!
           tmpMatch += "" + _wrd[i+j];
         }else{
          break; //move to next loop 
         }
        } else if(tmp == 'A'){    //check if vowel
           if(isVowel(_wrd[i+j]) || Character.toUpperCase(_wrd[i+j]) == 'Y'){
             if(subtype.length() > j+1 && subtype.charAt(j+1) == '\''){ //first vowel
            //check if first vowel...
            //println(firstA+" : "+(i+j)+" "+subtype.charAt(j+1));
            if(firstA != i+j){
              break;
              }
             }
             
            if(structArray[j] != null && structArray[j].equals("s")){
              tmpMatch += "V";
            }else{
            tmpMatch += "" + _wrd[i+j];
            }
           }else{
            break; 
           }
         } else if(tmp == 'B'){  //check if consonant
         if(subtype.length() > j+1 && subtype.charAt(j+1) == '\''){ //first vowel
            //check if first vowel...
            if(firstB != i+j){
              break;
            }
           }
           if(!isVowel(_wrd[i+j])){
            if(structArray[j] != null && structArray[j].equals("s")){
              tmpMatch += "C";
            }else{
            tmpMatch += "" + _wrd[i+j];
            }
           }else{
            break; 
           }
         } else if(tmp == 'Y'){ //takes anything
         
           if(structArray[j] != null && structArray[j].equals("s")){
              String tt = (isVowel(_wrd[i+j])) ? "V" : "C";
              tmpMatch += "" + tt;
            }else{
            tmpMatch += "" + _wrd[i+j];
            if(comment)
            println("tmpmatch: "+tmpMatch);
            }
         }
       }
       if(tmpMatch.length() == subtype.replaceAll("'","").length()){
       cluster = tmpMatch;
       }
     }
     //println("cluster:"+cluster);
   } else if(mix == 1){ //mix
   //println("Mix!");
     String wrdStr = new String(_wrd);
     for(int i = start; i <= start; i++){
       tmpMatch =  wrdStr.substring(i,i+subtype.length());
       if(comment){
       println("tmpMatch: "+tmpMatch);
       }
       String res = "";
       String delete = tmpMatch;
       //println("tmp: "+tmpMatch);
       //loop through and delete each...do chars, A/B, Y
       String[] ssSubtype = split(sortMix(subtype),"_"); 
       String sSubtype = ssSubtype[0];
       String sstruct = ssSubtype[1];
       //println(sSubtype);
       for(int j = 0; j < sSubtype.length(); j++){
       tmp = sSubtype.charAt(j);
       if(Character.isLowerCase(tmp)){ //check if actual character
         //println(tmp + " " + delete);
         //println("index of tmp "+ delete.indexOf(""+tmp));
         if(delete.indexOf(""+tmp) != -1){ //char match!
           res += tmp;
           delete = delete.replaceFirst(""+tmp,""); //removes first match
           //println("del: "+delete);
         }else{
          //println("breaking");
          break; //move to next loop 
         }
        } else if(tmp == 'A'){    //check if vowel
          int exists = 0;
           for(int k = 0; k < delete.length(); k++){
             if(isVowel(delete.charAt(k)) || Character.toUpperCase(delete.charAt(k)) == 'Y'){
              exists = 1;
              if(sstruct.charAt(j) == 's'){
                res += "V";
              }else{
              res += ""+delete.charAt(k);
              }
              delete = delete.replace(""+delete.charAt(k),"");
              break;  
             }
           }
           if(exists == 0){
             break;
           }
         } else if(tmp == 'B'){  //check if consonant
           int exists = 0;
           for(int k = 0; k < delete.length(); k++){
             if(!isVowel(delete.charAt(k))){
              exists = 1;
              if(sstruct.charAt(j) == 's'){
                res += "C";
              }else{
              res += ""+delete.charAt(k);
              }
              delete = delete.replace(""+delete.charAt(k),"");
              break;  
             }
           }
           if(exists == 0){
             break;
           }
         } else if(tmp == 'Y'){ //takes anything
           if(delete.length() > 0){
             if(sstruct.charAt(j) == 's'){
               String tt = (isVowel(delete.charAt(0))) ? "V" : "C"; 
               res += tt;
              }else{
              res += ""+delete.charAt(0);
              }
           delete = delete.replace(""+delete.charAt(0),"");
           }else{
            break; 
           }
         } 
       }
       //if it makes it here, then it should be a match
       if (delete.equals("")){
        //alpahbetically sort tmpMatch
        //char[] chars = tmpMatch.toCharArray();
        char[] chars = res.toCharArray();
        Arrays.sort(chars);
        String match = new String(chars);
       cluster = match; 
       }
     }
   }
     return cluster;
  }
};

