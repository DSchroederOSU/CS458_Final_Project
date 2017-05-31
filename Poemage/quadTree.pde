class QuadTree {
  private QuadTree tl, tr, bl, br; //four children
  //QuadTree NE, NEin, NWin, NW, ENin, ESin, SE, SEin, SWin, SW, WSin, WNin; 
  ArrayList<QuadTree> neighbors;
  public QuadTree parent = null;
  public QuadTree rootQT = null;
  public QuadTree mgridRoot = null;
  protected float maxAABBx, maxAABBy, minAABBx, minAABBy; 
  int max_capacity = 1;
  float max_width = 30;
  float max_widthE = 30;
  PVector midPoint;
  ArrayList<node> members;    //probably better to reference them...
  boolean selected = false;
  boolean edgeAmbiguity = false;
  boolean empty = true;
  ArrayList<segment> segs;
  color c;
  int pcrossings, ncrossings;
  color c2;
  int idnum = 0;
  boolean best = false;
  int mgrid = 0;

  QuadTree(float minx, float miny, float maxx, float maxy, QuadTree _parent, QuadTree _rootQT) {
    c2 = color(random(255), random(255), random(255));
    maxAABBx = maxx;
    maxAABBy = maxy;
    minAABBx = minx;
    minAABBy = miny;
    parent = _parent;
    rootQT = _rootQT;
    if (_rootQT == null && parent != null) {
      rootQT = parent;
    }

    tl = null;
    tr = null;
    bl = null;
    br = null;

    //mgrid = _mgrid;
    mgridRoot = this;

    members = new ArrayList<node>();
    neighbors = new ArrayList<QuadTree>();
    segs = new ArrayList<segment>();
    midPoint = new PVector((minAABBx + maxAABBx)/2.0, (minAABBy + maxAABBy)/2.0);
    c = color(random(255), random(255), random(255));
  }

  void insert(node member) {
    if (tr != null) {
      tr.insert(member);
      tl.insert(member);
      br.insert(member);
      bl.insert(member);
    } else {
      if (member.inbounds(minAABBx, minAABBy, maxAABBx, maxAABBy)) {
        members.add(member);
        if (members.size() > max_capacity || maxAABBx-minAABBx > max_width) {
          subdivide();
        }
      } else if (maxAABBx-minAABBx > max_widthE) {  //for empty nodes
        subdivide();
      }
    }
  }

  ///InsertSeg functions///////

  void insertSeg(segment S, int setType, int setNum, int segNum, int subsegNum) {
    //similar to inserting nodes...slightly less efficient...don't know how to call parent. 
    //println("level");
    if (containsPts(S)) { //contains both points
      if (tr != null) {
        int count = 0;
        if (tr.containsPts(S)) {
          tr.insertSeg(S, setType, setNum, segNum, subsegNum);
          count++;
        }
        if (tl.containsPts(S)) {
          tl.insertSeg(S, setType, setNum, segNum, subsegNum);
          count++;
        }
        if (br.containsPts(S)) {
          br.insertSeg(S, setType, setNum, segNum, subsegNum);
          count++;
        }
        if (bl.containsPts(S)) {
          bl.insertSeg(S, setType, setNum, segNum, subsegNum);
          count++;
        }
        if (count == 0) { //lowest level bounding box! start edge recursion from here...
          placeEdges(S, setType, setNum, segNum, subsegNum);
        }
      } else {
        //wont be an else because no cell will contain two points.
      }
    }
  }

  void clearSegs() {
    if (tr != null) {
      tr.clearSegs();
      tl.clearSegs();
      br.clearSegs();
      bl.clearSegs();
    } else {
      segs.clear();
    }
  }

  void removeEdges(segment S, int setType, int setNum, int segNum) {
    segment tmp = calcIntersepts(S, setType, setNum, segNum);
    if (calcIntersepts(S, setType, setNum, segNum) != null) {  //may be illegal
      if (tr != null) {
        tr.removeEdges(S, setType, setNum, segNum);
        tl.removeEdges(S, setType, setNum, segNum);
        br.removeEdges(S, setType, setNum, segNum);
        bl.removeEdges(S, setType, setNum, segNum);
      } else { //leaf node -  remove from segments. 
        for (int i = 0; i < segs.size (); i++) {
          if (tmp.p1.x == segs.get(i).p1.x && tmp.p2.x == segs.get(i).p2.x && tmp.p1.y == segs.get(i).p1.y && tmp.p2.y == segs.get(i).p2.y) {
            segs.remove(i);
          }
        }
      }
    }
  }

  void placeEdges(segment S, int setType, int setNum, int segNum, int subsegNum) {
    segment tmp = calcIntersepts(S, setType, setNum, segNum);
    if (tmp != null) {  //may be illegal
      if (tr != null) {
        tr.placeEdges(S, setType, setNum, segNum, subsegNum);
        tl.placeEdges(S, setType, setNum, segNum, subsegNum);
        br.placeEdges(S, setType, setNum, segNum, subsegNum);
        bl.placeEdges(S, setType, setNum, segNum, subsegNum);
      } else { //leaf node -  add to segments. 
        segs.add(tmp);
        segs.get(segs.size()-1).subseg = subsegNum;  //set to 1000 or to actual number. too hacky?
      }
    } else {
    }
  }

  boolean inbounds(float minx, float miny, float maxx, float maxy, PVector member) {
    if (member.x >= minx && member.x <= maxx && member.y >= miny && member.y <= maxy) { //will cause duplicates...
      return true;
    } else {
      return false;
    }
  }

  void queryQT(PVector member) {
    QuadTree _QT = null;
    if (inbounds(minAABBx, minAABBy, maxAABBx, maxAABBy, member)) {
      if (tr != null) {
        tr.queryQT(member);
        tl.queryQT(member);
        br.queryQT(member);
        bl.queryQT(member);
      } else {
        //println("returning this: " + this.midPoint.x);
        _QT = this;
        QT2 = this;
        //return _QT;
      }
    } 
    //println("returning null");
    //return _QT;
  }



  boolean emptyChildren() {
    if (tr == null) {
      return false;  //this shouldn't happen
    } else if (!tr.empty || !tl.empty || !br.empty || !bl.empty) {
      return false;
    } else {
      return true;
    }
  }

  void checkChildren() {
    if (tr != null) {
      tr.checkChildren();
      tl.checkChildren();
      br.checkChildren();
      bl.checkChildren();
    } else {
      if (!empty) {
        isempty = false;
      }
    }
  }


  boolean containsSeg(segment S) {
    ArrayList<PVector> tmpVerts = new ArrayList<PVector>();
    int intercepts = 0;
    int node = 0;
    segment seg = null;
    PVector tmpVert;
    tmpVerts.clear();

    //check if segment end points fall in cells
    if (S.inbounds(minAABBx, minAABBy, maxAABBx, maxAABBy, S.p1)) {
      intercepts++;
      node++;
      tmpVerts.add(new PVector(S.p1.x, S.p1.y));
    }
    if (S.inbounds(minAABBx, minAABBy, maxAABBx, maxAABBy, S.p2)) {
      intercepts++;
      node++;
      tmpVerts.add(new PVector(S.p2.x, S.p2.y));
    }

    if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, minAABBx, minAABBy, maxAABBx, minAABBy)) {
      tmpVert = intersection(minAABBx, minAABBy, maxAABBx, minAABBy, S);
      if (tmpVert != null && !tmpVerts.contains(tmpVert)) {
        intercepts++;
        tmpVerts.add(tmpVert);
      }
    }
    if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, maxAABBx, minAABBy, maxAABBx, maxAABBy)) {
      tmpVert = intersection(maxAABBx, minAABBy, maxAABBx, maxAABBy, S);
      if (tmpVert != null && !tmpVerts.contains(tmpVert)) {
        intercepts++;
        tmpVerts.add(tmpVert);
      }
    }
    if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, maxAABBx, maxAABBy, minAABBx, maxAABBy)) {
      tmpVert = intersection(maxAABBx, maxAABBy, minAABBx, maxAABBy, S);
      if (tmpVert != null && !tmpVerts.contains(tmpVert)) {
        intercepts++;
        tmpVerts.add(tmpVert);
      }
    }
    if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, minAABBx, minAABBy, minAABBx, maxAABBy)) {
      tmpVert = intersection(minAABBx, minAABBy, minAABBx, maxAABBy, S);
      if (tmpVert != null && !tmpVerts.contains(tmpVert)) {
        intercepts++;
        tmpVerts.add(tmpVert);
      }
    }
    //println("intersepts: "+intercepts+" nodes: "+node);
    if (intercepts == 2) {
      return true;
    } else {
      return false;
    }
  }

  PVector calcSegMidpoint(segment S) {
    segment seg =  calcIntersepts(S, 0, 0, 0); //not important here
    if (seg != null && seg.inbounds(minAABBx, minAABBy, maxAABBx, maxAABBy, seg.midPoint)) { 
      return seg.midPoint;
    }
    return null;
  }

  segment calcIntersepts(segment S, int setType, int setNum, int segNum) {
    ArrayList<PVector> tmpVerts = new ArrayList<PVector>();
    int intercepts = 0;
    int node = 0;
    segment seg = null;
    PVector tmpVert;
    tmpVerts.clear();

    //check if segment end points fall in cells
    if (S.inbounds(minAABBx, minAABBy, maxAABBx, maxAABBy, S.p1)) {
      intercepts++;
      node++;
      tmpVerts.add(new PVector(S.p1.x, S.p1.y));
    }
    if (S.inbounds(minAABBx, minAABBy, maxAABBx, maxAABBy, S.p2)) {
      intercepts++;
      node++;
      tmpVerts.add(new PVector(S.p2.x, S.p2.y));
    }

    if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, minAABBx, minAABBy, maxAABBx, minAABBy)) {
      tmpVert = intersection(minAABBx, minAABBy, maxAABBx, minAABBy, S);
      if (tmpVert != null && !tmpVerts.contains(tmpVert)) {
        intercepts++;
        tmpVerts.add(tmpVert);
      }
    }
    if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, maxAABBx, minAABBy, maxAABBx, maxAABBy)) {
      tmpVert = intersection(maxAABBx, minAABBy, maxAABBx, maxAABBy, S);
      if (tmpVert != null && !tmpVerts.contains(tmpVert)) {
        intercepts++;
        tmpVerts.add(tmpVert);
      }
    }
    if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, maxAABBx, maxAABBy, minAABBx, maxAABBy)) {
      tmpVert = intersection(maxAABBx, maxAABBy, minAABBx, maxAABBy, S);
      if (tmpVert != null && !tmpVerts.contains(tmpVert)) {
        intercepts++;
        tmpVerts.add(tmpVert);
      }
    }
    if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, minAABBx, minAABBy, minAABBx, maxAABBy)) {
      tmpVert = intersection(minAABBx, minAABBy, minAABBx, maxAABBy, S);
      if (tmpVert != null && !tmpVerts.contains(tmpVert)) {
        intercepts++;
        tmpVerts.add(tmpVert);
      }
    }
    //println("intersepts: "+intercepts+" nodes: "+node);
    if (intercepts == 2) {
      seg = new segment(tmpVerts.get(0), tmpVerts.get(1), setType, setNum, segNum, node);
    } 
    return seg;
  }

  PVector intersection(float p1x, float p1y, float p2x, float p2y, segment S) {
    float d = (p1x-p2x)*(S.p1.y-S.p2.y) - (p1y-p2y)*(S.p1.x-S.p2.x);
    if (d == 0) {
      //println("d0");
      return null;
    }

    float intx = ((S.p1.x-S.p2.x)*(p1x*p2y-p1y*p2x)-(p1x-p2x)*(S.p1.x*S.p2.y-S.p1.y*S.p2.x))/d; 
    float inty = ((S.p1.y-S.p2.y)*(p1x*p2y-p1y*p2x)-(p1y-p2y)*(S.p1.x*S.p2.y-S.p1.y*S.p2.x))/d; 
    //round - may cause a bug
    intx = Math.round(intx*10000.0)/10000.0;
    inty = Math.round(inty*10000.0)/10000.0;

    if (S.p1.x==S.p2.x) { 
      //if (inty < Math.round(Math.min(p1y, p2y)*10000.0)/10000.0 || inty > Math.round(Math.max(p1y, p2y)*10000.0)/10000.0){println("n1"); return null;} 
      if (inty < Math.round(Math.min(S.p1.y, S.p2.y)*10000.0)/10000.0 || inty > Math.round(Math.max(S.p1.y, S.p2.y)*10000.0)/10000.0) {
        //println("n2"); 
        return null;
      }
    }

    PVector point = new PVector(intx, inty);

    if (S.p1.y==S.p2.y) {
      //if (intx < Math.round(Math.min(p1x, p2x)*10000.0)/10000.0 || intx > Math.round(Math.max(p1x, p2x)*10000.0)/10000.0){println("n3"); return null;}
      if (intx < Math.round(Math.min(S.p1.x, S.p2.x)*10000.0)/10000.0 || intx > Math.round(Math.max(S.p1.x, S.p2.x)*10000.0)/10000.0) {
        //println("n4"); 
        return null;
      }
    }

    return point;
  }

  boolean containsPts(segment S) {
    if (S.inbounds(minAABBx, minAABBy, maxAABBx, maxAABBy, S.p1) && S.inbounds(minAABBx, minAABBy, maxAABBx, maxAABBy, S.p2)) {
      return true;
    } else {
      return false;
    }
  }


  void subdivide() {

    float midx = (minAABBx + maxAABBx)/2.0;
    float midy = (minAABBy + maxAABBy)/2.0;
    //float g = midx/9.5;

    //println(g);

    //else generate r children - minx, miny, maxx, maxy - remember y is backwards

    //println("subdividing ");
    tr = new QuadTree(midx, midy, maxAABBx, maxAABBy, this, rootQT);
    tl = new QuadTree(minAABBx, midy, midx, maxAABBy, this, rootQT);
    br = new QuadTree(midx, minAABBy, maxAABBx, midy, this, rootQT);
    bl = new QuadTree(minAABBx, minAABBy, midx, midy, this, rootQT);

    //insert into each quadtree;
    for (node n : members) {
      //println(n.wrd);
      tr.insert(n);
      tl.insert(n);
      br.insert(n); 
      bl.insert(n);   //it's flipped remember
    }
    members.clear();
  }

  void query(node member) {
    if (member.inbounds(minAABBx, minAABBy, maxAABBx, maxAABBy)) {
      if (tr != null) {
        selected = false; 
        tr.query(member);
        tl.query(member);
        br.query(member);
        bl.query(member);
      } else {
        selected = true;
      }
    }
  }

  void geoWish() {
    if (tr != null) {
      tr.geoWish();
      tl.geoWish();
      br.geoWish();
      bl.geoWish();
    } else {
      for (node n : members) {
        n.x = midPoint.x;
        n.y = midPoint.y;
      }
    }
  }

  void checkForAmbiguities() {
    if (tr != null) {
      tr.checkForAmbiguities();
      tl.checkForAmbiguities();
      br.checkForAmbiguities();
      bl.checkForAmbiguities();
    } else {
      if (members.size() == max_capacity) {    //if cell contains node, and seg is not incident = ambiguity.
        for (int i = 0; i < segs.size (); i++) {
          if (segs.get(i).node == 0 && segs.get(i).containsNode(members.get(0)) == false) {
            edgeAmbiguity = true;
            reroute3(i);
          }
        }
      }
    }
  }

  void reroute3(int s) {
    if(Line2D.ptSegDist(segs.get(s).p1.x, segs.get(s).p1.y, segs.get(s).p2.x, segs.get(s).p2.y, members.get(0).x, members.get(0).y) > 4){
      return;
    }
    
    
    segs.get(s).calcPerp();
    segs.get(s).calcSubSeg();
    segment tmpseg = null;
    segment tmpseg3 = null;

    if (Math.abs(segs.get(s).theta) == 0.0) {
      segs.get(s).dir = "neg";
      tmpseg = new segment(segs.get(s).midPoint, segs.get(s).negPerp);
    } else {  //take direction away from point
      tmpseg = new segment(segs.get(s).midPoint, segs.get(s).posPerp);
      tmpseg3 = new segment(segs.get(s).midPoint, segs.get(s).negPerp);
      double d1 = Line2D.ptSegDist(tmpseg.p1.x, tmpseg.p1.y, tmpseg.p2.x, tmpseg.p2.y, members.get(0).x, members.get(0).y);  
      double d2 = Line2D.ptSegDist(tmpseg3.p1.x, tmpseg3.p1.y, tmpseg3.p2.x, tmpseg3.p2.y, members.get(0).x, members.get(0).y);  
      if (d1 <= d2) {
        segs.get(s).dir = "neg";
        tmpseg = new segment(segs.get(s).midPoint, segs.get(s).negPerp);
      } else if (d1 <d2) {
        segs.get(s).dir = "pos";
        tmpseg = new segment(segs.get(s).midPoint, segs.get(s).posPerp);
      }  
      /*if((segs.get(s).p2.x < segs.get(s).p1.x) && (segs.get(s).p1.y < segs.get(s).p2.y)){
        segs.get(s).dir = "neg";
        tmpseg = new segment(segs.get(s).midPoint, segs.get(s).negPerp);
     }*/
    }
  traverseSegR(s, tmpseg);
  segs.get(s).sendControlPt(members.get(0));
}

