//cubic Bezier class
//button class
//dropdown menu class


class cubicBezier {
  ArrayList<PVector> anchors;
  ArrayList<PVector> anchors_og;

  ArrayList<PVector> anchors_gray;
  PVector[][] cps;
  PVector[][] cpsG;
  PVector[][] cpsOG;
  ArrayList<PVector> s_anchors = new ArrayList<PVector>();
  PVector[][] s_cps;
  ArrayList<PVector> diff_anchors = new ArrayList<PVector>();
  PVector[][] diff_cps;
  float t = 0.45; //0.45 is optimal; 0.3 ~ geoboard
  pointer ptr;
  ArrayList<pShape2> fillShapes = new ArrayList<pShape2>();
  int mode;
  int first, last;


  cubicBezier(pointer _ptr, int _mode) {
    anchors = new ArrayList<PVector>();
    anchors_og = new ArrayList<PVector>();
    anchors_gray = new ArrayList<PVector>();
    ptr = _ptr;
    mode = _mode;
    first = 0;
    last = anchors.size()-1;
  }

  //from: http://scaledinnovation.com/analytics/splines/aboutSplines.html
  //experiment with t; t=0.5 seems to work well.
  PVector[]  getControlPoints(PVector p0, PVector p1, PVector p2, float t) {
    PVector[] res = new PVector[2];
    double d01 = Math.sqrt(Math.pow(p1.x-p0.x, 2)+Math.pow(p1.y-p0.y, 2));
    double d12 = Math.sqrt(Math.pow(p2.x-p1.x, 2)+Math.pow(p2.y-p1.y, 2));
    double fa = t*d01/(d01+d12);   // scaling factor for triangle Ta
    double fb = t*d12/(d01+d12);   // ditto for Tb, simplifies to fb=t-fa

    res[0] = new PVector((float)(p1.x-fa*(p2.x-p0.x)), (float)(p1.y-fa*(p2.y-p0.y)));
    res[1] = new PVector((float)(p1.x+fb*(p2.x-p0.x)), (float)(p1.y+fb*(p2.y-p0.y)));

    /*res[0].x = (float)(p1.x-fa*(p2.x-p0.x));    // x2-x0 is the width of triangle T
     res[0].y = (float)(p1.y-fa*(p2.y-p0.y));    // y2-y0 is the height of T
     res[1].x = (float)(p1.x+fb*(p2.x-p0.x));
     res[1].y = (float)(p1.y+fb*(p2.y-p0.y));*/

    return res;
  }

  PVector[]  getControlPoints2(PVector p0, PVector p1, PVector p2, float t) {
    PVector[] res = new PVector[2];

    if (nodeLocs.indexOf(p1) == -1 && mids.containsKey((int)p1.y)) {
      res[0] = new PVector(p1.x, p1.y-7); 
      res[1] = new PVector(p1.x, p1.y+7); 
      return res;
    }

    double d01 = Math.sqrt(Math.pow(p1.x-p0.x, 2)+Math.pow(p1.y-p0.y, 2));
    double d12 = Math.sqrt(Math.pow(p2.x-p1.x, 2)+Math.pow(p2.y-p1.y, 2));
    double fa = t*d01/(d01+d12);   // scaling factor for triangle Ta
    double fb = t*d12/(d01+d12);   // ditto for Tb, simplifies to fb=t-fa

    res[0] = new PVector((float)(p1.x-fa*(p2.x-p0.x)), (float)(p1.y-fa*(p2.y-p0.y)));
    res[1] = new PVector((float)(p1.x+fb*(p2.x-p0.x)), (float)(p1.y+fb*(p2.y-p0.y)));

    /*res[0].x = (float)(p1.x-fa*(p2.x-p0.x));    // x2-x0 is the width of triangle T
     res[0].y = (float)(p1.y-fa*(p2.y-p0.y));    // y2-y0 is the height of T
     res[1].x = (float)(p1.x+fb*(p2.x-p0.x));
     res[1].y = (float)(p1.y+fb*(p2.y-p0.y));*/

    return res;
  }

  void calcCPTSOG() {
    PVector[] tmp; 
    if (anchors.size() < 3) {
    } else {
      cpsOG = new PVector[anchors_og.size()][2];
      //iterate through anchors and estimate control points
      for (int i = 0; i < anchors_og.size ()-1; i++) {
        if (i == 0) {
          cpsOG[i][0] = anchors_og.get(0);
          cpsOG[i][1] = anchors_og.get(0);
        } else { 
          tmp = getControlPoints(anchors_og.get(i-1), anchors_og.get(i), anchors_og.get(i+1), t);
          cpsOG[i][0] = tmp[0];
          cpsOG[i][1] = tmp[1];
        }
      }
    }
  }

  void calcCPTS() {
    PVector[] tmp; 
    if (anchors.size() < 3) {
    } else {
      cps = new PVector[anchors.size()][2];
      //iterate through anchors and estimate control points
      for (int i = 0; i < anchors.size ()-1; i++) {
        if (i == 0) {
          cps[i][0] = anchors.get(0);
          cps[i][1] = anchors.get(0);
        } else { 
          tmp = getControlPoints(anchors.get(i-1), anchors.get(i), anchors.get(i+1), t);
          cps[i][0] = tmp[0];
          cps[i][1] = tmp[1];
        }
      }
    }
    calcSecondary();
    calcDiff();
  }

  void calcNewCPTs() {
    PVector[] tmp; 
    if (anchors.size() < 3)return;
    cps = new PVector[anchors.size()][2];
    //iterate through anchors and estimate control points
    for (int i = 0; i < anchors.size ()-1; i++) {
      if (i == 0) {
        cps[i][0] = anchors.get(0);
        cps[i][1] = anchors.get(0);
      } else { 
        tmp = getControlPoints(anchors.get(i-1), anchors.get(i), anchors.get(i+1), t);
        cps[i][0] = tmp[0];
        cps[i][1] = tmp[1];
      }
    }
  }

