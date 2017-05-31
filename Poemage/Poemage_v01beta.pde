// for svg output
import java.util.Date;
import processing.pdf.*;
import processing.opengl.*;
import java.io.File;

//color schemes
import org.gicentre.utils.colour.*;

//for timestamps
import java.util.*;
import java.lang.Object.*;
import java.awt.*;
import java.awt.geom.*;
File dir;
String[] pFiles;

import controlP5.*;

DropdownList poems;

boolean init = true; 

//buttons
mbutton hball_b, clear_b, hoverWrd_b, customSet_b, uncertainty_b, showWords_b, showContext_b, fill_b, shuffle_b, m1_b, m2_b, m3_b, m4_b, nodes_b;

PrintWriter output, uncertaintyO;
String[] poem, poemU;
String[] uncertainty;

int noPoem = 0;
int poemPlease = 0;
int nexistpas = 0;
Word dropWord;
int _d = 10;

ControlP5 cp5, cp5_fr;
DropdownList rulesList;

// for window resize
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;

//int _w, _h, _min_w, _min_h;

int _pronunciations;

boolean _print_pdf = false;
int _pdf_counter = 0;
boolean selWord = false;

//TextView _text_view;
int[] _text_view_origin;
int _text_view_width, _text_view_height;

float[] tabLeft, tabRight; // tab vars
float tabTop, tabBottom;
float tabPad = 10;
dropdown dropMenu;
int dropi, dropj;
boolean menuOn = false;
String poemFile = "";
String errorMessage = "";
String currUpload = "";

CMUMap _cmuMap;
CMUMap2 _cmuMap2;
pMap _pMap;

//LTS 
LTS lts;

//notation guide
PFrame f;
secondApplet s;

void setup() {
  //generate new LTS
  isT = createInput("cmudict04_lts_mod.txt");
  lts = LTS.getInstance(isT);

  _min_w = _min_h = 200;
  //_w = 400;
  //_h = 300;

  _cmuMap = new CMUMap();
  _pMap = new pMap();

  sep = 50;

  dropMenu = new dropdown();
  // read in the data
  //readPoemFile( "../../../../Poems/rhymes.txt" );
  //readPoemFile( "./Poems/Night.txt" );
  //readPoemFile( "./Poems/GoldLeaf_ex.txt" );
  //readPoemFile( "./Poems/TheSkyWas.txt" );
  //readPoemFile( "./Poems/InJust.txt" );
  //readPoemFile( "./Poems/JustToSay.txt" );
  //readPoemFile( "./Poems/FedDrapes.txt" );
  //readPoemFile( "./Poems/MachinationsCalcite.txt" );
  //instead read config.txt
  //String[] poem = loadStrings("../../../../Poems/config.txt");

  File d = new File(sketchPath("")+"/Poems");
  if (!d.exists()) {
    readPoemFile("../../../../Poems/Night.txt");
  } else { 
    readPoemFile("./Poems/Night.txt");
  }
  //readPoemFile("./Poems/TheSkyWas.txt");
  //readPoemFile( "./Poems/FedDrapes.txt" );

  // create fonts
  generateFonts();
  addExistingRules();
  
  eye2 = new rhymerule("Eye2", "!O[NC^-...]");
  
  find_rhymes2();


  // create the views
  //_text_view = new TextView();
  //_text_view_origin = new int[2];


  cTable1 = new ColourTable();
  cTable1.addDiscreteColourRule(0, 166, 206, 227);
  cTable1.addDiscreteColourRule(1, 31, 120, 180);
  cTable1.addDiscreteColourRule(2, 178, 223, 138);
  cTable1.addDiscreteColourRule(3, 51, 160, 44);
  cTable1.addDiscreteColourRule(4, 251, 154, 153);
  cTable1.addDiscreteColourRule(5, 227, 26, 28);
  cTable1.addDiscreteColourRule(6, 106, 61, 154);
  cTable1.addDiscreteColourRule(7, 202, 178, 214);
  cTable1.addDiscreteColourRule(8, 106, 61, 154);

  //cTable1 = ColourTable.getPresetColourTable(ColourTable.PAIRED_12,0,9);
  //cTable1 = ColourTable.getPresetColourTable(ColourTable.SET2_8,0,8);

  _w = (int)(370 + sep*2 + maxX*2+30+tx*2);

  //set the window dimensions
  //_w += _text_view.longest_line;
  //_w = 1200;
  //_h = 800;
  _h = displayHeight-20; 

  size( _w, _h);
  
  frame.setLocation(0, 0);

  genButtons();
  genCP5();
  setDimensions();

  //noLoop();


  //pMax = height - 30;

  //popout
  //f = new PFrame();

  //makeFields();

  /*gc = createGraphics(width, height);
  gc.beginDraw();
  gc.strokeWeight(1);
  gc.noFill();
  for (int i = 20; i < 60; i++) {
    float inter = map(i, 20, 60, 0, 200); 
    color c = lerpColor(0, 255, inter);
    gc.stroke(inter); 
    gc.arc(0, 0, 2*i, 2*i, 0, PI);
  }
  gc.endDraw();*/
  //resize(displayWidth,displayHeight);
  setDimensions();
  
} 