void reroute(int s) {
  //println("rerouting!");
  ArrayList<PVector> candidates = new ArrayList<PVector>();
  segment tmpseg = null;
  segment tmpseg2 = null;
  segment tmpseg3 = null;
  //calculate line perpendicular to segment - choose midpoint? Note: these segments are CELL SEGMENTS not graph edges
  segs.get(s).calcPerp();
  segs.get(s).calcSubSeg();
  //pick direction (crosses least number of segments) 
  pcrossings = 0;
  ncrossings = 0;
  for (int i = 0; i < segs.size (); i++) {
    if (i == s || segs.get(i).incident == false) continue;    //skip non incident nodes
    //check pos 
    if (Line2D.linesIntersect(segs.get(s).midPoint.x, segs.get(s).midPoint.y, segs.get(s).posPerp.x, segs.get(s).posPerp.y, segs.get(i).p1.x, segs.get(i).p1.y, segs.get(i).p2.x, segs.get(i).p2.y)) {
      pcrossings++;
    } else if (Line2D.linesIntersect(segs.get(s).midPoint.x, segs.get(s).midPoint.y, segs.get(s).negPerp.x, segs.get(s).negPerp.y, segs.get(i).p1.x, segs.get(i).p1.y, segs.get(i).p2.x, segs.get(i).p2.y)) {
      ncrossings++;
    }
  }
  segs.get(s).dir = (pcrossings > ncrossings) ? "neg" : "pos"; //switch here if overlaps with self
  //find optimal nearest neighbor
  if (segs.get(s).dir.equals("pos")) {
    //tmpseg = new segment(new PVector(segs.get(s).midPoint.x, segs.get(s).midPoint.y), new PVector(segs.get(s).posPerp.x, segs.get(s).posPerp.y));
    tmpseg = new segment(segs.get(s).midPoint, segs.get(s).posPerp);
    //tmpseg3 = new segment(new PVector(segs.get(s).midPoint.x, segs.get(s).midPoint.y), new PVector(segs.get(s).negPerp.x, segs.get(s).negPerp.y));
    tmpseg3 = new segment(segs.get(s).midPoint, segs.get(s).negPerp);
  } else if (segs.get(s).dir.equals("neg")) {
    //tmpseg = new segment(new PVector(segs.get(s).midPoint.x, segs.get(s).midPoint.y), new PVector(segs.get(s).negPerp.x, segs.get(s).negPerp.y));
    tmpseg = new segment(segs.get(s).midPoint, segs.get(s).negPerp);
    //tmpseg3 = new segment(new PVector(segs.get(s).midPoint.x, segs.get(s).midPoint.y), new PVector(segs.get(s).posPerp.x, segs.get(s).posPerp.y));
    tmpseg3 = new segment(segs.get(s).midPoint, segs.get(s).posPerp);
  }
  //check if it intercepts itself
  /*if (tmpseg != null && interseptsSelf(s, tmpseg) && tmpseg3 != null && interseptsSelf(s, tmpseg3.scaled()) == false ) {
   if (segs.get(s).dir.equals("pos")) {
   segs.get(s).dir = "neg";
   //tmpseg = new segment(new PVector(segs.get(s).midPoint.x, segs.get(s).midPoint.y), new PVector(segs.get(s).negPerp.x, segs.get(s).negPerp.y));
   tmpseg = new segment(segs.get(s).midPoint, segs.get(s).negPerp);
   tmpseg3 = new segment(segs.get(s).midPoint, segs.get(s).posPerp);
   } else if (segs.get(s).dir.equals("neg")) {
   segs.get(s).dir = "pos";
   //tmpseg = new segment(new PVector(segs.get(s).midPoint.x, segs.get(s).midPoint.y), new PVector(segs.get(s).posPerp.x, segs.get(s).posPerp.y));
   tmpseg = new segment(segs.get(s).midPoint, segs.get(s).posPerp);
   tmpseg3 = new segment(segs.get(s).midPoint, segs.get(s).negPerp);
   }
   }*/
  //if horizontal, go neg. 
  if (Math.abs(segs.get(s).theta) == 0.0 || segs.get(s).theta == 180.0) {
    segs.get(s).dir = "neg";
  } else { //take direction away from point
    double d1 = Line2D.ptSegDist(tmpseg.p1.x, tmpseg.p1.y, tmpseg.p2.x, tmpseg.p2.y, members.get(0).x, members.get(0).y);  
    double d2 = Line2D.ptSegDist(tmpseg3.p1.x, tmpseg3.p1.y, tmpseg3.p2.x, tmpseg3.p2.y, members.get(0).x, members.get(0).y);  

    if (segs.get(s).dir == "neg") {
      if (d1 < d1) segs.get(s).dir = "pos";
    } else if (segs.get(s).dir == "pos") {
      if (d1 <d2) segs.get(s).dir = "neg";
    }
  }
  //march along perp
  /*traverseSegments(s, tmpseg);
   if (segs.get(s).controlPoint != null) {
   segs.get(s).sendControlPt(members.get(0));
   reroutes++;
   idnum = reroutes;
   } else if (useBest) { //just use the closest point
   best = true;
   segs.get(s).dir = (segs.get(s).dir.equals("neg")) ? "pos" : "neg";
   traverseSegment(s, tmpseg);
   best = false;
   if (segs.get(s).controlPoint != null) { //which should ALWAYS be the case
   segs.get(s).sendControlPt(members.get(0));
   reroutes++;
   idnum = reroutes;
   }
   }*/
  //println(reroutes);
  traverseSegR(s, tmpseg);
  segs.get(s).sendControlPt(members.get(0));
}



