//graph related classes:
//graph
//node
//segment
//midpoint

class graph {
  float graphx = 500; 
  float graphy = 0;
  float x1, x2, y1, y2, gridX, gridY;
  float cellRes = 19; //cell resolution
  int dimX, dimY, cellDimX;
  int pass;
  //int reroutes;

  graph() {
    //quadtree
    setupQT();
  }

  void setupQT() {
    //calculate bounding box
    x1 = x2 = nodeLocs.get(0).x;
    y1 = y2 = nodeLocs.get(0).y;

    for (int i = 0; i < nodeLocs.size (); i++) {
      if (nodeLocs.get(i).x < x1) {
        x1 = nodeLocs.get(i).x;
      } 
      if (nodeLocs.get(i).x > x2) {
        x2 = nodeLocs.get(i).x;
      }
      if (nodeLocs.get(i).y < y1) {
        y1 = nodeLocs.get(i).y;
      }
      if (nodeLocs.get(i).y > y2) {
        y2 = nodeLocs.get(i).y;
      }
    }

    if ((x2-x1) % cellRes != 0) {
      x2 += cellRes - ((x2-x1) % cellRes);
    }

    dimX = int((x2-x1)/cellRes)+2;  //extra cells for padding
    cellDimX = (dimX-1)*2;

    if ((y2-y1) % cellRes != 0) {
      y2 += cellRes-((y2-y1)%cellRes);
    }

    dimY = int((y2-y1)/cellRes)+2; //extra cells for padding

    println("dimX: "+dimX+" dimY: "+dimY);

    gridX = x1 - cellRes/3;    //shift so that less nodes fall on edges
    gridY = y1 - cellRes/3;

    float d = ((x2-x1) > (y2-y1)) ? (x2-x1) : (y2-y1);
    d = 9.5 * round(d/9.5);

    QT = new QuadTree(x1-21.5, y1-19, x1+d+19, y1+d+19, null, null); 

    initQT();
    //buildQT();

    //calcPatternInts();
  }

  void initQT() {
    //skip non-words
    for (int m = 0; m < nodeLocs.size (); m++) {
      if (nodeLocs.get(m).wrd.trim().length() == 0 || (nodeLocs.get(m).wrd.trim().length() == 1 && Character.isLetter(nodeLocs.get(m).wrd.trim().charAt(0)) == false)) {
        continue;
      } else {

        QT.insert(nodeLocs.get(m));
      }
    }

    /*if(geowish){
     QT.geoWish();
     }*/
  }

  void geowish() {
    QT.geoWish();
  }

  void buildQT2() {
    for (int i = 0; i < RhymeSets.size (); i++) {
      for (int j = 0; j < RhymeSets.get (i).size(); j++) {
        for (int k = 0; k < RhymeSets.get (i).get(j)._segs.size(); k++) {
          QT.insertSeg(RhymeSets.get(i).get(j)._segs.get(k), i, j, k, 1000);
        }
      }
    } 

    reroutes = 0;
    pass = 1;  //pass tells to look for new ambs or not. 
    QT.checkForAmbiguities();    //this is where the rerouting happens


      //println("First pass. Reroutes: "+reroutes);

    /*while(reroutes > 0 || pass < 5){
     reroutes = 0;
     pass++;  
     nextPass();
     }*/

    println("Pass: "+pass+" reroutes: "+reroutes);

    QT.getNeighbors();
    QT.calcM();
    QT.getmgridNeighbors();

    updatePatterns();

    for (int i = 0; i < nodeLocs.size (); i++) {
      nodeLocs.get(i).initbundle();
    }
  }

  void buildQT() {
    updatePatterns();
  }

  void updateInts() {
  }

  void clearSegs() {
    QT.clearSegs();
  }

  void nextPass() {    //use this same idea for next pass! then update iteratively 
    for (int i = 0; i < RhymeSets.size (); i++) {
      for (int j = 0; j < RhymeSets.get (i).size(); j++) {
        RhymeSets.get(i).get(j).updateSegs();
        for (int k = 0; k <  RhymeSets.get (i).get(j)._segs.size(); k++) {
          QT.insertSeg(RhymeSets.get(i).get(j)._segs.get(k), i, j, k, 1000);    
          /*newAmb = false;
           QT.passThroughNode(RhymeSets.get(i).get(j)._segs.get(k).subsegs.get(l));
           if (newAmb) {
           newAmb = false;
           QT.insertSeg(RhymeSets.get(i).get(j)._segs.get(k).subsegs.get(l), i, j, k, l);
           } else{
           QT.insertSeg(RhymeSets.get(i).get(j)._segs.get(k).subsegs.get(l), i, j, k, l);    //insert anyway!
           }*/
        }
      }
    }
    QT.checkForAmbiguities();
  }

  void updateForCustom() {
    //nextPass();
    //QT.getNeighbors();
    //QT.calcM();
    //QT.getmgridNeighbors();
    updatePatterns();
  }


  void calcPatternInts() {
  }

  void renderGraph() {
    pushMatrix();
    //translate(graphx,graphy);
    //renderQT();
    renderNodes();
    translate(0, pScroll);
    renderPatterns();
    //renderNodesWords();
    popMatrix();
  }
  
  void renderGraphPDF(PGraphics pdf) {
    pushMatrix();
    renderNodesPDF(pdf);
    renderPatternsPDF(pdf);
    popMatrix();
  }
  
  void renderNodesPDF(PGraphics pdf) {
    for (int i = 0; i < nodeLocs.size (); i++) {
      nodeLocs.get(i).drawNodePDF(pdf);
    }
  }

  void renderNodes() {
    for (int i = 0; i < nodeLocs.size (); i++) {
      nodeLocs.get(i).drawn = false;
    }
    for (int i = 0; i < nodeLocs.size (); i++) {
      if (nodeLocs.get(i).getY() < 65) {
        continue;
      } else if (nodeLocs.get(i).getY() > height - 50) {
        continue;
      } 
      nodeLocs.get(i).drawNode();
      //nodeLocs.get(i).drawNodeWord();
    }
  }
  
  void renderNodesWords() {
    for (int i = 0; i < nodeLocs.size (); i++) {
      if (nodeLocs.get(i).getY() < 65) {
        continue;
      } else if (nodeLocs.get(i).getY() > height - 50) {
        continue;
      } 
      nodeLocs.get(i).drawNodeWord();
    }
  }

  void updatePatterns() {
    for (int i = 0; i < RhymeSets.size (); i++) {
      for (int j = 0; j < RhymeSets.get (i).size(); j++) {
        RhymeSets.get(i).get(j).getAnchors();
        RhymeSets.get(i).get(j).calcBezier();
        RhymeSets.get(i).get(j).calcSubsegs();
      }
    }
  }

  void addCps() {
    for (int i = 0; i < RhymeSets.size (); i++) {
      for (int j = 0; j < RhymeSets.get (i).size(); j++) {
        RhymeSets.get(i).get(j).addCps();
        //RhymeSets.get(i).get(j).calcBezier();
        //RhymeSets.get(i).get(j).calcSubsegs();
      }
    }
  } 

  void renderPatterns() {
    hoveredPtrs.clear();

    //println("shapes size: "+shapes3.size());
    if (fill_b._selected) {

      //println("shapes: "+shapes3.size());
      for (int i = 0; i < shapes3.size (); i++) {
        shapes3.get(i).drawShape2();
      }
    }

    for (int i = 0; i < RhymeSets.size (); i++) {
      for (int j = 0; j < RhymeSets.get (i).size(); j++) {
        RhymeSets.get(i).get(j).hoverBezier();
      }
    }

    for (int i = 0; i < RhymeSets.size (); i++) {
      for (int j = 0; j < RhymeSets.get (i).size(); j++) {
        RhymeSets.get(i).get(j).drawRerouteBezier();
      }
    }

    for (int i = 0; i < hoveredPtrs.size (); i++) {
      hoveredPtrs.get(i).drawHover();
    }
  }
 
 
 
 void renderPatternsPDF(PGraphics pdf) {
    hoveredPtrs.clear();

    //println("shapes size: "+shapes3.size());
    if (fill_b._selected) {

      //println("shapes: "+shapes3.size());
      for (int i = 0; i < shapes3.size (); i++) {
        shapes3.get(i).drawShape2PDF(pdf);
      }
    }

    /*for (int i = 0; i < RhymeSets.size (); i++) {
      for (int j = 0; j < RhymeSets.get (i).size(); j++) {
        RhymeSets.get(i).get(j).hoverBezier();
      }
    }*/

    for (int i = 0; i < RhymeSets.size (); i++) {
      for (int j = 0; j < RhymeSets.get (i).size(); j++) {
        RhymeSets.get(i).get(j).drawRerouteBezierPDF(pdf);
      }
    }

    /*for (int i = 0; i < hoveredPtrs.size (); i++) {
      hoveredPtrs.get(i).drawHover();
    }*/
  }
  


  void renderQT() {
    QT.drawGridOutline(); 
    //QT.drawQT();
  }
};


class node {
  boolean drawn = false;
  float x = 0;
  float y = 0;
  float sx, sy;
  PVector P;
  //whitespace
  float xw = 0;
  float xn = 0; //mode geoish;
  //int id;
  Word _word;
  String wrd;
  int selNum = 0;
  QuadTree nodeQT = null;
  boolean active = true;    //within filters
  boolean hoverWrd = false;  //for hover word feature
  boolean hoverWrdPrior = false; //tmp variable
  boolean hoverCustomSet = false;  //for choosing custom sets
  boolean hoverUncertainty = false;  //for changing pron of amb. words
  boolean wrdSelected = false;
  ArrayList<pointer> allmembers = new ArrayList<pointer>();
  ArrayList<QuadTree> neighbs = new ArrayList<QuadTree>();
  ArrayList<segment> inc = new ArrayList<segment>();
  ArrayList<segment> lev = new ArrayList<segment>();
  ArrayList<bundle> lbundles = new ArrayList<bundle>();
  ArrayList<bundle> ibundles = new ArrayList<bundle>();



  node(String _wrd, float _x, float _xw, float _xn, float _y, Word word) {
    x = _x;
    xw = _xw; //with whitespace
    xn = _xn;
    y = _y;
    wrd = _wrd;
    _word = word;
    sx = x;
    sy = y;
    P = new PVector(x, y);
  }

  boolean inbounds(float minx, float miny, float maxx, float maxy) {
    if (x >= minx && x <= maxx && y >= miny && y <= maxy) { //will cause duplicates...can't have this. 
      return true;
    } else {
      return false;
    }
  }
  
