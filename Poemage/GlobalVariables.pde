//
// COLORS
//
public final color BACKGROUND_COLOR = color(219);//color(219);
public final color POEM_TEXT_COLOR = color( 50 );
public final color POEMAGE_LABEL_TEXT_COLOR = color( 200 );

public final color textcolor = color( 200 );

public final color BLUE = color( 55, 126, 184 );
public final color DRK_BLUE = color( 12, 79, 129 );
public final color LT_BLUE = color( 166, 206, 227 );
public final color LT_BLUE2 = color(222,235,245);
public final color ORANGE = color( 255, 127, 0);
public final color GREEN = color( 51, 160, 44 );
public final color LT_GREEN = color( 178, 223, 138 );
public final color DRK_GREEN = color( 20, 77, 0 );
public final color RED = color(255, 0, 0);
public final color PINK = color(255, 0, 234);
public final color GREY = color(220);

public final color HoverColor = color(134,156,173);

color[] setColors = {
  BLUE, LT_BLUE, ORANGE, GREEN, LT_GREEN, DRK_GREEN, RED, PINK, GREY
};

color[] myPalette = {
  color(255, 102, 102), /*color(153,51,51),*/color(204, 153, 204), color(102, 204, 51), color(153, 204, 255), color(0, 153, 204), color(0, 102, 153), color(102, 0, 153), color(204, 153, 204)
};

color[] myPalette2 = {
  color(166,206,227),color(31,120,180),color(178,223,138),color(51,160,44),color(251,154,153),color(227,26,28),color(253,191,111),color(255,127,0) };

public color BACKGROUND_COLOR_VAR = BACKGROUND_COLOR;

// COLOR TABLE
//
ColourTable cTable1;
int ctsize;

float sp = 12;

//
// SIZES
//
public static final int WINDOW_BORDER_WIDTH = 30;


//
// GLOBAL VARIABLES
//
Poem _poem;
int _longest_line_length;
int _title_length;

public static PFont _georgia_12, _georgia_14, _georgia_16;
public static PFont _georgia_14b, _georgia_24b;
public static PFont _gillsans_8;
public static PFont _gillsans_16i, _gillsans_20i;
public static PFont _clairhand_14;
public static PFont _pixel_font_8,_pixel_font_8b,_pixel_font_8i;
public static PFont _pixel_font_bold;
public static PFont _pixel_font_10;
public static PFont _helvetica_12;

import java.util.Comparator;

HashMap<String, String> phoneMap = new HashMap<String, String>();

int pronunciationNum = 1;
boolean whitespace = false;

boolean includeTitle = true;

int startRow = 0;

float scrollPos = 0;
boolean scroll = false;

float sep = 0;
float maxX = 0;

float pScroll = 0;
float mScroll = 0;
float pMax = 0;
float pMin = -100;
float sMin = -240;
float sHeight = 400;

float densityThreshold = 30;
float devThreshold = 20;
float regionThreshold = 15;

int cll = 444;

//clusterer _clusterer;
boolean gridOn = true;
boolean meshSegsOn = false;
boolean bundleOn = false;
boolean join = true;
boolean drawAll = false;
boolean colorOn = true;

int degs = 2;
float tightness = 1.1;
int numClusters = 1;
boolean charsOn = true;
boolean rhymesOn = true;
float sWeight = 1;
boolean delaunay = false;
boolean gridBased = true;
boolean clusterAtNodes = true;


int hoverSomething = 0;

boolean junk = false;
boolean geowish = false;
boolean curves = true;
boolean annotatedGraph = false;
boolean nodesOn = true;
boolean showInteractions = false;
boolean separate = false;
boolean multipleCPts = true;
boolean checkDupes = true;
boolean graphNodesOn = true;
boolean hairball = false;
boolean hairball_c = false;
boolean tCurves = false;
int spline = 0;
float strokeW = 1.25;
float strokeWOg = 1.25;
float scale = 1.0;
boolean setScale = true;

//for side-by-side
double prevDeg = 500; //if 500, null
int prevState = 0;
double prevTheta = 500;

//ArrayList<pointer> setPointers = new ArrayList<pointer>();