  void calcNewAnchors() {
    if (mode == 0) {
      routeCPsT = routeCPs;
    } else if (mode == 1) {
      routeCPsT = routeCPs1;
    } else if (mode == 2) {
      routeCPsT = routeCPs2;
    }
    //println("new anchors");
    for (int i = 0; i < anchors_og.size (); i++) {
      if (routeCPsT.containsKey(anchors_og.get(i)) && routeCPsT.get(anchors_og.get(i)).contains(ptr)) {
        //float t = 1.0+(float)(routeCPs.get(_anchors.get(i)).indexOf(ptr))*0.1;
        PVector t = new PVector(diff_anchors.get(i).x, diff_anchors.get(i).y);
        //take average tangent. 
        for (int g = 0; g < routeCPsT.get (anchors_og.get (i)).size(); g++) {
          //if(routeCPsT.get(anchors_og.get(i)).get(g).diff_i(anchors_og.get(i)) == diff_anchors.get(i)){continue;}
          t.add(routeCPsT.get(anchors_og.get(i)).get(g).diff_i(anchors_og.get(i)));
        }
        t.div(routeCPsT.get(anchors_og.get(i)).size());
        float ss = (float)(routeCPsT.get(anchors_og.get(i)).size()-1)/2.0;
        //set max bandwidth
        if (routeCPsT.get(anchors_og.get(i)).size() > 8) {
          //println("exceeding!" + routeCPs.get(anchors_og.get(i)).size());
          t.mult((float)(((float)routeCPsT.get(anchors_og.get(i)).indexOf(ptr))-ss)*(0.07*8/routeCPsT.get(anchors_og.get(i)).size()));
        } else {
          t.mult((float)(((float)routeCPsT.get(anchors_og.get(i)).indexOf(ptr))-ss)*0.07);
        }
        t.add(anchors_og.get(i));
        anchors.set(i, t);
        //anchors.set(i,anchors.get(i));
      } else {
        anchors.set(i, anchors.get(i));
      }
      //println(diff_anchors.get(i).x+" "+diff_anchors.get(i).y);
    }
    calcNewCPTs();
    //calcNewAnchorsGray();
  }

  void calcNewAnchors2() {
    //calcNewAnchorsGray();
  }

  void calcNewAnchorsGray() {
    anchors_gray = anchors_og;  
    for (int i = 0; i < anchors_og.size (); i++) {
      if (routeCPs.containsKey(anchors_og.get(i)) && routeCPs.get(anchors_og.get(i)).contains(ptr)) {
        PVector t = new PVector(diff_anchors.get(i).x, diff_anchors.get(i).y);
        t.mult((float)(routeCPs.get(anchors_og.get(i)).indexOf(ptr))*0.1-0.05);
        t.add(anchors_og.get(i));
        anchors_gray.set(i, t);
      } else {
        anchors_gray.set(i, anchors_og.get(i));
      }
    }
    calcNewCPTsG();
  }

  void calcNewCPTsG() {
    PVector[] tmp; 
    if (anchors_gray.size() < 3)return;
    cpsG = new PVector[anchors_gray.size()][2];
    //iterate through anchors and estimate control points
    for (int i = 0; i < anchors_gray.size ()-1; i++) {
      if (i == 0) {
        cpsG[i][0] = anchors_gray.get(0);
        cpsG[i][1] = anchors_gray.get(0);
      } else { 
        tmp = getControlPoints(anchors_og.get(i-1), anchors_og.get(i), anchors_og.get(i+1), t);
        cpsG[i][0] = tmp[0];
        cpsG[i][1] = tmp[1];
      }
    }
  }

  //this method returns a new control point either x or y
  float invertBezierB(float xy, float a, float c, float d) {    
    float d1 = abs(d-a);
    float d2 = abs(xy-a);
    float t = d2/d1;
    float t1 = 1.0F - t;
    //solve for b
    float b = (xy - a * t1 * t1 * t1 - 3.0F * c * t * t * t1 - d * t * t * t)/(3.0F * t * t1 * t1);
    return b;
  }

  PVector invertBezierB2(PVector xy, PVector a, PVector c, PVector d, int z) {    
    PVector b;
    PVector d1 = new PVector(abs(d.x-a.x), abs(d.y-a.y));
    PVector d2 = new PVector(abs(xy.x-a.x), abs(xy.y-a.y));
    PVector t = new PVector(d2.x/d1.x, d2.y/d1.y);
    PVector t1 = new PVector(1.0F - t.x, 1.0F - t.y);
    //solve for b
    b = new PVector(((xy.x - a.x * t1.x * t1.x * t1.x - 3.0F * c.x * t.x * t.x * t1.x - d.x * t.x * t.x * t.x)/(3.0F * t.x * t1.x * t1.x)), ((xy.y - a.y * t1.y * t1.y * t1.y - 3.0F * c.y * t.y * t.y * t1.y - d.y * t.y * t.y * t.y)/(3.0F * t.y * t1.y * t1.y)) );

    float tx = bezierTangent(xy.x, c.x, c.x, d.x, 0);
    float ty = bezierTangent(xy.y, c.y, c.y, d.y, 0);
    float g = atan2(ty, tx);
    g -= HALF_PI;
    PVector bt = new PVector(cos(g)*20, sin(g)*20);
    bt.mult((float)(routeCPs.get(anchors_og.get(z)).indexOf(ptr))*0.1);
    bt.add(b);
    return b;
  }

  PVector invertBezierC2(PVector xy, PVector a, PVector b, PVector d, int z) {    
    PVector c;
    PVector d1 = new PVector(abs(d.x-a.x), abs(d.y-a.y));
    PVector d2 = new PVector(abs(xy.x-d.x), abs(xy.y-d.y));
    PVector t = new PVector(1.0 - d2.x/d1.x, 1.0 - d2.y/d1.y);
    PVector t1 = new PVector(1.0F - t.x, 1.0F - t.y);
    //solve for b
    c = new PVector(((xy.x - a.x * t1.x * t1.x * t1.x - 3.0F * b.x * t.x * t1.x * t1.x - d.x * t.x * t.x * t.x)/(3.0F * t.x * t.x * t1.x)), ((xy.y - a.y * t1.y * t1.y * t1.y - 3.0F * b.y * t.y * t1.y * t1.y - d.y * t.y * t.y * t.y)/(3.0F * t.y * t.y * t1.y)) );

    float tx = bezierTangent(a.x, b.x, b.x, xy.x, 1);
    float ty = bezierTangent(a.y, b.y, b.y, xy.y, 1);
    float g = atan2(ty, tx);
    g -= HALF_PI;
    PVector ct = new PVector(cos(g)*20, sin(g)*20);
    ct.mult((float)(routeCPs.get(anchors_og.get(z)).indexOf(ptr))*0.1);
    ct.add(c);
    return c;
  }

  //this method returns a new control point either x or y
  float invertBezierC(float xy, float a, float b, float d) {    
    float d1 = abs(d-a);
    float d2 = abs(xy-d);
    float t = 1.0 - d2/d1;
    float t1 = 1.0F - t;
    //solve for c
    float c = (xy - a * t1 * t1 * t1 - 3.0F * b * t * t1 * t1 - d * t * t * t)/(3.0F * t * t * t1);
    return c;
  }

  PVector getPivot(PVector p1, PVector cp1, PVector cp2, PVector p2) {
    float x = bezierPoint(p1.x, cp1.x, cp2.x, p2.x, 0.25);
    float y = bezierPoint(p1.y, cp1.y, cp2.y, p2.y, 0.25);
    return new PVector(x, y);
  }