  void drawNodeWord() {
    if (_word._line == 1) {
      return;
    }
    
    if(wrd.trim().equals("-")){
      return;
    }

    boolean selected = isSelected();
    graphX = tx+maxX+350+2*sep;
    //textAlign(LEFT, CENTER);
    if(showContext_b._selected){
    textAlign(CENTER, CENTER);
    }else{
      textAlign(LEFT, CENTER);
    }
    textSize(10);
    if (active) {
      fill(100);
      //fill(0);
    } else {
      fill(210);
    }
    if ((selected || isHover()) && showWords_b._selected && active && !drawn) {
      drawn = true;
      text(wrd, getX()+xs+3, getY()-g);
    } else if (mouseX >= getX()-5 + graphX && mouseX <= getX()+5 + graphX && mouseY >= getY()-10 + graphY && mouseY <= getY()-5 + graphY && !drawn) {
      drawn = true;
      text(wrd, getX()+xs, getY()-g);
    } 

    if ((selected || isHover()) && showContext_b._selected) {
      //int r = 2;
      if(active){
      for (int i = 1; i <= cr; i++) {
        Word n = _word.getNext(i);
        Word p = _word.getPrev(i);
        if (n != null && n.isWord) {
          if (n._node != null && n._node.wrd != null && !n._node.isSelected() && !n._node.drawn) {
            n._node.drawn = true;
            text(n._node.wrd, n._node.getX()+xs, n._node.getY()-g);
          }
        }
        if (p != null && p.isWord) {
          if (p._node != null && p._node.wrd != null && !p._node.isSelected() && !p._node.drawn) {
            p._node.drawn = true;
            text(p._node.wrd, p._node.getX()+xs, p._node.getY()-g);
          }
        }
      }
      }
    }
  }
  
  
  void drawNodeWordPDF(PGraphics pdf) {
   /* if (_word._line == 1) {
      return;
    }
    
    if(wrd.trim().equals("-")){
      return;
    }*/

    boolean selected = isSelected();
    graphX = tx+maxX+350+2*sep;
    //textAlign(LEFT, CENTER);
    if(showContext_b._selected){
    pdf.textAlign(CENTER, CENTER);
    }else{
      pdf.textAlign(LEFT, CENTER);
    }
    pdf.textSize(10);
    if (active) {
      pdf.fill(100);
      //fill(0);
    } else {
      pdf.fill(100);
    }
    
    if(selected){
    pdf.text(wrd, getX()+xs+3, getYP()-g);
    }
    if ((selected || isHover()) && showWords_b._selected && active && !drawn) {
      drawn = true;
      pdf.text(wrd, getX()+xs+3, getYP()-g);
    } else if (mouseX >= getX()-5 + graphX && mouseX <= getX()+5 + graphX && mouseY >= getY()-10 + graphY && mouseY <= getY()-5 + graphY && !drawn) {
      drawn = true;
      pdf.text(wrd, getX()+xs, getYP()-g);
    } 

    if ((selected || isHover()) && showContext_b._selected) {
      //int r = 2;
      if(active){
      for (int i = 1; i <= cr; i++) {
        Word n = _word.getNext(i);
        Word p = _word.getPrev(i);
        if (n != null && n.isWord) {
          if (n._node != null && n._node.wrd != null && !n._node.isSelected() && !n._node.drawn) {
            n._node.drawn = true;
            pdf.text(n._node.wrd, n._node.getX()+xs, n._node.getYP()-g);
          }
        }
        if (p != null && p.isWord) {
          if (p._node != null && p._node.wrd != null && !p._node.isSelected() && !p._node.drawn) {
            p._node.drawn = true;
            pdf.text(p._node.wrd, p._node.getX()+xs, p._node.getYP()-g);
          }
        }
      }
      }
    }
  }

  void drawNode() {
    if (_word._line == 1) {
      return;
    }
    
    if(wrd.trim().equals("-")){
      return;
    }
    drawNodeWord();
    //if(!drawn && ){
    noStroke(); 
    if (active) {
      fill(150);
    } else {
      fill(210);
    }
    if (nodes_b._selected) {
      ellipse(getX(), getY(), 4, 4);
    }
    //}
  }
  
  void drawNodePDF(PGraphics pdf) {
    drawNodeWordPDF(pdf);
    //if(!drawn && ){
    pdf.noStroke(); 
    if (active) {
      pdf.fill(150);
    } else {
      pdf.fill(150);
    }
    if (nodes_b._selected) {
      //pdf.ellipse(getX(), getY(), 4, 4);
      pdf.ellipse(getX(), getYP(), 4, 4);
    }
    //}
  }

  void drawBullseye() { //not ordering quite yet...
  if (_word._line == 0) {
          textFont(_georgia_14b);
  }else{
    textFont(_pixel_font_8);
  }
    if (y + pScroll >= hfilt.y+5 && y + pScroll <= lfilt.y+5) {
      int count = 0;
      for (int i = 0; i < allmembers.size (); i++) {
        if (allmembers.get(i).selected) {
          noFill();
          //stroke(GREEN,100);
          strokeWeight(1.5);
          if (allmembers.get(i).menuSelected()) {
            stroke(cTable1.findColour(allmembers.get(i).getMenuId()%8));
          } else {
            stroke(cTable1.findColour(setPointers.indexOf(allmembers.get(i))%8));
          }
          ellipse(getSX()+textWidth(_word._displayWord)/2-1, getSY()+8, textWidth(_word._displayWord)+2*count+2, 10+2*count);
          count++;
        }
      }
    }
    textFont(_pixel_font_8);
  }
  
  
  void drawBullseyePDF(PGraphics pdf) { //not ordering quite yet...
  if (_word._line == 0) {
          pdf.textFont(_georgia_14b);
  }else{
    pdf.textFont(_pixel_font_8);
  }
    //if (y + pScroll >= hfilt.y+5 && y + pScroll <= lfilt.y+5) {
      int count = 0;
      for (int i = 0; i < allmembers.size (); i++) {
        if (allmembers.get(i).selected) {
         pdf.noFill();
          //stroke(GREEN,100);
          pdf.strokeWeight(1.5);
          if (allmembers.get(i).menuSelected()) {
            pdf.stroke(cTable1.findColour(allmembers.get(i).getMenuId()%8));
          } else {
            pdf.stroke(cTable1.findColour(setPointers.indexOf(allmembers.get(i))%8));
          }
          pdf.ellipse(getSX()+textWidth(_word._displayWord)/2-1, getSY()+8, textWidth(_word._displayWord)+2*count+2, 10+2*count);
          count++;
        }
      }
    //}
    pdf.textFont(_pixel_font_8);
  }
  

  void getQT() {
    QT.queryQT(new PVector(x, y));
    if (QT2 != null) { 
      nodeQT = QT2;
    } else {
      println("can't find node");
    }
  }

  void getILs() {
    inc.clear();
    lev.clear();
    for (int i = 0; i < allmembers.size (); i++) {
      inc.add(allmembers.get(i).getIncident(P));
      lev.add(allmembers.get(i).getLeaving(P));
    }
  }

  void initbundle() {
    getQT(); 
    getILs();
    neighbs.clear(); 
    neighbs.addAll(nodeQT.neighbors);
  }

  void rebundle() {
    for (int i = 0; i < allmembers.size (); i++) {
      if (allmembers.get(i).bundleCps.containsKey(P)) {
        allmembers.get(i).bundleCps.get(P)[0] = null; //= new HashMap<PVector, PVector[]>(); ;
        allmembers.get(i).bundleCps.get(P)[1] = null;
      }
    }
    //initbundle();
    lbundles.clear();
    ibundles.clear(); 
    ArrayList<pointer> members = new ArrayList<pointer>();
    ArrayList<segment> mSegs = new ArrayList<segment>();
    //bundle incoming
    for (int i = 0; i < neighbs.size (); i++) {
      members.clear();
      mSegs.clear();
      for (int j = 0; j < inc.size (); j++) {
        if (!allmembers.get(j).selected)continue;
        //correct this later...
        if (inc.get(j) == null)continue; 
        if (neighbs.get(i).containsSeg(inc.get(j))) {
          members.add(allmembers.get(j)); //add pointer. 
          mSegs.add(inc.get(j));
        }
      }
      if (members.size() > 1) {
        //println("ahead");
        ibundles.add(new bundle(members, mSegs, neighbs.get(i), this, 0));
      }
      //bundle outgoing
      members.clear();
      mSegs.clear();
      for (int j = 0; j < lev.size (); j++) {
        if (!allmembers.get(j).selected)continue;
        if (lev.get(j) == null)continue;
        if (neighbs.get(i).containsSeg(lev.get(j))) {
          members.add(allmembers.get(j)); //add pointer.  
          mSegs.add(lev.get(j));
        }
      }
      if (members.size() > 1) {
        lbundles.add(new bundle(members, mSegs, neighbs.get(i), this, 1));
      }
    }
    //now loop through bundles to calc point.
    for (int i = 0; i < ibundles.size (); i++) {
      ibundles.get(i).calcControlPoint();
    }
    for (int i = 0; i < lbundles.size (); i++) {
      lbundles.get(i).calcControlPoint();
    }
  }

  void isActive() {
    if (y + pScroll >= hfilt.y+5 && y + pScroll <= lfilt.y-10) {
      active = true;
    }else{
      active = false;
    }
  }
  
  boolean isActive2() {
    if (y + pScroll >= hfilt.y+5 && y + pScroll <= lfilt.y-10) {
      return true;
    }else{
      return false;
    }
  }

  void drawWord() {
    textAlign(LEFT, TOP);
    //textAlign(CENTER, TOP);
    //isActive();
    drawBullseye();
    isHoverWrd();
    if (y + pScroll >= hfilt.y+5 && y + pScroll <= lfilt.y-10) {
      active = true;
      if (hoverWrd || hoverCustomSet || (customSet_b._selected && customSets.get(customSets.size()-1)._wrds.contains(_word))) {
        fill(GREEN);
      } else if (isHover()) {
        //fill(HoverColor);
        //fill(50);
        fill(0, 60);
        textSize(11);
        if (_word._line == 0) {
          textFont(_georgia_14b);
          //fill(0);
        }
        text(_word._displayWord, getSX()+0.5, getSY()+0.7);
        //fill(DRK_BLUE);
        fill(0);
        textFont(_pixel_font_8);
        //textFont(_pixel_font_bold);
      } else {
        if (_word._lts) {
          fill(75, 150);
        } else {
          fill(75);
        }
        textFont(_pixel_font_8);
      }

      if (uncertainty_b._selected && _word._2DSyllables != null && isHover()==false) {
        if (_word._2DSyllables.length > 1) {
          fill(75);
        } else {
          fill(75, 50);
        }
      }
    } else { //deactivated
      active = false;
      fill(210);
    }
    textSize(11);
    if (_word._line == 1) {
      textFont(_gillsans_16i);
      textSize(14);
    } else if (_word._line == 0) {
      textFont(_georgia_14b);
      //fill(0);
    }

    text(_word._displayWord, getSX(), getSY());
    textFont(_pixel_font_8);
  }
  