//make the entire _text_view global
TextView _text_view;
//second popup
//PFrame f;
//secondApplet notationView;
float PX, PY;
int graphViewX, graphViewY;
float ct = 0.0;    //curve tightness

int colorScheme = 0;
boolean noloop = true;
boolean itReroute = true;
int ptrCounter = 0;
int reroutes = 0;
int pass = 0;
boolean useBest = true;
boolean adapt = false;

boolean isempty = true;
PVector prevPT = new PVector(0, 0);

ArrayList< ArrayList<Set> > RhymeSets = new ArrayList< ArrayList<Set> >();  
ArrayList<Set> customSets = new ArrayList<Set>();
Set _customSet;

ArrayList<node> nodeLocs = new ArrayList<node>();
ArrayList<PVector> pNodes = new ArrayList<PVector>();
ArrayList<PVector> pNodes1 = new ArrayList<PVector>();
ArrayList<PVector> pNodes2 = new ArrayList<PVector>();
ArrayList<String> absLoc = new ArrayList<String>();

Map<PVector, ArrayList<pointer>> routeCPsT;
Map<PVector, ArrayList<pointer>> routeCPs = new HashMap<PVector, ArrayList<pointer>>();
Map<PVector, ArrayList<pointer>> routeCPs1 = new HashMap<PVector, ArrayList<pointer>>();
Map<PVector, ArrayList<pointer>> routeCPs2 = new HashMap<PVector, ArrayList<pointer>>();
Map<PVector, ArrayList<pointer>> bundleCPs = new HashMap<PVector, ArrayList<pointer>>();

Map<Integer, ArrayList<midpoint>> mids = new HashMap<Integer, ArrayList<midpoint>>();
Map<Integer, ArrayList<midpoint>> mids1 = new HashMap<Integer, ArrayList<midpoint>>();
Map<Integer, ArrayList<midpoint>> mids2 = new HashMap<Integer, ArrayList<midpoint>>();

//Map<PVector, Integer> nodeHash = new HashMap<PVector, Integer>();

ArrayList<pointer> prevSetPointers = new ArrayList<pointer>();

ArrayList<pointer> setPointers = new ArrayList<pointer>();
ArrayList<pointer> hoveredPtrs = new ArrayList<pointer>();
ArrayList<pShape> shapes = new ArrayList<pShape>();
ArrayList<pShape3> shapes3 = new ArrayList<pShape3>();
ArrayList<pShape3> shapes31 = new ArrayList<pShape3>();
ArrayList<pShape3> shapes32 = new ArrayList<pShape3>();

//DamerauLevenshteinAlgorithm DLs = new DamerauLevenshteinAlgorithm(1, 1, 1, 1);
//Set _customSet;
//cSet _customcSet;
ArrayList<Word> customWords = new ArrayList<Word>();

int d = 2;

ArrayList<rhymerule> rules = new ArrayList<rhymerule>();
ArrayList<rhymerule> existingRules = new ArrayList<rhymerule>();

//RhymeDesign Globals
boolean combineRules = false;

int idCount = 0;

int[] pronNumbers;
String[] customPron;

Word[] currWords1, currWords2; //for crossWords
boolean comment = false;

int _w, _h, _min_w, _min_h;

float rSet_x = 50;
float mSet_x = 50;
float rSet_y = 15;

float graphX = 0;
float graphY = 0;

float nodeSep = 30;
int mode = 0;
//global quadtree vars
QuadTree QT;
QuadTree QT2 = null;
boolean newAmb = false;
tr tr_top, tr_bottom;
filterH hfilt;
filterL lfilt;
//poemage node limits
float y0,y1;

//hotkeys
boolean fill = false;
boolean hbhover = false;
int tx = 30;
int ty = 0;

int cr = 1;
int g = 2;
int xs = 1;

boolean visActive = true;
boolean sonActive = true;

int maxSet = 0;

boolean order = false;
PGraphics pg;
PGraphics gradient;
PGraphics gc;

rhymerule eye2;
//
InputStream isT;

boolean showWords = false;

float resView = 350;
boolean comment2 = false; //Hooray!
//do avoid repeated updates
ArrayList<pointer> updatePtrs = new ArrayList<pointer>();