void genButtons() {  
  println("sizes "+frame.getHeight()+" "+height+" "+displayHeight);
  //int button_y = height-40;
  int button_y = height+40;

  clear_b = new mbutton(15, button_y, "clear");
  hball_b = new mbutton(clear_b._x+clear_b._dx+_d, clear_b._y, "beautiful mess");
  hoverWrd_b = new mbutton((int)(tx+360+sep), clear_b._y, "hover word");
  uncertainty_b = new mbutton(hoverWrd_b._x+hoverWrd_b._dx+_d, clear_b._y, "show uncertainty");
  customSet_b = new mbutton(uncertainty_b._x+uncertainty_b._dx+_d, clear_b._y, "custom set");

  showWords_b = new mbutton((int)(tx+maxX+340+2*sep), clear_b._y, "show words");
  showContext_b = new mbutton(showWords_b._x+showWords_b._dx+_d, clear_b._y, "show context");
  //fill_b = new mbutton((int)graphX, clear_b._y-30, "fill intersecting paths");
  fill_b = new mbutton(showContext_b._x+showContext_b._dx+_d, clear_b._y, "fill intersecting paths");
  m1_b = new mbutton(((int)(tx+maxX+340+2*sep)+(int)textWidth("Modes: ")), (int)graphY+5, "1  ");
  m2_b = new mbutton(m1_b._x+m1_b._dx+10, (int)graphY+5, "2  ");
  m3_b = new mbutton(m2_b._x+m2_b._dx+10, (int)graphY+5, "3  ");
  //m4_b = new mbutton(m3_b._x+m3_b._dx+10, (int)graphY+40, "4  ");
  m1_b._selected = true;
  shuffle_b = new mbutton(m3_b._x+m3_b._dx+40, (int)graphY+5, "shuffle");
  nodes_b = new mbutton(shuffle_b._x+shuffle_b._dx+10, (int)graphY+5, "nodes");
  nodes_b._selected = true;
}

void genCP5() {

  cp5 = new ControlP5(this);
  cp5.setControlFont(new ControlFont(_pixel_font_8, 9));
  //cp5.setAutoDraw(false);
  // create a DropdownList
  poems = cp5.addDropdownList("Select Poem")
    .setPosition(180, 30)
      .setSize(200, 400)
        ;
  customize(poems);

  cp5.addSlider("ContextSlider")
    .setPosition(400, 30)
    .setSize(85, 10)
      .setRange(1, 5)
      .setColorBackground(color(150))
      .setColorCaptionLabel(color(100))
      .setCaptionLabel("Context Slider")
      .setColorActive(LT_BLUE)
        .setNumberOfTickMarks(5)
        .showTickMarks(false)
          ;
}

//(int)graphY+40

void newPoem(){
  _w = (int)(370 + sep*2 + maxX*2+30+tx*2);
  _h = _text_view_height+60; 
  //_h = displayHeight - 100;
  size( _w, _h);
  setDimensions();
}