  void drawWordPDF(PGraphics pdf) {
    pdf.textAlign(LEFT, TOP);
    //textAlign(CENTER, TOP);
    //isActive();
    drawBullseyePDF(pdf);
    isHoverWrd();
    if (y + pScroll >= hfilt.y+5 && y + pScroll <= lfilt.y-10) {
      active = true;
      if (hoverWrd || hoverCustomSet || (customSet_b._selected && customSets.get(customSets.size()-1)._wrds.contains(_word))) {
        pdf.fill(GREEN);
      } else if (isHover()) {
        //fill(HoverColor);
        //fill(50);
        pdf.fill(0, 60);
        pdf.textSize(11);
        if (_word._line == 0) {
          pdf.textFont(_georgia_14b);
          //fill(0);
        }
        pdf.text(_word._displayWord, getSX()+0.5, getSY()+0.7);
        //fill(DRK_BLUE);
        pdf.fill(0);
        pdf.textFont(_pixel_font_8);
        //textFont(_pixel_font_bold);
      } else {
        if (_word._lts) {
          pdf.fill(75, 150);
        } else {
          pdf.fill(75);
        }
        pdf.textFont(_pixel_font_8);
      }

      if (uncertainty_b._selected && _word._2DSyllables != null && isHover()==false) {
        if (_word._2DSyllables.length > 1) {
          pdf.fill(75);
        } else {
          pdf.fill(75, 50);
        }
      }
    } else { //deactivated
      active = false;
      pdf.fill(75);
    }
    pdf.textSize(11);
    if (_word._line == 1) {
      pdf.textFont(_gillsans_16i);
      pdf.textSize(14);
    } else if (_word._line == 0) {
      pdf.textFont(_georgia_14b);
      //fill(0);
    }

    pdf.text(_word._displayWord, getSX(), getSY());
    pdf.textFont(_pixel_font_8);
  }

  boolean isHover() {
    for (int i = 0; i < allmembers.size (); i++) {
      if (allmembers.get(i).hover || allmembers.get(i).mhover || allmembers.get(i).whover ) {
        return true;
      }
    }
    return false;
  }

  boolean isSelected() {
    boolean sel = false;
    selNum = 0;
    for (int i = 0; i < allmembers.size (); i++) {
      if (allmembers.get(i).selected) {
        selNum++;
        sel = true;
      }
    }
    return sel;
  }

  void isHoverWrd() {
    if (lfilt.locked || hfilt.locked) {
      hoverWrd = false;
      hoverCustomSet = false;
      hoverUncertainty = false;
      return;
    }
    float d2 = 350+sep;
    float dy = 0;
    //compare against prior
    hoverWrdPrior = hoverWrd;
    if (hoverWrd_b._selected) {
      if (mouseX >= getSX() + tx+d2 && mouseX <= getSX() + tx+d2 + textWidth(_word._displayWord) && mouseY >= getSY() + ty+dy+pScroll && mouseY <= getSY()+16 + ty+dy+pScroll) {
        hoverWrd = true;
      } else {
        hoverWrd = false;
      }
    } else if (customSet_b._selected) {
      if (mouseX >= getSX() + tx+d2 && mouseX <= getSX() + tx+d2 + textWidth(_word._displayWord) && mouseY >= getSY() + ty+dy+pScroll && mouseY <= getSY()+16 + ty+dy+pScroll) {
        hoverCustomSet = true;
      } else {
        hoverCustomSet = false;
      }
    } else if (uncertainty_b._selected) {
      if (mouseX >= getSX() + tx+d2 && mouseX <= getSX() + tx+d2 + textWidth(_word._displayWord) && mouseY >= getSY() + ty+dy + pScroll && mouseY <= getSY()+16 + ty+dy + pScroll) {
        hoverUncertainty = true;
      } else {
        hoverUncertainty = false;
      }
    }
    //check for change
    if (hoverWrdPrior != hoverWrd) {
      for (int i = 0; i < allmembers.size (); i++) {
        allmembers.get(i).whover = !allmembers.get(i).whover;
      }
    }
  }

  void calcBundleCPs() {
  }

  void clicked() {
    if (hoverWrd) {
      wrdSelected = !wrdSelected;
      if (wrdSelected) {
        for (int i = 0; i < allmembers.size (); i++) {
          allmembers.get(i).addPtr();
          //allmembers.get(i).addRemove();
        }
        /*for (int i = 0; i < allmembers.size (); i++) {
          allmembers.get(i).addRouteCps();
        }*/
      } else if (!wrdSelected) {
        for (int i = 0; i < allmembers.size (); i++) {
          allmembers.get(i).addRemove();
        }
      }
    } else if (hoverCustomSet) {
      if (customSets.get(customSets.size()-1)._wrds.contains(_word)) {
        println("already!");
      } else {
        println("addind "+_word.getDisplayWord());
        customSets.get(customSets.size()-1)._setIds.add(_word.wrdcount);
        customSets.get(customSets.size()-1)._wrds.add(_word);
        customSets.get(customSets.size()-1)._words.add(_word.getDisplayWord()+"("+_word.wrdcount+")");
      }
    }
  }

  void rightClicked() {
    if (hoverWrd) {
    }
  }

  void update() {
    clicked();
  }

  float getX() {
    if (mode == 0) {
      return xw;
    } else if (mode == 1) {
      return x;
    } else if (mode == 2) {
      return xn;
    } else if (mode == 3) {
      return xn;
    } else {
      return x;
    }
  }
  
  float getX2() {
    if (mode == 0) {
      return xw + textWidth(_word._displayWord)/2;
    } else if (mode == 1) {
      return x + textWidth(_word._displayWord)/2;
    } else if (mode == 2) {
      return xn + textWidth(_word._displayWord)/2;
    } else if (mode == 3) {
      return xn + textWidth(_word._displayWord)/2;
    } else {
      return x + textWidth(_word._displayWord)/2;
    }
  }

  float getX(int m) {
    if (m == 0) {
      return xw;
    } else if (m == 1) {
      return x;
    } else if (m == 2) {
      return xn;
    } else if (m == 3) {
      return xn;
    } else {
      return x;
    }
  }

  float getY() {
    return y+pScroll;
  }
  
  float getYP() {
    return y;
  }


  float getSX() {
    if (mode == 0) {
      return xw - textWidth(_word._displayWord)/2;
    } else if (mode == 1) {
      return x - textWidth(_word._displayWord)/2;
    } else {
      return x - textWidth(_word._displayWord)/2;
    }
  }
  
  float getSX2() {
    if (mode == 0) {
      return xw; 
    } else if (mode == 1) {
      return x;
    } else {
      return x;
    }
  }

  float getSY() {
    if (geowish) {
      return sy;
    } else {
    }
    return y;
  }
};

class segment {
  Word w1, w2;
  node n1, n2;
  PVector p1, p2, midPoint;
  PVector posPerp = new PVector(0, 0);
  PVector negPerp = new PVector(0, 0);
  float m, mrecip, mInfinity, b;
  double theta, thetaR, dx, dy, mag, dx2, dy2;
  int setType, setNum, segNum, node;
  ArrayList<cp> _p1Ctrls = new ArrayList<cp>();
  ArrayList<cp> _p2Ctrls = new ArrayList<cp>();
  ArrayList<cp> allcps = new ArrayList<cp>();
  ArrayList<node> rerouted = new ArrayList<node>();
  ArrayList<segment> subsegs = new ArrayList<segment>();
  ArrayList<PVector> ctrlPts = new ArrayList<PVector>();
  ArrayList<cp> cPts = new ArrayList<cp>();
  int subseg = 1000;
  segment subEdge, next, nnext, prev, pprev, parent;
  PVector controlPoint = null;
  PVector testPoint = null;
  PVector a1, a2, aa1, aa2;
  boolean incident = false;
  String dir = "";
  cp curr_cp = null;
  //int s;


  segment(Word _w1, Word _w2) {
    w1 = _w1;
    w2 = _w2;
    p1 = new PVector(w1.x, w1.y);
    p2 = new PVector(w2.x, w2.y);
    n1 = w1._node;
    n2 = w2._node;
  } 

  segment(PVector _p1, PVector _p2, int _setType, int _setNum, int _segNum, int _node) {
    p1 = _p1;
    p2 = _p2;
    setType = _setType;
    setNum = _setNum;
    segNum = _segNum;
    node = _node;
    a1 = a2 = aa1 = aa2 = null;
    incident = (_node == 0) ? false : true;
    calcVars();
    parent = RhymeSets.get(setType).get(setNum)._segs.get(segNum);
    if (comment2) {
      println(this.p1.x+" "+this.p1.y+" , "+parent.p1.x+" "+parent.p1.y);
    }
  }

  segment(PVector _p1, PVector _p2) {
    p1 = _p1;
    p2 = _p2;
    a1 = a2 = aa1 = aa2 = null;
    calcVars();
  }

  boolean inbounds(float minx, float miny, float maxx, float maxy, PVector p) {
    if (p.x >= minx && p.x <= maxx && p.y >= miny && p.y <= maxy) { //will cause duplicates...can't have this. 
      return true;
    } else {
      return false;
    }
  }

  boolean containsNode(node _node) {
    return rerouted.contains(_node);
  }

  void calcPerp() {
    if (Math.abs(theta) == 0.0 || theta == 180.0 ) {
      posPerp.set(midPoint.x + 0, midPoint.y + (float)mag);
      negPerp.set(midPoint.x - 0, midPoint.y - (float)mag);
    } else if (Math.abs(theta) == 90.0) {    //doesn't need to be consistent as long as neg/pos isn't called for other purposes. 
      posPerp.set(midPoint.x + (float)mag, midPoint.y + 0);
      negPerp.set(midPoint.x - (float)mag, midPoint.y - 0);
    } else {
      posPerp.set(midPoint.x + (float)dx, midPoint.y + (float)dy);
      negPerp.set(midPoint.x - (float)dx, midPoint.y - (float)dy);
    }
  }

  void calcSubSeg() {
    subEdge = getSubSeg(midPoint);
    a1 = subEdge.p1;
    a2 = subEdge.p2;
    aa1 = subEdge.p1;
    aa2 = subEdge.p2;

    next = nnext = prev = pprev = null;
    //calc prev and next
    if (segNum > 0) {  //get previous
      prev = RhymeSets.get(setType).get(setNum)._segs.get(segNum-1);
      if (segNum > 1) {
        pprev = RhymeSets.get(setType).get(setNum)._segs.get(segNum-2);
      }
    }
    if (RhymeSets.get(setType).get(setNum)._segs.size() > segNum+1) {
      next = RhymeSets.get(setType).get(setNum)._segs.get(segNum+1);
      if (RhymeSets.get(setType).get(setNum)._segs.size() > segNum+2) {
        nnext = RhymeSets.get(setType).get(setNum)._segs.get(segNum+2);
      }
    }
  }

