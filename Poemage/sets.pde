//set classes
//set
//setwrd
//pattern?

class Set {
  float sz; //size of the circle - depends on size of set
  int _id;
  int _snum;
  int _setSize;
  int _type;
  String _rhymeId;
  color var;
  PFont _line_font = _georgia_14;
  PFont _title_font = _georgia_16;
  int order = 0;
  int orderNum;
  int _rulenum;
  String _rulename;
  boolean hover = false;
  boolean selected = false;
  cubicBezier bz, bz0, bz1, bz2;
  pointer ptr;
  menuItem menu = null;


  ArrayList<Float> _x = new ArrayList<Float>();
  ArrayList<Integer> _y = new ArrayList<Integer>();
  ArrayList<setWrd> _setWrds = new ArrayList<setWrd>();
  ArrayList<Integer> _setIds = new ArrayList<Integer>();
  ArrayList<Word> _wrds = new ArrayList<Word>();
  ArrayList<String> _words = new ArrayList<String>();
  ArrayList<String> _phonetics = new ArrayList<String>();
  ArrayList<node> _setNodes = new ArrayList<node>();
  ArrayList<segment> _segsT;
  ArrayList<segment> _segs = new ArrayList<segment>();
  ArrayList<segment> _segs1 = new ArrayList<segment>();
  ArrayList<segment> _segs2 = new ArrayList<segment>();
  ArrayList<segment> _segsOrig = new ArrayList<segment>();
  ArrayList<segment> _segsOrig1 = new ArrayList<segment>();
  ArrayList<segment> _segsOrig2 = new ArrayList<segment>();
  ArrayList<PVector> _anchorsT;
  ArrayList<PVector> _anchors = new ArrayList<PVector>();
  ArrayList<PVector> _anchors1 = new ArrayList<PVector>();
  ArrayList<PVector> _anchors2 = new ArrayList<PVector>();
  ArrayList<segment> _subsegs = new ArrayList<segment>();
  ArrayList<segment> _tmpSegs = new ArrayList<segment>();
  ArrayList<pShape> patternShapes = new ArrayList<pShape>();
  ArrayList<midpoint> mps = new ArrayList<midpoint>();
  ArrayList<midpoint> mps1 = new ArrayList<midpoint>();
  ArrayList<midpoint> mps2 = new ArrayList<midpoint>();
  ArrayList<midpoint> mpsT; 

  Set(int rulenum, String name) {
    _rulenum = rulenum;
    _rulename = name;
    _rhymeId = name;
  }

  void genSetWrds(int stype, int snum) {
    _id = stype;
    _snum = snum;

    _setWrds.clear();
    for (int i = 0; i < _wrds.size (); i++) {
      setWrd swTmp = new setWrd(_words.get(i), _wrds.get(i));
      _setWrds.add(swTmp);
    }
    Collections.sort(_setWrds, new setWrdComparable());

    _segs.clear();
    _segs1.clear();
    _segs2.clear();

    //gen pointer
    ptr = new pointer(stype, snum, _rhymeId);

    for (int i = 0; i < _setWrds.size (); i++) {
      _x.add(_setWrds.get(i)._x);
      _y.add(_setWrds.get(i)._y);
      //_words.set(i, _setWrds.get(i)._word);
      _wrds.set(i, _setWrds.get(i)._wrd);
      //add ptr to node members list
      _wrds.get(i).addtoNode(ptr);
      if (i > 0) {
        _segs.add(new segment(new PVector((float)_wrds.get(i-1).getNodeX(0), (float)_wrds.get(i-1).getNodeY()), new PVector((float)_wrds.get(i).getNodeX(0), (float)_wrds.get(i).getNodeY())));
        _segs1.add(new segment(new PVector((float)_wrds.get(i-1).getNodeX(1), (float)_wrds.get(i-1).getNodeY()), new PVector((float)_wrds.get(i).getNodeX(1), (float)_wrds.get(i).getNodeY())));
        _segs2.add(new segment(new PVector((float)_wrds.get(i-1).getNodeX(2), (float)_wrds.get(i-1).getNodeY()), new PVector((float)_wrds.get(i).getNodeX(2), (float)_wrds.get(i).getNodeY())));
      }
    }
    _segsOrig.addAll(_segs);
  }

  //////bundling, ordering, filling, removing methods/////////

  void getAnchors() {
    //get all points, including reroutes...bundle on reroutes...
    _anchors.clear();
    for (int i = 0; i < _segs.size (); i++) {
      _anchors.add(_segs.get(i).p1);
      for (int j = 0; j < _segs.get (i).cPts.size(); j++) {
        _anchors.add(_segs.get(i).cPts.get(j).p);
      }
      if (i == _segs.size()-1) {
        _anchors.add(_segs.get(i).p2);
      }
    }
    //
    _anchors1.clear();
    for (int i = 0; i < _segs1.size (); i++) {
      _anchors1.add(_segs1.get(i).p1);
      for (int j = 0; j < _segs1.get (i).cPts.size(); j++) {
        _anchors1.add(_segs1.get(i).cPts.get(j).p);
      }
      if (i == _segs1.size()-1) {
        _anchors1.add(_segs1.get(i).p2);
      }
    }
    //
    _anchors2.clear();
    for (int i = 0; i < _segs2.size (); i++) {
      _anchors2.add(_segs2.get(i).p1);
      for (int j = 0; j < _segs2.get (i).cPts.size(); j++) {
        _anchors2.add(_segs2.get(i).cPts.get(j).p);
      }
      if (i == _segs2.size()-1) {
        _anchors2.add(_segs2.get(i).p2);
      }
    }
  }

