import java.util.Map;
import java.awt.Polygon;

String imgName = "img.jpg";
int N = 1000;
int point_radius = 1;

ArrayList<Point> points;
Grid g;
float chunkwidth = 50;
PImage img;
int b = 2;
boolean drawImg = false;
boolean showPoints = false;
boolean drawRect = false;
boolean noBorder = false;
float pMouseX, pMouseY, dx, dy;

class Grid {
  ArrayList<ArrayList<ArrayList<Point>>> grid;
  float w; 
  float h;
  float chunkWidth;
  boolean visible = false;
  
  Grid(float w, float h, float chunkWidth, ArrayList<Point> points) {
    this.w = w;
    this.h = h;
    this.chunkWidth = chunkWidth;
    grid = new ArrayList<ArrayList<ArrayList<Point>>>();
    for(int i = 0; i < ((img.height + 100) / chunkWidth) + 1; i++) {
      float limYmin = i * chunkWidth - chunkWidth;
      float limYmax = i * chunkWidth;
      ArrayList<ArrayList<Point>> row = new ArrayList<ArrayList<Point>>();
      for(int j = 0; j < ((img.width + 100) / chunkwidth) + 1; j++) {
        float limXmin = j * chunkWidth - chunkWidth;
        float limXmax = j * chunkWidth;
        ArrayList<Point> col = new ArrayList<Point>();
        for(int k = 0; k < points.size(); k++) {
          Point p = points.get(k);
          if (p.x >= limXmin && p.x < limXmax && p.y >= limYmin && p.y < limYmax) {
            col.add(p);
          }
        }
        row.add(col);
      }
      grid.add(row);
    }
    
    for(int r = 0; r < grid.size(); r++) {
      ArrayList<ArrayList<Point>> row = grid.get(r);
      for(int c = 0; c < row.size(); c++) {
        ArrayList<Point> col = row.get(c);
        ArrayList<Point> surrounding = new ArrayList<Point>();
        for(int i = r - b; i < r + b + 1; i++) {
          for(int j = c - b; j < c + b + 1; j++) {
            if (i < 0 || j < 0) continue;
            if (i >= grid.size() || j >= row.size()) continue;
            surrounding.addAll(grid.get(i).get(j));
          }
        }
        System.out.println(Integer.toString(r) + "," +Integer.toString(c) +","+Integer.toString(col.size())+","+Integer.toString(surrounding.size()));
        for(int p = 0; p < col.size(); p++) {
          col.get(p).makeOutlinePolygon(surrounding);
          col.get(p).polygon_color = color(random(255), random(255), random(255));
        }
      }
    }
  }
  ArrayList<Point> getSurroundingChunkPoints(Point p, int b) {
    ArrayList<Point> res = new ArrayList<Point>();
    for (int i = 0; i < grid.size(); i++) {
      float limYmin = i * chunkWidth - chunkWidth;
      float limYmax = i * chunkWidth;
      for(int j = 0; j < grid.get(i).size(); j++) {
        float limXmin = j * chunkWidth - chunkWidth;
        float limXmax = j * chunkWidth;
        if(limXmin <= p.x && limYmin <= p.y && limXmax > p.x && limYmax > p.y) {
          for(int r = i-b; r < i + b+1; r++) {
            for(int c = j-b; c < j+b+1; c++) {
              if (r > grid.size()) continue;
              if (c > grid.get(0).size()) continue;
              res.addAll(grid.get(r).get(c));
            }
          }
        }
      }
    }
    return res;
  }
  ArrayList<Point> getChunkPoints(Point p) {
    for (int i = 0; i < grid.size(); i++) {
      float limYmin = i * chunkWidth - chunkWidth;
      float limYmax = i * chunkWidth;
      for(int j = 0; j < grid.get(i).size(); j++) {
        float limXmin = j * chunkWidth - chunkWidth;
        float limXmax = j * chunkWidth;
        if(limXmin <= p.x && limYmin <= p.y && limXmax > p.x && limYmax > p.y) {
          return grid.get(i).get(j);
        }
      }
    }
    return null;
  }
  void draw() {
    if (visible) {
      stroke(0);
      for (int i = 0; i < grid.size(); i++) {
        float limYmin = i * chunkWidth - chunkWidth;
        float limYmax = i * chunkWidth;
        for(int j = 0; j < grid.get(i).size(); j++) {
          float limXmin = j * chunkWidth - chunkWidth;
          float limXmax = j * chunkWidth;
          rect(limXmin, limYmin, limXmax-limXmin, limYmax-limYmin);
        }
      }
    }
  }
}
class Colour {
  float r, g, b;
  Colour() {
    r = 0;
    g = 0;
    b = 0;
  }
  Colour(color c) {
    r = red(c);
    g = green(c);
    b = blue(c);
  }
}
class Point {
    float x;
    float y;
    float r;
    ArrayList<Point> polygon;
    ArrayList<Colour> colours;
    color polygon_color;
    ArrayList<Point> parents;
    Polygon polygonArea;
    Point(float x, float y) {
      this(x, y, 50);
    }
    Point(float x, float y, float r) {
      this.x = x;
      this.y = y;
      this.r = r;
      polygon_color = color(0,0,0);
      polygon = new ArrayList<Point>();
      parents = new ArrayList<Point>();
      colours = new ArrayList<Colour>();
    }
    public Point diffBA(Point b) {
      float px = b.x-x;
      float py = b.y-y;
      return new Point(px,py);
    }
    public boolean approxPointInPolygon(Point p) {
      if (polygonArea == null) {
        polygonArea = new Polygon();
        for(Point p2: polygon) {
          polygonArea.addPoint((int)(p2.x*100), (int)(p2.y*100));
        }
      }
      return polygonArea.contains((int)(p.x*100), (int)(p.y*100));
    }
    public float theta() {
      if (x == 0) return PI/2;
      else if (y == 0) return 0;
      else return abs(atan(y/x));
    }
    public int quadrant() {
      if (x > 0) {
        if (y >= 0) return 1;
        else return 4;
      } else if(x == 0) {
        if (y >= 0) return 2;
        else return 4;
      } else {
        if (y >= 0) return 2;
        else return 3;
      }
    }
    public float distanceFrom(Point p) {
      return centerDistanceFrom(p) - r - p.r;
    }
    public float centerDistanceFrom(Point p) {
      return sqrt(pow(p.x-x, 2) + pow(p.y - y, 2));
    }
    public String toString() {
      return "{"+Float.toString(x)+","+Float.toString(y)+","+Float.toString(r)+"}";
    }
    public void makeOutlinePolygon(ArrayList<Point> points) {
      Point a = this;
      for(int i = 0; i < points.size(); i++) {
        Point b = points.get(i);
        int parentCount = 0;
        if (a == b) continue;
        for(Point v: polygon) {
          for(Point parent: v.parents) {
            if (b == parent) parentCount++;
          }
        }
        if (parentCount >= 2) continue;
        LineFunc bL = a.getMidPointLine(b);
        for( int j = i+1; j < points.size(); j++) {
          Point c = points.get(j);
          if (c == a) continue;
          LineFunc cL = a.getMidPointLine(c);
          Point n = bL.intersect(cL);
          if (n != null) {
            n.parents.add(a);
            n.parents.add(b);
            n.parents.add(c);
            float anr = a.centerDistanceFrom(n);
            boolean valid = true;
  
            for( int k = 0; k < points.size(); k++) {
              Point d = points.get(k);
              if ((d == a) || (d == b) || (d == c)) continue;
              float dnr = d.centerDistanceFrom(n);
              if (dnr < anr) valid = false;
            }
            if (valid) {
              polygon.add(n);
              b.addPolygonVertex(n);
              c.addPolygonVertex(n);
            }
          }
        }
      }
    }
    void addPolygonVertex(Point v) {
      polygon.add(v);
    }
    ArrayList<Point> getOrderedList(ArrayList<Point> polygon) {
      ArrayList<Point> p2 = new ArrayList<Point>();
      ArrayList<Point> q1 = new ArrayList<Point>();
      ArrayList<Point> q2 = new ArrayList<Point>();
      ArrayList<Point> q3 = new ArrayList<Point>();
      ArrayList<Point> q4 = new ArrayList<Point>();
      for(int i = 0; i < polygon.size(); i++) {
        Point v = polygon.get(i);
        Point d = diffBA(v);
        switch(d.quadrant()) {
          case 1:
            insertByAngle(q1, v);
            break;
          case 2:
            insertByAngle(q2, v);
            break;
          case 3:
            insertByAngle(q3, v);
            break;
          case 4:
            insertByAngle(q4, v);
            break;
        }
      }
      for(int i = 0; i < q1.size(); i++) {
        p2.add(q1.get(i));
      }
      for(int i = q2.size() - 1; i >= 0; i--) {
        p2.add(q2.get(i));
      }
      for(int i = 0; i < q3.size(); i++) {
        p2.add(q3.get(i));
      }
      for(int i = q4.size() - 1; i >= 0; i--) {
        p2.add(q4.get(i));
      }
      return p2;
    }
    void insertByAngle(ArrayList<Point> list, Point p) {
      if (list.size() != 0) {
        Point d = diffBA(p);
        float theta = d.theta();
        for( int i = 0; i < list.size(); i++) {
          Point p2 = list.get(i);
          Point d2 = diffBA(p2);
          float theta2 = d2.theta();
          if (theta2 > theta) {
            list.add(i, p);
            return;
          }
        }
      }
      list.add(p);
    }
    public LineFunc getMidPointLine(Point b) {
      Point m = getMidpoint(b);
      return new LineFunc(m, this, b);
    }
    public Point getMidpoint(Point b) {
      Point a = this;
      float vABx = b.x - a.x;
      float vABy = b.y - a.y;
      float absvAB = sqrt(pow(vABx, 2) + pow(vABy, 2));
      float Aradx = a.x + a.r/absvAB * vABx;
      float Arady = a.y + a.r/absvAB * vABy;
      float lm = absvAB - a.r - b.r;
      float mx = Aradx + vABx * lm / absvAB / 2;
      float my = Arady + vABy * lm / absvAB / 2;
      Point m = new Point(mx,my,a.r*0.25);
      return m;
    }
    void draw() {
      circle(x, y, r*2);
    }
    void drawPolygon() {
      if(noBorder) stroke(polygon_color);
      else stroke(0);

      fill(polygon_color);
      if (polygon.size() > 2) {
        beginShape();
        for(int j = 0; j < polygon.size(); j++) {
          Point v = polygon.get(j);
          vertex(v.x, v.y);
        }
        endShape(CLOSE);
      }
    }
}
class LineFunc {
  Point o;
  float vX;
  float vY;
  LineFunc(Point origin, Point a, Point b) {
    this.o = origin;
    vX = - (b.y - a.y);
    vY = b.x - a.x;
  }
  public Point getNormalVector() {
    float absV = sqrt(pow(vX, 2) + pow(vY, 2));
    float pX = vX / absV;
    float pY = vY / absV;
    if (pX < 0) {
      pX = -pX;
      pY = -pY;
    }
    if (pX == 0 && pY < 0) {
      pY = -pY;
    }
    return new Point(pX, pY);
  }
  public Point intersect(LineFunc cL) { 
    LineFunc bL = this;
    Point cV = cL.getNormalVector();
    Point bV = bL.getNormalVector();
    if (cV.x == bV.x && cV.y == bV.y) return null;
    float t = (bV.y * (cL.o.x - bL.o.x) - bV.x * (cL.o.y - bL.o.y)) / (bV.x * cV.y - bV.y * cV.x);
    float inX = cL.o.x + t * cV.x;
    float inY = cL.o.y + t * cV.y;
    return new Point(inX, inY, bL.o.r*0.75);
  }
  void draw() {
    o.draw();
    line(o.x, o.y, o.x+vX, o.y+vY);
  }
}