  PVector incrementPoint(PVector cp, int amt) {
    if (dir.equals("pos")) {
      cp.x += amt*(dx/50.0);
      cp.y += amt*(dy/50.0);
    } else if (dir.equals("neg")) { 
      cp.x -= amt*(dx/50.0);
      cp.y -= amt*(dy/50.0);
    }
    return cp;
  }

  segment getSubSeg(PVector mp) {
    int s = getSegNum();
    if (s == -1) {
      println("Error! seg not found at getSubSeg!");
    }
    if (comment2) {
      if (RhymeSets.get(setType).get(setNum)._segs.get(s) == parent) {
        println("Hooray!");
      }
    }
    //return RhymeSets.get(setType).get(setNum)._segs.get(segNum).getSS(mp);
    return RhymeSets.get(setType).get(setNum)._segs.get(s).getSS(mp);
  }

  segment getSS(PVector cPoint) {
    PVector prev;
    PVector next;

    if (cPts.size() == 0) { 
      return new segment(p1, p2);
    } else { //find neighboring cpts
      cp tmp = new cp(cPoint);
      tmp.p1 = p1;
      tmp.proj = cPoint;
      cPts.add(tmp);
      sortcPts2();
      int ind = cPts.indexOf(tmp);
      if (ind > 0) {
        prev = cPts.get(ind-1).p;
      } else {
        prev = p1;
      }
      if (ind < cPts.size()-1) {
        next = cPts.get(ind+1).p;
      } else {
        next = p2;
      }
      segment seg = new segment(prev, next);
      cPts.remove(tmp);
      return seg;
    }
  }

  void sortcPts2() {
    Collections.sort(cPts, new cpDistComparable());
  }

  void sortcPts() {
    if (theta >= 0) {
      Collections.sort(cPts, new cpxComparable());
    } else {
      Collections.sort(cPts, new cpnegxComparable());
    }
    if (Math.abs(p1.y - p2.y) >= 40) {  
      Collections.sort(cPts, new cpComparable());
    }
  }

  segment scaled() {
    return new segment(p1, new PVector(p1.x+(p2.x-p1.x)/2, p1.y+(p2.y-p1.y)/2));
  }

  void calcVars() {
    m = (p2.y - p1.y)/(p2.x - p1.x);
    mrecip = -1/m;
    b = p1.y - m*p1.x;

    midPoint = new PVector((p1.x + (p2.x - p1.x)/2.0), (p1.y + (p2.y - p1.y)/2.0));
    theta = Math.toDegrees(Math.atan(m));

    if (m == Float.POSITIVE_INFINITY) {
      mInfinity = p2.x;
      b = mInfinity;
      theta = 90.0;
    } else if (m == Float.NEGATIVE_INFINITY) {
      mInfinity = p2.x;
      b = mInfinity;
      theta = -90.0;
    } else {
      theta = Math.toDegrees(Math.atan(m));
      b = p1.y - m*p1.x;
    }

    thetaR = Math.atan(m);
    thetaR += Math.PI/2.0;

    //solve for tan(theta)
    mag = 5;
    dx = mag * Math.cos(thetaR);
    dy = dx * Math.tan(thetaR);

    //double g = sqrt((float)(dx*dx + dy*dy));

    //println(g);

    dx2 = strokeW * Math.cos(thetaR);
    dy2 = dx2 * Math.tan(thetaR);
  }

  int getSegNum() {
    return RhymeSets.get(setType).get(setNum)._segs.indexOf(parent);
  }

  void addcPt(cp ctrlPt, int _dir, PVector _p1, PVector _proj, int sType, int sNum, int s, node _node) {
    rerouted.add(_node);
    cPts.add(ctrlPt);
    cPts.get(cPts.size()-1).dir = _dir;
    cPts.get(cPts.size()-1).p1 = _p1;
    cPts.get(cPts.size()-1).proj = _proj;
    sortcPts();
    if (adapt) {
      //RhymeSets.get(setType).get(setNum).updateSeg(s);
    }
    /*if (adapt) {    //if "adapt"
     //sortSeg();
     sortcPts2();
     getSubSegs();
     for (int i = 0; i < subsegs.size (); i++) {
     QT.insertSeg(subsegs.get(i), sType, sNum, sgNum, i);
     }
     //QT.removeEdges(this, _type, sType, sNum, sgNum);
     }*/
  }

  /*void addcPt2(cp ctrlPt, int _dir, PVector _p1, PVector _proj, int sType, int sNum, int s, node _node) {
   rerouted.add(_node);
   cPts.add(ctrlPt);
   cPts.get(cPts.size()-1).dir = _dir;
   cPts.get(cPts.size()-1).p1 = _p1;
   cPts.get(cPts.size()-1).proj = _proj;
   sortcPts();
   }*/

  void sendControlPt(node _node) {
    int s = getSegNum();
    if (s == -1) {
      println("Error! seg not found at sendControlPt!");
    }
    if (comment2) {
      if (RhymeSets.get(setType).get(setNum)._segs.get(s) == parent) {
        println("Hooray!");
      } else {
        println("problem at send control pts");
      }
    }

    PVector incr = new PVector(0, 0);
    if (dir.equals("pos")) {
      incr.set((float)dx2, (float)dy2);
    }
    if (dir.equals("neg")) {
      incr.set((float)-dx2, (float)-dy2);
    }
    if (curr_cp == null) {
      curr_cp = new cp(controlPoint, incr, theta);
    } else {
      //remove old control point and replace with new. 
      RhymeSets.get(setType).get(setNum)._segs.get(s).cPts.remove(curr_cp);
      curr_cp = new cp(controlPoint, incr, theta);
    }
    RhymeSets.get(setType).get(setNum)._segs.get(s).ctrlPts.add(controlPoint);
    int _dir = (dir.equals("pos")) ? 1 : -1;
    //sorts and creates subseg
    RhymeSets.get(setType).get(setNum)._segs.get(s).addcPt(curr_cp, _dir, RhymeSets.get(setType).get(setNum)._segs.get(s).p1, midPoint, setType, setNum, s, _node);
    //remove Original from QT
    if (adapt) {
      //QT.removeEdges(RhymeSets.get(setType).get(setNum)._segs.get(s), setType, setNum, s);
    }
  }

  /*void getSubSegs(){  //integrating bundling points as well
   subsegs.clear();
   allcps.clear();
   allcps.addAll(_p1Ctrls);
   allcps.addAll(cPts);
   allcps.addAll(_p2Ctrls);
   int t1 = _p1Ctrls.size();
   int t2 = cPts.size();
   int t3 = _p2Ctrls.size();
   
   if (allcps.size() == 0){
   subsegs.add(new segment(p1, p2, 1, null, null, ptr)); 
   //subsegs.get(subsegs.size()-1).cp1_type = subsegs.get(subsegs.size()-1).cp1_type = 2; 
   return;
   }
   subsegs.add(new segment(new Vertex(_p1.x, _p1.y), new Vertex(allcps.get(0).p.x, allcps.get(0).p.y), 1, null, allcps.get(0), ptr));
   //subsegs.get(subsegs.size()-1).cp2 = allcps.get(0);
   for (int i = 1; i < allcps.size (); i++) {
   subsegs.add(new segment(new Vertex(allcps.get(i-1).p.x, allcps.get(i-1).p.y), new Vertex(allcps.get(i).p.x, allcps.get(i).p.y),1,allcps.get(i-1),allcps.get(i),ptr));
   }
   subsegs.add(new segment(new Vertex(allcps.get(allcps.size()-1).p.x, allcps.get(allcps.size()-1).p.y), new Vertex(_p2.x, _p2.y),1,allcps.get(allcps.size()-1),null, ptr));
   //subsegs.get(subsegs.size()-1).cp1 = allcps.get(allcps.size()-1);
   }*/

  void incrementTestPoint() {
    if (Math.abs(theta) == 90.0) {
      dx = mag;
      dy = 0;
    }
    if (dir.equals("pos")) {
      testPoint.x += dx/10.0;
      testPoint.y += dy/10.0;
      if (Line2D.ptSegDist(midPoint.x, midPoint.y, posPerp.x, posPerp.y, testPoint.x, testPoint.y) > 0.001) {
        //println("pos: "+dx+" "+theta);
        //testPoint.x -= 2*dx/10.0;
        //testPoint.y -= 2*dy/10.0;
      }
      //if(Line2D.ptSegDist(midPoint.x, midPoint.y, posPerp.x, posPerp.y, testPoint.x, testPoint.y) > 0.001) println("wrong way!");
    } else if (dir.equals("neg")) { 
      testPoint.x -= dx/10.0;
      testPoint.y -= dy/10.0;
      if (Line2D.ptSegDist(midPoint.x, midPoint.y, negPerp.x, negPerp.y, testPoint.x, testPoint.y) > 0.001) {
        //println("neg: "+dx+" "+theta);
        //testPoint.x += 2*dx/10.0;
        //testPoint.y += 2*dy/10.0;
      }
      //if(Line2D.ptSegDist(midPoint.x, midPoint.y, negPerp.x, negPerp.y, testPoint.x, testPoint.y) > 0.001) println("wrong way!");
    }
  }

  void incrementControlPoint(PVector cp, int amt) {
    if (dir.equals("pos")) {
      cp.x += amt*(dx/10.0);
      cp.y += amt*(dy/10.0);
    } else if (dir.equals("neg")) { 
      cp.x -= amt*(dx/10.0);
      cp.y -= amt*(dy/10.0);
    }
  }

  ////DrawStuff////////

  void drawSeg() {
    line(p1.x, p1.y, p2.x, p2.y);
    drawPerp();
  }

  void drawRerouteSeg() {
    strokeWeight(1);
    beginShape();
    vertex(p1.x, p1.y);
    for (int i = 0; i < cPts.size (); i++) {
      vertex(cPts.get(i).p.x, cPts.get(i).p.y);
    }
    vertex(p2.x, p2.y);
    endShape();
  }

  void drawRerouteSegC() {
    strokeWeight(1);
    curveVertex(p1.x, p1.y);
    for (int i = 0; i < cPts.size (); i++) {
      curveVertex(cPts.get(i).p.x, cPts.get(i).p.y);
    }
  }

  void drawRerouteSegB() {
    strokeWeight(1);
    //have to calculate control points...
    //bezierVertex(p1.x, p1.y);
    for (int i = 0; i < cPts.size (); i++) {
      //bezierVertex(cPts.get(i).p.x, cPts.get(i).p.y);
    }
  } 

