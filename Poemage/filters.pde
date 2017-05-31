class filterH {
 float y,x;
 float miny = 0;
 float maxy = 0;
 float yOffset = 0.0; 
 float higher = 0;
 boolean over = false;
 boolean pressed = false;
 boolean locked = false;
 float dx = 0;
 int fill = 200;
 filterH(float _x, float _y){
    y = _y;
    x = _x;
    miny = _y;
 }
 void update(){
   y = y + yOffset;
   y = constrain(y, miny, lfilt.y-8);
   higher = y;
   if(locked){    
   //adjust
   }
   overMouse();
   pressMouse();
   if(over == true || locked){
    fill = 0; 
   } else {
     fill = 200;
   }
   if(pressed == true){
    yOffset = mouseY - y; 
   }
  //println(x+" "+y);  
 }
 void display(float _dx){
   dx = _dx;
    update();
    stroke(fill);
    strokeWeight(1);
    fill(fill);
    //y = constrain(y, plotY1, axis[index].filtL.y);
    triangle(x-4, y, x+4, y, x, y+4);
    //println(x+" "+y);
 }
 
 void overMouse() {
    if (mouseX >= (x - 5) && mouseX <= (x + 5) && mouseY >= (y - 3)  && mouseY <= (y + 6) && locked == false) { //add y coords later
      over = true;
    } 
    else {
      over = false;
    }
  }
  
  void pressMouse() {
    if ((over && mousePressed && !lfilt.locked) || locked) {
      pressed = true;
      locked = true;
    } else {
      pressed = false;
      locked = false;
    }
  }
  
  void releaseMouse(){
    pressed = false;
    over = false;
    locked = false;
  }
 
};

//low filter

class filterL {
 float y,x;
 float yOffset = 0.0; 
 float higher = 0;
 boolean over = false;
 boolean pressed = false;
 boolean locked = false;
 float miny = 0;
 float maxy = 0;
 int fill = 200;
 float dx = 0;
 filterL(float _x, float _y){
    y = _y;
    x = _x;
    maxy = _y;
 }
 void update(){
   y = y + yOffset;
   y = constrain(y, hfilt.y, maxy);
   higher = y;
   if(locked){  
   }
   overMouse();
   pressMouse();
   if(over == true || locked){
    fill = 0; 
   } else {
     fill = 200;
   }
   if(pressed == true){
    yOffset = mouseY - y; 
   }  
 }
 void display(float _dx){
    dx = _dx;
    update();
    stroke(fill);
    strokeWeight(1);
    fill(fill);
    triangle(x-4, y, x+4, y, x, y-4);
 }
 
 void overMouse() {
    if (mouseX >= (x - 5) && mouseX <= (x + 5) && mouseY >= (y - 3)  && mouseY <= (y+6) && locked == false) { //add y coords later
      over = true;
    } 
    else {
      over = false;
    }
  }
  
  void pressMouse() {
    if ((over && mousePressed && !hfilt.locked)|| locked) {
      pressed = true;
      locked = true;
      //println("arrowPressed!");
    } else {
      pressed = false;
      locked = false;
    }
  }
  
  void releaseMouse(){
    pressed = false;
    over = false;
    locked = false;
  }
 
};
