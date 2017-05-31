void readPoemFile( String file ) {

  println( "Reading poem..." );

  // read in the lines
  String[] rows = loadStrings( file );
  
  //TEMP
  pronNumbers = new int[rows.length*20];
  customPron = new String[rows.length*20];

  int counter = 0;
  String[] cols;

  // assume the first two lines are the title and author, followed by empty line
  String title = rows[0];
  
  String author = rows[1];
  Line[] lines;

    // read in each line as a set of words
    int num_lines = rows.length;// - 3;
    
    idCount = 0;

    _longest_line_length = 0;
    lines = new Line[num_lines];  //maybe add title here...
    for ( int i = 0; i < num_lines; i++ ) {
      
     /*if (whitespace) {
        cols = withWhitespace(rows[i]);
      } 
      else {
        cols = splitTokens( rows[i] );
      }*/
      //cols = splitTokens( rows[i] );
      rows[i] = rows[i].replaceAll("\u2014","-");
      rows[i] = rows[i].replaceAll("-","- ");
      //rows[i] = rows[i].substring(1);
      cols = split(rows[i]," ");
      //println(Arrays.asList(cols));
      
      lines[i] = new Line(cols, i);
      _longest_line_length = max( _longest_line_length, rows[i].length() );      
    }
  _poem = new Poem( title, author, lines );
}

String[] processRow(String row){
  ArrayList<String> words = new ArrayList<String>();
  
  String[] wordsArray = split(row, " ");
  println(wordsArray);
  int i = 0;
  /*while(i < row.length()){
    
  }*/
  //String[] wordsArray = words.toArray(new String[words.size()]);
  return wordsArray;
}


/*String[] withWhitespace(String row) {
  ArrayList<String> words = new ArrayList<String>();
  int isLett = 0; //1 means letter 0 means non-letter
  int prevLett = 0; //to compare to previous
  char prevChar;
  char current = ' ';
  String wrd = "";
  prevLett = 0;
  //String wrd = "";
  for (int j = 0; j < row.length(); j++) {
    prevChar = current;
    current = row.charAt(j);
    if(current == '’'){
     current = '\''; 
    }
    //print(j+": "+current);
    //tokenize: if there's a boundary change, switch to new word. 
    prevLett = isLett;
    isLett = (Character.isLetter(current) || current == '-' || current == '\'') ? 1 : 0;
    //isLett = (Character.isWhitespace(current)) ? 1 : 0;
    //println(" : "+isLett);
    if (j == 0) {
      wrd = ""+current;
      //println("Beginning: "+wrd);
    } else if (isLett == prevLett && prevChar != ';' && prevChar != ',') {    //if same state (letter/non-letter) as before, add to word
      wrd += ""+current;
      //println("word: "+ wrd);
    } else if (isLett == prevLett && (prevChar == ';' || prevChar == ',')) {    //if same state (letter/non-letter) as before, add to word
      words.add(wrd);
      //println(wrd);
      wrd = ""+current;
    } else if (isLett != prevLett) { //otherwise start new word!
      //println("New word: "+wrd);
      words.add(wrd);
      //println(wrd);
      wrd = ""+current;
    }
    if (j == row.length()-1) {
      //println("New word: "+wrd);
      words.add(wrd);
      //println(wrd);
      wrd = "";
    }
  }
  //if words with dashes are not in CMU, split words
  for(int l = 0; l < words.size(); l++){
   if(words.get(l).length() > 1 && words.get(l).indexOf("-") != -1 && _cmuMap.getFirstPhoneme(words.get(l)).replaceAll("_", " ").equals("?")){
     println(words.get(l));
    String[] str = split(words.get(l), "-");
    if(str.length == 2 && str[1].trim().length() > 0 && str[0].trim().length() > 0){
     words.set(l, str[0]);
     words.add(l+1, "-");
     words.add(l+2, str[1]); 
    }
   } 
  }
  
  String[] wordsArray = words.toArray(new String[words.size()]);
  return wordsArray;
}*/