  void drawPerp() {
    if (dir.equals("pos")) {
      line(midPoint.x, midPoint.y, posPerp.x, posPerp.y);
    } else if (dir.equals("neg")) {
      line(midPoint.x, midPoint.y, negPerp.x, negPerp.y);
    }
    if (controlPoint != null) {
      ellipse(controlPoint.x, controlPoint.y, 2, 2);
      ellipse(testPoint.x, testPoint.y, 2, 2);
      line(controlPoint.x, controlPoint.y, a1.x, a1.y);
      line(controlPoint.x, controlPoint.y, a2.x, a2.y);
    }
  }
};

public class cpComparable implements Comparator<cp> {
  @Override
    public int compare(cp a, cp b) {
    return (a.p.y<b.p.y ? -1 : (a.p.y==b.p.y ? 0 : 1));    //since it's on a line, only y matters...NOT TRUE
    //return ((b.y-a.y < 20) ? -1 : (a.y==b.y ? 0 : 1)); doesn't work
  }
}

public class cpDistComparable implements Comparator<cp> {
  @Override
    public int compare(cp a, cp b) {
    return (a.distance()<b.distance() ? -1 : (a.distance()==b.distance() ? 0 : 1));    //since it's on a line, only y matters...NOT TRUE
    //return ((b.y-a.y < 20) ? -1 : (a.y==b.y ? 0 : 1)); doesn't work
  }
}

public class pvectorxComparable implements Comparator<PVector> {
  @Override
    public int compare(PVector a, PVector b) {
    return (a.x<b.x ? -1 : (a.x==b.x ? 0 : 1));    //since it's on a line, only y matters...NOT TRUE
    //return ((b.y-a.y < 20) ? -1 : (a.y==b.y ? 0 : 1)); doesn't work
  }
}

public class pvectornegxComparable implements Comparator<PVector> {
  @Override
    public int compare(PVector a, PVector b) {
    return (a.x>b.x ? -1 : (a.x==b.x ? 0 : 1));    //since it's on a line, only y matters...NOT TRUE
    //return ((b.y-a.y < 20) ? -1 : (a.y==b.y ? 0 : 1)); doesn't work
  }
}

public class cpxComparable implements Comparator<cp> {
  @Override
    public int compare(cp a, cp b) {
    return (a.p.x<b.p.x ? -1 : (a.p.x==b.p.x ? 0 : 1));    //since it's on a line, only y matters...NOT TRUE
    //return ((b.y-a.y < 20) ? -1 : (a.y==b.y ? 0 : 1)); doesn't work
  }
}

public class cpnegxComparable implements Comparator<cp> {
  @Override
    public int compare(cp a, cp b) {
    return (a.p.x>b.p.x ? -1 : (a.p.x==b.p.x ? 0 : 1));    //since it's on a line, only y matters...NOT TRUE
    //return ((b.y-a.y < 20) ? -1 : (a.y==b.y ? 0 : 1)); doesn't work
  }
}

class cp {
  PVector p, incr, p1; 
  float memNum, memSize;
  double deg, theta;
  double dist2p, dist2otherp;
  int dir;    //keep track for side by side
  PVector proj;

  cp(PVector _p) {
    p = _p;
    p1 = _p;
  }

  cp(PVector _p, PVector _incr, double _theta) {
    p = _p;
    incr = _incr;
    deg = Math.toDegrees(Math.atan(incr.x/incr.y));
    if (incr.x >= 0 && incr.y <= 0) {
      deg += 180;
    } else if (incr.x < 0 && incr.y < 0) {
      deg += 180;
    } else if (incr.x <= 0 && incr.y >= 0) {
      deg += 360;
    }
    theta = _theta;
    if (theta < -0.0) {
      theta += 360;
    }
  }

  double distance() {
    //return Math.sqrt(Math.pow(p.x-p1.x, 2) + Math.pow(p.y - p1.y, 2));
    return Math.sqrt(Math.pow(proj.x-p1.x, 2) + Math.pow(proj.y - p1.y, 2));
  }

  void hack() {
    deg = Math.toDegrees(Math.atan(incr.x/incr.y));
    if (incr.x <= 0 && incr.y >= 0) {
      deg += 180;
    } else if (incr.x > 0 && incr.y >= 0) {
      deg += 180;
    } else if (incr.x > 0 && incr.y < 0) {
      deg += 360;
    }
  }
};

class pointer {
  int sType;
  int sNum;
  int orderNum;
  boolean hover = false;
  boolean mhover = false;
  boolean whover = false;
  boolean selected = false;
  String rhymeId;
  int menuId;
  ArrayList<Integer> nodeLs = new ArrayList<Integer>();

  Map<PVector, PVector[]> bundleCps = new HashMap<PVector, PVector[]>();

  pointer(int s1, int s2, String rId) {
    sType = s1;
    sNum = s2; 
    orderNum = ptrCounter;
    rhymeId = rId;
    ptrCounter++;
  }

  void getbs() {
    //println("rr: "+RhymeSets.get(sType).get(sNum).ptr.bundleCps.size());
    //RhymeSets.get(sType).get(sNum).drawRerouteBezier();
  }

  int getMenuId() {
    return RhymeSets.get(sType).get(sNum).menu.id;
  }
  
  boolean out(){
    return RhymeSets.get(sType).get(sNum).menu.out;
  }

  void transferPointer() {
    for (int i = 0; i < RhymeSets.get (sType).size(); i++) {
      if (RhymeSets.get(sType).get(i)._rhymeId.equals(rhymeId)) {
        RhymeSets.get(sType).get(i).addPtr();
      }
    }
  }

  void removePtr() {
    RhymeSets.get(sType).get(sNum).removePtr();
  }
  
  void addPtr() {
    RhymeSets.get(sType).get(sNum).addPtr();
  }

  void updateBs() {
    RhymeSets.get(sType).get(sNum).addCps();
  }

  void addRemove() {
    RhymeSets.get(sType).get(sNum).addRemovePtr(1);
  }

  void addRouteCps() {
    RhymeSets.get(sType).get(sNum).addRouteCps();
  }

  void drawPattern() {
    RhymeSets.get(sType).get(sNum).drawRerouteBezier();
  }

  void drawHover() {
    RhymeSets.get(sType).get(sNum).drawHoverBezier();
  }

  void recalcAnchors() {
    RhymeSets.get(sType).get(sNum).recalcAnchors();
  }

  void drawHalfBezier(PVector p1, PVector p2, int w) {
    if (w ==1) {
      RhymeSets.get(sType).get(sNum).bz.drawHalfBezier(p1, p2);
    } else if (w ==2) {
      RhymeSets.get(sType).get(sNum).bz.drawHalfBezierA(p1, p2);
    } else if (w == 3) {
      RhymeSets.get(sType).get(sNum).bz.drawHalfBezierB(p1, p2);
    }
  }

  ArrayList<pBezierVertex> getBvs(int m, PVector p1, PVector p2) {
    if (m == 0) {
      return RhymeSets.get(sType).get(sNum).bz0.getBvs(p1, p2);
    } else if (m == 1) {
      return RhymeSets.get(sType).get(sNum).bz1.getBvs(p1, p2);
    } else if (m == 2) {
      return RhymeSets.get(sType).get(sNum).bz2.getBvs(p1, p2);
    } else {
      return RhymeSets.get(sType).get(sNum).bz0.getBvs(p1, p2);
    }
  }

  PVector[] getFL(int m) {
    if (m == 0) {
      return RhymeSets.get(sType).get(sNum).bz0.getFirstLast();
    } else if (m == 1) {
      return RhymeSets.get(sType).get(sNum).bz1.getFirstLast();
    } else if (m == 2) {
      return RhymeSets.get(sType).get(sNum).bz2.getFirstLast();
    } else {
      return RhymeSets.get(sType).get(sNum).bz0.getFirstLast();
    }
  }

  PVector diff_i(PVector p) {
    int i = RhymeSets.get(sType).get(sNum).bz.anchors_og.indexOf(p);
    if (i != -1) {
      return  RhymeSets.get(sType).get(sNum).bz.diff_anchors.get(i);
    }
    return new PVector(0, 0);
  }

  segment getIncident(PVector p) {
    return RhymeSets.get(sType).get(sNum).getILSeg(p, 0);
  }

  segment getLeaving(PVector p) {
    return RhymeSets.get(sType).get(sNum).getILSeg(p, 1);
  }

  boolean menuSelected() {
    return RhymeSets.get(sType).get(sNum).menu.selected;
  }
};

public class ptrComparable implements Comparator<pointer> {
  @Override
    public int compare(pointer a, pointer b) {  
    return (a.orderNum<b.orderNum ? -1 : (a.orderNum==b.orderNum ? 0 : 1));
  }
}

class pShape {
  ArrayList< ArrayList<PVector> > vertices = new ArrayList< ArrayList<PVector> >(); //leave option for multiple shapes.
  ArrayList<PVector> sharedPoints;
  pointer _p1;
  pointer _p2;

  pShape(pointer ptr1, pointer ptr2, ArrayList<PVector> points) {
    _p1 = ptr1;
    _p2 = ptr2;
    sharedPoints = points;
    //calcShapes();
  }

  /*void calcShapes() {
   //move down one side
   int pt = 0;
   boolean on = false;
   for (int i = 0; i < RhymeSets.get (_p1.sType).get(_p1.sNum)._anchors.size(); i++) {
   if(on){
   vertices.get(vertices.size()-1).add(RhymeSets.get (_p1.sType).get(_p1.sNum)._anchors.get(i));
   }else if(RhymeSets.get (_p1.sType).get(_p1.sNum)._anchors.get(i).equals(sharedPoints.get(pt)){
   if(!on){
   on = true;
   vertices.add(new ArrayList<PVector>());
   vertices.get(vertices.size()-1).add(RhymeSets.get (_p1.sType).get(_p1.sNum)._anchors.get(i));
   }else{
   
   
   } 
   pt++; 
   }
   }
   //move up the other side
   }*/

  void drawpShape() {
    //fill(cTable1.findColour(shapes.indexOf(this)), 50);
    fill(GREEN, 50);
    beginShape();
    vertex(sharedPoints.get(0).x, sharedPoints.get(0).y);
    RhymeSets.get (_p1.sType).get(_p1.sNum).bz.drawPartialBezier(0, sharedPoints.get(0), sharedPoints.get(sharedPoints.size()-1));
    RhymeSets.get (_p2.sType).get(_p2.sNum).bz.drawPartialBezier(1, sharedPoints.get(0), sharedPoints.get(sharedPoints.size()-1));
    //vertex(sharedPoints.get(sharedPoints.size()-1).x, sharedPoints.get(sharedPoints.size()-1).y);
    endShape(CLOSE);
  }
};

