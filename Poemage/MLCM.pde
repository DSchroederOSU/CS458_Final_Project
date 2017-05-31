//mlcm methods
//commonSP (common subpaths)


class commonSP {
   ArrayList<segment> subpaths = new ArrayList<segment>();
   ArrayList<int[]> segnums = new ArrayList<int[]>();
   int luv, lvu, lf;    //1 means to left 0 means to right 2 means either - from two different directions, then final 
   double a1, a2, b1, b2, a, b; //angles
   commonSP(segment _seg, int[] _nums){
     subpaths.add(_seg);
     segnums.add(_nums);
   }
   void extend(segment _seg, int[] _nums){
     subpaths.add(_seg);
     segnums.add(_nums);
   }
   
   void calcLs(pointer thisPtr, pointer otherPtr){ //calc l for both inputs and outputs. 
    //calc luv. If first or last, set theta to 500 else, get theta and compare. 
    a = RhymeSets.get(thisPtr.sType).get(thisPtr.sNum)._subsegs.get(segnums.get(0)[0]).theta;
    if(a < 0)a += 180;
    a1 = (segnums.get(0)[0] == 0) ? 500 : RhymeSets.get(thisPtr.sType).get(thisPtr.sNum)._subsegs.get(segnums.get(0)[0]-1).theta;
    if(a1 < 0)a1 += 180;
    a2 = (segnums.get(0)[1] == 0) ? 500 : RhymeSets.get(otherPtr.sType).get(otherPtr.sNum)._subsegs.get(segnums.get(0)[1]-1).theta;
    if(a2 < 0)a2 += 180;
    b = RhymeSets.get(thisPtr.sType).get(thisPtr.sNum)._subsegs.get(segnums.get(segnums.size()-1)[0]).theta;
    if(b < 0)b += 180;
    b1 = (segnums.get(segnums.size()-1)[0] == RhymeSets.get(thisPtr.sType).get(thisPtr.sNum)._subsegs.size()-1) ? 500 : RhymeSets.get(thisPtr.sType).get(thisPtr.sNum)._subsegs.get(segnums.get(segnums.size()-1)[0]+1).theta;
    if(b1 < 0)b1 += 180;
    b2 = (segnums.get(segnums.size()-1)[1] == RhymeSets.get(otherPtr.sType).get(otherPtr.sNum)._subsegs.size()-1) ? 500 : RhymeSets.get(otherPtr.sType).get(otherPtr.sNum)._subsegs.get(segnums.get(segnums.size()-1)[1]+1).theta;
    if(b2 < 0)b2 += 180;
    //calc forward directions
    if(a1 == 500 || a2 == 500){    //if one or both segments terminate
     if(a1 != 500){
      if(a1 < a){
       luv = 0;
      }else if(a1 > a){
       luv = 1; 
      }else{
       luv = 2; 
      }
     }else if(a2 != 500){
      if(a2 < a){
       luv = 1;
      }else if(a2 > a){
       luv = 0; 
      }else{
       luv = 2; 
      }
     }else{
     luv = 2;
     }
    }else{
     if(a1 < a2){ //this should be reversed since incoming direction is flipped
      luv = 0;    //"left" is relative...but in terms of ordering, l1 should come before l2
     } else {
      luv = 1; 
     }
    }
    //calc backward direction
    if(b1 == 500 || b2 == 500){
     if(b1 != 500){
       if(b1 > b){
        lvu = 0;    //"left" is relative...but in terms of ordering, l1 should come before l2
       }else if(b1 < b){
        lvu = 1;    //"left" is relative...but in terms of ordering, l1 should come before l2
       }else {
        lvu = 2; 
       }
     }else if(b2 != 500){
        if(b2 > b){
        lvu = 1;    //"left" is relative...but in terms of ordering, l1 should come before l2
       }else if(b2 < b){
        lvu = 0;    //"left" is relative...but in terms of ordering, l1 should come before l2
       }else {
        lvu = 2; 
       }
     }else{
     lvu = 2;
     } 
    }else{
     if(b1 > b2){
      lvu = 0;    //"left" is relative...but in terms of ordering, l1 should come before l2
     } else {
      lvu = 1; 
     }
    }
    
    //calc overall
    if(luv == lvu){
      lf = luv;
    } else {
      if(luv == 2)lf = lvu;
      if(lvu == 2)lf = luv;
      //lf = 2;
    }
    
    //println("("+a+": "+a1+","+a2+") ; ("+b+": "+b1+","+b2+") forward: "+luv+" backward: "+lvu+" final: "+lf);
    
    /*for(int i = 0; i < segnums.size(); i++){
      a = setPointers.get(thisNum).segs.get(segnums.get(i)[0]).theta;
      if(a < 0)a += 180;
     println(a);
    }*/
    
   }
   
  }