  void addCps() {
    //insert cps
    int adv = 0;
    for (int i = 0; i < _anchors.size (); i++) {
      if (ptr.bundleCps.containsKey(_anchors.get(i))) {
        if (ptr.bundleCps.get(_anchors.get(i))[0] != null) {
          /*if(ptr.bundleCps.get(_anchors.get(i))[0].x == _anchors.get(i).x && ptr.bundleCps.get(_anchors.get(i))[0].y == _anchors.get(i).y ){
           println("oy");
           }*/
          _anchors.add(i, ptr.bundleCps.get(_anchors.get(i))[0]);
          println("yep in");
          i++;
        }
        /*if(ptr.bundleCps.get(_anchors.get(i))[1] != null){
         _anchors.add(i+1,ptr.bundleCps.get(_anchors.get(i))[1]);
         println("yep out");
         i++;
         }*/
      }
    }
    calcBezier();
  }

  void meanderSet5() {
  }

  void meanderSet() { //if set skips a line, redirect through the nearest midpoint to the segment intersection 
    //calc point of intersection between
    float ls = sp+5;
    mps.clear();
    int m = 0;
    ArrayList<segment> tseg = new ArrayList<segment>();
    ArrayList<PVector> tps = new ArrayList<PVector>();
    //println("meandering");
    for (int i = 0; i < _segs.size (); i++) {
      if (abs(_segs.get(i).p2.y-_segs.get(i).p1.y) == ls) {
        if (abs(_segs.get(i).p2.x-_segs.get(i).p1.x) < 100 || (i < _segs.size()-1 && (Math.abs(_segs.get(i+1).theta) != 0.0 && Math.abs(_segs.get(i+1).theta) != 180.0))) {
          tseg.add(_segs.get(i));
          continue;
        } else {
          tps.clear();
          tps.add(_segs.get(i).p1);
          //tps.add(new PVector((_segs.get(i).p1.x+_segs.get(i).p2.x)/2, _segs.get(i).p1.y+(sp/2)));   //make prettier
          tps.add(new PVector(_segs.get(i).p1.x-5, _segs.get(i).p1.y+(sp/2)));
          tps.add(new PVector(_segs.get(i).p2.x+5, _segs.get(i).p1.y+(sp/2)));   //make prettier
          tps.add(_segs.get(i).p2);
          for (int n = 0; n < tps.size ()-1; n++) {
            tseg.add(new segment(tps.get(n), tps.get(n+1)));
          }
        }
      } else if (abs(_segs.get(i).p2.y-_segs.get(i).p1.y) < 1) { //same line - meander around words. 
        //check if consecutive words
        int a = pNodes.indexOf(_segs.get(i).p1);
        int b = pNodes.indexOf(_segs.get(i).p2);
        if (b > a+1) {
          tps.clear();
          tps.add(_segs.get(i).p1);
          for (int z = a+1; z < b; z++) {
            tps.add(new PVector(pNodes.get(z).x, pNodes.get(z).y-(sp/2)-1));
          }    
          tps.add(_segs.get(i).p2);
          for (int n = 0; n < tps.size ()-1; n++) {
            tseg.add(new segment(tps.get(n), tps.get(n+1)));
          }
        } else {
          tseg.add(_segs.get(i));
        }
      } else {
        tps.clear(); 
        tps.add(_segs.get(i).p1);
        int diff = (int)((_segs.get(i).p2.y-_segs.get(i).p1.y)/ls) - 1;
        for (int j = 1; j <= diff; j++) {
          double dmin = 1000;
          double x_val = 0;
          for (int k = 0; k < mids.get ( (int)(_segs.get(i).p1.y+ls*j)).size(); k++) { 
            //println(i+" "+j+" "+k+" "+mids.get((int)(_segs.get(i).p1.y+19*j)).size());
            double d = Line2D.ptLineDistSq((double)_segs.get(i).p1.x, (double)_segs.get(i).p1.y, (double)_segs.get(i).p2.x, (double)_segs.get(i).p2.y, (double)mids.get((int)(_segs.get(i).p1.y+ls*j)).get(k).mid_x, (double)mids.get((int)(_segs.get(i).p1.y+ls*j)).get(k).y_val);
            if (d < dmin) {
              dmin = d; 
              x_val = mids.get((int)(_segs.get(i).p1.y+ls*j)).get(k).mid_x;
              m = k;
            }
          }
          if (_segs.get(i).p1.y+ls*j > 0 && dmin != 1000) {
            tps.add(new PVector((float)x_val, _segs.get(i).p1.y+ls*j));
            //tps.add(new PVector((float)x_val, _segs.get(i).p1.y+ls*j+8));
            mps.add(mids.get((int)(_segs.get(i).p1.y+ls*j)).get(m));
          }
        }
        tps.add(_segs.get(i).p2);
        for (int n = 0; n < tps.size ()-1; n++) {
          tseg.add(new segment(tps.get(n), tps.get(n+1)));
        }
      }
    }
    _segs.clear(); 
    _segs.addAll(tseg);

    meanderSet1();
    meanderSet2();

    getAnchors();
    //calcSubsegs();
  }