boolean interseptsSelf(int s, segment tmpSeg) {
  segment prev = null;
  segment next = null;
  if (segs.get(s).segNum > 0) {  //get previous
    prev = new segment(RhymeSets.get(segs.get(s).setType).get(segs.get(s).setNum)._segs.get(segs.get(s).segNum-1).p1, RhymeSets.get(segs.get(s).setType).get(segs.get(s).setNum)._segs.get(segs.get(s).segNum-1).p2);
    if (Line2D.linesIntersect(tmpSeg.p1.x, tmpSeg.p1.y, tmpSeg.p2.x, tmpSeg.p2.y, prev.p1.x, prev.p1.y, prev.p2.x, prev.p2.y)) {
      return true;
    }
  }
  if (segs.get(s).segNum > 1) {  //get previous
    prev = new segment(RhymeSets.get(segs.get(s).setType).get(segs.get(s).setNum)._segs.get(segs.get(s).segNum-2).p1, RhymeSets.get(segs.get(s).setType).get(segs.get(s).setNum)._segs.get(segs.get(s).segNum-2).p2);
    if (Line2D.linesIntersect(tmpSeg.p1.x, tmpSeg.p1.y, tmpSeg.p2.x, tmpSeg.p2.y, prev.p1.x, prev.p1.y, prev.p2.x, prev.p2.y)) {
      return true;
    }
  }

  if (RhymeSets.get(segs.get(s).setType).get(segs.get(s).setNum)._segs.size() > segs.get(s).segNum+1) { //get next
    next = new segment(RhymeSets.get(segs.get(s).setType).get(segs.get(s).setNum)._segs.get(segs.get(s).segNum+1).p1, RhymeSets.get(segs.get(s).setType).get(segs.get(s).setNum)._segs.get(segs.get(s).segNum+1).p2);
    if (Line2D.linesIntersect(tmpSeg.p1.x, tmpSeg.p1.y, tmpSeg.p2.x, tmpSeg.p2.y, next.p1.x, next.p1.y, next.p2.x, next.p2.y)) {
      return true;
    }
  }
  if (RhymeSets.get(segs.get(s).setType).get(segs.get(s).setNum)._segs.size() > segs.get(s).segNum+2) { //get next
    next = new segment(RhymeSets.get(segs.get(s).setType).get(segs.get(s).setNum)._segs.get(segs.get(s).segNum+2).p1, RhymeSets.get(segs.get(s).setType).get(segs.get(s).setNum)._segs.get(segs.get(s).segNum+2).p2);
    if (Line2D.linesIntersect(tmpSeg.p1.x, tmpSeg.p1.y, tmpSeg.p2.x, tmpSeg.p2.y, next.p1.x, next.p1.y, next.p2.x, next.p2.y)) {
      return true;
    }
  }

  return false;
}