void setDimensions() {
  sep = 50;
  // set up the TEXT VIEW
  _text_view_origin[0] = WINDOW_BORDER_WIDTH;
  _text_view_origin[1] = WINDOW_BORDER_WIDTH;
  _text_view_width = _w - 2*WINDOW_BORDER_WIDTH;
  _text_view_height = _h - 2*WINDOW_BORDER_WIDTH;
  _text_view.setDimensions( _text_view_width, _text_view_height );
  //sep = min((_text_view_width - (maxX*2 + 360 + tx))/2.0, 50);

  _w = max( frame.getWidth(), _min_w*2 );
  //_h = max( frame.getHeight(), _min_h+22 );
  _h = max( frame.getHeight(), _min_h+22 );
  frame.setSize(_w, _h); 
  
  //println("sizesA "+frame.getHeight()+" "+height+" "+displayHeight+" "+clear_b._y);
  
  int button_y = _text_view_height+20;

  clear_b._y = button_y;
  hball_b._y = button_y;
  hoverWrd_b._y = button_y;
  uncertainty_b._y = button_y;
  customSet_b._y = button_y;

  showWords_b._y = button_y;
  showContext_b._y = button_y;
  fill_b._y = button_y;

  showWords_b._x = (int)(tx+maxX+335+2*sep);
  showContext_b._x = showWords_b._x+showWords_b._dx+_d;
  fill_b._x = showContext_b._x+showContext_b._dx+_d;
  m1_b._x = (int)(tx+maxX+340+2*sep)+(int)textWidth("Modes: ");
  m2_b._x = m1_b._x+m1_b._dx+10;
  m3_b._x = m2_b._x+m2_b._dx+10;
  shuffle_b._x = m3_b._x+m3_b._dx+40;
  nodes_b._x = shuffle_b._x+shuffle_b._dx+10;

  pMin = height-nodeLocs.get(nodeLocs.size()-1).y-80;
  //sMin = height-1100+50;
  sMin = height - _text_view.rhymes.get(_text_view.rhymes.size()-1).menuItem_y-125 - 75;

  lfilt.y = min(nodeLocs.get(nodeLocs.size()-1).getY()+scale+5, height-50);
  cp5.controller("ContextSlider").setPosition(showContext_b._x, button_y+20);
  //temp!
  //_text_view_height = height-20;
  
  //println("sizes A "+frame.getHeight()+" "+height+" "+displayHeight+" "+clear_b._y);
}

void generateFonts() {
  _georgia_12 = createFont( "Georgia", 12, true );
  _georgia_14 = createFont( "Georgia", 14, true );
  _georgia_14b = createFont( "Georgia-Bold", 14, true );
  _georgia_16 = createFont( "Georgia", 16, true );
  _georgia_24b = createFont( "Georgia-Bold", 24, true );
  _helvetica_12 = createFont( "Helvetica", 24, true );
  _clairhand_14 = createFont( "ClaireHand-Regular", 14, true );
  _gillsans_16i = createFont( "GillSans-Italic", 16, true );
  _gillsans_20i = createFont( "GillSans-Italic", 20, true );
  _pixel_font_10 = createFont( "PFTempestaSeven", 10, false );
  //_pixel_font_8 = createFont( "MicrosoftSansSerif", 12, true );
  //_pixel_font_bold = createFont( "MicrosoftSansSerif-Bold", 12, false );
  _pixel_font_8 = createFont( "LucidaGrande", 12, true );
  _pixel_font_8i = createFont( "LucidaBright-Italic", 12, true );
  _pixel_font_bold = createFont( "TrebuchetMS-Bold", 12, false );
  //_pixel_font_bold = loadFont("LucidaGrande-Bold-48.vlw");

  // support window resizing
  frame.setResizable(true);
  frame.addComponentListener(new ComponentAdapter() {
    public void componentResized(ComponentEvent e) {
      if (e.getSource()==frame) 
      { 
        _w = max( frame.getWidth(), _min_w*2 );
        _h = max( frame.getHeight(), _min_h+22 );
        frame.setSize(_w, _h); 
        _h -= 22; // offset on mac (still true????)
        setDimensions();
      }
    }
  } 
  );
}

void draw() {
  // this is for rendering to a pdf file
  if ( _print_pdf ) {
    Date date = new Date();
    String filename = "./output/textView_" + date.toString() + ".pdf";
    beginRecord(PDF, filename);
  }
  

  background( BACKGROUND_COLOR);
  //background(255); 

  // translate to the origin of the TEXT VIEW
 
  //drawScene();
  //drawPopout();
  //println(mouseX+" ,"+mouseY);
  //drawScene();
  _text_view.render();
  drawButtons();
    
  // Poemage label
  textAlign( RIGHT, BOTTOM );
  textFont( _pixel_font_8 );
  fill( POEMAGE_LABEL_TEXT_COLOR );
  //fill(150);
  textSize(8);
  text( "Poemage v0.1", _w-5, _h-5 );
  textSize(12);
  
    
  //pronunciation menu
  if (uncertainty_b._selected && menuOn) {
    pushMatrix(); 
    dropMenu.drawMenu(dropWord);
    popMatrix();
  }

  if ( _print_pdf ) {
    _print_pdf = false;
    endRecord();
  }
}