  void meanderSet1() { //if set skips a line, redirect through the nearest midpoint to the segment intersection 
    //calc point of intersection between
    float ls = sp+5;
    mps1.clear();
    int m = 0;
    ArrayList<segment> tseg = new ArrayList<segment>();
    ArrayList<PVector> tps = new ArrayList<PVector>();
    //println("meandering");
    for (int i = 0; i < _segs1.size (); i++) {
      if (abs(_segs1.get(i).p2.y-_segs1.get(i).p1.y) == ls) {
        if (abs(_segs1.get(i).p2.x-_segs1.get(i).p1.x) < 100 || (i < _segs1.size()-1 && (Math.abs(_segs1.get(i+1).theta) != 0.0 && Math.abs(_segs1.get(i+1).theta) != 180.0))) {
          tseg.add(_segs1.get(i));
          continue;
        } else {
          tps.clear();
          tps.add(_segs1.get(i).p1);
          //tps.add(new PVector((_segs1.get(i).p1.x+_segs1.get(i).p2.x)/2, _segs1.get(i).p1.y+(sp/2)));   //make prettier
          tps.add(new PVector(_segs1.get(i).p1.x-5, _segs1.get(i).p1.y+(sp/2)));
          tps.add(new PVector(_segs1.get(i).p2.x+5, _segs1.get(i).p1.y+(sp/2)));   //make prettier
          tps.add(_segs1.get(i).p2);
          for (int n = 0; n < tps.size ()-1; n++) {
            tseg.add(new segment(tps.get(n), tps.get(n+1)));
          }
        }
      } else if (abs(_segs1.get(i).p2.y-_segs1.get(i).p1.y) < 1) { //same line - meander around words. 
        //check if consecutive words
        int a = pNodes1.indexOf(_segs1.get(i).p1);
        int b = pNodes1.indexOf(_segs1.get(i).p2);
        if (b > a+1) {
          tps.clear();
          tps.add(_segs1.get(i).p1);
          for (int z = a+1; z < b; z++) {
            tps.add(new PVector(pNodes1.get(z).x, pNodes1.get(z).y-(sp/2)-1));
          }    
          tps.add(_segs1.get(i).p2);
          for (int n = 0; n < tps.size ()-1; n++) {
            tseg.add(new segment(tps.get(n), tps.get(n+1)));
          }
        } else {
          tseg.add(_segs1.get(i));
        }
      } else {
        tps.clear(); 
        tps.add(_segs1.get(i).p1);
        int diff = (int)((_segs1.get(i).p2.y-_segs1.get(i).p1.y)/ls) - 1;
        for (int j = 1; j <= diff; j++) {
          double dmin = 1000;
          double x_val = 0;
          for (int k = 0; k < mids1.get ( (int)(_segs1.get(i).p1.y+ls*j)).size(); k++) { 
            //println(i+" "+j+" "+k+" "+mids.get((int)(_segs1.get(i).p1.y+19*j)).size());
            double d = Line2D.ptLineDistSq((double)_segs1.get(i).p1.x, (double)_segs1.get(i).p1.y, (double)_segs1.get(i).p2.x, (double)_segs1.get(i).p2.y, (double)mids1.get((int)(_segs1.get(i).p1.y+ls*j)).get(k).mid_x, (double)mids1.get((int)(_segs1.get(i).p1.y+ls*j)).get(k).y_val);
            if (d < dmin) {
              dmin = d; 
              x_val = mids1.get((int)(_segs1.get(i).p1.y+ls*j)).get(k).mid_x;
              m = k;
            }
          }
          if (_segs1.get(i).p1.y+ls*j > 0 && dmin != 1000) {
            tps.add(new PVector((float)x_val, _segs1.get(i).p1.y+ls*j));
            mps1.add(mids1.get((int)(_segs1.get(i).p1.y+ls*j)).get(m));
          }
        }
        tps.add(_segs1.get(i).p2);
        for (int n = 0; n < tps.size ()-1; n++) {
          tseg.add(new segment(tps.get(n), tps.get(n+1)));
        }
      }
    }
    _segs1.clear(); 
    _segs1.addAll(tseg);
    //getAnchors1();
    //calcSubsegs();
  }

  void meanderSet2() { //if set skips a line, redirect through the nearest midpoint to the segment intersection 
    //calc point of intersection between
    float ls = sp+5;
    mps2.clear();
    int m = 0;
    ArrayList<segment> tseg = new ArrayList<segment>();
    ArrayList<PVector> tps = new ArrayList<PVector>();
    //println("meandering");
    for (int i = 0; i < _segs2.size (); i++) {
      if (abs(_segs2.get(i).p2.y-_segs2.get(i).p1.y) == ls) {
        if (abs(_segs2.get(i).p2.x-_segs2.get(i).p1.x) < 100 || (i < _segs2.size()-1 && (Math.abs(_segs2.get(i+1).theta) != 0.0 && Math.abs(_segs2.get(i+1).theta) != 180.0))) {
          tseg.add(_segs2.get(i));
          continue;
        } else {
          tps.clear();
          tps.add(_segs2.get(i).p1);
          //tps.add(new PVector((_segs2.get(i).p1.x+_segs2.get(i).p2.x)/2, _segs2.get(i).p1.y+(sp/2)));   //make prettier
          tps.add(new PVector(_segs2.get(i).p1.x-5, _segs2.get(i).p1.y+(sp/2)));
          tps.add(new PVector(_segs2.get(i).p2.x+5, _segs2.get(i).p1.y+(sp/2)));   //make prettier
          tps.add(_segs2.get(i).p2);
          for (int n = 0; n < tps.size ()-1; n++) {
            tseg.add(new segment(tps.get(n), tps.get(n+1)));
          }
        }
      } else if (abs(_segs2.get(i).p2.y-_segs2.get(i).p1.y) < 1) { //same line - meander around words. 
        //check if consecutive words
        int a = pNodes2.indexOf(_segs2.get(i).p1);
        int b = pNodes2.indexOf(_segs2.get(i).p2);
        if (b > a+1) {
          tps.clear();
          tps.add(_segs2.get(i).p1);
          for (int z = a+1; z < b; z++) {
            tps.add(new PVector(pNodes2.get(z).x, pNodes2.get(z).y-(sp/2)-1));
          }    
          tps.add(_segs2.get(i).p2);
          for (int n = 0; n < tps.size ()-1; n++) {
            tseg.add(new segment(tps.get(n), tps.get(n+1)));
          }
        } else {
          tseg.add(_segs2.get(i));
        }
      } else {
        tps.clear(); 
        tps.add(_segs2.get(i).p1);
        int diff = (int)((_segs2.get(i).p2.y-_segs2.get(i).p1.y)/ls) - 1;
        for (int j = 1; j <= diff; j++) {
          double dmin = 1000;
          double x_val = 0;
          for (int k = 0; k < mids2.get ( (int)(_segs2.get(i).p1.y+ls*j)).size(); k++) { 
            //println(i+" "+j+" "+k+" "+mids.get((int)(_segs2.get(i).p1.y+19*j)).size());
            double d = Line2D.ptLineDistSq((double)_segs2.get(i).p1.x, (double)_segs2.get(i).p1.y, (double)_segs2.get(i).p2.x, (double)_segs2.get(i).p2.y, (double)mids2.get((int)(_segs2.get(i).p1.y+ls*j)).get(k).mid_x, (double)mids2.get((int)(_segs2.get(i).p1.y+ls*j)).get(k).y_val);
            if (d < dmin) {
              dmin = d; 
              x_val = mids2.get((int)(_segs2.get(i).p1.y+ls*j)).get(k).mid_x;
              m = k;
            }
          }
          if (_segs2.get(i).p1.y+ls*j > 0 && dmin != 1000) {
            tps.add(new PVector((float)x_val, _segs2.get(i).p1.y+ls*j));
            mps2.add(mids2.get((int)(_segs2.get(i).p1.y+ls*j)).get(m));
          }
        }
        tps.add(_segs2.get(i).p2);
        for (int n = 0; n < tps.size ()-1; n++) {
          tseg.add(new segment(tps.get(n), tps.get(n+1)));
        }
      }
    }
    _segs2.clear(); 
    _segs2.addAll(tseg);
    //getAnchors2();
    //calcSubsegs();
  }