segment calcInterseptsQT(segment S) {
  ArrayList<PVector> tmpVerts = new ArrayList<PVector>();
  int intercepts = 0;
  int node = 0;
  segment seg = null;
  PVector tmpVert;

  //check if segment end points fall in cells
  if (S.inbounds(minAABBx, minAABBy, maxAABBx, maxAABBy, S.p1)) {
    intercepts++;
    node++;
    tmpVerts.add(S.p1);
  }
  if (S.inbounds(minAABBx, minAABBy, maxAABBx, maxAABBy, S.p2)) {
    intercepts++;
    node++;
    tmpVerts.add(S.p2);
  }
  if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, minAABBx, minAABBy, maxAABBx, minAABBy)) {
    tmpVert = intersection(minAABBx, minAABBy, maxAABBx, minAABBy, S);
    if (tmpVert != null) {
      intercepts++;
      tmpVerts.add(tmpVert);
    }
  }
  if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, maxAABBx, minAABBy, maxAABBx, maxAABBy)) {
    tmpVert = intersection(maxAABBx, minAABBy, maxAABBx, maxAABBy, S);
    if (tmpVert != null) {
      intercepts++;
      tmpVerts.add(tmpVert);
    }
  }
  if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, maxAABBx, maxAABBy, minAABBx, maxAABBy)) {
    tmpVert = intersection(maxAABBx, maxAABBy, minAABBx, maxAABBy, S);
    if (tmpVert != null) {
      intercepts++;
      tmpVerts.add(tmpVert);
    }
  }
  if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, minAABBx, maxAABBy, minAABBx, minAABBy)) {
    tmpVert = intersection(minAABBx, maxAABBy, minAABBx, minAABBy, S);
    if (tmpVert != null) {
      intercepts++;
      tmpVerts.add(tmpVert);
    }
  }
  if (intercepts == 2) {
    if (tmpVerts.get(0).x == tmpVerts.get(1).x && tmpVerts.get(0).y == tmpVerts.get(1).y ) {
    } else {
      seg = new segment(tmpVerts.get(0), tmpVerts.get(1));
      if (seg.theta == -90) {
        //println(seg.theta + ","+seg.thetaR+":"+seg.m+" "+(seg.v2.y - seg.v1.y)+" "+(seg.v2.x - seg.v1.x));
        //println("("+tmpVerts.get(0).x+","+tmpVerts.get(0).y+")  ("+tmpVerts.get(1).x+","+tmpVerts.get(1).y+")");
      }
    }
  }
  return seg;
}