void setup() {
  img = loadImage(imgName);
  size(1000,500);
  img.resize(width,0);
  if (img.height > height) img.resize(0,height);
  points = new ArrayList<Point>();
  for(int i = 0; i < N; i++) {
    Point p;
    while(true) {
      p = new Point(random(img.width + 100) - 50, random(img.height + 100) - 50,point_radius);
      boolean b = true;
      for(int j = 0; j < points.size(); j++) {
        Point p2 = points.get(j);
        if (p2.distanceFrom(p) < 0) {
          b = false;
          break;
        }
      }
      if (b)break;
    }
    points.add(p);
  }
  System.out.println("done!");
  
  g = new Grid(img.width, img.height, chunkwidth, points);
  
  for(int i = 0; i < points.size(); i++) {
    Point p = points.get(i);
    p.polygon = p.getOrderedList(p.polygon);
  }
  
  for(int x = 0; x < img.width; x++) {
    for(int y = 0; y < img.height; y++) {
      Point cp = new Point(x, y);
      color c = img.get(x,y);
      Colour cc = new Colour(c);
      ArrayList<Point> s = g.getSurroundingChunkPoints(cp, 1);
      if (s == null) s = points;
      for(Point p: s) {
        if (p.approxPointInPolygon(cp)) {
          p.colours.add(cc);
        }
      }
    }
  }
  for(Point p: points) {
    Colour c = new Colour();
    for (Colour cc: p.colours) {
      c.r += cc.r;
      c.g += cc.g;
      c.b += cc.b;
    }
    c.r = c.r/p.colours.size();
    c.g = c.g/p.colours.size();
    c.b = c.b/p.colours.size();
    p.polygon_color = color(c.r, c.g, c.b);
  }

}