class pShape3 {
  ArrayList< ArrayList<PVector> > p1Shapes = new ArrayList< ArrayList<PVector> >(); //leave option for multiple shapes.
  ArrayList< ArrayList<PVector> > p2Shapes = new ArrayList< ArrayList<PVector> >();
  ArrayList<PVector> sharedPoints;
  PVector sharedPoint;
  ArrayList<Integer> i_s;
  ArrayList<Integer> j_s;
  pointer _p1;
  pointer _p2;
  PVector center;
  int _type = 0; //0 for fill, 1 for gradient up, 2 for gradient down.
  ArrayList<pBezierVertex> pbvs = new ArrayList<pBezierVertex>();
  ArrayList<pBezierVertex> pbvs1 = new ArrayList<pBezierVertex>();
  ArrayList<pBezierVertex> pbvs2 = new ArrayList<pBezierVertex>();
  PVector[] FL;
  int Y_AXIS = 1;
  int X_AXIS = 2;
  int b1, b2;
  PImage gradient;
  PGraphics gc;
  float f = 0;
  float l = 0;
  int ff = 0;

  pShape3(pointer ptr1, pointer ptr2, ArrayList<PVector> points, ArrayList<Integer> is, ArrayList<Integer> js, int type) {
    _p1 = ptr1;
    _p2 = ptr2;
    sharedPoints = points;
    i_s = is;
    j_s = js;
    _type = type;
    if (_type == 0) {
      calcShapes();
    } else if (_type == 1 || _type == 2) {
      calcShapes2();
    }
  }

  //for gradient fill
  /*pShape3(pointer ptr1, pointer ptr2, ArrayList<PVector> points, ArrayList<Integer> is, ArrayList<Integer> js, int type) {
   _p1 = ptr1;
   _p2 = ptr2;
   sharedPoints = points;
   i_s = is;
   j_s = js;
   _type = type;
   calcShapes2();
   }*/

  void calcShapes2() {
    //pbvs.addAll(_p1.getBvs(p1Shapes.get(0).get(0), p1Shapes.get(0).get(1))); 
    /*if(_type == 1){
     pbvs.addAll(_p1.getBvs(sharedPoints.get(0), sharedPoints.get(1)));
     pbvs.addAll(_p2.getBvs(sharedPoints.get(2), sharedPoints.get(0)));
     println("pbvs: "+pbvs.size());
     }else if(_type == 2){
     pbvs.addAll(_p1.getBvs(sharedPoints.get(0), sharedPoints.get(1)));
     pbvs.addAll(_p2.getBvs(sharedPoints.get(2), sharedPoints.get(0)));
     println("pbvs: "+pbvs.size());
     }*/
     
     
     PVector p3 = new PVector((sharedPoints.get(1).x + sharedPoints.get(2).x)/2.0, (sharedPoints.get(1).y + sharedPoints.get(2).y)/2.0);
      float tx = (sharedPoints.get(0).x-p3.x)/sqrt(sq((sharedPoints.get(0).x-p3.x))+sq((sharedPoints.get(0).y-p3.y)));
      float ty = (sharedPoints.get(0).y-p3.y)/sqrt(sq((sharedPoints.get(0).x-p3.x))+sq((sharedPoints.get(0).y-p3.y)));
      float a = atan2(ty, tx);
      a += HALF_PI;

    center = new PVector(sharedPoints.get(1).x, sharedPoints.get(1).y);
    center.add(sharedPoints.get(2));
    center.div(2);

    float f = sqrt((sq(sharedPoints.get(0).x-center.x) + sq(sharedPoints.get(0).y-center.y)));
    center.mult(25/f);
    
    PVector ntb = new PVector(sharedPoints.get(0).x-tx*20,sharedPoints.get(0).y-ty*20);

    pbvs.addAll(_p1.getBvs(0, sharedPoints.get(0), sharedPoints.get(1)));
    pbvs.addAll(_p1.getBvs(0, sharedPoints.get(1), sharedPoints.get(0)));
    if(pbvs.size()>0)pbvs.remove(pbvs.size()-1);
    //pbvs.add(new pBezierVertex(ntb,ntb,ntb));
    pbvs1.clear();
    pbvs1.addAll(_p2.getBvs(0, sharedPoints.get(0), sharedPoints.get(2)));
    if(pbvs1.size()>0) pbvs1.remove(0);
    
    /*if(pbvs1.size()>0 && pbvs.size()>0){
      PVector p4 = new PVector((pbvs.get(pbvs.size()-1)._p.x + pbvs1.get(0)._p.x)/2.0, (pbvs.get(pbvs.size()-1)._p.y + pbvs1.get(0)._p.y)/2.0);
      float tx2 = (sharedPoints.get(0).x-p4.x)/sqrt(sq((sharedPoints.get(0).x-p4.x))+sq((sharedPoints.get(0).y-p4.y)));
      float ty2 = (sharedPoints.get(0).y-p4.y)/sqrt(sq((sharedPoints.get(0).x-p4.x))+sq((sharedPoints.get(0).y-p4.y)));
      float a2 = atan2(ty2, tx2);
      a2 += HALF_PI;
      PVector ntb2 = new PVector(sharedPoints.get(0).x-tx2*20,sharedPoints.get(0).y-ty2*20);
      PVector nc_1 = new PVector(sharedPoints.get(0).x-tx2*20 - cos(a2)*10,sharedPoints.get(0).y-ty2*20-sin(a2)*10);
      PVector nc_2 = new PVector(sharedPoints.get(0).x-tx2*20 + cos(a2)*10,sharedPoints.get(0).y-ty2*20+sin(a2)*10);
      pbvs.add(new pBezierVertex(nc_1,nc_2,ntb2));
    }else{
     println("nope"); 
    }*/

    //pbvs.add(new pBezierVertex(ntb,ntb,ntb));
    
    pbvs.addAll(pbvs1);
    pbvs1.clear();
    pbvs.addAll(_p2.getBvs(0, sharedPoints.get(2), sharedPoints.get(0)));
    
    
    
    
    
    //pbvs.add(new pBezierVertex(ntb,ntb,ntb));
    
    //pbvs.addAll(_p1.getBvs(0, sharedPoints.get(0), sharedPoints.get(1)));
    //pbvs.addAll(_p2.getBvs(0, sharedPoints.get(2), sharedPoints.get(0)));
    //println("pbvs: "+pbvs.size());
    //println("shapes: "+shapes3.size());
     /*pg = createGraphics(width, height);
      pg.beginDraw();
      //pg.background();
      pg.fill(cTable1.findColour(setPointers.indexOf(_p1)%8));
      pg.noStroke();
      pg.beginShape(POLYGON);
      pg.vertex(sharedPoints.get(0).x, sharedPoints.get(0).y);
        for (int j = 0; j < pbvs.size (); j++) {
          pbvs.get(j).addBV(pg);
        }
      for (int j = 0; j < sharedPoints.size (); j++) {
        pg.vertex(sharedPoints.get(j).x, sharedPoints.get(j).y);
        //ellipse(sharedPoints.get(j).x, sharedPoints.get(j).y, 5, 5);
      }
      pg.endShape();
      pg.endDraw();
      gradient = pg.get();
      
      //PGraphics gc;
      PImage mask;
      gc = createGraphics(width, height);
      gc.beginDraw();
      gc.strokeWeight(1);
      gc.noFill();
      for(int i = 50; i < 100; i++){
       float inter = map(i, 50,100,0,200); 
       color c = lerpColor(0, 255, inter);
       
       //gc.stroke(cTable1.findColour(setPointers.indexOf(_p1)%8), inter);
       gc.stroke(inter); 
       if(_type == 1){
       //gc.arc(sharedPoints.get(0).x-tx*100,sharedPoints.get(0).y-ty*100,2.5*i,2.5*i,0,PI);
       }else if(_type == 2){
         gc.arc(sharedPoints.get(0).x-tx*100,sharedPoints.get(0).y-ty*100,2.5*i,2.5*i,PI,2*PI);
       }
       //gc.line(sharedPoints.get(0).x+i*tx - cos(a)*30, sharedPoints.get(0).y+i*ty-sin(a)*30, cos(a)*30 + sharedPoints.get(0).x+i*tx, sin(a)*30 + sharedPoints.get(0).y+i*ty);
       //gc.line(sharedPoints.get(0).x+i*tx - cos(a)*30, sharedPoints.get(0).y+i*ty-sin(a)*30, cos(a)*30 + sharedPoints.get(0).x+i*tx, sin(a)*30 + sharedPoints.get(0).y+i*ty);
      }
      gc.endDraw();
      mask = gc.get();
      //tst.mask(mask);
      //test.mask(gc);
      //gradient.mask(mask); */
  }
  
  void calcShapes3() {
     PVector p3 = new PVector((sharedPoints.get(1).x + sharedPoints.get(2).x)/2.0, (sharedPoints.get(1).y + sharedPoints.get(2).y)/2.0);
     float tx = (sharedPoints.get(0).x-p3.x)/sqrt(sq((sharedPoints.get(0).x-p3.x))+sq((sharedPoints.get(0).y-p3.y)));
     float ty = (sharedPoints.get(0).y-p3.y)/sqrt(sq((sharedPoints.get(0).x-p3.x))+sq((sharedPoints.get(0).y-p3.y)));
     float a = atan2(ty, tx);
     a += HALF_PI;

    center = new PVector(sharedPoints.get(1).x, sharedPoints.get(1).y);
    center.add(sharedPoints.get(2));
    center.div(2);

    float f = sqrt((sq(sharedPoints.get(0).x-center.x) + sq(sharedPoints.get(0).y-center.y)));
    center.mult(25/f);
    
    PVector ntb = new PVector(sharedPoints.get(0).x-tx*20,sharedPoints.get(0).y-ty*20);

    pbvs.addAll(_p1.getBvs(0, sharedPoints.get(0), sharedPoints.get(1)));
    pbvs.addAll(_p1.getBvs(0, sharedPoints.get(1), sharedPoints.get(0)));
    if(pbvs.size()>0)pbvs.remove(pbvs.size()-1);
    //pbvs.add(new pBezierVertex(ntb,ntb,ntb));
    pbvs1.clear();
    pbvs1.addAll(_p2.getBvs(0, sharedPoints.get(0), sharedPoints.get(2)));
    if(pbvs1.size()>0) pbvs1.remove(0);
    pbvs.addAll(pbvs1);
    pbvs1.clear();
    pbvs.addAll(_p2.getBvs(0, sharedPoints.get(2), sharedPoints.get(0)));
  }

