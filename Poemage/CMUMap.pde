import java.util.*;
import java.io.*;

//creating CMU map

class CMUMap {

  Map<String, ArrayList<String>> cmuMap = new HashMap<String, ArrayList<String>>();

  CMUMap() {

    String v2 = "(2)";
    String v3 = "(3)";
    String v4 = "(4)";

    String[] lines = loadStrings("data/syllabifiedCMU_NM.txt");
    String[] values = new String[3];
    String tmp, str;

    for (int i = 0; i < lines.length; i++) {
      String[] pieces = split(lines[i], " ");
      if (pieces[0].indexOf(v2) != -1) {
        //println(pieces[0]);
        tmp = pieces[0].substring(0, pieces[0].length() - 3);
        //str = pieces[1].replaceAll("-", " ");
        cmuMap.get(tmp).add(pieces[1]);
      } 
      else if (pieces[0].indexOf(v3) != -1) {
        tmp = pieces[0].substring(0, pieces[0].length() - 3);
        //str = pieces[1].replaceAll("-", " ");
        //println(tmp);
        cmuMap.get(tmp).add(pieces[1]);
      } 
      else if (pieces[0].indexOf(v4) != -1) {
        tmp = pieces[0].substring(0, pieces[0].length() - 3);
        //str = pieces[1].replaceAll("-", " ");
        //println(tmp);
        cmuMap.get(tmp).add(pieces[1]);
      } 
      else {
        //println(pieces[0]);
        //str = pieces[1].replaceAll("-", " ");
        cmuMap.put(pieces[0], new ArrayList());
        cmuMap.get(pieces[0]).add(pieces[1]);
      }
    }
  }

  ArrayList<String>  getPhonemes(String word) {
    word = word.toUpperCase();
    if (cmuMap.get(word) == null) {
      return null;
    } 
    else {
      ArrayList<String> phonemeVec = cmuMap.get(word);
      //println("pvec: "+phonemeVec);
      return phonemeVec;
    }
  }

  String  getFirstPhoneme(String word) {
    String Defs = "", Hom = "";
    //word = word.replaceAll("[.,;:()?-]", "");
    word = word.toUpperCase();
    if (cmuMap.get(word) == null) {
      //println("Skipping: " + word);
      String str = "?";
      return str;
      //return secondSearch(word);
    } else {
      //word = word.replaceAll("[.,;:()?-]", "");
      /*if(homonym(word) == true){
       Hom = " \" ";
       }*/
      ArrayList<String> phonemeVec = cmuMap.get(word);
      _pronunciations = phonemeVec.size();
      String noStress = phonemeVec.get(0); //.replaceAll("[012]", "");
      /*if (_pronunciations > 1) {
        noStress += ":" + _pronunciations;
      }*/
      return noStress + ":" + _pronunciations;
    }
  }
  
  String  getSecondPhoneme(String word) {
    String Defs = "", Hom = "";
    //word = word.replaceAll("[.,;:()?-]", "");
    word = word.toUpperCase();
    if (cmuMap.get(word) == null) {
      //println("Skipping: " + word);
      String str = "?";
      return str;
      //return secondSearch(word);
    } else {
      //word = word.replaceAll("[.,;:()?-]", "");
      /*if(homonym(word) == true){
       Hom = " \" ";
       }*/
      ArrayList<String> phonemeVec = cmuMap.get(word);
      String noStress = "";
      _pronunciations = phonemeVec.size();
      if(_pronunciations > 1){
      noStress = phonemeVec.get(1); //.replaceAll("[012]", "");
      }else{
        noStress = phonemeVec.get(0);
      }
      /*if (_pronunciations > 1) {
        noStress += ":" + _pronunciations;
      }*/
      return noStress + ":" + _pronunciations;
    }
  }
  
  String secondSearch2(String word) {
    String noStress = ""; 
    String[] split = splitTokens(word, "(),:;-.'");
    for (int i = 0; i < split.length; i++) {
      if (cmuMap.get(split[i]) == null) {
        println(split[i].substring(split[i].length()-4));
        if (cmuMap.get(split[i].substring(split[i].length()-4)) != null && cmuMap.get(split[i].substring(0, split[i].length()-4)) != null) {
          //if(split[i].substring(split[i].length()-4).equals(MENT)){
          String str1 = split[i].substring(0, split[i].length()-4);
          String str2 = split[i].substring(split[i].length()-4);
          String p1 = getPhonemeVec(str1);
          String p2 = getPhonemeVec(str2);
          println(str1+ " , " + str2);
          println(p1+ "-" + p2);
          noStress += p1+ "-" + p2 + " ";
        } 
        else {
          println(split[i]);
          noStress += "";
        }
      } 
      else {    
        //noStress = getPhonemeVec(split[i]);
        ArrayList<String> phonemeVec = cmuMap.get(split[i]);
        _pronunciations = phonemeVec.size();
        String noStressTmp = phonemeVec.get(0).replaceAll("[012]", "");
        if (_pronunciations > 1) {
          //noStress += noStressTmp + " (" + _pronunciations + ") ";
        } 
        else {
          noStress += noStressTmp + "";
          println(noStress);
        }
      }
    }
    return noStress;
  }