void traverseSegments(int s, segment tmpseg) {
  traverseSegment(s, tmpseg);
  if (segs.get(s).controlPoint != null) {
    //println("success!");
    return;
  } else {
    //println("take2");
    segment tmpseg2 = null;
    segs.get(s).dir = (segs.get(s).dir.equals("neg")) ? "pos" : "neg";
    if (segs.get(s).dir.equals("pos")) {
      tmpseg2 = new segment(segs.get(s).midPoint, segs.get(s).posPerp);
    } else if (segs.get(s).dir.equals("neg")) {
      tmpseg2 = new segment(segs.get(s).midPoint, segs.get(s).negPerp);
    }
    traverseSegment(s, tmpseg2);
    /*if (segs.get(s).controlPoint == null) {
     println("Still Null");
     }*/
  }
}

void traverseSegR(int s, segment tmpseg) {
  segs.get(s).controlPoint = tmpseg.p2;
  int c = 0;
  while(members.get(0).P.dist(segs.get(s).controlPoint) < 5 && c <5){
      segs.get(s).incrementControlPoint(segs.get(s).controlPoint, 2);
      c++;
  }
}

void traverseSegment(int s, segment tmpseg) {
  if (tmpseg == null) {
    return;
  }
  segment tmp = calcInterseptsQT(tmpseg);
  boolean filled = false;
  PVector end = tmpseg.p1;    //
  int count = 0;
  while (!filled) {
    if (tmp != null) {
      count++;
      if (end.x == tmp.p1.x && end.y == tmp.p1.y) {
      }
      PVector locate = (end.x == tmp.p1.x && end.y == tmp.p1.y) ? tmp.p2 : tmp.p1;
      segs.get(s).testPoint = locate;
      segs.get(s).incrementTestPoint();
      QT2 = null;
      if (rootQT != null) {
        rootQT.queryQT(segs.get(s).testPoint);
      } else {
        queryQT(segs.get(s).testPoint);
      }
      if (QT2 != null) {
        PVector ctmp = getClosestPoint(s, tmpseg, QT2.midPoint);
        if (checkRouteBool(QT2, s, ctmp)) {
          segs.get(s).controlPoint = getClosestPoint(s, tmpseg, QT2.midPoint);
          if (segs.get(s).controlPoint == null) {
            println("null!");
          }
          filled = true;
        } else {
          if (best) {    //just use first proper candidate
            segs.get(s).controlPoint = getClosestPoint(s, tmpseg, QT2.midPoint);
            filled = true;
          }
          end = locate;
          tmp = QT2.calcInterseptsQT(tmpseg);
        }
      } //println("problem..."); FIX THIS
      if (count > 2) {
        filled = true;
      }
    } else {
      filled = true;
    }
  }
}

