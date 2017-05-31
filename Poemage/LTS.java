/**
 * Portions Copyright 2001 Sun Microsystems, Inc.
 * Portions Copyright 1999-2001 Language Technologies Institute,
 * Carnegie Mellon University.
 * All Rights Reserved.  Use is subject to license terms.
 */

import java.io.*;
import java.util.*;
import java.lang.*;

public class LTS {
    static boolean debug = false;
    static String[] tmp;
    static String wrd = "";

    //private static String RULES = "cmuFormatCMU6test.txt";
    private static String RULES = "cmudict04_lts_mod.txt";
    
    static LTS instance;
    
    //ugly but effecient...
    static String[] vowels = {"AA","AE","AH","AO","AW","AY","EH","ER","EY","IH","IY","OW","OY","UH","UW"};
    
    public static LTS getInstance(InputStream isT){
        if(instance == null)
            instance = new LTS(isT);
        initSonority();
        return instance;
    }
    
    /**
     * Entry in file represents the total number of states in the file. This
     * should be at the top of the file. The format should be "TOTAL n" where n is
     * an integer value.
     */
    final static String TOTAL = "TOTAL";
    
    /**
     * Entry in file represents the beginning of a new letter index. This should
     * appear before the list of a new set of states for a particular letter. The
     * format should be "INDEX n c" where n is the index into the state machine
     * array and c is the character.
     */
    final static String INDEX = "INDEX";
    
    /**
     * Entry in file represents a state. The format should be "STATE i c t f"
     * where 'i' represents an index to look at in the decision string, c is the
     * character that should match, t is the index of the state to go to if there
     * is a match, and f is the of the state to go to if there isn't a match.
     */
    final static String STATE = "STATE";
    
    /**
     * Entry in file represents a final state. The format should be "PHONE p"
     * where p represents a phone string that comes from the phone table.
     */
    final static String PHONE = "PHONE";
    
    /**
     * If true, the state string is tokenized when it is first read. The side
     * effects of this are quicker lookups, but more memory usage and a longer
     * startup time.
     */
    protected boolean tokenizeOnLoad = true;
    
    /**
     * If true, the state string is tokenized the first time it is referenced. The
     * side effects of this are quicker lookups, but more memory usage.
     */
    protected boolean tokenizeOnLookup = false;
    /**
     * The LTS state machine. Entries can be String or State. An ArrayList could
     * be used here -- I chose not to because I thought it might be quicker to
     * avoid dealing with the dynamic resizing.
     */
    private Object[] stateMachine = null;
    
    /**
     * The number of states in the state machine.
     */
    private int numStates = 0;
    
    /**
     * The 'window size' of the LTS rules.
     */
    private final static int WINDOW_SIZE = 4;
    /**
     * An array of characters to hold a string for checking against a rule. This
     * will be reused over and over again, so the goal was just to have a single
     * area instead of new'ing up a new one for every word. The name choice is to
     * match that in Flite's <code>cst_lts.c</code>.
     */
    private char[] fval_buff = new char[WINDOW_SIZE * 2];

    /**
     * The indices of the starting points for letters in the state machine.
     */
    protected HashMap<String, Integer> letterIndex;
    
    /**
     * The list of phones that can be returned by the LTS rules.
     */
    static private List phonemeTable;
    
    //private constructor
    private LTS(InputStream isT){
        //InputStream is = this.getClass().getClassLoader().getResourceAsStream(RULES);
        
        InputStream is = null;
        
       try{
          
          //is = new  FileInputStream("/Users/ninam/Desktop/"+RULES);
          
          //File f = new File("user.dir/data/"+RULES);
          //File f = new File(System.getProperty("user.dir")+"/data/"+RULES);
          //is = new FileInputStream(f);
          
          //is = createInput(RULES);
          is = isT;

        if(is == null)
            throw new Exception("No LTS rules found");
        loadText(is).close();
        
        } catch (Exception e){
            System.out.println("No LTS rules found");
        }
        
    }
    
    private InputStream loadText(InputStream is) throws IOException {
        BufferedReader reader;
        String line;
        
        letterIndex = new HashMap<String, Integer>();
        
        reader = new BufferedReader(new InputStreamReader(is));
        while((line = reader.readLine()) != null) {
            if(!line.startsWith("***"))
                parseAndAdd(line);
                //System.out.println("yes it does");
        }
        return is;
    }
    
