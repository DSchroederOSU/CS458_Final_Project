class menuItem {
  String Title;
  boolean header = false;
  int id;
  int setNum;
  int sz;
  boolean hover = false;
  boolean selected = false;
  boolean active = true;
  boolean lScrollOn = false;
  boolean rScrollOn = false; 
  float menuItem_x;
  float menuItem_width = 350; 
  float menuItem_height = 40;
  float menuItem_y, text_y;
  float padding_x = 0;
  float padding_y = 20;
  float poem_y = 24 + 16 + 30;
  float running_x;
  ArrayList<circ> circs = new ArrayList<circ>();
  float cScroll = 30;
  boolean lshover = false;   //scroll hover
  boolean rshover = false;
  boolean omitHover = false;
  int type;
  boolean out;
  
  menuItem(int _id) {
    rSet_x = maxX+52; 
    id = _id;
    setNum = RhymeSets.get(id).size();
    menuItem_x = 0;
    //println("SetNum: "+setNum);
    Title = (id < rules.size()) ? rules.get(id).name: "Custom Sets   ";
    menuItem_y = poem_y + id*menuItem_height;
    if(id > 15){ menuItem_y += 25;}
    text_y = menuItem_y+(menuItem_height/2)+5;
    Collections.sort(RhymeSets.get(id), new rhymeComparable());
    running_x = menuItem_x + textWidth(Title) + padding_x + 5;
    for (int s = 0; s < setNum; s++) {
      RhymeSets.get(id).get(s).genSetWrds(id, s);
      RhymeSets.get(id).get(s).menu = this;
      sz = RhymeSets.get(id).get(s)._wrds.size(); 
      RhymeSets.get(id).get(s).sz = sz;
      running_x += sz/2; 
      circs.add(new circ(sz, running_x, text_y-5, id, s, RhymeSets.get(id).get(s)._rhymeId, this));
      running_x += sz/2+5;
      if(sz > maxSet) maxSet = sz;
    }
    menuItem_width = running_x - menuItem_x;
    type = (id < 16)?0:1;
    if(id == 25)type = 2;
  }
  
  void updateXs(){
  running_x = menuItem_x + textWidth(Title) + padding_x + 5;
  for (int s = 0; s < circs.size(); s++) {
     float m = map(circs.get(s).sz, 2, maxSet, 3, 50);
     if(maxSet <= 50){
      m = circs.get(s).sz; 
     } 
      circs.get(s).m = m;
      running_x += m/2; 
      circs.get(s).x_0 = running_x;
      circs.get(s).x = running_x;
      running_x += m/2+5;
    }
  }
  
  void addCustom(){
    setNum = RhymeSets.get(id).size();
    String tm = RhymeSets.get(id).get(setNum-1)._rhymeId;
    Collections.sort(RhymeSets.get(id), new rhymeComparable());
    running_x = menuItem_x + textWidth(Title) + padding_x + 5;
    circs.clear();
    for (int s = 0; s < setNum; s++) {
      RhymeSets.get(id).get(s).genSetWrds(id, s);
      RhymeSets.get(id).get(s).menu = this;
      sz = RhymeSets.get(id).get(s)._wrds.size(); 
      RhymeSets.get(id).get(s).sz = sz;
      running_x += sz/2; 
      circs.add(new circ(sz, running_x, text_y-5, id, s, RhymeSets.get(id).get(s)._rhymeId, this));
      running_x += sz/2+5;
      RhymeSets.get(id).get(s).meanderSet();
      /*if(RhymeSets.get(id).get(s)._rhymeId.equals(tm)){
        RhymeSets.get(id).get(s).meanderSet();
      }*/
    }
    menuItem_width = running_x - menuItem_x; 
    type = 2;
  }
  
  int hack(){
  if(text_y + mScroll < 85){
      return -1;
    }else if(text_y + mScroll > height - 70){
      return 1; 
    }
    return 0;
  }

  int drawMenu() {
    if(text_y + mScroll < 85){
      return -1;
    }else if(text_y + mScroll > height - 70){
      return 1; 
    }
    
    if(active){
      fill(150);
    }else{
      noFill();
    }
    /*if(mouseX >= tx-25 && mouseX <= tx && mouseY >= text_y-10+mScroll-5 && mouseY <= text_y-10+mScroll+5){
     omitHover = true; 
     stroke(0);
    }else{
     omitHover = false; 
     stroke(150);
    }*/
    //text("-",menuItem_x+padding_x-25, text_y);
    
    if(Title.equals("Identical Rhyme/Rhyme Riche")){
      fill(150);
      stroke(150);
      textSize(11);
      textAlign(LEFT);
      text("SONIC RHYMES", menuItem_x+padding_x, text_y-30);
      //text("-", menuItem_x+padding_x-25, text_y-30);
      line(menuItem_x+padding_x, text_y-30, menuItem_x+padding_x+100, text_y-30);
      noFill();
      //ellipse(menuItem_x+padding_x-22, text_y-35,10,10);
      if(sonActive){
        //text("-", menuItem_x+padding_x-25, text_y-31);
        fill(175);
      }else{
        noFill();
        //text("+", menuItem_x+padding_x-25, text_y-31);
      }
      if(mouseX >= 5 && mouseX <= 15 && mouseY >= (text_y+rSet_y-30+mScroll) && mouseY <= (text_y+rSet_y-20+mScroll)){
        stroke(0);
        omitHover = true;
      }else{
      stroke(100);
        omitHover = false;
        }
      ellipse(menuItem_x+padding_x-22, text_y-35,10,10);
      noFill();
    }else if(Title.equals("single character")){
      fill(150);
      stroke(150);
      textSize(11);
      textAlign(LEFT);
      text("VISUAL RHYMES", menuItem_x+padding_x, text_y-30);
      line(menuItem_x+padding_x, text_y-30, menuItem_x+padding_x+100, text_y-30);
      noFill();
      if(visActive){
        //text("-", menuItem_x+padding_x-25, text_y-31);
        fill(175);
      }else{
        noFill();
        //text("+", menuItem_x+padding_x-25, text_y-31);
      }
      if(mouseX >= 5 && mouseX <= 15 && mouseY >= (text_y+rSet_y-30+mScroll) && mouseY <= (text_y+rSet_y-20+mScroll)){
        stroke(0);
        omitHover = true;
      }else{
      stroke(100);
        omitHover = false;
        }
      ellipse(menuItem_x+padding_x-22, text_y-35,10,10);
      noFill();
    }
    
    if((type == 0 && sonActive) || (type == 1 && visActive) || type == 2){
    hover();
    out = false; 
    }else{
     out = true; 
    }
    //rectMode(CORNERS);
    noStroke();
    if(!active){
      fill(200);
    }else{
    if (hover) {
      fill(HoverColor);
    } else if(selected){
      fill(cTable1.findColour(id%8));
    }else if(out){
      fill(75,50);
    }else{
      fill(75);
    }
    }
    textAlign(LEFT);
    textSize(11);
    text(Title, menuItem_x+padding_x, text_y);
    fill(200);
    pushMatrix();
    translate(cScroll,0);
    lScrollOn = rScrollOn = false;
    int scrollOn = 0;
    for (int i = 0; i < circs.size (); i++) {
      scrollOn = circs.get(i).drawcirc(cScroll);
      if(scrollOn == -1){
        lScrollOn = true;
      }else if(scrollOn == 1){
        rScrollOn = true;
      }
    }
    popMatrix();
    stroke(200);
    if(rScrollOn){
     if(rshover){
      fill(200);
     }else{
      noFill();
     } 
     line(resView + 10,text_y-15, resView + 10,text_y+5);
     triangle(resView + 10,text_y-10, resView + 13,text_y-5, resView + 10,text_y);    
    }
    
    if(lScrollOn){
     if(lshover){
      fill(200);
     }else{
      noFill();
     }
     line(textWidth(Title) + 15,text_y-15, textWidth(Title) + 15,text_y+5);
     triangle(textWidth(Title) + 15,text_y-10, textWidth(Title) + 12,text_y-5, textWidth(Title) + 15,text_y);  
    }
    
    return 0;
  }

  void update() {
   
    if(omitHover){
     if(type == 0){
      sonActive = !sonActive;
     }else if(type == 1){
      visActive = !visActive; 
     }
    }
    
    if (hover) {
      selected = !selected;
      for (int i = 0; i < setNum; i++) {
        RhymeSets.get(id).get(i).addRemovePtr(0);
      }
    }else{
    for (int i = 0; i < circs.size (); i++) {
      if (circs.get(i).hover) {
        RhymeSets.get(id).get(i).addRemovePtr(0);
      }
    }
    }
  }
  
  void addSet(){
    selected = true;
      for (int i = 0; i < setNum; i++) {
        RhymeSets.get(id).get(i).addRemovePtr(0);
     }
  }
  
  void removeSet(){
     selected = false;
      for (int i = 0; i < setNum; i++) {
        RhymeSets.get(id).get(i).addRemovePtr(0);
     }
  }
  
  void meander(){
    for (int i = 0; i < setNum; i++) {
        RhymeSets.get(id).get(i).meanderSet();
     }
  }

  void hover() {
    //if (mouseX >= (rSet_x) && mouseX <= (rSet_x + textWidth(Title)+ 5) && mouseY >= (text_y+rSet_y-10+mScroll) && mouseY <= (text_y+rSet_y+10+mScroll)) { //add y coords later
    if (mouseX >= tx && mouseX <= tx + textWidth(Title)+ 5 && mouseY >= (text_y+rSet_y-10+mScroll) && mouseY <= (text_y+rSet_y+10+mScroll)) {
      hover = true;
      for (int i = 0; i < setNum; i++) {
        RhymeSets.get(id).get(i).ptr.mhover = true;
      }
    } else {
      hover = false;
      for (int i = 0; i < setNum; i++) {
        RhymeSets.get(id).get(i).ptr.mhover = false;
      }
    }
    if(rScrollOn && mouseX >= tx+resView + 8 && mouseX <= tx+resView + 15 && mouseY >= text_y-5+rSet_y+mScroll && mouseY <= text_y+10+rSet_y+mScroll){
     rshover = true; 
    }else{
     rshover = false;
    }
    if(lScrollOn && mouseX >= tx + textWidth(Title) + 10 && mouseX <= tx + textWidth(Title) + 15 && mouseY >= text_y+rSet_y-5+mScroll && mouseY <= text_y+10+rSet_y+mScroll){
     lshover = true; 
    }else{
     lshover = false;
    }
    if(rshover && mousePressed){
     cScroll -= 10; 
    }else if(lshover && mousePressed){
     cScroll += 10; 
    }
  }
  
};