  void calcShapes() {
    if (sharedPoints.size() < 2)return;
    //for (int i = 0; i < sharedPoints.size ()-1; i++) {
    //looking for non-consecutive shared points
    /*if (i_s.get(i+1) > i_s.get(i)+1) { //bingo!
     p1Shapes.add(new ArrayList<PVector>());
     p1Shapes.get(p1Shapes.size()-1).add(sharedPoints.get(i));
     p1Shapes.get(p1Shapes.size()-1).add(sharedPoints.get(i+1));
     }
     //same for p2shapes
     if (j_s.get(i+1) > j_s.get(i)+1) { //bingo!
     p2Shapes.add(new ArrayList<PVector>());
     p2Shapes.get(p2Shapes.size()-1).add(sharedPoints.get(i));
     p2Shapes.get(p2Shapes.size()-1).add(sharedPoints.get(i+1));
     }*/
    p1Shapes.add(new ArrayList<PVector>());
    p1Shapes.get(p1Shapes.size()-1).add(sharedPoints.get(0));
    p1Shapes.get(p1Shapes.size()-1).add(sharedPoints.get(sharedPoints.size()-1));

    p2Shapes.add(new ArrayList<PVector>());
    p2Shapes.get(p2Shapes.size()-1).add(sharedPoints.get(0));
    p2Shapes.get(p2Shapes.size()-1).add(sharedPoints.get(sharedPoints.size()-1));

    //}

    if (p1Shapes.size()>0 && p2Shapes.size()>0) {
      pbvs.addAll(_p1.getBvs(0, p1Shapes.get(0).get(0), p1Shapes.get(0).get(1)));
      pbvs.addAll(_p2.getBvs(0, p2Shapes.get(0).get(1), p2Shapes.get(0).get(0)));

      b1 = pNodes.indexOf(p1Shapes.get(0).get(0));
      b2 = pNodes.indexOf(p1Shapes.get(0).get(1));

      pbvs1.addAll(_p1.getBvs(1, pNodes1.get(b1), pNodes1.get(b2)));
      pbvs1.addAll(_p2.getBvs(1, pNodes1.get(b2), pNodes1.get(b1)));

      pbvs2.addAll(_p1.getBvs(2, pNodes2.get(b1), pNodes2.get(b2)));
      pbvs2.addAll(_p2.getBvs(2, pNodes2.get(b2), pNodes2.get(b1)));
    }
  }

  void drawShape() {
    //println("p1shapes size: "+p1Shapes.size() + " sharedPoints: "+sharedPoints.size());
    //p1 halves
    for (int i = 0; i < p1Shapes.size (); i++) {
      if (p1Shapes.get(i).size() < 2)continue;
      _p1.drawHalfBezier(p1Shapes.get(i).get(0), p1Shapes.get(i).get(1), 1);
    }
    //p2 halves
    for (int i = 0; i < p2Shapes.size (); i++) {
      if (p2Shapes.get(i).size() < 2)continue;
      _p2.drawHalfBezier(p2Shapes.get(i).get(0), p2Shapes.get(i).get(1), 1);
    }
  }

  void drawSShape() {
    if (_type == 2 || _type == 1) {
      //println("Drawing");
      //fill(cTable1.findColour(setPointers.indexOf(_p1)%8), 50);
      //stroke(cTable1.findColour(setPointers.indexOf(_p1)%8), 50);
     
      //image(pg, 0, 0);
      
      /*fill(BLUE);
      beginShape();
      for (int j = 0; j < sharedPoints.size (); j++) {
        vertex(sharedPoints.get(j).x, sharedPoints.get(j).y);
        //ellipse(sharedPoints.get(j).x, sharedPoints.get(j).y, 5, 5);
      }
      endShape();*/
      
      PVector p3 = new PVector((sharedPoints.get(1).x + sharedPoints.get(2).x)/2.0, (sharedPoints.get(1).y + sharedPoints.get(2).y)/2.0);
      
      color c1 = color(219,255);
      color c2 = color(219,0);
      
      //line(sharedPoints.get(0).x, sharedPoints.get(0).y, p3.x, p3.y);
      float tx = (sharedPoints.get(0).x-p3.x)/sqrt(sq((sharedPoints.get(0).x-p3.x))+sq((sharedPoints.get(0).y-p3.y)));
      float ty = (sharedPoints.get(0).y-p3.y)/sqrt(sq((sharedPoints.get(0).x-p3.x))+sq((sharedPoints.get(0).y-p3.y)));
      //tx = tx/sqrt(sq(tx)+sq(ty));
      //ty = ty/sqrt(sq(tx)+sq(ty));
      //println(sqrt(sq(tx)+sq(ty)));
      float a = atan2(ty, tx);
      a += HALF_PI;
      
      //image(gradient,0,0);
      //image(gc,0,0);
      
      //vertex(sharedPoints.get(0).x,sharedPoints.get(0).y);
      /*pbvs.get(0).addBV();
       vertex(sharedPoints.get(1).x,sharedPoints.get(1).y);
       vertex(sharedPoints.get(2).x,sharedPoints.get(2).y);
       pbvs.get(1).addBV();
       vertex(sharedPoints.get(0).x,sharedPoints.get(0).y);*/
      /*for(int j = 0; j < pbvs.size(); j++){
       pbvs.get(j).addBV();
       }*/
      //vertex(sharedPoints.get(0).x,sharedPoints.get(0).y);
      //vertex(p1Shapes.get(i).get(0).x, p1Shapes.get(i).get(0).y);
      //_p1.drawHalfBezier(p1Shapes.get(i).get(0), p1Shapes.get(i).get(1), 4);
      //vertex(p1Shapes.get(i).get(0).x, p1Shapes.get(i).get(0).y);
      //_p2.drawHalfBezier(p1Shapes.get(i).get(1), p1Shapes.get(i).get(0), 4);
      //endShape();
      //noFill();
    }
    if (_type == 3) {
      fill(cTable1.findColour(setPointers.indexOf(_p1)%8), 50);
      noStroke();
      beginShape();
      /*vertex(sharedPoints.get(0).x,sharedPoints.get(0).y);
       for(int j = 0; j < pbvs.size(); j++){
       pbvs.get(j).addBV();
       }
       vertex(sharedPoints.get(0).x,sharedPoints.get(0).y);*/
      for (int j = 0; j < sharedPoints.size (); j++) {
        vertex(sharedPoints.get(j).x, sharedPoints.get(j).y);
        ellipse(sharedPoints.get(j).x, sharedPoints.get(j).y, 5, 5);
      }
      //vertex(p1Shapes.get(i).get(0).x, p1Shapes.get(i).get(0).y);
      //_p1.drawHalfBezier(p1Shapes.get(i).get(0), p1Shapes.get(i).get(1), 4);
      //vertex(p1Shapes.get(i).get(0).x, p1Shapes.get(i).get(0).y);
      //_p2.drawHalfBezier(p1Shapes.get(i).get(1), p1Shapes.get(i).get(0), 4);
      endShape();
      noFill();
    }
    //stroke(0);
    //line(sharedPoints.get(0).x,sharedPoints.get(0).y, center.x, center.y);
  }
  
  void drawSSShape(){        
        //fill(200, 50);
        fill(cTable1.findColour(setPointers.indexOf(_p1)%8), 50);
        noStroke();
        beginShape();
        vertex(sharedPoints.get(0).x, sharedPoints.get(0).y);
        //vertex(f.x, f.y);
        for (int j = 0; j < pbvs.size (); j++) {
          pbvs.get(j).addBV();
        }
        endShape();
        noFill();
  }
  
  void calcFirstLast(){
    l = 0; 
    f = 0;
    for(int i = 0; i < sharedPoints.size();i++){
     if(sharedPoints.get(i).y >= hfilt.y && f == 0){
      f = sharedPoints.get(i).y;
      ff = i;
     }
     if(sharedPoints.get(i).y <= lfilt.y){
      l = sharedPoints.get(i).y; 
     } 
    }
  }

  void drawShape2() {
    if(_p1.out() || _p2.out()){
     return; 
    }
    if (_type == 1 || _type == 2) {
      drawSSShape();
      return;
    }
    calcFirstLast();
    if (mode == 0) {
      for (int i = 0; i < p1Shapes.size (); i++) {
        if (p1Shapes.get(i).size() < 2)continue;
        //if (pbvs.get(0)._p.y < hfilt.y+5)continue;
        //if (sharedPoints.get(sharedPoints.size()-1).y > lfilt.y-5)continue;
        //println(pbvs.get(0)._p.y+" "+pbvs.get(pbvs.size()-1)._p.y+" "+lfilt.y);
        //fill(200, 50);
        boolean st = true;
        fill(cTable1.findColour(setPointers.indexOf(_p1)%8), 50);
        noStroke();
        beginShape();
        //vertex(p1Shapes.get(i).get(0).x, p1Shapes.get(i).get(0).y);
        //vertex(sharedPoints.get(ff).x,sharedPoints.get(ff).y);
        //vertex(f.x, f.y);
        for (int j = 0; j < pbvs.size (); j++) {
          if(st && pbvs.get(j)._p.y >= f){
            vertex(pbvs.get(j)._p.x,pbvs.get(j)._p.y);
            st = false;
          }
          pbvs.get(j).addBV(l,f);
        }
        endShape();
        noFill();
      }
    } else if (mode == 1) {
      if (b1 != -1 && b2 != -1) {
        //if (pbvs1.get(0)._p.y < hfilt.y+5)return;
        //if (pbvs1.get(pbvs1.size()-1)._p.y > lfilt.y-5)return;
        boolean st = true;
        fill(cTable1.findColour(setPointers.indexOf(_p1)%8), 50);
        noStroke();
        beginShape();
        //vertex(pNodes1.get(b1).x, pNodes1.get(b1).y);
        for (int j = 0; j < pbvs1.size (); j++) {
          if(st && pbvs1.get(j)._p.y >= f){
            vertex(pbvs1.get(j)._p.x,pbvs1.get(j)._p.y);
            st = false;
          }
          
          
          pbvs1.get(j).addBV(l,f);
        }
        endShape();
        noFill();
      }
    } else if (mode == 2) {
      if (b1 != -1 && b2 != -1) {
        //if (pbvs2.get(0)._p.y < hfilt.y+5)return;
        //if (pbvs2.get(pbvs2.size()-1)._p.y > lfilt.y-5)return;
        boolean st = true;
        fill(cTable1.findColour(setPointers.indexOf(_p1)%8), 50);
        noStroke();
        beginShape();
        //vertex(pNodes2.get(b1).x, pNodes2.get(b1).y);
        for (int j = 0; j < pbvs2.size (); j++) {
          if(st && pbvs2.get(j)._p.y >= f){
            vertex(pbvs2.get(j)._p.x,pbvs2.get(j)._p.y);
            st = false;
          }
          pbvs2.get(j).addBV(l,f);
        }
        endShape();
        noFill();
      }
    }
  }
  
  
  void drawShape2PDF(PGraphics pdf) {
    if(_p1.out() || _p2.out()){
     return; 
    }
    if (_type == 1 || _type == 2) {
      drawSSShape();
      return;
    }
    calcFirstLast();
    if (mode == 0) {
      for (int i = 0; i < p1Shapes.size (); i++) {
        if (p1Shapes.get(i).size() < 2)continue;
        boolean st = true;
        pdf.fill(cTable1.findColour(setPointers.indexOf(_p1)%8), 50);
        pdf.noStroke();
        pdf.beginShape();
        for (int j = 0; j < pbvs.size (); j++) {
          if(st){
            pdf.vertex(pbvs.get(j)._p.x,pbvs.get(j)._p.y);
            st = false;
          }
          pbvs.get(j).addBV_PDF(l,f,pdf);
        }
        pdf.endShape();
        pdf.noFill();
      }
    } else if (mode == 1) {
      if (b1 != -1 && b2 != -1) {
        boolean st = true;
        pdf.fill(cTable1.findColour(setPointers.indexOf(_p1)%8), 50);
        pdf.noStroke();
        pdf.beginShape();
        for (int j = 0; j < pbvs1.size (); j++) {
          if(st && pbvs1.get(j)._p.y >= f){
            pdf.vertex(pbvs1.get(j)._p.x,pbvs1.get(j)._p.y);
            st = false;
          }
          pbvs1.get(j).addBV_PDF(l,f,pdf);
        }
        pdf.endShape();
        pdf.noFill();
      }
    } else if (mode == 2) {
      if (b1 != -1 && b2 != -1) {
        boolean st = true;
        pdf.fill(cTable1.findColour(setPointers.indexOf(_p1)%8), 50);
        pdf.noStroke();
        pdf.beginShape();
        for (int j = 0; j < pbvs2.size (); j++) {
          if(st && pbvs2.get(j)._p.y >= f){
            pdf.vertex(pbvs2.get(j)._p.x,pbvs2.get(j)._p.y);
            st = false;
          }
          pbvs2.get(j).addBV_PDF(l,f,pdf);
        }
        pdf.endShape();
        pdf.noFill();
      }
    }
  }
  