void draw() {
  background(255);
  translate(dx, dy);
  for(int i = 0; i < points.size(); i++) {
    Point p = points.get(i);
    if (i == 0) fill(255,0,0);
    else if (i == 1) fill(255,0,255);
    else fill(255,150,0);
    p.drawPolygon();
    if(showPoints)p.draw();
  }
  
  Point mouse = new Point(mouseX-dx, mouseY-dy);
  for(int i = 0; i < points.size(); i++) {
    Point p = points.get(i);
    if (p.centerDistanceFrom(mouse) < p.r) {
      for(int j = 0; j < p.polygon.size(); j++) {
        Point v = p.polygon.get(j);
        fill(255);
        ellipse(v.x+16, v.y-5, 50, 25);
        fill(0);
        Point d = p.diffBA(v);
        text(Integer.toString(j) + ":" + Integer.toString(d.quadrant())+ ":" + Integer.toString((int)(d.theta() * 180 / PI)), p.polygon.get(j).x,p.polygon.get(j).y);
      }
    }
  }
  ArrayList<Point> subset = g.getChunkPoints(mouse);
  if (subset != null) {
    for(Point p: subset) {
      fill(255);
      p.draw();
    }
  }

  noFill();
  g.draw();
  if(drawRect) rect(0,0,img.width,img.height);
  if(drawImg) image(img, 0, 0);
}

void keyPressed() {
  if (key == 'g') {
    g.visible = !g.visible;
  }
  if (key == 'p') {
    showPoints = !showPoints;
  }
  if (key == 's') {
    dx = 0;
    dy = 0;
  }
  if (key == 'b') {
    noBorder = !noBorder;
  }
  if (key == 'r') {
    drawRect = !drawRect;
  }
  if (key == 'i') {
    drawImg = !drawImg;
  }
  if (key == ' ') {
    PImage i = get(0,0,img.width,img.height);
    String filename = String.format("%04d%02d%02d_%02d%02d%02d_%05d.jpg", year(), month(), day(), hour(), minute(), second(),N);
    i.save(filename);
  }
}
void mousePressed() {
  pMouseX = mouseX;
  pMouseY = mouseY;
}

void mouseDragged() {
  dx -= (pMouseX - mouseX);
  dy -= (pMouseY - mouseY);
  pMouseX = mouseX;
  pMouseY = mouseY;
}