    protected void parseAndAdd(String line){
        
        StringTokenizer tokenizer = new StringTokenizer(line, " ");
        String type = tokenizer.nextToken();
        
        if(type.equals(STATE) || type.equals(PHONE)){
            
            //System.out.println("STATE or PHONE");
            
            if (tokenizeOnLoad){
                stateMachine[numStates] = getState(type, tokenizer); //gets state at given index...
            } else {
                stateMachine[numStates] = line;
            }
            
            
            numStates++;
        
        } else if(type.equals(INDEX)){
            
            //System.out.println("INDEX");
            Integer index = new Integer(tokenizer.nextToken());
            if(index.intValue() != numStates){
                throw new Error("Bad Index in file");
            } else {
                String c = tokenizer.nextToken();
                letterIndex.put(c, index); //add to hashmap
            }
            
            
        } else if(type.equals(TOTAL)){
            
            //System.out.println("TOTAL");
            //initialize the size of the state machine object array.
            
            stateMachine = new Object[Integer.parseInt(tokenizer.nextToken())];
            
        }
        
        
    }
    
    //overloaded
    protected State getState(int i){
        State state = null;
        if(stateMachine[i] instanceof String){
            state = getState((String) stateMachine[i]);
            if(tokenizeOnLookup){
                stateMachine[i] = state;
            }
        } else {
            state = (State) stateMachine[i];
        }
        return state;
    }
    
    protected State getState(String s){
        StringTokenizer tokenizer = new StringTokenizer(s, " ");
        return getState(tokenizer.nextToken(), tokenizer);
    }
    
    protected State getState(String type, StringTokenizer tokenizer){
        if(type.equals(STATE)){
            int index = Integer.parseInt(tokenizer.nextToken());
            String c = tokenizer.nextToken();
            int qtrue = Integer.parseInt(tokenizer.nextToken()); //both the same?
            int qfalse = Integer.parseInt(tokenizer.nextToken());
            //System.out.println(index + " " + c );
            return new DecisionState(index, c.charAt(0), qtrue, qfalse);
        } else if (type.equals(PHONE)){
            
            return new FinalState(tokenizer.nextToken());
            
        }
        return null;
    }
    
    //a marker interface for the states
    static interface State {
        public void writeBinary(DataOutputStream dos) throws IOException;
        //public boolean compare(State other);
    }
    
    
    protected char[] getFullBuff(String word){
        
        char[] full_buff = new char[word.length() + (2* WINDOW_SIZE)];
        
        //make buff look like "000#word#000"
        for(int i = 0; i < (WINDOW_SIZE - 1); i++){
            full_buff[i] = '0';
        }
        full_buff[WINDOW_SIZE - 1] = '#';
        word.getChars(0, word.length(), full_buff, WINDOW_SIZE);
        for(int i = 0; i < (WINDOW_SIZE - 1); i++){
            
            full_buff[full_buff.length - i - 1] = '0';
        }
        full_buff[full_buff.length - WINDOW_SIZE] = '#';
        return full_buff;
    }
    
    //get phones!
    public String[] getPhones(String word){
        return getPhones(word.toLowerCase(), null);
    }
    
    
    //we wont be using this one
    public String[] getPhones(String _word, String partOfSpeech){
        String word = _word.toLowerCase();
        
        //System.out.println("Using LTS for '"+word+"'");
        
        List<String> phoneList = new ArrayList<String>();
        State currentState;
        Integer startIndex;
        int stateIndex;
        char c;
        
        char[] full_buff = getFullBuff(word);
        //System.out.println(full_buff);
        
        for(int pos = 0; pos < word.length(); pos++){
            for(int i = 0; i < WINDOW_SIZE; i++){
                fval_buff[i] = full_buff[pos+i];
                fval_buff[i + WINDOW_SIZE] = full_buff[i + pos + 1 + WINDOW_SIZE];
            }
            //System.out.println(fval_buff);
            c = word.charAt(pos);
            startIndex = (Integer) letterIndex.get(Character.toString(c));
            if(startIndex == null){
                continue;
            }
            
            stateIndex = startIndex.intValue();
            currentState = getState(stateIndex);
            while(!(currentState instanceof FinalState)){
                stateIndex = ((DecisionState) currentState).getNextState(fval_buff);
                currentState = getState(stateIndex);
                //System.out.println(currentState.index + " " + currentState.c);
                //System.out.println(stateIndex);
            }
            ((FinalState) currentState).append((ArrayList<String>) phoneList);
        }
        
        //return statement
        //
        
        return (String[]) phoneList.toArray(new String[0]);
    }
    