/*http://www.ogre3d.org/tikiwiki/Nearest+point+on+a+line*/
PVector getClosestPoint(int _s, segment s, PVector p) {
  //println("Getting closest point");
  PVector p1 = new PVector(s.p1.x, s.p1.y);
  PVector p2 = new PVector(s.p2.x, s.p2.y);
  PVector a = new PVector(p.x - p1.x, p.y - p1.y);
  PVector b = new PVector(p2.x - p1.x, p2.y - p1.y);
  float cosTheta = a.dot(b)/(a.mag() * b.mag());
  float scale = (a.mag()*cosTheta)/b.mag();
  b.set(b.x*scale, b.y*scale);
  //println(b.x+" "+b.y);
  p1.set(p1.x+b.x, p1.y+b.y);
  if (members.size() > 0 && pdist(p1, new PVector(members.get(0).x, members.get(0).y)) < 5) {
    return segs.get(_s).incrementPoint(p1, 5-(int)pdist(p1, new PVector(members.get(0).x, members.get(0).y)));
  } else {
    return p1;
  }
}

double pdist(PVector p1, PVector p2) {
  double dx = Math.pow((p2.x - p1.x), 2);
  double dy = Math.pow((p2.y - p1.y), 2);
  return Math.sqrt(dx + dy);
}

boolean intersept(segment s1, segment s2) { 
  if (Line2D.linesIntersect(s1.p1.x, s1.p1.y, s1.p2.x, s1.p2.y, s2.p1.x, s2.p1.y, s2.p2.x, s2.p2.y)) {
    if ((s1.p1.x == s2.p1.x && s1.p1.y == s2.p1.y)|| (s1.p1.x == s2.p2.x && s1.p1.y == s2.p2.y) || (s1.p2.x == s2.p1.x && s1.p2.y == s2.p1.y) || (s1.p2.x == s2.p2.x && s1.p2.y == s2.p2.y)) {
      println("false!"); 
      return false;
    } else {
      //println("("+s1.v1.x+","+s1.v1.y+")"+"("+s1.v2.x+","+s1.v2.y+")"+"("+s2.v1.x+","+s2.v1.y+")"+"("+s2.v2.x+","+s2.v2.y+")");
      return true;
    }
  }
  return false;
} 

boolean checkRouteBool(QuadTree QT2, int s, PVector _ctmp) {
  return true;
} 