  void calcSecondary() { //need to avg the tangents
    int dim = 20;
    float last = 1;
    s_anchors.clear();
    for (int i = 0; i < anchors.size (); i++) {
      if (anchors.size() < 3) {
        if (i == 0) {
          float tx = (anchors.get(i+1).x - anchors.get(i).x);
          float ty = (anchors.get(i+1).y - anchors.get(i).y);  
          float a = atan2(ty, tx);
          a -= HALF_PI;
          s_anchors.add(new PVector(cos(a)*dim + anchors.get(i).x, sin(a)*dim + anchors.get(i).y));
        } else if (i == 1) {
          float tx = (anchors.get(i).x - anchors.get(i-1).x);
          float ty = (anchors.get(i).y - anchors.get(i-1).y);  
          float a = atan2(ty, tx);
          a -= HALF_PI;
          s_anchors.add(new PVector(cos(a)*dim + anchors.get(i).x, sin(a)*dim + anchors.get(i).y));
        }
      } else {
        if (i == 0) {
          //vertex(anchors.get(i).x, anchors.get(i).y);
          //s_anchors.add(anchors.get(i));
          float x = bezierPoint(anchors.get(i).x, cps[i+1][0].x, cps[i+1][1].x, anchors.get(i+1).x, 0);
          float y = bezierPoint(anchors.get(i).y, cps[i+1][0].y, cps[i+1][1].y, anchors.get(i+1).y, 0);
          float tx = bezierTangent(anchors.get(i).x, cps[i+1][0].x, cps[i+1][1].x, anchors.get(i+1).x, 0);
          float ty = bezierTangent(anchors.get(i).y, cps[i+1][0].y, cps[i+1][1].y, anchors.get(i+1).y, 0);
          float a = atan2(ty, tx);
          a -= HALF_PI;
          s_anchors.add(new PVector(cos(a)*dim + x, sin(a)*dim + y));
          last = a;
        } else if (i == anchors.size()-1) {
          float x = bezierPoint(anchors.get(i-1).x, cps[i-1][0].x, cps[i-1][1].x, anchors.get(i).x, 1);
          float y = bezierPoint(anchors.get(i-1).y, cps[i-1][0].y, cps[i-1][1].y, anchors.get(i).y, 1);
          float tx = bezierTangent(anchors.get(i-1).x, cps[i-1][0].x, cps[i-1][1].x, anchors.get(i).x, 1);
          float ty = bezierTangent(anchors.get(i-1).y, cps[i-1][0].y, cps[i-1][1].y, anchors.get(i).y, 1);
          float a = atan2(ty, tx);
          a -= HALF_PI;
          s_anchors.add(new PVector(cos(a)*dim + x, sin(a)*dim + y));
          //last = a;
        } else {
          //avg from both sides
          float x = bezierPoint(anchors.get(i-1).x, cps[i-1][1].x, cps[i][0].x, anchors.get(i).x, 0.9);
          float y = bezierPoint(anchors.get(i-1).y, cps[i-1][1].y, cps[i][0].y, anchors.get(i).y, 0.9);
          float tx = bezierTangent(anchors.get(i-1).x, cps[i-1][1].x, cps[i][0].x, anchors.get(i).x, 0.9);
          float ty = bezierTangent(anchors.get(i-1).y, cps[i-1][1].y, cps[i][0].y, anchors.get(i).y, 0.9);
          float a = atan2(ty, tx);
          //a -= HALF_PI;

          if (i < anchors.size()-2) {
            float x2 = bezierPoint(anchors.get(i).x, cps[i][1].x, cps[i+1][0].x, anchors.get(i+1).x, 0.1);
            float y2 = bezierPoint(anchors.get(i).y, cps[i][1].y, cps[i+1][0].y, anchors.get(i+1).y, 0.1);
            float tx2 = bezierTangent(anchors.get(i).x, cps[i][1].x, cps[i+1][0].x, anchors.get(i+1).x, 0.1);
            float ty2 = bezierTangent(anchors.get(i).y, cps[i][1].y, cps[i+1][0].y, anchors.get(i+1).y, 0.1);
            float a2 = atan2(ty2, tx2);
            //a2 -= HALF_PI;
            x = (x+x2)/2.0;
            y = (y+y2)/2.0;
            a = (a+a2)/2.0;
            //x = x2;
            //y = y2;
            //a = a2;
            //println((a-a2));
            //println("b: "+(x-x2));

            a -= HALF_PI;
          } else {
            a -= HALF_PI;
          }


          s_anchors.add(new PVector(cos(a)*dim + x, sin(a)*dim + y));


          //s_anchors.add(new PVector(((cos(a)+cos(last))/2)*dim + x, ((sin(a)+sin(last))/2)*dim + y));
          //popMatrix();
          //last = a;
        }
      }
    } 
    //calc secondary controlPts
    PVector[] tmp; 
    if (s_anchors.size() < 3)return;
    s_cps = new PVector[s_anchors.size()][2];
    //iterate through anchors and estimate control points
    for (int i = 0; i < s_anchors.size ()-1; i++) {
      if (i == 0) {
        s_cps[i][0] = s_anchors.get(0);
        s_cps[i][1] = s_anchors.get(0);
      } else { 
        tmp = getControlPoints(s_anchors.get(i-1), s_anchors.get(i), s_anchors.get(i+1), t);
        s_cps[i][0] = tmp[0];
        s_cps[i][1] = tmp[1];
      }
    }
  }

  void calcDiff() {
    diff_anchors.clear();
    if (anchors.size() != s_anchors.size()) {
      println("anchor/s_anchor size issue"); 
      return;
    }
    for (int i = 0; i < anchors.size (); i++) {
      diff_anchors.add(new PVector(s_anchors.get(i).x-anchors.get(i).x, s_anchors.get(i).y-anchors.get(i).y));
    }
    if (anchors.size() > 2) {
      diff_cps = new PVector[cps.length][2];
      for (int i = 0; i < cps.length; i++) {
        if (cps[i][0] == null && cps[i][1] == null) {
          diff_cps[i][0] = cps[i][0];
          diff_cps[i][1] = cps[i][1];
        } else {
          diff_cps[i][0] = new PVector(s_cps[i][0].x - cps[i][0].x, s_cps[i][0].y - cps[i][0].y);
          diff_cps[i][1] = new PVector(s_cps[i][1].x - cps[i][1].x, s_cps[i][1].y - cps[i][1].y);
        }
      }
    }
  }

  void drawBezierG() { 
    noFill();
    beginShape();
    for (int i = 0; i < anchors_gray.size (); i++) {
      //ellipse(anchors.get(i).x, anchors.get(i).y, 5,5);    
      if (anchors_gray.size() < 3) {
        vertex(anchors_gray.get(i).x, anchors_gray.get(i).y);
      } else {
        if (i == 0) {
          vertex(anchors_gray.get(i).x, anchors_gray.get(i).y);
        } else if (i == anchors_gray.size()-1) {
          bezierVertex(cpsG[i-1][1].x, cpsG[i-1][1].y, anchors_gray.get(i).x, anchors_gray.get(i).y, anchors_gray.get(i).x, anchors_gray.get(i).y);
        } else {
          bezierVertex(cpsG[i-1][1].x, cpsG[i-1][1].y, cpsG[i][0].x, cpsG[i][0].y, anchors_gray.get(i).x, anchors_gray.get(i).y);
        }
      }
    }
    endShape();
  }