void keyPressed() {
  if ( key == 'P' ) _print_pdf = true;
  if ( key == 'f' ) fill = !fill;
  if ( key == 'n' ) nodesOn = !nodesOn;
  if ( key == 'o' ) order = !order;
  if ( key == 'p'){
  PGraphics pdf = createGraphics(800, (int)nodeLocs.get(nodeLocs.size()-1).y+100, PDF, "output.pdf");
  pdf.beginDraw();
  pdf.background(255);
  pdf.translate(20,0);
  _text_view.renderPDF(pdf);
  pdf.dispose();
  pdf.endDraw(); 
  }
}


void drawButtons(){
//draw buttons
  hball_b.drawButton();
  clear_b.drawButton();
  hoverWrd_b.drawButton();
  customSet_b.drawButton();
  uncertainty_b.drawButton();
  showWords_b.drawButton();
  showContext_b.drawButton();
  fill_b.drawButton();
  shuffle_b.drawButton();
  nodes_b.drawButton();
  //graph modes
  m1_b.drawButton();
  m2_b.drawButton();
  m3_b.drawButton();
}


void mouseMoved() {
}

void mouseClicked() {
  int x1 = 520;
  int y1 = 70; 
  int sp = 20;
  for (int i = 0; i < rules.size (); i++) { 
    if (mouseX >= x1+0 && mouseX <= x1+10 && mouseY >= y1+i*sp-4 && mouseY <= y1+i*sp+6) {
      rules.remove(i);
    }
  }

  if (mouseX >500 && mouseX <= 510 && mouseY >= 407 && mouseY <= 417) {
    combineRules = !combineRules;
    println("combine Rules: "+combineRules);
  }

  int b = setPointers.size();

  //if selected is changed, update interactions. 
  if (b-setPointers.size() != 0) {
    _text_view.pgraph.updateInts();
  }

  //update buttons
  hball_b.clicked();
  clear_b.clicked();
  hoverWrd_b.clicked();
  customSet_b.clicked();
  uncertainty_b.clicked();
  showWords_b.clicked();
  showContext_b.clicked();
  fill_b.clicked();
  shuffle_b.clicked();
  nodes_b.clicked();
  m1_b.clicked();
  m2_b.clicked();
  m3_b.clicked();
  //m4_b.clicked();


  for (int r = 0; r < _text_view.rhymes.size (); r++) {
    _text_view.rhymes.get(r).update();
  }

  for (int i = 0; i < nodeLocs.size (); i++) {
    nodeLocs.get(i).update();
  }
}

void mousePressed() {
  if (mouseButton == RIGHT && uncertainty_b._selected) {
    println("yippee!!");
    for (int i = 0; i < nodeLocs.size (); i++) {
      if (nodeLocs.get(i).hoverUncertainty) {
        menuOn = true;
        dropWord = nodeLocs.get(i)._word;
        println(dropWord._displayWord);
        return;
      }
    }
    menuOn = false;
    dropWord = null;
  }
}

void mouseReleased() {
  if (mouseButton == RIGHT && uncertainty_b._selected) {
    menuOn = false;
    dropMenu.mouseReleased();
    dropWord = null;
  } else if (uncertainty_b._selected && dropWord != null) {
    menuOn = false;
    dropMenu.mouseReleased();
    dropWord = null;
  }
  hfilt.releaseMouse();
  lfilt.releaseMouse();
}

void mouseWheel(MouseEvent event) {
  if (mouseX >= tx+350+sep && mouseX <= tx+350+sep+maxX) {
    float t = - event.getCount();
    if (t < 0 && pScroll > pMin) {
      pScroll = (pScroll + t >= pMin) ? pScroll + t : pMin;
    } else if (t > 0 && pScroll < pMax) {
      pScroll = (pScroll + t <= pMax) ? pScroll + t : pMax;
    }
  } else if (mouseX >= tx && mouseX <= tx + 350) {
    float t = - event.getCount();
    if (t < 0 && mScroll > sMin) {
      mScroll = (mScroll + t >= sMin) ? mScroll + t : sMin;
    } else if (t > 0 && mScroll < pMax) {
      mScroll = (mScroll + t <= pMax) ? mScroll + t : pMax;
    }
  }
}

