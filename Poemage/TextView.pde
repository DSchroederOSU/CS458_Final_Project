class TextView {

  int _width, _height;
  int _title_author_y, _poem_y;
  int _phoneme_offset, _histogram_offset, _poem_width;
  int _view_offset;
  float longest_line;
  //int graphx = 800;
  //int graphy = 20;
  int numNodes = 0;
  graph pgraph;
  ellipseBox ebox = new ellipseBox();

  //lev distance
  //DamerauLevenshteinAlgorithm DLs;

  PFont _line_font, _line_fontb, _phoneme_line_font;
  ArrayList<menuItem> rhymes = new ArrayList<menuItem>();

  //ArrayList< ArrayList<Set> > RhymeSets = new ArrayList< ArrayList<Set> >();  

  TextView() { 
    _line_font = _georgia_14;
    _line_fontb = _georgia_14b;
    _phoneme_line_font = _clairhand_14;

    _title_author_y = 0;
    _poem_y = 24 + 16 + 30;

    _view_offset = 40;

    //compute title length
    //textFont( _georgia_24b );
    int title_l = (int)textWidth(_poem.getTitle());

    // compute the length of the longest line (bad approximation!)
    //textFont( _line_font );
    int c_l = (int)textWidth( "s" );

    //_phoneme_offset = c_l*_longest_line_length + _view_offset;
    _phoneme_offset = (c_l*_longest_line_length > title_l) ? c_l*_longest_line_length + _view_offset : title_l + _view_offset; 
    _poem_width = c_l*_longest_line_length + _view_offset;
    _histogram_offset = _phoneme_offset*2;
    
    //setup nodeLocs
    countNodes();   
    
    //calc separations
    sep = min((1200 - (maxX*2 + 360 + tx))/2.0, 20); 
    
    //initialize graph
   pgraph = new graph();
   /*if(geowish){
   pgraph.geowish();
   pgraph = new graph(); 
   }*/
    
    pMin = (nodeLocs.size() > 0)? - max((nodeLocs.get(nodeLocs.size()-1).getY()+scale - 750),0) : 0;
    
    //scrollers
    scale = 8;
    y0 = (nodeLocs.size() > 0)? nodeLocs.get(0).getY()-scale : 0;
    y1 = (nodeLocs.size() > 0)? min(nodeLocs.get(nodeLocs.size()-1).getY()+scale, 750) : 0;
    //tr_top = new tr(-scale/2,y0,0,y0+scale,scale/2,y0);
    //tr_bottom = new tr(-scale/2,y1+scale,0,y1,scale/2,y1+scale);
    
    //y0 = 300;
    tr_top = new tr(-scale,y0+scale,-scale);
    tr_bottom = new tr(scale,y1,scale);
    
    
    //graphX = tx + _longest_line_length*7 + 400;
    graphX = tx + maxX + sep + 400;
    graphY = ty + 10;
    
    println("sep:"+sep);
    
    hfilt = new filterH(tx+360+sep+10,y0);
    lfilt = new filterL(tx+360+sep+10,y1+5);
    
  }

  // this is called when the window size changes
  void setDimensions( int w, int h ) {
    _width = w;
    _height = h;
  }


  void findRhymes() {
    //ArrayList<Set> combined = new ArrayList<Set>();
    RhymeSets.clear();
    rhymes.clear();
    for(int i = 0; i < nodeLocs.size(); i++){
     nodeLocs.get(i).allmembers.clear(); 
    }
    /*if(combineRules){
      RhymeSets.add(new ArrayList<Set>()); //add new array of rhyme sets
      renderCombinedRhymes();
    }else{*/
    //println("and again: "+rules.size());
    
    
    
    for (int i = 0; i < rules.size (); i++) {
      RhymeSets.add(new ArrayList<Set>()); //add new array of rhyme sets
      renderRhymesB(rules.get(i), i);
      rhymes.add(new menuItem(i)); 
    }
    //add custom rhyme menu
    RhymeSets.add(new ArrayList<Set>());
    rhymes.add(new menuItem(RhymeSets.size()-1)); 
    //}
    
    for(int i = 0; i < rhymes.size(); i++){
     rhymes.get(i).updateXs(); 
    }
    
    meander();
    
  }
  
  void meander(){
    for(int i = 0; i < rhymes.size(); i++){
     rhymes.get(i).meander(); 
    }
  }
  
  void updateCustom(){
    rhymes.set(rhymes.size()-1,new menuItem(RhymeSets.size()-1));
  }
  
  void genGraph(){
   pgraph.buildQT(); 
  }

  ////////////////////find rhymesets////////////////
  void renderRhymes(rhymerule _rule, int ruleNum) {
    int start;
    boolean first;
    ArrayList<Integer> sets = new ArrayList<Integer>();

    Line l, m;
    Word[] words, words2;

    for ( int k = 0; k < _poem.getNumLines (); k++ ) {  //looping through lines. 
    
    //skip author
    if(k == 1){
      continue;
    }

      l = _poem.getLine(k);
      words = l.getWords();
      
      currWords1 = words; //for cross words

      for (int i = 0; i < words.length; i++) {
        if (words[i]._exists == false || words[i].isWord == false) {
          continue;
        }

        first = true;
        boolean duplicate = false;

        for ( int h = k; h < _poem.getNumLines (); h++ ) {      //looping through all other words after word[i]
          m = _poem.getLine(h);
          
          words2 = m.getWords();
          currWords2 = words2; //for crossWords
          
          //skip author
          if(h == 1){
            continue;
          }
          
          if (h==k) {
            start = i+1;
          } else {
            start = 0;
          } 
          for (int j = start; j < words2.length; j++) { 
            if (words2[j]._exists == false || words2[j].isWord == false) {
              continue;
            }
            
            ArrayList<String> result = rhymePairRule2(words[i], words2[j], _rule, i,j,false);
            if(_rule.bimatch){
                result.addAll(rhymePairRule2(words2[j], words[i], _rule, j,i,true)); //if bimatch - try other direction - may need to do this regardless
            }
            if (result.size() == 0) { //no match - move to next word
              continue;
            }
            //println("what we're working with... "+result);
            for (int ii = 0; ii < result.size (); ii++) { //loop through all poss matches
              duplicate = false;
              int set = 100000;
              //check to see if rhyme alread exists, in which case, add to existing. Otherwise...
              for (int n = 0; n < RhymeSets.get (ruleNum).size(); n++) {
                if (result.get(ii).equals(RhymeSets.get(ruleNum).get(n)._rhymeId)) {
                  
                  int f = 0;
                  ArrayList<String> result2 = new ArrayList<String>();
                  ArrayList<String> result3 = new ArrayList<String>();
                  for (int mm = 0; mm < RhymeSets.get (ruleNum).get(n)._wrds.size(); mm++) {
                    //println(mm);
                    if(words[i] == RhymeSets.get(ruleNum).get(n)._wrds.get(mm)){
                    result2.add("equals");
                    result3 = rhymePairRule2(words2[j], RhymeSets.get(ruleNum).get(n)._wrds.get(mm), _rule, i, j, false);
                    //println("res3: "+result3);
                    }else if(words2[j] == RhymeSets.get(ruleNum).get(n)._wrds.get(mm)){
                    result3.add("equals");  
                    result2 = rhymePairRule2(words[i], RhymeSets.get(ruleNum).get(n)._wrds.get(mm), _rule, i, j, false);
                    //println("res2: "+result2);
                    }else{
                      result2 = rhymePairRule2(words[i], RhymeSets.get(ruleNum).get(n)._wrds.get(mm), _rule, i, j, false);
                      result3 = rhymePairRule2(words2[j], RhymeSets.get(ruleNum).get(n)._wrds.get(mm), _rule, i, j, false);
                    }
                    if (_rule.bimatch) {
                      if(words[i] != RhymeSets.get(ruleNum).get(n)._wrds.get(mm)){
                      result2.addAll(rhymePairRule2(RhymeSets.get(ruleNum).get(n)._wrds.get(mm), words[i], _rule, j, i, true)); //if bimatch - try other direction - may need to do this regardless
                      }
                      if(words2[j] == RhymeSets.get(ruleNum).get(n)._wrds.get(mm)){
                      result3.addAll(rhymePairRule2(RhymeSets.get(ruleNum).get(n)._wrds.get(mm), words2[j], _rule, j, i, true));  
                      }
                    }
                    if (result2.size() == 0 || result3.size() == 0) {
                      //println("rs: "+result2.size()+" r3: "+result3.size());
                      f++;
                    }
                    result2.clear();
                    result3.clear();
                    //println("f: "+f);
                  }
                  
                  if(f > 0){
                    duplicate = false;
                  }else{
                  duplicate = true;
                  set = n;
                  }
                }
              }
              if (duplicate == false) {  //create new rhyme set
                //println("new set!");
                Set _set = new Set(ruleNum, _rule.name);
                _set._setIds.add(words[i].wrdcount);
                _set._setIds.add(words2[j].wrdcount);
                _set._wrds.add(words[i]);
                _set._wrds.add(words2[j]);
                //_set._setNodes.add(words[i]._node);
                //_set._setNodes.add(words2[j]._node);
                ///*":"+words[i].pronNum+*//*":"+words2[j].pronNum+*/
                _set._words.add(words[i].getDisplayWord()+"("+words[i].wrdcount+")");
                _set._words.add(words2[j].getDisplayWord()+"("+words2[j].wrdcount+")");
                _set._rhymeId = result.get(ii);
                RhymeSets.get(ruleNum).add(_set);
              } else if (duplicate == true && set != 100000) {
                boolean dup1 = false;
                boolean dup2 = false;
                int num = 10000;
                for (int it = 0; it < RhymeSets.get (ruleNum).get(set)._setIds.size(); it++) {
                  if (words[i].wrdcount == RhymeSets.get(ruleNum).get(set)._setIds.get(it)) {
                    dup1 = true;
                  } else if (words2[j].wrdcount == RhymeSets.get(ruleNum).get(set)._setIds.get(it)) {
                    dup2 = true; 
                    num = it;
                  }
                  //num = it;
                  //println("duplicate!");
                }
                if (dup1 == false && num != 10000) {
                  RhymeSets.get(ruleNum).get(set)._setIds.add(num, words[i].wrdcount); 
                  RhymeSets.get(ruleNum).get(set)._words.add(num, words[i].getDisplayWord()+"("+words[i].wrdcount+")"); 
                  RhymeSets.get(ruleNum).get(set)._wrds.add(num, words[i]);
                }
                if (dup2 ==  false) {
                  RhymeSets.get(ruleNum).get(set)._setIds.add(words2[j].wrdcount); 
                  RhymeSets.get(ruleNum).get(set)._words.add(words2[j].getDisplayWord()+"("+words2[j].wrdcount+")");
                  RhymeSets.get(ruleNum).get(set)._wrds.add(words2[j]);
                }
              }
            }//for (ii)
          }
        }
      }
    }
  }
  
  void renderRhymesB(rhymerule _rule, int ruleNum) {
    int start;
    boolean first;
    ArrayList<Integer> sets = new ArrayList<Integer>();
    ArrayList<String> res1;
    ArrayList<String> resB = new ArrayList<String>();

    Line l, m;
    Word[] words, words2;

    for ( int k = 0; k < _poem.getNumLines (); k++ ) {  //looping through lines. 

      //skip author
          if(k == 1){
            continue;
          }
      
      l = _poem.getLine(k);
      words = l.getWords();

      currWords1 = words; //for cross words

        for (int i = 0; i < words.length; i++) {
        if (words[i]._exists == false || words[i].isWord == false) {
          continue;
        }

        first = true;
        boolean duplicate = false;
        res1 = rhymePairRuleSingle(words[i], _rule, i, false);
        if(_rule.bimatch){
        resB = rhymePairRuleSingle(words[i], _rule, i, true);
        }

        for ( int h = k; h < _poem.getNumLines (); h++ ) {      //looping through all other words after word[i]
          m = _poem.getLine(h);

          words2 = m.getWords();

          currWords2 = words2; //for crossWords

          //skip author
          if(h == 1){
            continue;
          }
          
          if (h==k) {
            start = i+1;
          } else {
            start = 0;
          } 
          for (int j = start; j < words2.length; j++) { 
            if (words2[j]._exists == false || words2[j].isWord == false) {
              continue;
            }
            
            res1 = rhymePairRuleSingle(words[i], _rule, i, false);

            ArrayList<String> result = rhymePairRuleB(res1, words[i], words2[j], _rule, j, false);
            if (_rule.bimatch) {
              result.addAll(rhymePairRule2(words2[j], words[i], _rule, j,i,true));
              //result.addAll(rhymePairRuleB(resB, words[i], words2[j], _rule, j, true)); //if bimatch - try other direction - may need to do this regardless
            }
            
            if(_rule.name.equals("Eye rhyme") && result.size() > 0){
             ArrayList<String> res3 = rhymePairRuleSingle(words[i], eye2, i, false);
             ArrayList<String> res4 = rhymePairRuleB(res3, words[i], words2[j], eye2, j, false);
             if(res4.size() == 0){
              result.clear(); 
             }
            }
            
            if (result.size() == 0) { //no match - move to next word
              continue;
            }
            
            //println("what we're working with... "+result);
            //println(result);
            for (int ii = 0; ii < result.size (); ii++) { //loop through all poss matches
              duplicate = false;
              int set = 100000;
              //check to see if rhyme alread exists, in which case, add to existing. Otherwise...
              for (int n = 0; n < RhymeSets.get (ruleNum).size(); n++) {
                if (result.get(ii).equals(RhymeSets.get(ruleNum).get(n)._rhymeId)) {
                  //println("yep!");
                  //&& RhymeSets.get(ruleNum).get(n)._wrds.get(0) == words[i]
                  //check each rhyme independently
                  int f = 0;
                  /*ArrayList<String> res4 = new ArrayList<String>();
                  for (int mm = 0; mm < RhymeSets.get (ruleNum).get(n)._wrds.size(); mm++) {
                  res4.clear();
                  res4.addAll(words[i].currRes);
                  res4.retainAll(RhymeSets.get(ruleNum).get(n)._wrds.get(mm).currRes); //this wont quite work
                  if(res4.size() == 0 && _rule.bimatch){
                    res4.clear();
                    res4.addAll(words[i].currRes);
                    res4.retainAll(RhymeSets.get(ruleNum).get(n)._wrds.get(mm).currRes); //this wont quite work
                    }
                    
                    if((res4.size() > 0 && !_rule.noMatch) || (res4.size() == 0 && _rule.noMatch)){
                      
                    }else{
                      f++;
                    }  
                    
                  }*/
                  if(_rule.bimatch || _rule.noMatch){
                  ArrayList<String> result2 = new ArrayList<String>();
                  ArrayList<String> result3 = new ArrayList<String>();
                  for (int mm = 0; mm < RhymeSets.get (ruleNum).get(n)._wrds.size(); mm++) {
                    //println(mm);
                    if(words[i] == RhymeSets.get(ruleNum).get(n)._wrds.get(mm)){
                    result2.add("equals");
                    result3 = rhymePairRule2(words2[j], RhymeSets.get(ruleNum).get(n)._wrds.get(mm), _rule, i, j, false);
                    //println("res3: "+result3);
                    }else if(words2[j] == RhymeSets.get(ruleNum).get(n)._wrds.get(mm)){
                    result3.add("equals");  
                    result2 = rhymePairRule2(words[i], RhymeSets.get(ruleNum).get(n)._wrds.get(mm), _rule, i, j, false);
                    //println("res2: "+result2);
                    }else{
                      result2 = rhymePairRule2(words[i], RhymeSets.get(ruleNum).get(n)._wrds.get(mm), _rule, i, j, false);
                      result3 = rhymePairRule2(words2[j], RhymeSets.get(ruleNum).get(n)._wrds.get(mm), _rule, i, j, false);
                    }
                    if (_rule.bimatch) {
                      if(words[i] != RhymeSets.get(ruleNum).get(n)._wrds.get(mm)){
                      result2.addAll(rhymePairRule2(RhymeSets.get(ruleNum).get(n)._wrds.get(mm), words[i], _rule, j, i, true)); //if bimatch - try other direction - may need to do this regardless
                      }
                      if(words2[j] == RhymeSets.get(ruleNum).get(n)._wrds.get(mm)){
                      result3.addAll(rhymePairRule2(RhymeSets.get(ruleNum).get(n)._wrds.get(mm), words2[j], _rule, j, i, true));  
                      }
                    }
                    if (result2.size() == 0 || result3.size() == 0) {
                      //println("rs: "+result2.size()+" r3: "+result3.size());
                      f++;
                    }
                    result2.clear();
                    result3.clear();
                    //println("f: "+f);
                  }
                  }
                  if(f > 0){
                    duplicate = false; 
                  }else{
                    duplicate = true;
                    set = n; 
                  }
                }
              }
              //duplicate = false;
              if (duplicate == false) {  //create new rhyme set
                //println("new set!");
                Set _set = new Set(ruleNum, _rule.name);
                _set._setIds.add(words[i].wrdcount);
                _set._setIds.add(words2[j].wrdcount);
                _set._wrds.add(words[i]);
                _set._wrds.add(words2[j]);
                //_set._setNodes.add(words[i]._node);
                //_set._setNodes.add(words2[j]._node);
                ///*":"+words[i].pronNum+*//*":"+words2[j].pronNum+*/
                _set._words.add(words[i].getDisplayWord()+"("+words[i].wrdcount+")");
                _set._words.add(words2[j].getDisplayWord()+"("+words2[j].wrdcount+")");
                _set._rhymeId = result.get(ii);
                RhymeSets.get(ruleNum).add(_set);
              } else if (duplicate == true && set != 100000) {
                boolean dup1 = false;
                boolean dup2 = false;
                int num = 10000;
                for (int it = 0; it < RhymeSets.get (ruleNum).get(set)._setIds.size(); it++) {
                  if (words[i].wrdcount == RhymeSets.get(ruleNum).get(set)._setIds.get(it)) {
                    dup1 = true;
                  } else if (words2[j].wrdcount == RhymeSets.get(ruleNum).get(set)._setIds.get(it)) {
                    dup2 = true; 
                    num = it;
                  }
                  //num = it;
                  //println("duplicate!");
                }
                if (dup1 == false && num != 10000) {
                  RhymeSets.get(ruleNum).get(set)._setIds.add(num, words[i].wrdcount); 
                  RhymeSets.get(ruleNum).get(set)._words.add(num, words[i].getDisplayWord()+"("+words[i].wrdcount+")"); 
                  RhymeSets.get(ruleNum).get(set)._wrds.add(num, words[i]);
                }
                if (dup2 ==  false) {
                  RhymeSets.get(ruleNum).get(set)._setIds.add(words2[j].wrdcount); 
                  RhymeSets.get(ruleNum).get(set)._words.add(words2[j].getDisplayWord()+"("+words2[j].wrdcount+")");
                  RhymeSets.get(ruleNum).get(set)._wrds.add(words2[j]);
                }
              }
            }//for (ii)
          }
        }
      }
    }
   // combineSets(ruleNum);
  }
  
  void renderCombinedRhymes() {
    int ruleNum = 0;
    int start;
    boolean first;
    ArrayList<Integer> sets = new ArrayList<Integer>();

    Line l, m;
    Word[] words, words2;

    for ( int k = 0; k < _poem.getNumLines (); k++ ) {  //looping through lines. 

      l = _poem.getLine(k);
      words = l.getWords();
      
      currWords1 = words;

      for (int i = 0; i < words.length; i++) {
        if (words[i]._exists == false || words[i].isWord == false) {
          continue;
        }

        first = true;
        boolean duplicate = false;

        for ( int h = k; h < _poem.getNumLines (); h++ ) {      //looping through all other words after word[i]
          m = _poem.getLine(h);
          words2 = m.getWords();
          
          currWords2 = words2;
          
          if (h==k) {
            start = i+1;
          } else {
            start = 0;
          } 
          for (int j = start; j < words2.length; j++) { 
            if (words2[j]._exists == false || words2[j].isWord == false) {
              continue;
            }
            //detect rhyme
            ArrayList< ArrayList<String> > resultCombined = new ArrayList< ArrayList<String> >();
            if(comment)
            println("Combined: "+resultCombined);
            if(combineRules){ //make more efficient
              int cont = 0;
              for (int ru = 0; ru < rules.size (); ru++) { //if any don't have matches, move to next...
                ArrayList<String> result2 = rhymePairRule2(words[i], words2[j], rules.get(ru), i,j,false);
                if(rules.get(ru).bimatch){
                 result2.addAll(rhymePairRule2(words2[j], words[i], rules.get(ru), j,i,true));
                }
                if(result2.size() == 0){
                 cont = 1; 
                }else{
                 resultCombined.add(result2); 
                }
              }
              if(cont == 1){
              continue;
             } 
            }
           
            
            ArrayList<String> result = getPermutations(resultCombined);
            if (result.size() == 0) { //no match - move to next word
              continue;
            }
            if(comment)
            println("Permutations: "+result);
            
            
            //println("what we're working with... "+result);
            for (int ii = 0; ii < result.size (); ii++) { //loop through all poss matches
              duplicate = false;
              int set = 100000;
              //check to see if rhyme alread exists, in which case, add to existing. Otherwise...
              for (int n = 0; n < RhymeSets.get (ruleNum).size(); n++) {
                if (result.get(ii).equals(RhymeSets.get(ruleNum).get(n)._rhymeId)) {
                  duplicate = true;
                  set = n;
                }
              }
              if (duplicate == false) {  //create new rhyme set
              if(comment){
                println("new set!");
              }
                Set _set = new Set(ruleNum, "combined");
                _set._setIds.add(words[i].wrdcount);
                _set._setIds.add(words2[j].wrdcount);
                _set._wrds.add(words[i]);
                _set._wrds.add(words2[j]);
                
                _set._words.add(words[i].getDisplayWord()+"("+words[i].wrdcount+")");
                _set._words.add(words2[j].getDisplayWord()+"("+words2[j].wrdcount+")");
                _set._rhymeId = result.get(ii);
                RhymeSets.get(ruleNum).add(_set);
              } else if (duplicate == true && set != 100000) {
                boolean dup1 = false;
                boolean dup2 = false;
                int num = 10000;
                for (int it = 0; it < RhymeSets.get (ruleNum).get(set)._setIds.size(); it++) {
                  if (words[i].wrdcount == RhymeSets.get(ruleNum).get(set)._setIds.get(it)) {
                    dup1 = true;
                  } else if (words2[j].wrdcount == RhymeSets.get(ruleNum).get(set)._setIds.get(it)) {
                    dup2 = true; 
                    num = it;
                  }
                  //num = it;
                  //println("duplicate!");
                }
                if (dup1 == false && num != 10000) {
                  RhymeSets.get(ruleNum).get(set)._setIds.add(num, words[i].wrdcount); 
                  RhymeSets.get(ruleNum).get(set)._words.add(num, words[i].getDisplayWord()+"("+words[i].wrdcount+")"); 
                  RhymeSets.get(ruleNum).get(set)._wrds.add(num, words[i]);
                }
                if (dup2 ==  false) {
                  RhymeSets.get(ruleNum).get(set)._setIds.add(words2[j].wrdcount); 
                  RhymeSets.get(ruleNum).get(set)._words.add(words2[j].getDisplayWord()+"("+words2[j].wrdcount+")");
                  RhymeSets.get(ruleNum).get(set)._wrds.add(words2[j]);
                }
              }
            }//for (ii)
          }
        }
      }
    }
  }
  
  void printRhymeSets(PrintWriter output) {
    output.println("IMPORTANT: please make sure to close file before rerunning program");
    if(combineRules){
      output.println("\nCombined Rules:");
      for (int i = 0; i < rules.size (); i++){
      output.println("Rule "+i+": "+rules.get(i).strRule);
      }
      output.println("\nDetected Rhymes:\n");
      for (int j = 0; j < RhymeSets.get(0).size(); j++) {
        output.println(RhymeSets.get(0).get(j)._rhymeId + ": "+RhymeSets.get(0).get(j)._words);
      }
      output.println("\n");
    }else{
    output.println("\nDetected Rhymes\n");
    for (int i = 0; i < rules.size (); i++) {
      output.println("Rule "+i+": "+rules.get(i).strRule);
      for (int j = 0; j < RhymeSets.get (i).size(); j++) {
        output.println(RhymeSets.get(i).get(j)._rhymeId + ": "+RhymeSets.get(i).get(j)._words);
      }
      output.println("\n");
    }
    }
  }
  
  void countNodes() {
    maxX = 0;
    numNodes = 0;
    nodeLocs.clear();
    pNodes.clear();
    pNodes1.clear();
    pNodes2.clear();
    absLoc.clear();
    mids.clear();
    mids1.clear();
    mids2.clear();
    int y = _poem_y;
    float x = 0;
    float xw = 0;
    float xn = 0;
    int line_spacing = 5;
    Line l;
    Word[] words;

    for ( int i = startRow; i < _poem.getNumLines(); i++ ) {
      if(i == 1){
      textFont(_gillsans_16i);
      textSize(14);
    }else if(i == 0){
     textFont(_georgia_14b);
    }else{
      textFont(_pixel_font_8);
      textSize(11);
    }
    
      
      
      mids.put(y, new ArrayList<midpoint>());
      mids1.put(y, new ArrayList<midpoint>());
      mids2.put(y, new ArrayList<midpoint>());
      
      l = _poem.getLine(i);
      words = l.getWords();
      
      if(words.length > 0){
     // mids.get(y).add(new midpoint(y,-5,null, words[0]));
     // mids1.get(y).add(new midpoint(y,-5,null, words[0]));
     // mids2.get(y).add(new midpoint(y,-5,null, words[0]));
      }
      
      numNodes += words.length; 
      x = 0;
      xw = 0;
      xn = 0;
      for ( int j = 0; j < words.length; j++ ) {
        if (_poem._lines[i]._words[j].isWord == false) {
          if(_poem._lines[i]._words[j].ws){
           xw += textWidth(" "); 
          }
          continue;
        }
        /*if (whitespace && _poem._lines[i]._words[j].isWord == false) {
          continue;
        }*/
        
        x += textWidth(words[j].getDisplayWord())/2;
        xw += textWidth(words[j].getDisplayWord())/2;
        
        //print(nodeLocs.size()+" : ");
        nodeLocs.add(new node(words[j].getDisplayWord(), x, xw, xn, y, words[j]));
        pNodes.add(new PVector(xw,y)); //may need to change this for whitespace
        pNodes1.add(new PVector(x,y));
        pNodes2.add(new PVector(xn,y)); 
        absLoc.add(""+x+":"+y);
        //println(nodeLocs.get(nodeLocs.size()-1).x + " , " + nodeLocs.get(nodeLocs.size()-1).y);
        //add word info to word class
        _poem._lines[i]._words[j].x = x;
        _poem._lines[i]._words[j].y = y;
        _poem._lines[i]._words[j]._node = nodeLocs.get(nodeLocs.size()-1);
        _poem._lines[i]._words[j].nodeId = nodeLocs.size()-1;
        
        
        float xval = xw + textWidth( words[j].getDisplayWord())/2+textWidth(" ");// + " ")*0.7;
        float xvw = x + textWidth( words[j].getDisplayWord())/2+textWidth(" ");
       // float xval = xw + textWidth( words[j].getDisplayWord());
       // float xvw = x + textWidth( words[j].getDisplayWord() + " ")*0.7; //not quite...
        //float xval = xw + textWidth( words[j].getDisplayWord())-2;
        Word w = (j < words.length-1)? words[j+1] : null;
        
        mids.get(y).add(new midpoint(y,xval,words[j], w));
        mids1.get(y).add(new midpoint(y,xvw,words[j], w));
        mids2.get(y).add(new midpoint(y,xn+nodeSep/2,words[j], w));
        
        
        if(words[j].getDisplayWord().indexOf("-") != -1 && words[j].getDisplayWord().indexOf("-") == words[j].getDisplayWord().length()-1){
          xw += textWidth(words[j].getDisplayWord())/2;
          x += textWidth( words[j].getDisplayWord())/2;
          xn += nodeSep; 
          //xw += textWidth( words[j].getDisplayWord());
          //x += textWidth( words[j].getDisplayWord());
          //xn += nodeSep;
        }else{
          //xw += textWidth( words[j].getDisplayWord()+" ");
          //x += textWidth( words[j].getDisplayWord()+" ");
          //xn += nodeSep;
          
          xw += textWidth(words[j].getDisplayWord())/2+textWidth(" ");
          x += textWidth( words[j].getDisplayWord())/2+textWidth(" ");
          xn += nodeSep; 
        }
        // xw += textWidth( words[j].getDisplayWord())/2 + textWidth(" ");
          //xw += textWidth( words[j].getDisplayWord()+" ");
        // x += textWidth( words[j].getDisplayWord())/2 + textWidth(" ");
         
         if(xw > maxX)maxX = xw;
      }
      y += sp + line_spacing;
    }
    maxX = max(maxX,300);
    //println("Number of nodes: "+nodeLocs.size());
    //println(absLoc);
  }
  
  void updatePointers(){
    for(int i = 0; i < prevSetPointers.size(); i++){
      prevSetPointers.get(i).transferPointer();
    }
    prevSetPointers.clear();
  }
  
  void refresh(){
  shapes3.clear();  
  cursor(WAIT);  
  ptrCounter = 0;
  prevSetPointers.addAll(setPointers);  
  findRhymes();
  updatePointers();
  int m = millis();
  pgraph = new graph();
  //pgraph.clearSegs();
  genGraph();
  int ti = millis()-m;
  println("time: "+ti +" "+m);
  cursor(ARROW);
  }
  
  void clearAll(){
   if(hball_b._selected){
    for(int r = 0; r < _text_view.rhymes.size(); r++){
       rhymes.get(r).removeSet();
     }
     hball_b._selected = false;
    }
    //single sets
    for(int i = 0; i < setPointers.size(); i++){
      setPointers.get(i).removePtr();
    }
    setPointers.clear();
    //menu items
    for(int r = 0; r < _text_view.rhymes.size(); r++){
       rhymes.get(r).selected = false;
     }
     for(int i = 0; i < nodeLocs.size(); i++){
       
     }
  }
  
  //////////RENDER//////////////////
  void render(){
   textSize(14); 
   fill(80);
   textFont(_georgia_14b);
   text("Poemage v 0.1", 120, 30); 
   textFont(_pixel_font_8);
   renderSets();
   renderP();
   renderGraph();
  }
  
  void renderPDF(PGraphics pdf){
    renderP_PDF(pdf);
    renderGraphPDF(pdf);
  }
  
  void renderViewBox(int _x, int _y, int _x2, int _y2, String name){
   textSize(11); 
   textAlign(LEFT,CENTER);
   stroke(200);
   strokeWeight(1);
   fill(255);
   rect(_x,_y,_x2,_y2);
   fill(219);
   //rect(_x,_y,_x2,_y+15);
   rect(_x,35,_x2,50);
   fill(80);
   text(name, _x+5,_y+7);
   fill(255); 
  }
  
  void renderP(){
   pushMatrix();
   translate(tx+350+sep,ty);
   renderViewBox(-20,35,(int)maxX+20,height-45, "Poem View");
   //translate(0,20);
   renderPoem();
   popMatrix();
   renderFilters();
   noStroke();
   //rect(tx, 0, tx + _text_view._poem_width, 30);
   //rect(tx, height-60, tx + _text_view._poem_width, height);
   if(pScroll < 0){
   ebox.draw(tx+350+sep, 60);
   }
   if(nodeLocs.get(nodeLocs.size()-1).getY() + pScroll > height - 60){
   ebox.draw(tx+350+sep, height - 70);
   }
  }
  
  void renderP_PDF(PGraphics pdf){
   pdf.stroke(220);
   pdf.fill(220); 
   for(int i = 0; i < nodeLocs.size(); i++){
    nodeLocs.get(i).drawWordPDF(pdf); 
   }
  }
  
  void renderSets(){ 
   ebox.draw(tx, height-60);
   pushMatrix();
   translate(tx,ty);
   //translate(maxX+sep,0);
   renderViewBox(-15,35,370,height-45, "Set View");
   translate(0,mScroll + 20);
   boolean up = false;
   boolean down = false;
   int scrollOn = 0;
   for(int i = 0; i < rhymes.size(); i++){
    scrollOn = rhymes.get(i).drawMenu();
    if(scrollOn == -1){
      up = true;
    }else if(scrollOn == 1){
     down = true; 
    }
   }
   popMatrix();
   //println(scrollOn);
   fill(255);
   noStroke();
   //rect(tx + _longest_line_length*8, 0, tx + _longest_line_length*8 + 350, 30);
   //rect(tx + _longest_line_length*8, height-60, tx + _longest_line_length*8 + 350, height);
   if(up){ ebox.draw(tx, 60);}
   if(down){ebox.draw(tx, height-60);}
  }
  
  void renderGraph(){
   pushMatrix();
   translate(tx,ty);
   translate(maxX+2*sep+350,0);
   renderViewBox(-20,35,(int)(maxX+5),height-45, "Path View");
   translate(0,0);
   fill(100);
   text("Modes: ",-25,25);
   //translate(_longest_line_length*8,0);
   //translate(_longest_line_length*12,10);
   pgraph.renderGraph();
   popMatrix();
  }
  
  void renderGraphPDF(PGraphics pdf){
   pdf.translate(_poem_width,0);
   pgraph.renderGraphPDF(pdf);
  }
  
  
  void renderPoem(){
   stroke(220);
   fill(220);
   pushMatrix();
   popMatrix();
   translate(0,pScroll); 
   for(int i = 0; i < nodeLocs.size(); i++){
    if(nodeLocs.get(i).getSY() + pScroll < 65){
      continue;
    }else if(nodeLocs.get(i).getSY() + pScroll > height - 70){
      continue; 
    } 
    nodeLocs.get(i).drawWord(); 
   }
   /*for(int i = 0; i < nodeLocs.size(); i++){
    if(nodeLocs.get(i).getSY() + pScroll < 65){
      continue;
    }else if(nodeLocs.get(i).getSY() + pScroll > height - 70){
      continue; 
    } 
    nodeLocs.get(i).drawWord(); 
   } */
  }
  
  void renderFilters(){
   stroke(200);
   strokeWeight(1); 
   line(hfilt.x,hfilt.y+4,hfilt.x,lfilt.y-4);
   hfilt.display(1);
   lfilt.display(1);
  }
  
}



class tr {
  float lx, ly;
  float x1, y1, x2, y2, x3, y3, y;
  float yOffset = 0.0;
  boolean hover = false;
  boolean pressed = false;
  boolean locked = false;
  
  
  tr(float _y1, float _y2, float _y3){
    y1 = _y1;
    y2 = _y2;
    y3 = _y3;
  }
  
  void update(){
    y2 = y2 + yOffset;
    y2 = constrain(y2, y0, y1);
    if(pressed){
      yOffset = mouseY - y2;
    }
  }
  
  void isHover(){
   if ((mouseX >= 35 && mouseX <= 40 && mouseY >= y1 && mouseY <= y2/2)) {
      hover = true;
    } else {
      hover = false;
    }
  }
  
  void drawtr(){
    isHover();
    if(hover){
      fill(0);
    }else{
    fill(200);
    }
    triangle(-scale/2, y2+y1, 0, y2, scale/2, y2+y3);
  }
  
}