  int getLast() {
    for (int j = anchors.size ()-1; j > 0; j-=1) {
      if (mode == 0) { 
        if (anchors.get(j).y + pScroll < lfilt.y+5 && pNodes.contains(anchors_og.get(j))) {
          last = j;
          return j;
        } else {
          continue;
        }
      } else if (mode == 1) {
        if (anchors.get(j).y + pScroll < lfilt.y+5 && pNodes1.contains(anchors_og.get(j))) {
          last = j;
          return j;
        } else {
          continue;
        }
      } else if (mode== 2) {
        if (anchors.get(j).y + pScroll < lfilt.y+5 && pNodes2.contains(anchors_og.get(j))) {
          last = j;
          return j;
        } else {
          continue;
        }
      }
    }
    return 0;
  }

  int getFirst() {
    for (int i = 0; i < anchors.size (); i++) {
      if (anchors.get(i).y < hfilt.y+5)continue;
      if (mode == 0) {
        if (!pNodes.contains(anchors_og.get(i)))continue;
        first = i;
        return i;
      } else if (mode == 1) {
        if (!pNodes1.contains(anchors_og.get(i)))continue;
        first = i;
        return i;
      } else if (mode == 2) {
        if (!pNodes2.contains(anchors_og.get(i)))continue;
        first = i;
        return i;
      } else {
        first = 0;
        return 0;
      }
    }
    return 0;
  }