  void drawShape3() {
    if (_type == 1 || _type == 2) {
      //drawSShape();
    }
   
    /*if(p1Shapes.size() == 0)return;
    if (p1Shapes.get(0).size() < 2)return;
    FL = _p1.getFL(mode); //get first and last node
    PVector f = p1Shapes.get(0).get(0);
    b1 = pNodes.indexOf(p1Shapes.get(0).get(0));
      if (p1Shapes.get(0).get(0).y >= FL[0].y) {
        //println("nope");
        //f = p1Shapes.get(0).get(0);
      } else {
        for (int l = 0; l < sharedPoints.size (); l++) {
          if (sharedPoints.get(l).y >= FL[0].y) {
            //println("yep");
            f = sharedPoints.get(l);
            b1 = pNodes.indexOf(sharedPoints.get(l));
            break;
          }
        }
      }*/


    for (int i = 0; i < p1Shapes.size (); i++) {
      if (p1Shapes.get(i).size() < 2)continue;

      if (mode == 0) {
        //fill(200, 50);
        fill(cTable1.findColour(setPointers.indexOf(_p1)%8), 50);
        noStroke();
        beginShape();
        vertex(p1Shapes.get(i).get(0).x, p1Shapes.get(i).get(0).y);
        //vertex(f.x, f.y);
        for (int j = 0; j < pbvs.size (); j++) {
          pbvs.get(j).addBV();
          //pbvs.get(j).addBV(FL);
        }
        endShape();
        noFill();
      } else if (mode == 1) {
        if (b1 != -1 && b2 != -1) {
          fill(cTable1.findColour(setPointers.indexOf(_p1)%8), 50);
          noStroke();
          beginShape();
          vertex(pNodes1.get(b1).x, pNodes1.get(b1).y);
          //vertex(f.x, f.y);
          for (int j = 0; j < pbvs1.size (); j++) {
            pbvs1.get(j).addBV();
            //pbvs1.get(j).addBV(FL);
          }
          endShape();
          noFill();
        } else if (mode == 2) {
          if (b1 != -1 && b2 != -1) {
            fill(cTable1.findColour(setPointers.indexOf(_p1)%8), 50);
            noStroke();
            beginShape();
            vertex(pNodes2.get(b1).x, pNodes2.get(b1).y);
            //vertex(f.x, f.y);
            for (int j = 0; j < pbvs2.size (); j++) {
              pbvs2.get(j).addBV();
              //pbvs2.get(j).addBV(FL);
            }
            endShape();
            noFill();
          }
        }
      }
    }
  }


  //https://processing.org/examples/lineargradient.html
  void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {
    noFill();
    if (axis == Y_AXIS) {  // Top to bottom gradient
      for (int i = y; i <= y+h; i++) {
        float inter = map(i, y, y+h, 0, 1);
        color c = lerpColor(c1, c2, inter);
        stroke(c);
        line(x, i, x+w, i);
      }
    } else if (axis == X_AXIS) {  // Left to right gradient
      for (int i = x; i <= x+w; i++) {
        float inter = map(i, x, x+w, 0, 1);
        color c = lerpColor(c1, c2, inter);
        stroke(c);
        line(i, y, i, y+h);
      }
    }
  }
};

class pShape2 {
  ArrayList<pBezierVertex> bvs;
  PVector v1;
  PVector v2;

  pShape2() {
    bvs = new ArrayList<pBezierVertex>();
  }

  void drawShape() {
    if (v1 == null)return;
    fill(200, 100);
    noStroke();
    beginShape();
    vertex(v1.x, v1.y);
    for (int i = 0; i < bvs.size (); i++) {        
      if (bvs.size() < 3) {
        vertex(bvs.get(i)._p.x, bvs.get(i)._p.y);
      } else {
        bvs.get(i).addBV();
      }
    }
    endShape();
    noFill();
  }
};

class pBezierVertex {
  PVector _c1;
  PVector _c2;
  PVector _p;
  pBezierVertex(PVector A, PVector B, PVector C) {
    _c1 = A;
    _c2 = B;
    _p = C;
  }
  void addBV() {
    bezierVertex(_c1.x, _c1.y, _c2.x, _c2.y, _p.x, _p.y);
  }
  
  void addBV(float l, float h) {
    if(_p.y < h || _p.y > l){
      return;
    }else{ 
    bezierVertex(_c1.x, _c1.y, _c2.x, _c2.y, _p.x, _p.y);
    }
  }
  
  void addBV_PDF(float l, float h,PGraphics pdf) {
    /*if(_p.y < h || _p.y > l){
      return;
    }else{ 
    pdf.bezierVertex(_c1.x, _c1.y, _c2.x, _c2.y, _p.x, _p.y);
    }*/
    pdf.bezierVertex(_c1.x, _c1.y, _c2.x, _c2.y, _p.x, _p.y);
  }
  
  void addBV(PGraphics pg) {
    pg.bezierVertex(_c1.x, _c1.y, _c2.x, _c2.y, _p.x, _p.y);
  }

  void addBV(PVector[] fl) {
    if (_p.y > fl[0].y && _p.y <= fl[1].y) {
      bezierVertex(_c1.x, _c1.y, _c2.x, _c2.y, _p.x, _p.y);
    }
  }
};

class bundle {
  PVector cP;
  ArrayList<pointer> ptrs;
  ArrayList<segment> segs = new ArrayList<segment>();
  ArrayList<QuadTree> neighbs = new ArrayList<QuadTree>();
  QuadTree neighb_0;
  node n;
  int dir;
  PVector tmpcP;
  bundle(ArrayList<pointer> members, ArrayList<segment> msegs, QuadTree neighb, node _n, int _dir) {
    ptrs = new ArrayList<pointer>();
    ptrs.addAll(members);
    segs.addAll(msegs);
    neighb_0 = neighb;
    n = _n;
    dir = _dir;
  } 

  void calcControlPoint() {
    //println("calcing");
    //calc midpoint
    int num = 0;
    for (int i = 0; i < segs.size (); i++) {
      tmpcP = neighb_0.calcSegMidpoint(segs.get(i));
      if (tmpcP != null) {
        num++;
        if (cP == null) {
          cP = tmpcP;
        } else {
          cP.add(tmpcP);
        }
      }
    }
    if (num > 0) {
      cP.div(num);
    }
    sendCps();

    /*for (QuadTree QT : neighb_0.neighbors) {
     if (neighbs.contains(QT) == false && QT.empty==true) {
     neighbs.add(QT);
     }
     }*/
  }

  void sendCps() {
    if (cP == null)return;
    //println("sending: "+ptrs.size());
    for (int i = 0; i < ptrs.size (); i++) {
      if (ptrs.get(i).bundleCps.containsKey(n.P)) {
        ptrs.get(i).bundleCps.get(n.P)[dir] = cP;
        //ptrs.get(i).getbs();
      } else {
        //println("b "+ptrs.get(i).bundleCps.size());
        ptrs.get(i).bundleCps.put(n.P, new PVector[2]);
        ptrs.get(i).bundleCps.get(n.P)[dir] = cP;
        //println(ptrs.get(i).bundleCps.size());
        //ptrs.get(i).getbs();
      }
    }
  }

  void drawCP() {
    fill(0);
    ellipse(cP.x, cP.y, 2, 2); 
    noFill();
  }
};

class midpoint {
  int y_val;
  float mid_x;
  Word l_word;
  Word r_word;
  midpoint(int yval, float xval, Word lw, Word rw) {
    //mid_x = (rw == null)? lw.getNodeX() + 10: (lw.getNodeX() + rw.getNodeX())/2.0;
    y_val = yval;
    mid_x = xval;
    l_word = lw;
    r_word = rw;
  }

  void drawM() {
    if(!l_word._node.isActive2()){
      return;
    }
    fill(100);
    textAlign(CENTER, CENTER);
    if (l_word != null && l_word._node != null && !l_word._node.drawn) {
      //println("left!");
      text(l_word._displayWord, l_word.getNodeX()+xs, l_word.getNodeY()-g);

      if (cr > 1) {
        for (int i = 1; i < cr; i++) {
          Word p = l_word.getPrev(i);

          if (p != null && p._node != null && !p._node.drawn) {
            text(p._displayWord, p.getNodeX()+xs, p.getNodeY()-g);
          }
        }
      }
    }
    if (r_word != null && r_word._node != null && !r_word._node.drawn) {
      //println("right!");
      text(r_word._displayWord, r_word.getNodeX()+xs, r_word.getNodeY()-g);

      if (cr > 1) {
        for (int i = 1; i < cr; i++) {
          Word n = r_word.getNext(i);
          if (n != null && n._node != null && !n._node.drawn) {
            text(n._displayWord, n.getNodeX()+xs, n.getNodeY()-g);
          }
        }
      }
    }
    noFill();
  }
};