    public void printPhones(String word){
        String[] tmp = getPhones(word);
        
        for(int i = 0; i < tmp.length; i++){
            
            System.out.print(tmp[i].toUpperCase() + " ");
            
        }
        System.out.println("\n");
    }
    
    
    static class DecisionState implements State {
        final static int TYPE = 1;
        int index;
        char c;
        int qtrue;
        int qfalse;
        
        
        //constructor
        public DecisionState(int index, char c, int qtrue, int qfalse){
            this.index = index;
            this.c = c;
            this.qtrue = qtrue;
            this.qfalse = qfalse;
            
        }
        
        //get next state
        public int getNextState(char[] chars){
            //debugging nm
            if(debug){
            if(chars[index] == c){
                System.out.println(index + " " + c + " yes! " + qtrue);
            }else{
                System.out.println(index + " " + c + " nope " + qfalse);
            }
            }
            return (chars[index] == c) ? qtrue:qfalse;
        }
        
        public void writeBinary(DataOutputStream dos) throws IOException
        {
            dos.writeInt(TYPE);
            dos.writeInt(index);
            dos.writeChar(c);
            dos.writeInt(qtrue);
            dos.writeInt(qfalse);
        }

    
    
    }
    static class FinalState implements State {
        
        final static int TYPE = 2;
        
        String[] phoneList;
        
        //constructor
        public FinalState(String phones){
            //degub NM
            if(debug){
            System.out.println(phones);
            }
            if(phones.equals("epsilon")){
                phoneList = null;
            } else {
                int i = phones.indexOf("-");
                if( i != -1){ //if "-" does exist...
                    phoneList = new String[2]; //grab different parts of phone...
                    phoneList[0] = phones.substring(0,i);
                    phoneList[1] = phones.substring(i+1);
                } else {
                    phoneList = new String[1];
                    phoneList[0] = phones; //without "-"
                }
            }
        }
        
        //constructor for list fo phones
        public FinalState(String[] phones){
            phoneList = phones; //just set them equal
        }
        
        //appends phoneList to provided array...
        public void append(ArrayList<String> array){
            if(phoneList == null){
                return;
            } else {
                for(int i = 0; i < phoneList.length; i++){
                    array.add(phoneList[i]);
                }
            }
        }
        
        
        public void writeBinary(DataOutputStream dos) throws IOException{
            dos.writeInt(TYPE);
            if(phoneList == null){
                dos.writeInt(0);
            } else { //grabs the proper phonemes from the table
                dos.writeInt(phoneList.length);
                for(int i = 0; i < phoneList.length; i++){
                    dos.writeInt(phonemeTable.indexOf(phoneList[i]));
                }
            }
            
            
        }
    
    }
    
    //protected HashMap<String, Integer> phonemeType;
    
    public static HashMap<String, Integer> sonorityVal;
    
    //also just do onset filter here as well...
    //the following set was taken from RiString.java;
    public static String[] impossOnsets = { "pw", "bw", "fw", "vw"};
    //two labials
    //non-strident coronal followed by a lateral
    //voiced fricative
    //palatal constant
    
    public static boolean prohibitedOnset(String onset){
        boolean results = false;
        if(Arrays.asList(impossOnsets).contains(onset)){
        results = true;
            System.out.println("Prohibited: "+onset);
        }else{
        results = false;
        }
        return results;
    }
    