class circ {  
  int sz;
  float mn = 1.5;
  float mn_y;
  float m = 0; //rescaling
  float x, y, x_0;
  boolean hover;
  int id, s;
  String rhymeId;
  menuItem menu;

  circ(int _sz, float _x, float _y, int _id, int _s, String _rhymeId, menuItem _menu) {
    sz = _sz;
    x = _x;
    x_0 = _x;
    y = _y;
    id = _id;
    s = _s;
    mn_y = (sz < 10) ? 10 : sz/2;
    rhymeId = _rhymeId;
    menu = _menu;
  } 

  void isHover(float cScroll) { 
    rSet_x = tx;
    x = x_0;
    //m = sz;
    //m = map(sz, 2, maxSet, 3, 50);
    //x = x_0 * (m/sz);
    if(maxSet <= 50){ m = sz; 
    //x = x_0; 
    }
    if (mouseX >= x-m/mn + rSet_x + cScroll && mouseX <= x+m/mn + rSet_x + cScroll && mouseY >= y-mn_y+rSet_y+5+mScroll && mouseY <= y+mn_y+rSet_y+10+mScroll) { //make this better
      RhymeSets.get(id).get(s).hover = true;
      RhymeSets.get(id).get(s).ptr.hover = true;
      hover = true;
      //return true;
    } else {
      RhymeSets.get(id).get(s).hover = false;
      RhymeSets.get(id).get(s).ptr.hover = false;
      hover = false;
      //return false;
    }
  }