  String secondSearch(String word) {
    String noStress = ""; 
    //String MENT = "MENT", MENTS = "MENTS", ING = "ING";
    String[] split = splitTokens(word, "(),:;-.'");
    for (int i = 0; i < split.length; i++) {
      if (cmuMap.get(split[i]) == null) {
        println(split[i].substring(split[i].length()-4));
        if (cmuMap.get(split[i].substring(split[i].length()-4)) != null && cmuMap.get(split[i].substring(0, split[i].length()-4)) != null) {
          //if(split[i].substring(split[i].length()-4).equals(MENT)){
          String str1 = split[i].substring(0, split[i].length()-4);
          String str2 = split[i].substring(split[i].length()-4);
          String p1 = getPhonemeVec(str1);
          String p2 = getPhonemeVec(str2);
          println(str1+ " , " + str2);
          println(p1+ "-" + p2);
          noStress += p1+ "-" + p2 + " ";
        } 
        else {
          println(split[i]);
          noStress += "";
        }
      } 
      else {    
        //noStress = getPhonemeVec(split[i]);
        ArrayList<String> phonemeVec = cmuMap.get(split[i]);
        _pronunciations = phonemeVec.size();
        String noStressTmp = phonemeVec.get(0).replaceAll("[012]", "");
        if (_pronunciations > 1) {
          //noStress += noStressTmp + " (" + _pronunciations + ") ";
        } 
        else {
          noStress += noStressTmp + "";
          println(noStress);
        }
      }
    }
    return noStress;
  }

  String getPhonemeVec(String wrd) {
    ArrayList<String> phonemeVec = cmuMap.get(wrd);
    int _pronunciations = phonemeVec.size();
    String noStress = "";
    String noStressTmp = phonemeVec.get(0).replaceAll("[012]", "");
    if (_pronunciations > 1) {
      //noStress += noStressTmp + " (" + _pronunciations + ") ";
    } 
    else {

      noStress += noStressTmp;
    }
    return noStress;
  }
} //end of CMU class

/////////////////////////////////////just for phonemes!////////////////////combine later

class CMUMap2 {

  Map<String, ArrayList<String>> cmuMap = new HashMap<String, ArrayList<String>>();

  CMUMap2() {

    String v2 = "(1)";
    String v3 = "(2)";
    String v4 = "(3)";

    String[] lines = loadStrings("data/CMUnymsgraphs.txt");
    String[] values = new String[3];
    String tmp, str;

    for (int i = 0; i < lines.length; i++) {
      String[] pieces = split(lines[i], "  ");
      if (pieces[0].indexOf(v2) != -1) {
        tmp = pieces[0].substring(0, pieces[0].length() - 3);
        //str = pieces[1].replaceAll("-", " ");
        //println(tmp);
        cmuMap.get(tmp).add(pieces[1]);
      } 
      else if (pieces[0].indexOf(v3) != -1) {
        tmp = pieces[0].substring(0, pieces[0].length() - 3);
        //str = pieces[1].replaceAll("-", " ");
        //println(tmp);
        cmuMap.get(tmp).add(pieces[1]);
      } 
      else if (pieces[0].indexOf(v4) != -1) {
        tmp = pieces[0].substring(0, pieces[0].length() - 3);
        //str = pieces[1].replaceAll("-", " ");
        //println(tmp);
        cmuMap.get(tmp).add(pieces[1]);
      } 
      else {
        //println(pieces[0]);
        //str = pieces[1].replaceAll("-", " ");
        cmuMap.put(pieces[0], new ArrayList());
        cmuMap.get(pieces[0]).add(pieces[1]);
      }
    }
  }

  ArrayList<String>  getPhonemes(String word) {
    word = word.toUpperCase();
    if (cmuMap.get(word) == null) {
      return null;
    } 
    else {
      ArrayList<String> phonemeVec = cmuMap.get(word);
      return phonemeVec;
    }
  }