boolean checkRouteBool1(QuadTree QT2, int s, PVector _ctmp) {
  if (pass == 1) {
    if (QT2.members.size() == 0) { 
      return true;
    } else {
      return false;
    }
  }
  segment a = null;
  segment b = null;
  segment orig = null;
  segment prev, pprev, next, nnext;
  prev = pprev = next = nnext = null;

  orig = segs.get(s).subEdge;
  next = segs.get(s).next;
  prev = segs.get(s).prev;
  if (orig == null) println("null");
  a = new segment(orig.p1, _ctmp);
  b = new segment(_ctmp, orig.p2);

  //create nnext and pprevs and check tmpseg...should help for most cases...
  if (prev != null && (intersept(b, prev))||(pprev != null && (intersept(a, pprev) || intersept(b, pprev)))) {
    //println("intersepts self!");
    return false;
  } else if (next != null && (intersept(a, next)) ||(nnext != null && (intersept(a, nnext) || intersept(b, nnext)))) {
    //println("intersepts self!");
    return false;
  }

  newAmb = false;
  rootQT.passThroughNode(a);
  if (newAmb) {
    return false;
  } else {
    rootQT.passThroughNode(b);
  }
  if (newAmb) {
    return false;
  } else {
    return true;
  }
}

void passThroughNode(segment s) {
  if (tr != null) {
    tr.passThroughNode(s);
    tl.passThroughNode(s);
    br.passThroughNode(s);
    bl.passThroughNode(s);
  } else {
    if (containsInterSeg(s) && members.size() > 0) { 
      if ((members.get(0).x == s.p1.x && members.get(0).y == s.p1.y)||(members.get(0).x == s.p2.x && members.get(0).y == s.p2.y)) {  //check if member is endpoint
      } else {
        newAmb = true;
      }
    }
  }
}

boolean containsInterSeg(segment S) {
  int intercepts = 0;
  if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, minAABBx, minAABBy, maxAABBx, minAABBy)) {
    intercepts++;
  }
  if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, maxAABBx, minAABBy, maxAABBx, maxAABBy)) {
    intercepts++;
  }
  if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, maxAABBx, maxAABBy, minAABBx, maxAABBy)) {
    intercepts++;
  }
  if (Line2D.linesIntersect(S.p1.x, S.p1.y, S.p2.x, S.p2.y, minAABBx, maxAABBy, minAABBx, minAABBy)) {
    intercepts++;
  }
  if (intercepts >= 2) {
    return true;
  } else {
    return false;
  }
}

////////get neighbors methods//////////////////
void getNeighbors() {
  if (members.size() > 0) { 
    empty = false;
  } 
  if (tr != null) {
    tr.getNeighbors();
    tl.getNeighbors();
    br.getNeighbors();
    bl.getNeighbors();
  } else {
    neighbors.clear(); 
    //NW, NWin, NEin, NE, ENin, ESin, SE, SEin, SWin, SW, WSin, WNin; 
    rootQT.queryQT(new PVector(minAABBx - 2, minAABBy - 2));  //NW
    //NW = QT2;
    if (QT2 != null) {
      neighbors.add(QT2);
    }
    rootQT.queryQT(new PVector(minAABBx + 2, minAABBy - 2)); //NWin
    //NWin = QT2;
    if (QT2 != null) {
      neighbors.add(QT2);
    }
    rootQT.queryQT(new PVector(maxAABBx - 2, minAABBy - 2)); //NEin
    //NEin = QT2;
    if (QT2 != null) {
      neighbors.add(QT2);
    }
    rootQT.queryQT(new PVector(maxAABBx + 2, minAABBy - 2)); //NE
    //NE = QT2;
    if (QT2 != null) {
      neighbors.add(QT2);
    }
    rootQT.queryQT(new PVector(maxAABBx + 2, minAABBy + 2)); //ENin
    //ENin = QT2;
    if (QT2 != null) {
      neighbors.add(QT2);
    }
    rootQT.queryQT(new PVector(maxAABBx + 2, maxAABBy - 2)); //ESin
    //ESin = QT2;
    if (QT2 != null) {
      neighbors.add(QT2);
    }
    rootQT.queryQT(new PVector(maxAABBx + 2, maxAABBy + 2)); //SE
    //SE = QT2;
    if (QT2 != null) {
      neighbors.add(QT2);
    }
    rootQT.queryQT(new PVector(maxAABBx - 2, maxAABBy + 2)); //SEin
    //SEin = QT2;
    if (QT2 != null) {
      neighbors.add(QT2);
    }
    rootQT.queryQT(new PVector(minAABBx + 2, maxAABBy + 2)); //SWin
    //SWin = QT2;
    if (QT2 != null) {
      neighbors.add(QT2);
    }
    rootQT.queryQT(new PVector(minAABBx - 2, maxAABBy + 2)); //SW 
    //SW = QT2;
    if (QT2 != null) {
      neighbors.add(QT2);
    }
    rootQT.queryQT(new PVector(minAABBx - 2, maxAABBy - 2));  //WSin
    //WSin = QT2;
    if (QT2 != null) {
      neighbors.add(QT2);
    }
    rootQT.queryQT(new PVector(minAABBx - 2, minAABBy + 2));  //WNin
    //WNin = QT2;
    if (QT2 != null) {
      neighbors.add(QT2);
    }
  }
}

void calcM() {
  if (tr != null) {
    tr.calcM();
    tl.calcM();
    br.calcM();
    bl.calcM();
  } else {
    if (parent != null && parent.emptyChildren()) { 
      mgrid = 1;
      mgridRoot = parent;
      boolean search = true;
      while (search) {
        isempty = true; 
        mgridRoot.parent.checkChildren();
        if (mgridRoot.parent != null && isempty) {
          isempty = true;
          mgridRoot = mgridRoot.parent;
        } else {
          search = false;
        }
      }
    }
  }
}