  segment getILSeg(PVector p, int n) {
    for (int i = 0; i < _subsegs.size (); i++) {
      if ((_subsegs.get(i).p1.x == p.x && _subsegs.get(i).p1.y == p.y) && n == 1) {
        return _subsegs.get(i);
      } else if ((_subsegs.get(i).p2.x == p.x && _subsegs.get(i).p2.y == p.y) && n == 0) {
        return _subsegs.get(i);
      }
    }
    return null;
  }

  void recalcAnchors() {
    bz0.calcNewAnchors();
    bz1.calcNewAnchors();
    bz2.calcNewAnchors();
  }

  void calcSubsegs() {
    _subsegs.clear();
    for (int i = 0; i < _anchors.size ()-1; i++) {
      _subsegs.add(new segment(_anchors.get(i), _anchors.get(i+1)));
    }
  }

  void updateSegs() {
    for (int i = 0; i < _segs.size (); i++) {
      QT.removeEdges(_segs.get(i), _id, _snum, i);
    }
    getAnchors();
    _segs.clear();
    for (int i = 0; i < _anchors.size ()-1; i++) {
      _segs.add(new segment(_anchors.get(i), _anchors.get(i+1)));
    }
  }

  void updateSeg(int i) {
    _tmpSegs.clear();
    //don't do anything if no new points...
    if (_segs.get(i).cPts.size() == 0) {
      return;
    }
    QT.removeEdges(_segs.get(i), _id, _snum, i);
    for (int j = 0; j < _segs.get (i).cPts.size(); j++) {
      _anchors.add(_anchors.indexOf(_segs.get(i).p1)+j+1, _segs.get(i).cPts.get(j).p);
    }
    for (int j = _anchors.indexOf (_segs.get (i).p1); j < _anchors.indexOf(_segs.get(i).p2); j++) {
      _tmpSegs.add(new segment(_anchors.get(j), _anchors.get(j+1)));
      //add new seg to QT
      QT.insertSeg(_tmpSegs.get(_tmpSegs.size()-1), _id, _snum, i + _tmpSegs.size()-1, 1000); //need to take subseg out of the equation...
    }
    //add rerouted segs to _segs
    _segs.addAll(i+1, _tmpSegs); //not certain that this works...
    //remove orig seg
    _segs.remove(i);
  }

  void addRemovePtr(int ty) { //come back to this!!! have to make sure ordering is correct
    if (!selected && !setPointers.contains(ptr) && !menu.out) {
      selected = true;
      ptr.selected = true;
      setPointers.add(ptr);
      ptr.orderNum = setPointers.size()-1;
      calcOrder();
      if (ty == 0) {
        addRouteCps();
      }
    } else if (selected && setPointers.contains(ptr)) {
      selected = false;
      ptr.selected = false;
      setPointers.remove(ptr);
      updateShapes();
      updateONum();
      removeRouteCps();
    }
    //updateBs();
  }

  void addRouteCps() {
    updatePtrs.clear();  
    for (int i = 0; i < _anchors.size (); i++) {  //submit anchors to determing ordering
      if (routeCPs.containsKey(_anchors.get(i))) {
        //add to ptrs update list
        for (pointer p : routeCPs.get (_anchors.get (i))) {
          if (!updatePtrs.contains(p)) updatePtrs.add(p);
        }
        routeCPs.get(_anchors.get(i)).add(ptr);
      } else {   //add new mapping
        routeCPs.put(_anchors.get(i), new ArrayList<pointer>());
        routeCPs.get(_anchors.get(i)).add(ptr);
      }
      Collections.sort(routeCPs.get(_anchors.get(i)), new ptrComparable());
    }

    //mode2
    //updatePtrs.clear();  
    for (int i = 0; i < _anchors1.size (); i++) {  //submit anchors to determing ordering
      if (routeCPs1.containsKey(_anchors1.get(i))) {
        //add to ptrs update list
        for (pointer p : routeCPs1.get (_anchors1.get (i))) {
          if (!updatePtrs.contains(p)) updatePtrs.add(p);
        }
        routeCPs1.get(_anchors1.get(i)).add(ptr);
      } else {   //add new mapping
        routeCPs1.put(_anchors1.get(i), new ArrayList<pointer>());
        routeCPs1.get(_anchors1.get(i)).add(ptr);
      }
      Collections.sort(routeCPs1.get(_anchors1.get(i)), new ptrComparable());
    }

    //mode3
    //updatePtrs.clear();  
    for (int i = 0; i < _anchors2.size (); i++) {  //submit anchors to determing ordering
      if (routeCPs2.containsKey(_anchors2.get(i))) {
        //add to ptrs update list
        for (pointer p : routeCPs2.get (_anchors2.get (i))) {
          if (!updatePtrs.contains(p)) updatePtrs.add(p);
        }
        routeCPs2.get(_anchors2.get(i)).add(ptr);
      } else {   //add new mapping
        routeCPs2.put(_anchors2.get(i), new ArrayList<pointer>());
        routeCPs2.get(_anchors2.get(i)).add(ptr);
      }
      Collections.sort(routeCPs2.get(_anchors2.get(i)), new ptrComparable());
    }
    //update other ptrs
    for (pointer p : updatePtrs) {
      p.recalcAnchors();
    }

    recalcAnchors();
  }