    public static void initSonority(){
        
        sonorityVal= new HashMap<String, Integer>();
        sonorityVal.put("AA",4);
        sonorityVal.put("AE",4);
        sonorityVal.put("AH",4);
        sonorityVal.put("AO",4);
        sonorityVal.put("AW",4);
        sonorityVal.put("AY",4);
        sonorityVal.put("B",0);
        sonorityVal.put("CH",0);
        sonorityVal.put("D",0);
        sonorityVal.put("DH",0);
        sonorityVal.put("EH",4);
        sonorityVal.put("ER",4);
        sonorityVal.put("EY",4);
        sonorityVal.put("F",0);
        sonorityVal.put("G",0);
        sonorityVal.put("HH",0);
        sonorityVal.put("IH",4);
        sonorityVal.put("IY",4);
        sonorityVal.put("JH",0);
        sonorityVal.put("K",0);
        sonorityVal.put("L",2);
        sonorityVal.put("M",1);
        sonorityVal.put("N",1);
        sonorityVal.put("NG",1);
        sonorityVal.put("OW",4);
        sonorityVal.put("OY",4);
        sonorityVal.put("P",0);
        sonorityVal.put("R",2);
        sonorityVal.put("S",0);
        sonorityVal.put("SH",0);
        sonorityVal.put("T",0);
        sonorityVal.put("TH",0);
        sonorityVal.put("UH",4);
        sonorityVal.put("UW",4);
        sonorityVal.put("V",0);
        sonorityVal.put("W",3);
        sonorityVal.put("Y",3);
        sonorityVal.put("Z",0);
        sonorityVal.put("ZH",0);
        
        

    }
    