  int drawcirc(float cScroll) {
   if(x+m/mn+cScroll > resView){
     return 1; 
   }else if(x-m/mn+cScroll < textWidth(menu.Title) + 20){
     return -1; 
   }
   //float m = map(sz, 2, maxSet, 3, 40);
   //if(maxSet <= 40) m = sz;
   if(menu.active && !menu.out){
   isHover(cScroll);
   }
   if (hover) {
      stroke(50);
      fill(100);
      if (s%2 == 0) {
        text(rhymeId, x-(textWidth(rhymeId)/2), y-(m/2)-5);
      } else {
        text(rhymeId, x-(textWidth(rhymeId)/2), y+(m/2)+15);
      }
      fill(HoverColor, 200);
    } else if (menu.selected || RhymeSets.get(id).get(s).ptr.selected) {
      noStroke();
      fill(100);
      if (s%2 == 0) {
        text(rhymeId, x-(textWidth(rhymeId)/2), y-(m/2)-5);
      } else {
        text(rhymeId, x-(textWidth(rhymeId)/2), y+(m/2)+15);
      }
      fill(cTable1.findColour(setPointers.indexOf(RhymeSets.get(id).get(s).ptr)%8)); //FIX THIS
      if(menu.selected){
      fill(cTable1.findColour(menu.id%8));
    } else if(RhymeSets.get(id).get(s).ptr.selected){
      fill(cTable1.findColour(setPointers.indexOf(RhymeSets.get(id).get(s).ptr)%8));
    } else if ((menu.hover || RhymeSets.get(id).get(s).ptr.whover) && menu.active) {
      noStroke();
      fill(HoverColor, 200);
    } else if(!menu.active){
      noStroke(); 
      fill(220);
    }
    }else{
      noStroke(); 
      fill(200);
    }
    
    if ((menu.hover || RhymeSets.get(id).get(s).ptr.whover) && menu.active) {
      noStroke();
      fill(HoverColor, 200);
    }
    
    if(menu.out){
     noStroke();
     fill(75,50); 
    }
    
    if(maxSet > 40){
       //float m = map(sz, 2, maxSet, 5, 40);
       ellipse(x, y, m, m);
    }else{
       ellipse(x, y, sz, sz);
    }
    return 0;
  }

  void drawcircTxt() {
    if (hover || RhymeSets.get(id).get(s).selected) {
      stroke(0);
      fill(100);
      if (s%2 == 0) {
        text(rhymeId, x-(textWidth(rhymeId)/2), y-(sz/2)-10);
      } else {
        text(rhymeId, x-(textWidth(rhymeId)/2), y+(sz/2)+20);
      }
    } else {
      noStroke();
    }
    fill(200);
    //ellipse(x,y,sz,sz);
  }
}