void drawScene() {
  color bckg = color(230);
  //color bckg = color(203,224,237);
  textSize(12);
  textAlign(LEFT, CENTER);
  pushMatrix();
  translate(20, 20);
  stroke(200);
  noFill();
  rect(0, 0, 450, 125);
  fill(bckg);
  rect(0, 0, 450, 20);
  fill(100);
  text("1. Upload Poem", 5, 8);
  text("Poem File: ", 20, 50);
  if (nexistpas == 1) {
    textSize(11);
    fill(ORANGE);
    String st = "Poems/"+cp5.get(Textfield.class, "poem").getText()+".txt";
    text("The file "+ st + " does not exist...", 20, 90);
    textSize(12);
  } else if (poemFile.length()>0) {
    textSize(11);
    fill(LT_BLUE);
    //String st = "Poems/"+cp5.get(Textfield.class,"poem").getText()+".txt";
    text("Poem uploaded: "+ currUpload, 20, 90);
    textSize(12);
  }
  //text("Uncertainty File: ",20,80);
  noFill();
  translate(0, 150);
  fill(100);
  noFill();
  rect(0, 20, 450, 105);
  fill(bckg);
  rect(0, 0, 450, 20);
  fill(100);
  text("2. Generate Custom Rule", 5, 8);
  if (errorMessage.length() > 0) {
    fill(ORANGE);
    text("Error: "+errorMessage, 10, 60, 440, 60);
  }
  noFill();
  translate(0, 150);
  rect(0, 0, 450, 295);
  fill(bckg);
  rect(0, 0, 450, 20);
  fill(100);
  text("3. Select Existing Rule", 5, 8);
  noFill();
  rect(10, 39, 427, 189);
  popMatrix();
  pushMatrix();
  translate(500, 20);
  rect(0, 0, 315, 375);
  fill(bckg);
  rect(0, 0, 315, 20);
  fill(100);
  text("Current Rules", 5, 8);
  noFill();
  rect(0, height-254, 10, 10);
  fill(100);
  text("Combine Rules", 15, height-250);
  if (combineRules) {
    text("\u2713", 1, height-250);
  }

  text("4. Run Program!", 15, height-75);
  if (poemPlease == 1) {
    //fill(255,0,0);
    fill(ORANGE);
    text("Please upload a poem", 15, height-95);
  }
  noFill();
  translate(20, 50);
  textSize(10);
  int sp = 20;
  for (int i = 0; i < rules.size (); i++) {
    if (mouseX >= 520+0 && mouseX <= 520+10 && mouseY >= 70+i*sp-4 && mouseY <= 70+i*sp+6) {
      fill(200);
    } else {
      noFill();
    }
    rect(0, i*sp-4, 10, 10);  
    line(0, i*sp-4, 10, i*sp+6);
    line(10, i*sp-4, 0, i*sp+6);
    fill(100);
    text(rules.get(i).strRule, 20, i*sp);
  }
  popMatrix();
}

//submit new rule
public void submit() {
  if (!containsRule(cp5.get(Textfield.class, "input").getText())) {
    if (checkRule(cp5.get(Textfield.class, "input").getText())) {
      rhymerule rule_tmp = new rhymerule(cp5.get(Textfield.class, "input").getText());
      //make sure rule is lega
      rules.add(rule_tmp);
    }
  }
  //cp5.get(Textfield.class,"input").clear();
}

boolean checkRule(String rule) {
  //if((rule.contains("[ONC]")) && (rule.contains("[ABY]"))){
  if ((rule.contains("O") || rule.contains("N") || rule.contains("C")) && (rule.contains("A") || rule.contains("B") || rule.contains("Y")) ) {
    errorMessage = "Sorry, rules may not combine syllable(ONC) and visual(ABY) notation";
    return false;
  } else if ((rule.contains("A") || rule.contains("B") || rule.contains("Y")) && rule.contains("-")) {
    errorMessage = "Sorry, syllable segmentation (indicated with \"-\") cannot be applied to orthographic representations";
    return false;
  } else if ((rule.contains("A") || rule.contains("B") || rule.contains("Y")) && (rule.contains("_{m") | rule.contains("_{v") | rule.contains("_{p"))) {
    errorMessage = "For structural rhymes, please use \"_{s}\" ";
    return false;
  } else if ((rule.contains("O") || rule.contains("N") || rule.contains("C")) && rule.contains("_{s}")) {
    errorMessage = "For phonetic rhymes, please use a variation of \"_{mvp}\" ";
    return false;
  } else if ((rule.contains("O") || rule.contains("N") || rule.contains("C")) && rule.contains("*")) {
    errorMessage = "the symbol \"*\" cannot be applied to syllables"; 
    return false;
  }/*else if((rule.contains("A") || rule.contains("B") || rule.contains("Y")) && rule.contains("\'")){
   errorMessage = "the symbol \" \' \" cannot be applied to orthographic "; 
   return false;
   }*/
  else {
    errorMessage = "";
    return true;
  }
}