    public static int getSonority(String _phone){
        return (sonorityVal.containsKey(_phone)) ? sonorityVal.get(_phone) : 100;
        
    }
    
    
    public static String syllabify(String[] _phones){
        
        ArrayList<Integer> tmpOnset = new ArrayList<Integer>();
        boolean legalOnset = false;
    
        String sylls = "";
        String tmp = "";
        int index;
        int sonorityDistance = 2;
        //store phonemes and tags
        String[][] ONCs = new String[_phones.length][2];
        
        //ArrayList<syllable> syllList = new ArrayList<syllable>();
        
        //phoneme[] values;
        
        String[] type = new String[_phones.length];
        for(int i = 0; i < _phones.length; i++ ){
            if(!Arrays.asList(vowels).contains(_phones[i].replaceAll("[102]", "").toUpperCase())){
                type[i] = "consonant";
                //System.out.println("consonant: " +_phones[i].replaceAll("[102]", "").toUpperCase());
            } else {
                type[i] = "vowel";
                //System.out.println("vowel: " +_phones[i].replaceAll("[102]", "").toUpperCase());
            }
        }
        
        
        //phoneme tmpPhoneme;
        //tag each phoneme as Vowel or onset
        //for(int i = 0; i < _phones.length; i++){
        int i = 0;
        int sonA, sonB;
        boolean vowels = false;
        //while(i < _phones.length){
        if(_phones.length > 0){
            tmp = _phones[i].replaceAll("[102]", "").toUpperCase();     //labeling the phonemes
            index = i + 1;
           
            //until current phoneme is vowel, label current phoneme as onset
            while(type[i] != "vowel"){
                ONCs[i][0] = _phones[i].toUpperCase();
                ONCs[i][1] = "O";//+index;
                //System.out.println(ONCs[i][0]+" : "+ONCs[i][1]);
                i++;
                index = i + 1;
                tmp = _phones[i].replaceAll("[102]", "").toUpperCase();

            }
            while(i < _phones.length){
                tmp = _phones[i].replaceAll("[102]", "").toUpperCase();
                if(_phones[i].toUpperCase().indexOf("1") == -1){
                ONCs[i][0] = _phones[i].toUpperCase()+"0";  
                }else{
                ONCs[i][0] = _phones[i].toUpperCase();
                }
                ONCs[i][1] = "N";//+index;
                //System.out.println(ONCs[i][0]+" : "+ONCs[i][1]);
                i++;
                vowels = false;
                //if there are no more vowels in the word, label all remaining consonants and codas
                for(int j = i; j < _phones.length; j++){
                    if(type[j] == "vowel"){
                        vowels = true;
                    }
                }
                
                if(vowels == false){
                    while(i < _phones.length){
                        ONCs[i][0] = _phones[i].toUpperCase();
                        ONCs[i][1] = "C";//+index;
                        //System.out.println(ONCs[i][0]+" : "+ONCs[i][1]);
                        i++;
                    }
                } else {
                    //label all consonants before next vowel as onsets
                    tmpOnset.clear();
                    while(type[i] != "vowel"){
                        ONCs[i][0] = _phones[i].toUpperCase();
                        ONCs[i][1] = "O";//+index;
                        //System.out.println(ONCs[i][0]+" : "+ONCs[i][1]);
                        tmpOnset.add(i);
                        i++;
                    }//until onset is legal, coda = coda + first phoneme of onset
                    if(tmpOnset.size() > 1){
                    legalOnset = false;
                    String currOnset = "";
                    while(!legalOnset){
                        currOnset = "";
                        for(int m = 0; m < tmpOnset.size(); m++){
                            currOnset += _phones[tmpOnset.get(m)].replaceAll("[102]", "").toLowerCase() + " ";
                        }
                        //this needs to be changed...to prohibited, not allowed...
                        if(prohibitedOnset(currOnset.trim())){
                            legalOnset = false;
                        
                        } else {
                        
                        legalOnset = true;
                        for(int k = 1; k < tmpOnset.size(); k++){
                            sonA = getSonority(_phones[tmpOnset.get(k)].replaceAll("[102]", "").toUpperCase());
                            sonB = getSonority(_phones[tmpOnset.get(k-1)].replaceAll("[102]", "").toUpperCase());
                            if(Math.abs(sonA - sonB) >= sonorityDistance && sonA != 100 && sonB != 100){
                                continue;
                            }else if(sonA == 100 || sonB == 100){
                                System.out.println("PHONEME NOT FOUND: "+_phones[tmpOnset.get(k)]+" or "+_phones[tmpOnset.get(k-1)]);
                            }else{
                                legalOnset = false;
                                break;
                            } //need to also check if it's on the prohibited list
                            
                        }
                        }
                        
                        if(!legalOnset){
                            ONCs[tmpOnset.get(0)][1] = "C";
                            tmpOnset.remove(0);
                        }
                    }
                    }
                    
                }
                
            }
            
            /*if(!vowels.contains(" "+tmp+" ")){
                System.out.println("vowel: " +tmp);
            } else {
                System.out.println("consonant: " +tmp);
            }
            
            //tmpPhoneme = new phoneme(_phones[i].replaceAll("1", "").toUpperCase(), sonorityVal.get(_phones[i]));
            
            //just looking at the sonority for now.
            ONCs[i][0] = _phones[i];
            
            if(sonorityVal.containsKey(_phones[i].replaceAll("1", "").toUpperCase())){
                //System.out.println(_phones[i]+" : "+sonorityVal.get(_phones[i].replaceAll("1", "").toUpperCase()));
                ONCs[i][1] = ""+sonorityVal.get(_phones[i].replaceAll("1", "").toUpperCase());
            } else {
                System.out.println(_phones[i]+" not found");
                ONCs[i][1] = ""+100;
            }
         System.out.println(ONCs[i][0]+" : "+ONCs[i][1]);*/
            
        }
        
        String prev = "";
        String curr = "";
        for(int j = 0; j < ONCs.length; j++){
            //System.out.println(ONCs[j][0]+" : "+ONCs[j][1]);
            if(j > 0){
                prev = curr;
                curr = ONCs[j][1];
                //System.out.println(prev+" , "+curr);
                if(prev.equals("C") && curr.equals("O")|| prev.equals("N") && curr.equals("O")){
                    sylls += "_-_"+ONCs[j][0];
                }else{
                    sylls += "_"+ONCs[j][0];
                }
                
            }else{
                curr = ONCs[j][1];
                sylls += ONCs[j][0];
            }
            
            
        }
        
        return sylls;
    }
    
    public ArrayList<String> LTSphones(String word){
     ArrayList<String> phones = new ArrayList<String>();
     phones.add(syllabifiedPhones(word));
     return phones;
    }
    
    //syllabified phones
    public String syllabifiedPhones(String word){
        //System.out.println("word: " +word);
        
        String syllables = "";
        String[] phones = getPhones(word);
        
        //printPhones(word);
        
        //phoneme tmpPhoneme;
        
        /*for(int i = 0; i < phones.length; i++){
            System.out.print(phones[i]+" ");
        }*/
        
        syllables = syllabify(phones);
        if(syllables.length() == 0){
            syllables = "null";
        }
        
        return syllables;
    }
    
    
    
    public static void  main(String[] args){
       //LTS text = LTS.getInstance();
       //System.out.println(text.syllabifiedPhones("hello"));
        //text.printPhones("hello");
        //System.out.println(Arrays.asList(text.getPhones("Hello")));
        //System.out.println(Arrays.asList(text.syllabifiedPhones("hello")));
        //System.out.println("Well at least there's that...");
        }
}
