import java.awt.Frame;

public class PFrame extends Frame {
    public PFrame() {
        setBounds(0,0,350,700);
        setLocation(980,0);
        s = new secondApplet();
        add(s);
        s.init();
        setTitle("Notation Guide");
        show();
    }
}

public class secondApplet extends PApplet {
    public void setup() {
        size(350, 700);
        noLoop();
    }

    public void draw() {
      background(220);
      fill(240);
      noStroke();
      rect(10,42,width-20,230);
      fill(250);
      rect(10,42,width-20,42);
      rect(10,125,width-20,42);
      rect(10,192,width-20,38);
      fill(50);
      pushMatrix();
      translate(10,15);
      text("Rhyme Notation", 0, 0);
      drawNotation();
      popMatrix();
    }
    
    void drawNotation(){
      int t = 40;
      fill(100);
      textLeading(10);
      String gen = "indicates the matching portion of the rhyming pair (the rhyming segment)\nindicates that additional syllables may or may not exist\nindicates an imperfect match in the rhyme segment\ndistinguishes between the rhyming pair words\nindicates the occurrence of “one or both”\n ";
      textSize(11);
      translate(5,15);
      text("General Rhyme Notation:", -5, 10);
      //textSize(11);
      text("[brackets]",0,30);
      text("indicates the matching portion of the rhyming pair (the rhyming segment)",80,20,230,800);
      translate(0,t);
      textSize(13);
      text("…",0,30);
      textSize(11);
      text("indicates that additional syllables/characters may or may not exist",80,20,230,800);
      //translate(0,t);
      /*textSize(15);
      text("˜",0,30);
      textSize(11);
      text("[brackets]",10,30);
      text("indicates an imperfect match in the rhyme segment (NOT IMPLEMENTED YET)",80,20,230,800);*/ 
      translate(0,t);
      text("&",0,30);
      text("distinguishes between the rhyming pair words",80,20,230,800);
      translate(0,t);
      text("|",0,30);
      text("indicates the occurrence of \"one or both\"",80,20,230,800);
      translate(0,t-15);
      textSize(13);
      text(":",0,30);
      textSize(11);
      text("indicates a word break (e.g. for cross-word rhymes)",80,20,230,800);
      translate(0,t);
      textSize(13);
      text("!",0,30);
      textSize(11);
      text("indicates no match (must be placed at beginning of rule)",80,20,230,800);
      //text(gen,80,20,230,800);
      //text("indicates the matching portion of the rhyming pair (the rhyming segment)\nindicates that additional syllables may or may not exist\nindicates an imperfect match in the rhyme segment\n",40,30);
      
      translate(0,80);
      fill(245);
      rect(-5,0,width-20,180);
      fill(100);
      textLeading(20);
      text("Sonic Rhyme Notation:",-5,0);
      text("O :  Onset (leading consonant phonemes)\nN :  Nucleus (vowel phoneme)\nC : Coda (ending consonant phonemes)\n - : Indicates syllable break\n' :  Indicates primary stress\n^ :  Indicates \"stressed or unstressed\"", 0, 5,300,400);
      translate(0,150);
      text("Ext. Phonetic Rhyme Notation:", 0, 0);
      text("_{mpv} : Match Manner, Place, Voice", 0, 10,300,400);
      translate(0, 55);
      fill(245);
      rect(-5,0,width-20,150);
      fill(100);
      text("Visual Rhyme Notation:", -5, 0);
      text("A :  Vowel\nB :  Consonant\nY :  Vowel or Consonant\n* : Mixed Character Clusters e.g. \"est/tes\"", 0, 20);
      translate(0,120);
      text("Ext. Structural Rhyme Notation:", 0, 0);
      text("_{s} :  Match structure (e.g. A_{s} : A/O (vowel/vowel) match)", 0, 20);
      translate(0,45);
      textSize(9);
      text("Link to paper", -5, 0);
      textSize(11);
      
    }
    
    void mousePressed(){
      if(mouseX < 10 && mouseY < 10){
     f.dispose(); 
      }
    }
} 