boolean containsRule(String rr) {
  for (int i = 0; i < rules.size (); i++) {
    if (rr.equals(rules.get(i).strRule)) {
      return true;
    }
  }
  return false;
}

public void upload1() {
  clearAll();  
  poemFile = cp5.get(Textfield.class, "poem").getText().replaceAll(".txt", "");
  File f = new File(sketchPath("./Poems/"+poemFile+".txt"));
  if (!f.exists()) {
    nexistpas = 1;
  } else {
    nexistpas = 0;
    noPoem = 1;
    poem = loadStrings("../../../Poems/"+poemFile+".txt");
    currUpload = "Poems/"+poemFile+".txt";
    //loadUncertainty(poemFile);
    //readPoemFile("./Poems/"+poemFile+".txt");
    //readPoemFile( "./Poems/Night.txt" );
    //_text_view = new TextView();
    //_text_view_origin = new int[2];
  }
} 

void clearAll() {
  poem = new String[0]; 
  _text_view = null;
  poemFile = "";
  _text_view_origin = new int[0];
}

void loadUncertainty(String _poemFile) {
  pronNumbers = new int[poem.length*20];
  customPron = new String[poem.length*20];
  File f = new File(sketchPath("./Poems/"+poemFile+"_uncertainty.txt"));
  //poemU = loadStrings("./Poems/"+poemFile+"_uncertainty.txt");
  if (f.exists()) {
    println("uncertainty file exists");
    poemU = loadStrings("./Poems/"+poemFile+"_uncertainty.txt");
    int start = 0;
    int st2 = 0;
    for (int i = 0; i < poemU.length; i++) {
      if (poemU[i].length()==0) {
        continue;
      }
      if (start == 0 && poemU[i].charAt(0) == '*') {
        start = 1;
        continue;
      } else if (start == 1 && poemU[i].charAt(0) == '*') {
        if (st2 == 1) {
          return;
        } else {
          start = 0;
          st2 = 1;
          continue;
        }
      } else if (start == 1) {
        if (poemU[i].charAt(0) == '%') { //skip commented lines
          continue;
        } else {
          String[] sp = split(poemU[i], ":");
          //println(sp);
          if (sp.length == 2) {
            pronNumbers[int(sp[0])] = int(sp[1]);
          } else if (sp.length > 2) {
            pronNumbers[int(sp[0])] = int(sp[1]);
            customPron[int(sp[0])] = "";
            customPron[int(sp[0])] = sp[2].replaceAll(" ", "_");
            println("custom: "+customPron[int(sp[0])]);
            /*
        for(int c = 2; c < sp.length; c++){  
             if(c > 2){
             customPron[int(sp[0])] += ":";
             }  
             customPron[int(sp[0])] += sp[c].replaceAll(" ","_");
             }*/
          }
        }
      }
    }
  } else {
    //nexistpas = 1;
    println("can't find uncertainty file");
  }
  //println(pronNumbers);
}
/*public void upload2() {
 uncertainty = loadStrings("./Poems/"+cp5.get(Textfield.class,"uncertainty").getText()+".txt");
 }*/

void find_rhymes2() {
  ptrCounter = 0;
  _text_view = new TextView();
  _text_view_origin = new int[2];
  int m = millis();
  _text_view.findRhymes();
  int ti = millis()-m;
  _text_view.updatePointers();
  _text_view.pgraph = new graph();
  println("time: "+ti +" "+m);
  _text_view.genGraph();
  //output = createWriter("./Poems/output.txt");
  //_text_view.printRhymeSets(output);
  //output.flush();
  //output.close();
}

public void find_rhymes() {
  if (noPoem == 0) {
    poemPlease = 1;
    return;
  } else {
    poemPlease = 0;
  }
  loadUncertainty(poemFile);
  readPoemFile("./Poems/"+poemFile+".txt");
  _text_view = new TextView();
  _text_view_origin = new int[2];
  _text_view.findRhymes();
  //String file = poemFile+"_output.txt";//cp5_fr.get(Textfield.class,"input2").getText();
  String file = cp5_fr.get(Textfield.class, "input2").getText();
  output = createWriter("./Poems/"+file);
  uncertaintyO = createWriter("./Poems/"+poemFile+"_uncertainty.txt");
  //_text_view.printRhymeSets(output);
  //_text_view.printPoemWithIDs(output, uncertaintyO, file);
  //_text_view.printUncertaintyFile(uncertainty);
  //output.println();
  output.flush(); // Writes the remaining data to the file
  uncertaintyO.flush();
  output.close(); // Finishes the file
  uncertaintyO.close();
  cp5_fr.get(Textfield.class, "input2").setText("output_filename");
  File f1 = new File(sketchPath("./Poems/"+cp5_fr.get(Textfield.class, "input2").getText()));
  File f2 = new File(sketchPath("./Poems/"+poemFile+"_uncertainty.txt"));
  try {
    Desktop.getDesktop().open(f1);
  } 
  catch (IOException e) { 
    e.printStackTrace();
  }
  try {
    Desktop.getDesktop().open(f2);
  } 
  catch (IOException e) { 
    e.printStackTrace();
  }
} 