  String  getFirstPhoneme(String word) {
    String Defs = "", Hom = "";
    word = word.toUpperCase();
    if (cmuMap.get(word) == null) {
      return secondSearch(word);
    } else {
          //word = word.replaceAll("[.,;:()?-]", "");
          /*if(homonym(word) == true){
             Hom = " \" ";
            }*/
          ArrayList<String> phonemeVec = cmuMap.get(word);
          _pronunciations = phonemeVec.size();
          String noStress = phonemeVec.get(0).replaceAll("[012]", "");
          if (_pronunciations > 1) {
            /*if(multiDefs(word) == true){
             Defs = "*";
            }*/
            /*if(homographs(word) == true){
             Defs = "*";
            }*/
            noStress += " (" + _pronunciations + ")";
          }
          return noStress + Defs + Hom;
        }
  }

String secondSearch(String word){
  String noStress = ""; 
  String MENT = "MENT", MENTS = "MENTS", ING = "ING";
      String[] split = splitTokens(word, "(),:;-.'");
      for (int i = 0; i < split.length; i++) {
        if (cmuMap.get(split[i]) == null) {
          println(split[i].substring(split[i].length()-4));
          if(cmuMap.get(split[i].substring(split[i].length()-4)) != null && cmuMap.get(split[i].substring(0,split[i].length()-4)) != null){
          //if(split[i].substring(split[i].length()-4).equals(MENT)){
            String str1 = split[i].substring(0, split[i].length()-4);
            String str2 = split[i].substring(split[i].length()-4);
            String p1 = getPhonemeVec(str1);
            String p2 = getPhonemeVec(str2);
            println(str1+ " , " + str2);
            println(p1+ "-" + p2);
            noStress += p1+ "-" + p2 + " ";
          } else {
          println(split[i]);
          noStress += "?";
          }
        } else {    
          //noStress = getPhonemeVec(split[i]);
          ArrayList<String> phonemeVec = cmuMap.get(split[i]);
          _pronunciations = phonemeVec.size();
          String noStressTmp = phonemeVec.get(0).replaceAll("[012]", "");
          if (_pronunciations > 1) {
            noStress += noStressTmp + " (" + _pronunciations + ") ";
          } else {
            
             noStress += noStressTmp + "";
          }
        }  
    }
      return noStress;
}

String getPhonemeVec(String wrd){
   ArrayList<String> phonemeVec = cmuMap.get(wrd);
   int _pronunciations = phonemeVec.size();
   String noStress = "";
   String noStressTmp = phonemeVec.get(0).replaceAll("[012]", "");
   if (_pronunciations > 1) {
            noStress += noStressTmp + " (" + _pronunciations + ") ";
          } else {
            
             noStress += noStressTmp;
          }
  return noStress;
}

} //end of CMU class




// creating Phoneme Map


class pMap {

  Map<String, String> _pMap = new HashMap<String, String>();
  char _type;
  String _phone;
  int stress; 

  pMap() {

    println("creating pMap...");

    String s0 = "1";
    String s1 = "2";
    String s2 = "3";

    String[] lines2 = loadStrings("data/phones.txt");

    for (int i = 0; i < lines2.length; i++) {
      String[] pieces2 = split(lines2[i], "\t");
      _pMap.put(pieces2[0], pieces2[1]);
      //println(pieces2[0] + "  " + pieces2[1]);
    }
  }
  
  String getPhone(String _phoneme) {

    if (_pMap.get(_phoneme) == null) {
      println(_phoneme+" not found");
      return null;
    } 
    else {
      return _pMap.get(_phoneme);
    }
  }
}

    // creating Phoneme Map

    /*Map<String, String> createPMap() {

      println("creating pMap...");

      Map<String, String> pMap = new HashMap<String, String>();

      String s0 = "1";
      String s1 = "2";
      String s2 = "3";
      int syllables;

      String[] lines2 = loadStrings("data/phones.txt");

      for (int i = 0; i < lines2.length; i++) {
        String[] pieces2 = split(lines2[i], "\t");
        pMap.put(pieces2[0], pieces2[1]);
        //println(pieces2[0] + "  " + pieces2[1]);
      }
      return pMap;
    }*/


    //Querying Function

    void QueryCMU(Map<String, ArrayList<String>> cmuMap, Map<String, String> pMap, String word) {
      int syllables;
      word = word.toUpperCase();
      print(word + ":  ");
      ArrayList<String>  phonemeVec = cmuMap.get(word);
      Iterator<String> it = phonemeVec.iterator();
      while (it.hasNext ())
      {
        syllables = 0;
        String s = it.next();
        print(s + "\t( ");
        String[] phones = split(s, " ");
        for (int i = 0; i<phones.length; i++) {
          if (phones[i].indexOf("0") != -1 || phones[i].indexOf("1") != -1 || phones[i].indexOf("2") != -1) {
            String tmp = phones[i].substring(0, phones[i].length() - 1);
            print(pMap.get(tmp) + " ");
            syllables++;
          } 
          else {
            print(pMap.get(phones[i]) + " ");
          }
        }
        println(") , Syllables: " + syllables);
      }
    }