  void removeRouteCps() {
    updatePtrs.clear();  
    for (int i = 0; i < _anchors.size (); i++) {  //submit anchors to determing ordering
      if (routeCPs.containsKey(_anchors.get(i))) {
        //add to ptrs update list
        for (pointer p : routeCPs.get (_anchors.get (i))) {
          if (!updatePtrs.contains(p)) updatePtrs.add(p);
        }
        routeCPs.get(_anchors.get(i)).remove(ptr);
        //if no more pointers, remove from hashmap
        if (routeCPs.get(_anchors.get(i)).size() == 0) {
          routeCPs.remove(_anchors.get(i));
        }
      }
    } 

    //mode 1
    for (int i = 0; i < _anchors1.size (); i++) {  //submit anchors to determing ordering
      if (routeCPs1.containsKey(_anchors1.get(i))) {
        //add to ptrs update list
        for (pointer p : routeCPs1.get (_anchors1.get (i))) {
          if (!updatePtrs.contains(p)) updatePtrs.add(p);
        }
        routeCPs1.get(_anchors1.get(i)).remove(ptr);
        //if no more pointers, remove from hashmap
        if (routeCPs1.get(_anchors1.get(i)).size() == 0) {
          routeCPs1.remove(_anchors1.get(i));
        }
      }
    } 

    //mode 2
    for (int i = 0; i < _anchors2.size (); i++) {  //submit anchors to determing ordering
      if (routeCPs2.containsKey(_anchors2.get(i))) {
        //add to ptrs update list
        for (pointer p : routeCPs2.get (_anchors2.get (i))) {
          if (!updatePtrs.contains(p)) updatePtrs.add(p);
        }
        routeCPs2.get(_anchors2.get(i)).remove(ptr);
        //if no more pointers, remove from hashmap
        if (routeCPs2.get(_anchors2.get(i)).size() == 0) {
          routeCPs2.remove(_anchors2.get(i));
        }
      }
    } 


    //update other ptrs
    for (pointer p : updatePtrs) {
      p.recalcAnchors();
    }
    recalcAnchors();
  }

  void addPtr() { //come back to this!!! have to make sure ordering is correct
    if (!selected && !setPointers.contains(ptr) && !menu.out) {
      selected = true;
      ptr.selected = true;
      setPointers.add(ptr);
      ptr.orderNum = setPointers.size()-1;
      calcOrder();
      addRouteCps();
    }
  }

  void removePtr() {
    if (ptr.selected && setPointers.contains(ptr)) {
      selected = false;
      ptr.selected = false;
      //setPointers.remove(ptr);
      //remove shapes. 
      updateShapes();
      updateONum();
    }
    removeRouteCps();
  }

  void calcOrder() {
    int s = setPointers.size();
    if (s > 1) {
      for (int i = 0; i < s-1; i++) { 
        //calc order pairwise
        //println("calcing");
        pOrder(i);
      }
    }
  } 

  void updateBs() {
    for (int i = 0; i < _wrds.size (); i++) {
      _wrds.get(i)._node.rebundle();
    }
    /*for(int i = 0; i < setPointers.size(); i++){
     setPointers.get(i).updateBs(); 
     }*/
  }