void makeFields() {
  cp5 = new ControlP5(this);

  PFont font = createFont("Ariel", 11);
  PFont font2 = createFont("helvetica-light", 11);
  cp5.setControlFont(new ControlFont(createFont("Ariel", 11), 11));

  cp5.addTextfield("input")
    //.setText("...-[ONC'-ONC-ONC]")
    //.setText("...-[O]|[C]'-...")
    .setText("...[YY]")
      //.setText("...[A_{s}B_{s}]...")
      .setPosition(40, 205)
        .setSize(315, 20)
          .setFont(font)
            .setFocus(false)
              .setColor(color(100))
                .setColorForeground(color(200))
                  .setColorActive(color(200))
                    .setColorBackground(color(255))
                      .setColorCursor(color(100))
                        ;

  cp5.addBang("submit")
    .setPosition(370, 205)
      .setSize(80, 20)
        .setColorCaptionLabel(color(100))
          .setColorForeground(color(220))
            .setColorActive(color(200))
              .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                ;  


  //upload poem
  cp5.addTextfield("poem")
    .setText("tst2")
      .setPosition(155, 60)
        .setSize(200, 20)
          .setFont(font)
            .setFocus(false)
              .setColor(color(100))
                .setColorForeground(color(200))
                  .setColorActive(color(200))
                    .setColorBackground(color(255))
                      .setColorCursor(color(100))
                        ;

  cp5.addBang("upload1")
    .setPosition(370, 60)
      .setSize(80, 20)
        .setColorCaptionLabel(color(100))
          .setColorForeground(color(220))
            .setColorActive(color(200))
              .setCaptionLabel("upload")
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ;  

  //upload uncertainty
  /*cp5.addTextfield("uncertainty")
   .setText("filename")
   .setPosition(155,90)
   .setSize(200,20)
   .setFont(font)
   .setFocus(false)
   .setColor(color(100))
   .setColorForeground(color(200))
   .setColorActive(color(200))
   .setColorBackground(color(255))
   .setColorCursor(color(100))
   ;
   
   cp5.addBang("upload2")
   .setPosition(370,90)
   .setSize(80,20)
   .setColorCaptionLabel(color(100))
   .setColorForeground(color(220))
   .setColorActive(color(200))
   .setCaptionLabel("upload")
   .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
   ;*/



  //find rhymes!

  cp5_fr = new ControlP5(this);

  cp5_fr.setControlFont(new ControlFont(createFont("Ariel", 11), 11));

  cp5_fr.addTextfield("input2")
    .setText("output_filename")
      .setPosition(width-325, height-45)
        .setSize(175, 20)
          .setFont(font)
            .setFocus(false)
              .setColor(color(100))
                .setColorForeground(color(200))
                  .setColorActive(color(200))
                    .setColorBackground(color(255))
                      .setColorCursor(color(100))
                        ;

  cp5_fr.addBang("find_rhymes")
    .setPosition(width-140, height-65)
      .setSize(120, 40)
        .setColorCaptionLabel(color(100))
          .setColorForeground(color(220))
            .setColorActive(color(200))
              .setCaptionLabel("Find Rhymes!")
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ;  


  //dropdown list
  rulesList = cp5.addDropdownList("existingRulesList")
    .setPosition(32, 360)
      .setSize(425, 200)
        .toUpperCase(false) 
          ;
  customize(rulesList);
}

String makeWspace(String orig) {
  String res = "";
  //for(int i = 0; i < int(200-textWidth(orig)); i++){
  for (int i = 0; i < 50-orig.length (); i++) {
    res += " ";
  }
  return res;
}