  PVector[] getFirstLast() {
    PVector[] n = {
      anchors.get(getFirst()), anchors.get(getLast())
    };
    return n;
  }

void drawHballB() {
    boolean first = true;
    //int l = getFirst();
    int m = getLast();
    if (m == 0) {
      return;
    }
    beginShape();
    for (int i = 0; i < anchors_og.size (); i++) {
      if (anchors_og.get(i).y < hfilt.y+5)continue;
      if (i > m) { //broken!
        continue;
      }  
      if (anchors_og.size() < 3) {   
        vertex(anchors_og.get(i).x, anchors_og.get(i).y);
      } else {
        if (first) {
          if (mode == 0) {
            if (!pNodes.contains(anchors_og.get(i)))continue;
          } else if (mode == 1) {
            if (!pNodes1.contains(anchors_og.get(i)))continue;
          } else if (mode == 2) {
            if (!pNodes2.contains(anchors_og.get(i)))continue;
          }
          first = false;
          vertex(anchors_og.get(i).x, anchors_og.get(i).y);
        } else if (i == anchors_og.size()-1) {
          bezierVertex(cpsOG[i-1][1].x, cpsOG[i-1][1].y, anchors_og.get(i).x, anchors_og.get(i).y, anchors_og.get(i).x, anchors_og.get(i).y);
        } else {
          bezierVertex(cpsOG[i-1][1].x, cpsOG[i-1][1].y, cpsOG[i][0].x, cpsOG[i][0].y, anchors_og.get(i).x, anchors_og.get(i).y);
        }
      }
    }
  endShape();
}

void drawBezier() { 
  if (hball_b._selected) {
    drawHballB();
    return;
  }  
  boolean first = true;
  //int l = getFirst();
  int m = getLast();
  //int m = anchors_og.size()-1;
  if (m == 0) {
    return;
  }
  //line(anchors_og.get(0).x,anchors_og.get(0).y,anchors.get(0).x,anchors.get(0).y);

  /*if(anchors.size() > 1 && cps.length > 1 && cps[1][0] != null && cps[1][1] != null){
   PVector piv = getPivot(anchors.get(0),cps[1][0], cps[1][1], anchors.get(1));
   }*/
  //println(diff_anchors.size());

  beginShape();
  for (int i = 0; i < anchors.size (); i++) {
    if (anchors.get(i).y + pScroll < hfilt.y+5)continue;
    if (i > m) { //broken!
      continue;
    }
    //if((anchors.get(i).y > lfilt.y+5))continue; 
    //ellipse(anchors.get(i).x, anchors.get(i).y, 5,5);    
    if (anchors.size() < 3) {
      /*if (first) {
       if(!pNodes.contains(anchors_og.get(i)))continue;
       first = false;
       vertex(anchors_og.get(i).x, anchors_og.get(i).y);
       continue;
       }
       if(i == anchors.size()-1){
       vertex(anchors_og.get(i).x, anchors_og.get(i).y);
       }else{
       vertex(anchors.get(i).x, anchors.get(i).y);
       }*/
      //vertex(anchors.get(i).x, anchors.get(i).y);
      vertex(anchors_og.get(i).x, anchors_og.get(i).y);
    } else {
      if (first) {
        if (mode == 0) {
          if (!pNodes.contains(anchors_og.get(i)))continue;
        } else if (mode == 1) {
          if (!pNodes1.contains(anchors_og.get(i)))continue;
        } else if (mode == 2) {
          if (!pNodes2.contains(anchors_og.get(i)))continue;
        }
        first = false;
        vertex(anchors_og.get(i).x, anchors_og.get(i).y);
      } else if (i == anchors.size()-1) {
        bezierVertex(cps[i-1][1].x, cps[i-1][1].y, anchors.get(i).x, anchors.get(i).y, anchors_og.get(i).x, anchors_og.get(i).y);
      } else {
        //println("sz: "+ptr.bundleCps.size());
        if (ptr.bundleCps.containsKey(anchors_og.get(i))) {

          float c1x = 0;
          float c1y = 0;
          PVector c1 = cps[i-1][1];
          if (ptr.bundleCps.containsKey(anchors_og.get(i-1))) {  
            PVector pa = (ptr.bundleCps.get(anchors_og.get(i-1))[1] != null) ? ptr.bundleCps.get(anchors_og.get(i-1))[1] : cps[i-1][1];

            //c1 = invertBezierB2(pa, anchors.get(i-1), cps[i][0], anchors.get(i), i-1);
            /*float tx = bezierTangent(anchors.get(i-1).x, cps[i-1][1].x, cps[i][0].x, anchors.get(i).x, 1);
             float ty = bezierTangent(anchors.get(i-1).y, cps[i-1][1].y, cps[i][0].y, anchors.get(i).y, 1);
             float a = atan2(ty, tx);
             a -= HALF_PI;
             s_anchors.add(new PVector(cos(a)*dim + x, sin(a)*dim + y));*/


            //c1x = invertBezierB(pa.x, anchors.get(i-1).x, cps[i][0].x, anchors.get(i).x);
            //c1y = invertBezierB(pa.y, anchors.get(i-1).y, cps[i][0].y, anchors.get(i).y);
          } else {
            c1x = cps[i-1][1].x;
            c1y = cps[i-1][1].y;
          }

          PVector pb = (ptr.bundleCps.get(anchors_og.get(i))[0] != null) ? ptr.bundleCps.get(anchors_og.get(i))[0] : cps[i][0];

          //PVector c2 = invertBezierC2(pb, anchors.get(i-1), cps[i-1][1], anchors.get(i), i);

          //float c2x = invertBezierC(pb.x, anchors.get(i-1).x, cps[i-1][1].x, anchors.get(i).x);
          //float c2y = invertBezierC(pb.y, anchors.get(i-1).y, cps[i-1][1].y, anchors.get(i).y);

          //bezierVertex(c1.x, c1.y, c2.x, c2.y, anchors.get(i).x, anchors.get(i).y);
          //line(anchors.get(i-1).x,anchors.get(i-1).y,c1.x, c1.y);
          //line(c2.x, c2.y, anchors.get(i).x, anchors.get(i).y);
          bezierVertex(cps[i-1][1].x, cps[i-1][1].y, cps[i][0].x, cps[i][0].y, anchors.get(i).x, anchors.get(i).y);

          //ellipse(cps[i-1][1].x,cps[i-1][1].y,5,5);
          //ellipse(cps[i][0].x,cps[i][0].y,5,5);
          //line(anchors_og.get(i).x, anchors_og.get(i).y,anchors.get(i).x+diff_anchors.get(i).x*1, anchors.get(i).y+diff_anchors.get(i).y*1);
        } else {
          bezierVertex(cps[i-1][1].x, cps[i-1][1].y, cps[i][0].x, cps[i][0].y, anchors.get(i).x, anchors.get(i).y);
          //line(anchors_og.get(i).x, anchors_og.get(i).y,anchors.get(i).x+diff_anchors.get(i).x*1, anchors.get(i).y+diff_anchors.get(i).y*1);
          //println("please: "+i+" "+diff_anchors.get(i).x + " "+ diff_anchors.get(i).y);
          //ellipse(cps[i-1][1].x,cps[i-1][1].y,5,5);
          //ellipse(cps[i][0].x,cps[i][0].y,5,5);
        }
        //bezierVertex(cps[i-1][1].x, cps[i-1][1].y, cps[i][0].x, cps[i][0].y, anchors.get(i).x, anchors.get(i).y);
      }
    }
  }
  endShape();
  //line(anchors.get(anchors.size()-1).x,anchors.get(anchors.size()-1).y,anchors_og.get(anchors_og.size()-1).x,anchors_og.get(anchors_og.size()-1).y); 
  //drawReg();
}

void drawBezierPDF(PGraphics pdf) { 
  if (hball_b._selected) {
    drawHballB();
    return;
  }  
  boolean first = true;
  //int l = getFirst();
  //int m = getLast();
  int m = anchors_og.size()-1;
  if (m == 0) {
    return;
  }
  //line(anchors_og.get(0).x,anchors_og.get(0).y,anchors.get(0).x,anchors.get(0).y);

  /*if(anchors.size() > 1 && cps.length > 1 && cps[1][0] != null && cps[1][1] != null){
   PVector piv = getPivot(anchors.get(0),cps[1][0], cps[1][1], anchors.get(1));
   }*/
  //println(diff_anchors.size());

  pdf.beginShape();
  for (int i = 0; i < anchors.size (); i++) {
    //if (anchors.get(i).y + pScroll < hfilt.y+5)continue;
    if (i > m) { //broken!
      continue;
    }
    //if((anchors.get(i).y > lfilt.y+5))continue; 
    //ellipse(anchors.get(i).x, anchors.get(i).y, 5,5);    
    if (anchors.size() < 3) {
      /*if (first) {
       if(!pNodes.contains(anchors_og.get(i)))continue;
       first = false;
       vertex(anchors_og.get(i).x, anchors_og.get(i).y);
       continue;
       }
       if(i == anchors.size()-1){
       vertex(anchors_og.get(i).x, anchors_og.get(i).y);
       }else{
       vertex(anchors.get(i).x, anchors.get(i).y);
       }*/
      //vertex(anchors.get(i).x, anchors.get(i).y);
      pdf.vertex(anchors_og.get(i).x, anchors_og.get(i).y);
    } else {
      if (first) {
        if (mode == 0) {
          if (!pNodes.contains(anchors_og.get(i)))continue;
        } else if (mode == 1) {
          if (!pNodes1.contains(anchors_og.get(i)))continue;
        } else if (mode == 2) {
          if (!pNodes2.contains(anchors_og.get(i)))continue;
        }
        first = false;
        pdf.vertex(anchors_og.get(i).x, anchors_og.get(i).y);
      } else if (i == anchors.size()-1) {
        pdf.bezierVertex(cps[i-1][1].x, cps[i-1][1].y, anchors.get(i).x, anchors.get(i).y, anchors_og.get(i).x, anchors_og.get(i).y);
      } else {
        //println("sz: "+ptr.bundleCps.size());
        if (ptr.bundleCps.containsKey(anchors_og.get(i))) {

          float c1x = 0;
          float c1y = 0;
          PVector c1 = cps[i-1][1];
          if (ptr.bundleCps.containsKey(anchors_og.get(i-1))) {  
            PVector pa = (ptr.bundleCps.get(anchors_og.get(i-1))[1] != null) ? ptr.bundleCps.get(anchors_og.get(i-1))[1] : cps[i-1][1];
          } else {
            c1x = cps[i-1][1].x;
            c1y = cps[i-1][1].y;
          }

          PVector pb = (ptr.bundleCps.get(anchors_og.get(i))[0] != null) ? ptr.bundleCps.get(anchors_og.get(i))[0] : cps[i][0];
          pdf.bezierVertex(cps[i-1][1].x, cps[i-1][1].y, cps[i][0].x, cps[i][0].y, anchors.get(i).x, anchors.get(i).y);
        } else {
          pdf.bezierVertex(cps[i-1][1].x, cps[i-1][1].y, cps[i][0].x, cps[i][0].y, anchors.get(i).x, anchors.get(i).y);
        }
      }
    }
  }
  pdf.endShape();
  //line(anchors.get(anchors.size()-1).x,anchors.get(anchors.size()-1).y,anchors_og.get(anchors_og.size()-1).x,anchors_og.get(anchors_og.size()-1).y); 
  //drawReg();
}

void drawReg() {
  int last = 0;
  beginShape();
  if (anchors.size() < 1)return;
  curveVertex(anchors.get(0).x, anchors.get(0).y);
  for (int i = 0; i < anchors.size (); i++) {
    /*if((i > 0 && abs(anchors.get(i).dist(anchors.get(last))) > 10) || i == 0 || i == anchors.size()-1){
     curveVertex(anchors.get(i).x, anchors.get(i).y);
     last = i;
     }*/
    curveVertex(anchors.get(i).x, anchors.get(i).y);
    //ellipse(anchors.get(i).x, anchors.get(i).y,5,5); 
    /*if(i < anchors.size()-4){
     curveVertex((curvePoint(anchors.get(i).x,anchors.get(i+1).x,anchors.get(i+2).x,anchors.get(i+3).x, 0.1)),(curvePoint(anchors.get(i).y,anchors.get(i+1).y,anchors.get(i+2).y,anchors.get(i+3).y, 0.1)));
     }*/
    /*if(ptr.bundleCps.containsKey(anchors.get(i))){
     ellipse(anchors.get(i).x, anchors.get(i).y,5,5); 
     }*/
  }
  curveVertex(anchors.get(anchors.size()-1).x, anchors.get(anchors.size()-1).y);
  endShape();
}


void drawBezierFill() { 
  fillShapes.clear();
  beginShape();
  for (int i = 0; i < anchors.size (); i++) {        
    if (anchors.size() < 3) {
      vertex(anchors.get(i).x, anchors.get(i).y);
    } else {
      if (i == 0) {
        vertex(anchors.get(i).x, anchors.get(i).y);
        fillShapes.add(new pShape2());
        fillShapes.get(fillShapes.size()-1).v1 = anchors.get(i);
      } else if (i == anchors.size()-1) {
        bezierVertex(cps[i-1][1].x, cps[i-1][1].y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
      } else {
        if (i < 4) {
          fillShapes.get(fillShapes.size()-1).bvs.add(new pBezierVertex(cps[i-1][1], cps[i][0], anchors.get(i)));
        } else {
        }
        bezierVertex(cps[i-1][1].x, cps[i-1][1].y, cps[i][0].x, cps[i][0].y, anchors.get(i).x, anchors.get(i).y);
      }
    }
    //if(junk){
    //ellipse(anchors.get(i).x,anchors.get(i).y,3,3);
    //}
  }
  endShape();
  for (int i = 0; i < fillShapes.size (); i++) {
    fillShapes.get(i).drawShape();
  }
}

void drawSecondaryBezier() { 
  beginShape();
  for (int i = 0; i < s_anchors.size (); i++) {
    if (s_anchors.size() < 3) {
      vertex(s_anchors.get(i).x, s_anchors.get(i).y);
    } else {
      if (i == 0) {
        vertex(s_anchors.get(i).x, s_anchors.get(i).y);
      } else if (i == s_anchors.size()-1) {
        bezierVertex(s_cps[i-1][1].x, s_cps[i-1][1].y, s_anchors.get(i).x, s_anchors.get(i).y, s_anchors.get(i).x, s_anchors.get(i).y);
      } else {
        bezierVertex(s_cps[i-1][1].x, s_cps[i-1][1].y, s_cps[i][0].x, s_cps[i][0].y, s_anchors.get(i).x, s_anchors.get(i).y);
      }
    }
  }
  endShape();
}

void drawBezierDiff(float order) { 
  //float order = 1.4;
  beginShape();
  for (int i = 0; i < anchors.size (); i++) {
    if (anchors.size() < 3) {
      vertex(anchors.get(i).x+(diff_anchors.get(i).x*order), anchors.get(i).y+(diff_anchors.get(i).y*order));
    } else {
      if (i == 0) {
        vertex(anchors.get(i).x+(diff_anchors.get(i).x*order), anchors.get(i).y+(diff_anchors.get(i).y*order));
      } else if (i == anchors.size()-1) {
        bezierVertex(cps[i-1][1].x + (diff_cps[i-1][1].x*order), cps[i-1][1].y + (diff_cps[i-1][1].y*order), anchors.get(i).x+(diff_anchors.get(i).x*order), anchors.get(i).y+(diff_anchors.get(i).y*order), anchors.get(i).x+(diff_anchors.get(i).x*order), anchors.get(i).y+(diff_anchors.get(i).y*order));
      } else {
        bezierVertex(cps[i-1][1].x+(diff_cps[i-1][1].x*order), cps[i-1][1].y+(diff_cps[i-1][1].y*order), cps[i][0].x+(diff_cps[i][0].x*order), cps[i][0].y+(diff_cps[i][0].y*order), anchors.get(i).x+diff_anchors.get(i).x*order, anchors.get(i).y+diff_anchors.get(i).y*order);
      }
    }
  }
  endShape();
}

void drawHalfBezier(PVector p1, PVector p2) {
  int a = anchors_og.indexOf(p1);
  int b = anchors_og.indexOf(p2);
  if (a == -1 || b == -1) { 
    println("V not found"); 
    return;
  }
  fill(200, 60);
  noStroke();
  if (a < b) { //forward
    beginShape();
    vertex(p1.x, p1.y);
    for (int i = a+1; i < b+1; i++) {
      if (i == anchors.size()-1) {
        bezierVertex(cps[i-1][1].x, cps[i-1][1].y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
      } else {
        bezierVertex(cps[i-1][1].x, cps[i-1][1].y, cps[i][0].x, cps[i][0].y, anchors.get(i).x, anchors.get(i).y);
      }
    }
    vertex(p2.x, p2.y);
    endShape();
  } else { //backward
    println("backwards");
    beginShape();
    vertex(p1.x, p1.y);
    for (int i = a-1; i >= b; i -= 1) {
      println(i);
      if (i == 0) {
        bezierVertex(cps[i+1][0].x, cps[i+1][0].y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
      } else if (i == anchors.size()-2) {
        bezierVertex(cps[i][1].x, cps[i][1].y, cps[i][1].x, cps[i][1].y, anchors.get(i).x, anchors.get(i).y);
      } else {
        bezierVertex(cps[i+1][0].x, cps[i+1][0].y, cps[i][1].x, cps[i][1].y, anchors.get(i).x, anchors.get(i).y);
      }
    }
    vertex(p2.x, p2.y);
    endShape();
  }
  noFill();
}


ArrayList<pBezierVertex> getBvs(PVector p1, PVector p2) {
  ArrayList<pBezierVertex> BVS = new ArrayList<pBezierVertex>();
  int a = anchors_og.indexOf(p1);
  int b = anchors_og.indexOf(p2);
  if (a == -1 || b == -1) { 
    //println("V not found"); 
    return BVS;
  }

  if (cps == null) {
    return BVS;
  }

  //fill(200,60);
  //noStroke();
  if (a < b) { //forward
    //vertex(p1.x, p1.y);
    for (int i = a; i < b+1; i++) {
      if (i == 0) {
        //BVS.add(new pBezierVertex(cps[i-1][1],anchors.get(i),anchors.get(i)));
      } else if (i == anchors.size()-1 && cps != null) {
        BVS.add(new pBezierVertex(cps[i-1][1], anchors.get(i), anchors.get(i)));
        //bezierVertex(cps[i-1][1].x, cps[i-1][1].y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
      } else {
        BVS.add(new pBezierVertex(cps[i-1][1], cps[i][0], anchors.get(i)));
        //bezierVertex(cps[i-1][1].x, cps[i-1][1].y, cps[i][0].x, cps[i][0].y, anchors.get(i).x, anchors.get(i).y);
      }
    }
  } else { //backward    
    for (int i = a-1; i >= b; i -= 1) {
      if (i == 0) {
        BVS.add(new pBezierVertex(cps[i+1][0], anchors.get(i), anchors.get(i)));
        //bezierVertex(cps[i+1][0].x, cps[i+1][0].y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
      } else if (i == anchors.size()-2) {
        BVS.add(new pBezierVertex(cps[i][1], cps[i][1], anchors.get(i)));
        //bezierVertex(cps[i][1].x, cps[i][1].y, cps[i][1].x, cps[i][1].y, anchors.get(i).x, anchors.get(i).y);
      } else {
        BVS.add(new pBezierVertex(cps[i+1][0], cps[i][1], anchors.get(i)));
        //bezierVertex(cps[i+1][0].x, cps[i+1][0].y, cps[i][1].x, cps[i][1].y, anchors.get(i).x, anchors.get(i).y);
      }
    }
    //vertex(p2.x, p2.y);
  }
  return BVS;
}


void drawHalfBezierA(PVector p1, PVector p2) {
  int a = anchors_og.indexOf(p1);
  int b = anchors_og.indexOf(p2);
  if (a == -1 || b == -1) { 
    //println("V not found"); 
    return;
  }
  //beginShape();
  //vertex(p1.x, p1.y);
  for (int i = a+1; i < b+1; i++) {
    if (i == anchors.size()-1) {
      bezierVertex(cps[i-1][1].x, cps[i-1][1].y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
    } else if (i == 0) {
      vertex(anchors.get(i).x, anchors.get(i).y);
    } else {
      bezierVertex(cps[i-1][1].x, cps[i-1][1].y, cps[i][0].x, cps[i][0].y, anchors.get(i).x, anchors.get(i).y);
    }
  }
  //endShape();
  //noFill();
}
void drawHalfBezierB(PVector p1, PVector p2) {
  int a = anchors_og.indexOf(p1);
  int b = anchors_og.indexOf(p2);
  if (a == -1 || b == -1) { 
    println("V not found"); 
    return;
  }
  for (int i = b; i > a+1; i--) {
    if (i == anchors.size()-1) {
      bezierVertex(cps[i-1][1].x, cps[i-1][1].y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
    } else if (i == 0) {
      vertex(anchors.get(i).x, anchors.get(i).y);
    } else {
      bezierVertex(cps[i-1][1].x, cps[i-1][1].y, cps[i][0].x, cps[i][0].y, anchors.get(i).x, anchors.get(i).y);
    }
  }
  //endShape();
  //noFill();
}

void drawPartialBezier2(int dir, PVector p1, PVector p2) {
  int a = anchors.indexOf(p1);
  int b = anchors.indexOf(p2);
  if (a == -1 || b == -1) { 
    println("V not found"); 
    return;
  }
  int c = (a > 0) ? a-1 : a; //extend one point out to capture complete curve;
  int d = (b < anchors.size()-1) ? b+1 : b;
  if (dir == 0) {
    if (c == 0) {
      bezierVertex(anchors.get(c).x, anchors.get(c).y, anchors.get(c).x, anchors.get(c).y, anchors.get(c).x, anchors.get(c).y);
    } else {
      bezierVertex(cps[c-1][1].x, cps[c-1][1].y, cps[c][0].x, cps[c][0].y, anchors.get(c).x, anchors.get(c).y);
    }
    for (int i = a; i < b+1; i++) {
      if (i == 0) {
        bezierVertex(anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
      } else if (i == anchors.size()-1) {
        bezierVertex(cps[i-1][1].x, cps[i-1][1].y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
      } else {
        //control pt 1, control pt 2, anchor pt
        bezierVertex(cps[i-1][1].x, cps[i-1][1].y, cps[i][0].x, cps[i][0].y, anchors.get(i).x, anchors.get(i).y);
      }
    }
  } else if (dir == 1) {
    for (int i = b; i > a-1; i--) {
      if (i == 0) {
        bezierVertex(anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
      } else if (i > anchors.size()-3) {
        bezierVertex(cps[i-1][1].x, cps[i-1][1].y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
      } else {
        //control pt 1, control pt 2, anchor pt
        bezierVertex(cps[i+1][1].x, cps[i+1][1].y, cps[i][0].x, cps[i][0].y, anchors.get(i).x, anchors.get(i).y);
      }
    }
    if (c == 0) {
      bezierVertex(anchors.get(c).x, anchors.get(c).y, anchors.get(c).x, anchors.get(c).y, anchors.get(c).x, anchors.get(c).y);
    } else {
      bezierVertex(cps[c-1][1].x, cps[c-1][1].y, cps[c][0].x, cps[c][0].y, anchors.get(c).x, anchors.get(c).y);
    }
  }
}

void drawPartialBezier(int dir, PVector p1, PVector p2) {
  //i indicates down or up (0:1);
  if (dir == 0) {
    boolean start = false;
    for (int i = 0; i < anchors.size (); i++) {
      if (anchors.get(i).equals(p1)) { 
        start = true;
      } else if (anchors.get(i).equals(p2)) { 
        start = false;
      }

      if (start) {
        if (i == 0) {
          bezierVertex(anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
        } else if (i == anchors.size()-1) {
          bezierVertex(cps[i-1][1].x, cps[i-1][1].y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
        } else {
          //control pt 1, control pt 2, anchor pt
          bezierVertex(cps[i-1][1].x, cps[i-1][1].y, cps[i][0].x, cps[i][0].y, anchors.get(i).x, anchors.get(i).y);
        }
      }
    }
  } else if (dir == 1) {
    boolean start = false;
    for (int i = anchors.size ()-1; i > -1; i--) {

      if (start) {
        if (i == 0) {
          bezierVertex(cps[i+1][1].x, cps[i+1][1].y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
        } else if (i > anchors.size()-3) {
          bezierVertex(anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y, anchors.get(i).x, anchors.get(i).y);
        } else {
          //control pt 1, control pt 2, anchor pt
          bezierVertex(cps[i+1][1].x, cps[i+1][1].y, cps[i][0].x, cps[i][0].y, anchors.get(i).x, anchors.get(i).y);
        }
      }

      if (anchors.get(i).equals(p2)) {
        start = true;
      } else if (anchors.get(i).equals(p1)) {
        start = false;
      }
    }
  }
}
};


class mbutton {
  int _x, _y, _dx, _dy; //loc and dimensions
  boolean _hover = false;
  boolean _selected = false;
  String _title;

  mbutton(int x, int y, String title) {
    _x = x;
    _y = y;
    _title = title;
    _dx = (int)textWidth(_title)+10;
    _dy = 16;
  }


  void drawButton() {
    isHover(); 
    rectMode(CORNERS);
    if (_hover) {
      stroke(LT_BLUE);
      strokeWeight(2);
    } else if (_selected) {
      strokeWeight(0.5);
      stroke(DRK_BLUE);
    } else {
      stroke(200);
      strokeWeight(1);
    }
    if (_selected && !_title.equals("clear")) {
      fill(LT_BLUE);
    } else {
      fill(LT_BLUE2);
    }
    /*if(_title.equals("1  ") || _title.equals("2  ") || _title.equals("3  ") || _title.equals("4  ")){
     ellipse(_x, _y,_dx,_dx);
     }else{
     rect(_x, _y, _x+_dx, _y+_dy); 
     }*/
    rect(_x, _y, _x+_dx+2, _y+_dy, 4); 
    fill(DRK_BLUE);
    //textFont( _pixel_font_10 );
    textAlign(LEFT, CENTER);
    textSize(10);
    text(_title, _x + 10, _y + 6);
    textFont( _pixel_font_8 );
  }

  void isHover() {
    if ((mouseX >= _x && mouseX <= _x + _dx && mouseY >= _y && mouseY <= _y + _dy)) {
      _hover = true;
    } else {
      _hover = false;
    }
  }

  void clicked() {
    if (_hover) {
      //_selected = !_selected;
      customFunction();
    }
  }

  void customFunction() {
    if (_title.equals("beautiful mess")) {
      cursor(WAIT);
      _selected = !_selected;
      if (_selected) {
        for (int r = 0; r < _text_view.rhymes.size (); r++) {
          if(!_text_view.rhymes.get(r).out){
          _text_view.rhymes.get(r).addSet();
          }
        }
      } else if (!_selected) {
        for (int r = 0; r < _text_view.rhymes.size (); r++) {
          _text_view.rhymes.get(r).removeSet();
        }
      }
      cursor(ARROW);
    } else if (_title.equals("show words") || _title.equals("show uncertainty") || _title.equals("show context") || _title.equals("fill intersecting paths") || _title.equals("nodes")) {
      _selected = !_selected;
    } else if (_title.equals("clear")) {
      _selected = !_selected;
      _text_view.clearAll();
      //have to clear nodes as well...
      _selected = false;
    } else if (_title.equals("shuffle")) {
      //_selected = !_selected;
      clear_b.customFunction();
      for (int n = 0; n < nodeLocs.size (); n++) {
        nodeLocs.get(n)._word.shuffle();
      }
      _text_view.refresh();
      //have to clear nodes as well...
      _selected = false;
    } else if (_title.equals("hover word")) {
      _selected = !_selected;
      //need to clear words if !selected
    } else if (_title.equals("custom set")) {
      _selected = !_selected;
      if (_selected) {
        println("new custom set!");
        String name = "cstm"+RhymeSets.get(RhymeSets.size()-1).size();
        //create new set to add to
        customSets.add(new Set(RhymeSets.size()-1, name));
      } else if (!_selected) {
        if (customSets.get(customSets.size()-1)._wrds.size() > 0) {
          RhymeSets.get(RhymeSets.size()-1).add(customSets.get(customSets.size()-1)); 
          //_text_view.updateCustom();
          _text_view.rhymes.get(_text_view.rhymes.size()-1).addCustom();
          _text_view.pgraph.updateForCustom();
        }
        customSets.clear();
      }
    } else if (_title.equals("1  ")) {
      _selected = true;
      mode = 0;
      m2_b._selected = false;
      m3_b._selected = false;
      //_text_view.refresh();
      //m4_b._selected = false;
    } else if (_title.equals("2  ")) {
      mode = 1;
      _selected = true;
      m1_b._selected = false;
      m3_b._selected = false;
      //_text_view.refresh();
      //m4_b._selected = false;
    } else if (_title.equals("3  ")) {
      mode = 2;
      _selected = true;
      m1_b._selected = false;
      m2_b._selected = false;
      //_text_view.refresh();
      //m4_b._selected = false;
    } else if (_title.equals("4  ")) {
      mode = 3;
      _selected = true;
      m1_b._selected = false;
      m2_b._selected = false;
      //m3_b._selected = false;
    }
  }
}; //end button class

class dropdown {
  float scrollPos = 0;
  float x, y, maxLength;
  String displayName;
  int size; 
  ArrayList<String> prons;
  int[] hover;
  Word _word;

  ArrayList<Syllable> tmpSyllArray;

  dropdown() {
  }

  void render(Word _word) {
    prons = new ArrayList<String>();
    maxLength = 0;

    stroke(200);
    fill(255);
    //line(x+10+textWidth(_word._displayWord)/2, y-5, x+10+textWidth(_word._displayWord)/2, y); 
    line(x+10, y-5, x+10, y); 
    rectMode(CORNERS);
    String chk;
    float tc = textWidth("\u2022 ");
    for (int k = 0; k < size; k++) {
      String syll2 = "";
      for (int l = 0; l < _word.syllableArray.get (k).size(); l++) {
        syll2 += " "+_word.syllableArray.get(k).get(l).returnString(_word.syllableArray.get(k).get(l)._fullSyll)+_word.syllableArray.get(k).get(l)._stress;
      }
      //println("2: "+syll2);
      prons.add(syll2);
      if (textWidth(syll2)>maxLength) { 
        maxLength = textWidth(syll2);
      }
    }
    for (int m = 0; m < prons.size (); m++) {
      stroke(220);
      chk = (m == _word.pronNum) ? "\u2022 " : "";
      if (hover[m] == 1) {
        fill(220);
        rect(x, y+(20*m)+5, x+maxLength+10+tc, y+(20*m)+20+5);
        noStroke();
        fill(0);
      } else {
        fill(255);
        rect(x, y+(20*m)+5, x+maxLength+10+tc, y+(20*m)+20+5);
        noStroke();
        fill(50);
      }
      textAlign(LEFT, CENTER);
      text(chk+prons.get(m), x+5, y+(20*m)+15);
    }
  }

  void drawMenu(Word wrd) { 
    _word = wrd; 
    displayName = _word._displayWord; 
    x = _word.x+20+350+sep;
    y = _word.y+10;
    size = _word.syllableArray.size();
    hover = new int[size];
    if (scroll) {
      pushMatrix();
      scrollPos = 0;//vs1.getPos() - 800 + 400;
      translate(0, scrollPos);
    }
    mouseOver();
    pushMatrix();
    translate(0, pScroll);
    render(_word);
    popMatrix();
    if (scroll) {
      popMatrix();
    }
  }

  void mouseOver() {
    for (int i = 0; i < size; i++) {
      if (mouseX >= x+5 && mouseX <= x+maxLength+5 && mouseY >= y+(20*i)+5 + pScroll && mouseY <= y+(20*i)+20+5 + pScroll) {
        hover[i] = 1;
      } else {
        hover[i] = 0;
      }
    }
  }

  void mouseReleased() {
    for (int i = 0; i < size; i++) {
      if (hover[i] == 1) {
        //tmpSyllArray = _word.syllableArray.get(i);
        //_word.syllableArray.remove(i);
        //_word.syllableArray.add(0, tmpSyllArray);
        _word.pronNum = i;
        //then have to rerun everything!
        _text_view.refresh();
      }
    }
  }
};

class ellipseBox {
  ellipseBox() {
  }
  void draw(float x, float y) {
    rectMode(CORNERS);
    textAlign(LEFT, CENTER);
    stroke(220);
    rect(x, y, x + 20, y + 10);
    fill(180);
    text("...", x+5, y);
    noStroke();
    noFill();
  }
};