  void pOrder(int other) {
    ArrayList<commonSP> commonSubPaths = new ArrayList<commonSP>();
    int sharedEdges = 0;
    ArrayList<PVector> sharedPts = new ArrayList<PVector>();
    ArrayList<PVector> sharedPtsTop = new ArrayList<PVector>();
    ArrayList<PVector> sharedPtsBottom = new ArrayList<PVector>();
    ArrayList<Integer> i_s = new ArrayList<Integer>();
    ArrayList<Integer> j_s = new ArrayList<Integer>();
    int last = 500;
    int l;
    int l1_ind = ptr.orderNum; 
    int l2_ind = setPointers.get(other).orderNum;
    pointer otherPtr = setPointers.get(other);
    //iterate through segs
    for (int i = 0; i < _subsegs.size (); i++) {
      for (int j = 0; j < RhymeSets.get (otherPtr.sType).get(otherPtr.sNum)._subsegs.size(); j++) {
        if (_subsegs.get(i).p1.equals(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum)._subsegs.get(j).p1) && _subsegs.get(i).p2.equals(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum)._subsegs.get(j).p2)) {
          sharedEdges++;  
          if (last == i-1) {  //add to existing subpaths...probably don't need to store segs...
            commonSubPaths.get(commonSubPaths.size()-1).extend(_subsegs.get(i), new int[] {
              i, j
            }
            );
          } else {  //open new common subpath
            commonSubPaths.add(new commonSP(_subsegs.get(i), new int[] {
              i, j
            }
            ));
          }
          last = i;
          //check for shapes
        } else if (_subsegs.get(i).p1.equals(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum)._subsegs.get(j).p1)) {
          //if(!sharedPts.contains(_subsegs.get(i).p1)){
          //sharedPts.add(_subsegs.get(i).p1);
          //i_s.add(i);
          //j_s.add(j);
          //}
        } else if (_subsegs.get(i).p2.equals(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum)._subsegs.get(j).p2)) {
          //if(!sharedPts.contains(_subsegs.get(i).p2)){
          //sharedPts.add(_subsegs.get(i).p2);
          //i_s.add(i);
          //j_s.add(j);
          //}
        }
      }
    }

    //get shared anchor points.
    for (int i = 0; i < _anchors.size (); i++) {
      //make sure its a real node point and not a node point
      if (pNodes.indexOf(_anchors.get(i)) == -1)continue;
      int t = RhymeSets.get(otherPtr.sType).get(otherPtr.sNum)._anchors.indexOf(_anchors.get(i));
      if (t != -1) {
        sharedPts.add(_anchors.get(i));
        i_s.add(i);
        j_s.add(t);
      }
    }



    //gen shapes
    //println("adding pshape: "+sharedPts.size());
    if (sharedPts.size()>=2) {
      //println("adding pshape");
      //shapes.add(new pShape(ptr, otherPtr, sharedPts));
      shapes3.add(new pShape3(ptr, otherPtr, sharedPts, i_s, j_s, 0));
      /*int e1 = bz.anchors.indexOf(sharedPts.get(0));
       int e2 = RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.indexOf(sharedPts.get(0));
       if(e1 > -1 && e2 > -1){
       if(e1 > 0 && e2 > 0){
       sharedPtsTop.add(sharedPts.get(0));
       sharedPtsTop.add(bz.anchors.get(e1-1));
       sharedPtsTop.add(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.get(e2-1));
       shapes3.add(new pShape3(ptr, otherPtr, sharedPtsTop, i_s, j_s,1));
       }
       e1 = bz.anchors.indexOf(sharedPts.size()-1);
       e2 = RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.indexOf(sharedPts.size()-1);
       if(e1 < bz.anchors.size()-1 && e2 < RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.size()-1){
       sharedPtsBottom.add(sharedPts.get(sharedPts.size()-1));
       sharedPtsBottom.add(bz.anchors.get(e1+1));
       sharedPtsBottom.add(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.get(e2+1));
       shapes3.add(new pShape3(ptr, otherPtr, sharedPtsBottom, i_s, j_s,2));
       }
       }*/
      //top
      int e1 = bz.anchors.indexOf(sharedPts.get(0));
      int e2 = RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.indexOf(sharedPts.get(0));
      if (e1 > -1 && e2 > -1) {
        if (e1 > 0 && e2 > 0) {
          //println("top");
          sharedPtsTop.add(sharedPts.get(0));
          //sharedPtsTop.add(bz.anchors.get(e1-1));
          sharedPtsTop.add(bz.anchors.get(0));
          //sharedPtsTop.add(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.get(e2-1));
          sharedPtsTop.add(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.get(0));
          shapes3.add(new pShape3(ptr, otherPtr, sharedPtsTop, i_s, j_s, 1));
        }
      }
      //bottom
      e1 = bz.anchors.indexOf(sharedPts.get(sharedPts.size()-1));
      e2 = RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.indexOf(sharedPts.get(sharedPts.size()-1));
      if (e1 > -1 && e2 > -1) {
        if (e1 < bz.anchors.size()-1 && e2 < RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.size()-1) {
          //println("bottom"); 
          sharedPtsBottom.add(sharedPts.get(sharedPts.size()-1));
          sharedPtsBottom.add(bz.anchors.get(bz.anchors.size()-1));
          sharedPtsBottom.add(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.get(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.size()-1));
          shapes3.add(new pShape3(ptr, otherPtr, sharedPtsBottom, i_s, j_s, 2));
        }
      }
    } else if (sharedPts.size()==1) {
      //println("single shape");
      int e1 = bz.anchors.indexOf(sharedPts.get(0));
      int e2 = RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.indexOf(sharedPts.get(0));
      if (e1 > -1 && e2 > -1) {
        if (e1 > 0 && e2 > 0) {
          //println("top");
          sharedPtsTop.add(sharedPts.get(0));
          
          /*PVector n = closestPoint(0,1,20);
          if(n != null){
            sharedPtsTop.add(n);
          }else{
            //println("null");
          sharedPtsTop.add(bz.anchors.get(e1-1));
          }*/
          //sharedPtsTop.add(bz.anchors.get(e1-1));
          sharedPtsTop.add(bz.anchors.get(0));
          //sharedPtsTop.add(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.get(e2-1));
          sharedPtsTop.add(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.get(0));
          shapes3.add(new pShape3(ptr, otherPtr, sharedPtsTop, i_s, j_s, 1));
        }

        /*if(e1 < bz.anchors.size()-1 && e2 < RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.size()-1){
         //println("bottom");
         sharedPtsBottom.add(sharedPts.get(0));
         //sharedPtsBottom.add(bz.anchors.get(bz.anchors.size()-1));
         sharedPtsBottom.add(bz.anchors.get(bz.anchors.size()-1));
         sharedPtsBottom.add(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.get(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.size()-1));
         shapes3.add(new pShape3(ptr, otherPtr, sharedPtsBottom, i_s, j_s,2));
         }*/
        e1 = bz.anchors.indexOf(sharedPts.get(sharedPts.size()-1));
        e2 = RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.indexOf(sharedPts.get(sharedPts.size()-1));
        if (e1 > -1 && e2 > -1) {
          if (e1 < bz.anchors.size()-1 && e2 < RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.size()-1) {
            //println("bottom"); 
            sharedPtsBottom.add(sharedPts.get(sharedPts.size()-1));
            sharedPtsBottom.add(bz.anchors.get(bz.anchors.size()-1));
            sharedPtsBottom.add(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.get(RhymeSets.get(otherPtr.sType).get(otherPtr.sNum).bz.anchors.size()-1));
            shapes3.add(new pShape3(ptr, otherPtr, sharedPtsBottom, i_s, j_s, 2));
          }
        }
      }
    }
    //println("size: "+shapes3.size());


    if (commonSubPaths.size() == 0) {
      //println("no common paths");
      return;
    }
    int[] dirs = new int[3];
    for (int i = 0; i < commonSubPaths.size (); i++) {
      commonSubPaths.get(i).calcLs(ptr, otherPtr);
      dirs[commonSubPaths.get(i).lf] += 1;
    }
    if (dirs[0] > dirs[1]) {  //don't need to take 2's into account. 
      l = 0;
    } else {
      l = 1;
    }
    //int tmp = ptr.orderNum;

    //println("ptr before: "+ptr.orderNum);
    ptr.orderNum = (l == 1)? l2_ind+1 : l2_ind;
    //println("ptr after: "+ptr.orderNum);
    //println("otherPtr before: "+otherPtr.orderNum);
    otherPtr.orderNum =(l == 1)? l2_ind : l2_ind+1;
    //println("otherPtr after: "+otherPtr.orderNum);

    for (int i = l1_ind+1; i < setPointers.size (); i++) {
      setPointers.get(i).orderNum = setPointers.get(i).orderNum + 1;
    }

    /*for (int i = 0; i < setPointers.size (); i++) {
     print(setPointers.get(i).orderNum + " ");
     }
     println();*/
    Collections.sort(setPointers, new ptrComparable());
    /*for (int i = 0; i < setPointers.size (); i++) {
     print(setPointers.get(i).orderNum + " ");
     } 
     println();*/
    updateONum();
    return;
  }

  PVector closestPoint(int index, int dir, float dist) {
    //add up point until you reach a particular arclength 
    PVector p,p1,p2,c1,c2; 
    int steps = 10;
    if (dir == 0) { //proceeding downward
      float d = 0.0;
      while (d < dist && index < bz.anchors.size()-1) {
        p1 = bz.anchors.get(index);
        p2 = bz.anchors.get(index+1);
        c1 = bz.cps[index][1];
        c2 = (index+1 < bz.anchors.size()-1) ? bz.cps[index+1][0] : bz.anchors.get(index+1);
        float px = p1.x;
        float py = p1.y;
        for (int i = 0; i <= steps; i++) {
          float t = i / float(steps);
          float x = bezierPoint(p1.x, c1.x, c2.x, p2.x, t);
          float y = bezierPoint(p1.y, c1.y, c2.y, p2.y, t);
          d += sqrt(sq(x-px)+sq(y-py));
          if(d > dist){
           //return new PVector(x,y); 
           return p2;
          }
        }
      }
      } else if (dir == 1) { //proceeding upward
        float d = 0.0;
        while (d < dist && index > 0) {
        p1 = bz.anchors.get(index);
        p2 = bz.anchors.get(index-1);
        c1 = bz.cps[index][0];
        c2 = (index-1 >0) ? bz.cps[index-1][0] : bz.anchors.get(index-1);
        float px = p1.x;
        float py = p1.y;
        for (int i = 0; i <= steps; i++) {
          float t = i / float(steps);
          float x = bezierPoint(p1.x, c1.x, c2.x, p2.x, t);
          float y = bezierPoint(p1.y, c1.y, c2.y, p2.y, t);
          d += sqrt(sq(x-px)+sq(y-py));
          if(d > dist){
           //return new PVector(x,y); 
           return p2;
          }
        }
      }
      
      }
    return null;
  }

    void updateShapes() {
      //remove shapes. 
      for (int i = 0; i < shapes3.size (); i++) {
        if (shapes3.get(i)._p1 == ptr || shapes3.get(i)._p2 == ptr) {
          shapes3.set(i, null);
        }
      }
      shapes3.removeAll(Collections.singleton(null));
    }

    void updateONum() {
      for (int i = 0; i < setPointers.size (); i++) {
        setPointers.get(i).orderNum = i;
      }
    }


    ////drawing methods/////

    void drawPattern() {
      if (hover || selected) {
        stroke(HoverColor); 
        noFill();
        beginShape();
        for (int i = 0; i < _wrds.size (); i++) {
          if (i ==0) {
            curveVertex(_wrds.get(i).getNodeX(), _wrds.get(i).getNodeY());
          }
          curveVertex(_wrds.get(i).getNodeX(), _wrds.get(i).getNodeY());
          if (i ==_wrds.size()-1) {
            curveVertex(_wrds.get(i).getNodeX(), _wrds.get(i).getNodeY());
          }
        }
        endShape();
      }
    }

    void drawPatternLine() {
      if (hover || selected) {
        stroke(HoverColor); 
        noFill();
        for (int i = 0; i < _segs.size (); i++) {
          _segs.get(i).drawSeg();
        }
      }
    }

    void drawRerouteLine() {
      if (hover || selected) {
        stroke(HoverColor); 
        noFill();
        for (int i = 0; i < _segs.size (); i++) {
          _segs.get(i).drawRerouteSeg();
        }
      }
    }

    void calcBezier() {
      bz0 = new cubicBezier(ptr, 0);
      bz0.anchors.addAll(_anchors);
      bz0.anchors_og.addAll(_anchors);
      bz0.calcCPTS();
      bz0.calcCPTSOG();

      bz1 = new cubicBezier(ptr, 1);
      bz1.anchors.addAll(_anchors1);
      bz1.anchors_og.addAll(_anchors1);
      bz1.calcCPTS();
      bz1.calcCPTSOG();

      bz2 = new cubicBezier(ptr, 2);
      bz2.anchors.addAll(_anchors2);
      bz2.anchors_og.addAll(_anchors2);
      bz2.calcCPTS();
      bz2.calcCPTSOG();

      /*if(mode == 0){
       bz = bz0; 
       }*/
    }

    /*void calcBezier2(){
     bz = new cubicBezier(ptr);
     bz.anchors.addAll(_anchors);
     bz.anchors_og.addAll(_anchors);
     bz.calcSecondary();
     bz.calcDiff();
     }*/

    void drawRerouteCurve() {
      if (hover || selected) {
        stroke(HoverColor); 
        noFill();
        beginShape();
        for (int i = 0; i < _segs.size (); i++) {
          if (i == 0) {
            curveVertex(_segs.get(i).p1.x, _segs.get(i).p1.y);
          }
          _segs.get(i).drawRerouteSegC();
          if (i == _segs.size()-1) {
            curveVertex(_segs.get(i).p2.x, _segs.get(i).p2.y);
            curveVertex(_segs.get(i).p2.x, _segs.get(i).p2.y);
          }
        }
        endShape();
      }
    }

    void hoverBezier() {
      if(!visActive && menu.type == 1){
        return;
      }
      if(!sonActive && menu.type == 0){
        return;
      }
      if (ptr.hover || ptr.mhover || ptr.whover) {
        stroke(HoverColor); 
        noFill();
        //bz.drawBezier();
        hoveredPtrs.add(ptr);
      }
    }

    void drawRerouteBezier() {
      if(!visActive && menu.type == 1){
        return;
      }
      if(!sonActive && menu.type == 0){
        return;
      }
      
      if (mode == 0) {
        bz = bz0;
        mpsT = mps;
      } else if (mode == 1) {
        bz = bz1; 
        mpsT = mps1;
      } else if (mode == 2) {
        bz = bz2;
        mpsT = mps2;
      } else {
        bz = bz0;
        mpsT = mps;
      }
      /*if(ptr.selected){
       println("sz: "+ptr.bundleCps.size());
       }*/
      strokeWeight(1.5);
      if (ptr.hover || ptr.mhover || ptr.whover) {
        stroke(HoverColor);  
        noFill();
        //bz.drawBezier();
        //hoveredPtrs.add(ptr);
      } else if (ptr.selected) {
        noFill();
        stroke(100, 50);
        strokeWeight(3);
        //bz.drawBezierG();
        strokeWeight(1.25);
        if (hoveredPtrs.size()>0) {
          if (menu.selected) {
            stroke(cTable1.findColour(menu.id%8), 50);
          } else {
            stroke(cTable1.findColour(setPointers.indexOf(ptr)%8), 50);
          }
        } else {
          if (menu.selected) {
            stroke(cTable1.findColour(menu.id%8));
          } else {
            stroke(cTable1.findColour(setPointers.indexOf(ptr)%8));
          }
        }

        //if(setPointers.indexOf(ptr)); 
        //stroke(HoverColor); 
        noFill();
        //pushMatrix();
        //translate(ptr.orderNum*5.0,0);
        if (showContext_b._selected) {
          for (int k = 0; k < mpsT.size (); k++) {
            mpsT.get(k).drawM();
          }
        }
        /*beginShape();
         for(int k = 0; k < _x.size(); k++){
         vertex(_x.get(k), _y.get(k));
         }
         endShape();*/
        bz.drawBezier();
        //bz.drawReg();
        //bz.drawSecondaryBezier();
        //bz.drawBezierDiff(1.0);
        //popMatrix();
      }
    }
    
    void drawRerouteBezierPDF(PGraphics pdf) {
      if(!visActive && menu.type == 1){
        return;
      }
      if(!sonActive && menu.type == 0){
        return;
      }
      
      if (mode == 0) {
        bz = bz0;
        mpsT = mps;
      } else if (mode == 1) {
        bz = bz1; 
        mpsT = mps1;
      } else if (mode == 2) {
        bz = bz2;
        mpsT = mps2;
      } else {
        bz = bz0;
        mpsT = mps;
      }
      /*if(ptr.selected){
       println("sz: "+ptr.bundleCps.size());
       }*/
      pdf.strokeWeight(1.5);
      if (ptr.hover || ptr.mhover || ptr.whover) {
        pdf.stroke(HoverColor);  
        pdf.noFill();
        //bz.drawBezier();
        //hoveredPtrs.add(ptr);
      } else if (ptr.selected) {
        pdf.noFill();
        pdf.stroke(100, 50);
        pdf.strokeWeight(3);
        //bz.drawBezierG();
        pdf.strokeWeight(1.25);
        if (hoveredPtrs.size()>0) {
          if (menu.selected) {
            pdf.stroke(cTable1.findColour(menu.id%8), 50);
          } else {
            pdf.stroke(cTable1.findColour(setPointers.indexOf(ptr)%8), 50);
          }
        } else {
          if (menu.selected) {
           pdf.stroke(cTable1.findColour(menu.id%8));
          } else {
            pdf.stroke(cTable1.findColour(setPointers.indexOf(ptr)%8));
          }
        }

        //if(setPointers.indexOf(ptr)); 
        //stroke(HoverColor); 
        pdf.noFill();
        //pushMatrix();
        //translate(ptr.orderNum*5.0,0);
        if (showContext_b._selected) {
          for (int k = 0; k < mpsT.size (); k++) {
            mpsT.get(k).drawM();
          }
        }
        bz.drawBezierPDF(pdf);
      }
    }

    void drawHoverBezier() {
      if (mode == 0) {
        bz = bz0;
        mpsT = mps;
      } else if (mode == 1) {
        bz = bz1; 
        mpsT = mps1;
      } else if (mode == 2) {
        bz = bz2;
        mpsT = mps2;
      } else {
        bz = bz0;
        mpsT = mps;
      }

      strokeWeight(1.25);
      if (ptr.hover || ptr.mhover || ptr.whover) {
        stroke(HoverColor); 
        noFill();
        if (showContext_b._selected) {
          for (int k = 0; k < mpsT.size (); k++) {
            mpsT.get(k).drawM();
          }
        }
        bz.drawBezier();
        //bz.drawReg();
        //bz.drawSecondaryBezier();
        //bz.drawBezierDiff(1.0);
      } 
      strokeWeight(1);
    }
  };

  public class rhymeComparable implements Comparator<Set> {

    @Override
      public int compare(Set a, Set b) {
      return (a._wrds.size()>b._wrds.size() ? -1 : (a._wrds.size()==b._wrds.size() ? 0 : 1));
      //return a.sz
    }
  }

  public class alphabetizeSets implements Comparator<Set> {
    @Override
      public int compare(Set a, Set b) {
      return a._rhymeId.compareTo(b._rhymeId);
      //return a.sz
    }
  }

  public class setWrdComparable implements Comparator<setWrd> {

    @Override
      public int compare(setWrd a, setWrd b) {
      return (a._y<b._y ? -1 : (a._y==b._y ? (a._x<b._x ? -1 : 1) : 1));
      //return a.sz
    }
  }

  class setWrd {
    float _x;
    int _y;
    int _selected;
    String _word;
    String _phonetics;
    String _chars;
    Word _wrd;

    setWrd(String word, Word wrd) {
      //_x = wrd.getNodeX2();
      _x = wrd.getNodeX();
      _y = (int)wrd.getNodeY();
      _word = word;
      _wrd = wrd;
    }

    setWrd(float x, int y, String word, String phonetics, String chars, Word wrd) {
      _x = x;
      _y = y;
      _word = word;
      _wrd = wrd;
      _phonetics = phonetics;
      _chars = chars;
    }
  };