void getmgridNeighbors() {
  if (mgridRoot == this) {  //if is root
    if (rootQT == null) {
      //return;
    } else {
      neighbors.clear(); 
      //NW, NWin, NEin, NE, ENin, ESin, SE, SEin, SWin, SW, WSin, WNin;
      //inch into neighboring cells and then query. 
      rootQT.queryQT(new PVector(minAABBx - 2, minAABBy - 2));  //NW
      //NW = QT2;
      if (QT2 != null && neighbors.contains(QT2.mgridRoot) == false) {
        neighbors.add(QT2.mgridRoot);
      }
      rootQT.queryQT(new PVector(minAABBx + 2, minAABBy - 2)); //NWin
      //NWin = QT2;
      if (QT2 != null && neighbors.contains(QT2.mgridRoot) == false) {
        neighbors.add(QT2.mgridRoot);
      }
      rootQT.queryQT(new PVector(maxAABBx - 2, minAABBy - 2)); //NEin
      //NEin = QT2;
      if (QT2 != null && neighbors.contains(QT2.mgridRoot) == false) {
        neighbors.add(QT2.mgridRoot);
      }
      rootQT.queryQT(new PVector(maxAABBx + 2, minAABBy - 2)); //NE
      //NE = QT2;
      if (QT2 != null && neighbors.contains(QT2.mgridRoot) == false) {
        neighbors.add(QT2.mgridRoot);
      }
      rootQT.queryQT(new PVector(maxAABBx + 2, minAABBy + 2)); //ENin
      //ENin = QT2;
      if (QT2 != null && neighbors.contains(QT2.mgridRoot) == false) {
        neighbors.add(QT2.mgridRoot);
      }
      rootQT.queryQT(new PVector(maxAABBx + 2, maxAABBy - 2)); //ESin
      //ESin = QT2;
      if (QT2 != null && neighbors.contains(QT2.mgridRoot) == false) {
        neighbors.add(QT2.mgridRoot);
      }
      rootQT.queryQT(new PVector(maxAABBx + 2, maxAABBy + 2)); //SE
      //SE = QT2;
      if (QT2 != null && neighbors.contains(QT2.mgridRoot) == false) {
        neighbors.add(QT2.mgridRoot);
      }
      rootQT.queryQT(new PVector(maxAABBx - 2, maxAABBy + 2)); //SEin
      //SEin = QT2;
      if (QT2 != null && neighbors.contains(QT2.mgridRoot) == false) {
        neighbors.add(QT2.mgridRoot);
      }
      rootQT.queryQT(new PVector(minAABBx + 2, maxAABBy + 2)); //SWin
      //SWin = QT2;
      if (QT2 != null && neighbors.contains(QT2.mgridRoot) == false) {
        neighbors.add(QT2.mgridRoot);
      }
      rootQT.queryQT(new PVector(minAABBx - 2, maxAABBy + 2)); //SW 
      //SW = QT2;
      if (QT2 != null && neighbors.contains(QT2.mgridRoot) == false) {
        neighbors.add(QT2.mgridRoot);
      }
      rootQT.queryQT(new PVector(minAABBx - 2, maxAABBy - 2));  //WSin
      //WSin = QT2;
      if (QT2 != null && neighbors.contains(QT2.mgridRoot) == false) {
        neighbors.add(QT2.mgridRoot);
      }
      rootQT.queryQT(new PVector(minAABBx - 2, minAABBy + 2));  //WNin
      //WNin = QT2;
      if (QT2 != null && neighbors.contains(QT2.mgridRoot) == false) {
        neighbors.add(QT2.mgridRoot);
      }
    } 
    if (tr != null) {
      tr.getmgridNeighbors();
      tl.getmgridNeighbors();
      br.getmgridNeighbors();
      bl.getmgridNeighbors();
    }
  }
}


//////////////drawing methods/////////////////

void drawGridOutline() {
  stroke(LT_BLUE);
  strokeWeight(0.25);
  noFill();
  quad(minAABBx, minAABBy, maxAABBx, minAABBy, maxAABBx, maxAABBy, minAABBx, maxAABBy);
  noFill();
  strokeWeight(0.5);
  if (tr != null) {
    tr.drawGridOutline();
    tl.drawGridOutline();
    br.drawGridOutline();
    bl.drawGridOutline();
  } else {
    if (junk) {
      for (int i = 0; i < segs.size (); i++) {
        stroke(c);
        segs.get(i).drawSeg();
      }
    }
  }
}

void drawOutline() {
  stroke(LT_BLUE);
  strokeWeight(1.25);
  noFill();
  quad(minAABBx, minAABBy, maxAABBx, minAABBy, maxAABBx, maxAABBy, minAABBx, maxAABBy);
  noFill();
  strokeWeight(0.5);
}

void drawQT() {
  stroke(LT_BLUE);
  strokeWeight(0.25);
  noFill();
  quad(minAABBx, minAABBy, maxAABBx, minAABBy, maxAABBx, maxAABBy, minAABBx, maxAABBy);
  noFill();
  strokeWeight(0.25);
  if (tr != null) {
    tr.drawQT();
    tl.drawQT();
    br.drawQT();
    bl.drawQT();
  } else {
    mgridRoot.drawOutline();
    if (junk) {
      for (int i = 0; i < segs.size (); i++) {
        stroke(c);
        segs.get(i).drawSeg();
      }
    }
  }
}


public boolean equals(Object other) {
  if (other == null)
  {
    return false;
  }
  if (this.getClass() != other.getClass())
  {
    return false;
  }
  //maxAABBx, maxAABBy, minAABBx, minAABBy
  if (this.minAABBx == ((QuadTree)other).minAABBx && this.maxAABBx == ((QuadTree)other).maxAABBx && this.minAABBy == ((QuadTree)other).minAABBy && this.maxAABBy == ((QuadTree)other).maxAABBy)
  {
    return true;
  } else {
    return false;
  }
}
};