/*void customize(DropdownList ddl) {
 // a convenience function to customize a DropdownList
 //ddl.setBackgroundColor(color(190));
 ddl.setItemHeight(20);
 ddl.setBarHeight(0);
 ddl.captionLabel().set("");
 ddl.captionLabel().style().marginTop = 3;
 ddl.captionLabel().style().marginLeft = 0;
 ddl.captionLabel().setColor(color(255));
 ddl.valueLabel().style().marginTop = 3;
 for (int i=0; i<existingRules.size (); i++) {
 ddl.addItem(existingRules.get(i).name+makeWspace(existingRules.get(i).name)+existingRules.get(i).strRule, i);
 //ddl.addItem(existingRules.get(i).name, i);
 //ddl.addItem("item "+i, i);
 }
 //ddl.scroll(0);
 ddl.setColorBackground(color(255));
 ddl.setColorForeground(color(230));
 ddl.setColorLabel(color(100));
 ddl.setColorActive(color(220));
 ddl.setColorValue(color(220));
 ddl.setBackgroundColor(color(220));
 //ddl.open();
 ddl.setOpen(true);
 ddl.disableCollapse();
 }
 
 void controlEvent(ControlEvent theEvent) {
 // DropdownList is of type ControlGroup.
 // A controlEvent will be triggered from inside the ControlGroup class.
 // therefore you need to check the originator of the Event with
 // if (theEvent.isGroup())
 // to avoid an error message thrown by controlP5.
 
 if (theEvent.isGroup()) {
 // check if the Event was triggered from a ControlGroup
 //println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
 theEvent.getGroup().setOpen(true);
 if (!rules.contains(existingRules.get(int(theEvent.getGroup().getValue())))) {
 rules.add(existingRules.get(int(theEvent.getGroup().getValue())));
 }
 theEvent.getGroup().captionLabel().set("");
 } else if (theEvent.isController()) {
 println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
 }
 }*/

void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup()+" "+pFiles[(int)(theEvent.getGroup().getValue())]);
    cursor(WAIT);
    refreshAll();
    File f = new File(sketchPath("./Poems/"+pFiles[(int)(theEvent.getGroup().getValue())]));
    if (!f.exists()) {
      f = new File("../../../../Poems/"+pFiles[(int)(theEvent.getGroup().getValue())]);
      readPoemFile( "../../../../Poems/"+pFiles[(int)(theEvent.getGroup().getValue())]);
    } else {
      readPoemFile( "./Poems/"+pFiles[(int)(theEvent.getGroup().getValue())]);
    }
    find_rhymes2();
    newPoem();
    //setDimensions();
    cursor(ARROW);
  } else if (theEvent.isController()) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
    //readPoemFile( "./Poems/"+theEvent.getController().getLabel());
    //_text_view.refresh();
  }
}

void refreshAll() {
  RhymeSets = new ArrayList< ArrayList<Set> >();  
  customSets = new ArrayList<Set>();
  Set _customSet;
  nodeLocs = new ArrayList<node>();
  pNodes = new ArrayList<PVector>();
  absLoc = new ArrayList<String>();
  routeCPs = new HashMap<PVector, ArrayList<pointer>>();
  bundleCPs = new HashMap<PVector, ArrayList<pointer>>();
  mids = new HashMap<Integer, ArrayList<midpoint>>();
  prevSetPointers = new ArrayList<pointer>();
  setPointers = new ArrayList<pointer>();
  hoveredPtrs = new ArrayList<pointer>();
  shapes3 = new ArrayList<pShape3>();
}

void customize(DropdownList ddl) {
  ControlFont font = new ControlFont(_pixel_font_8, 11);
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(240));
  ddl.setColorLabel(color(100));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.captionLabel().set("Select Poem");
  ddl.captionLabel().style().marginTop = 1;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.captionLabel().setFont(font);
  ddl.valueLabel().setFont(font);
  ddl.valueLabel().style().marginTop = 3;

  //dir = new File((System.getProperty("user.dir"))+"/Poems");
  dir = new File(sketchPath("")+"/Poems");
  if (!dir.exists()) {
    dir = new File("../../../../Poems");
  }
  println(dir.getAbsolutePath());
  pFiles = dir.list();
  if (pFiles == null) {
    println("directory not found!");
  } else {
    println(pFiles.length);
  }
  for (int i=1; i<pFiles.length; i++) {
    ddl.addItem(pFiles[i], i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(219));
  ddl.setColorForeground(color(200));
  ddl.setColorActive(color(200));
}

void ContextSlider(int value) {
  //myColor = color(theColor);
  //println("a slider event. setting background to "+value);
  cr = value;
}

