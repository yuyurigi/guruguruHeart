import java.util.Calendar;

float radius = 20;     // 最初の四角の大きさ(直径/2)
float addRadius = 10.0; //線と線の間隔（数字が小さいと狭い）
float thickness = 22; //線の太さ
PVector[] vertex = {};
float[] vertexX = {};
float[] vertexY= {};
int vc = 0;
float SCALE = 1.0; 
boolean b = true;
boolean b2 = true;
PVector Pos, Ac, mp;
float hRad, hDeg, hAng, lastAng, tr, amt;
int angle, colorDist;
color[] c = {#ffffff, #a0cbee, #bde1df};
int ce0 = c.length-1;
int ce1 = 0;
float amtValue = 0.01; //色の変化量

void setup() {
  frameRate(360);
  size(800, 800);

  background(#f0f0f0);
  noStroke();

  PVector center = new PVector(width/2, height/2);

  Ac = new PVector();

  //四角形の頂点を配列に代入
  float ang = 90;
  for (int i = 0; i <=6*4; i++) { //うずまき6週*４頂点
    float rad = radians(ang);
    float x =  center.x + (radius*cos(rad));
    float y = center.y+ (radius* sin(rad));
    vertex = (PVector[]) append(vertex, new PVector(x, y));
    vertexX = append(vertexX, x);
    vertexY = append(vertexY, y);
    radius += addRadius;
    ang  += 90;
  }

  //Pos = vertex[0];

  //ハートが真ん中に表示されるようy座標を変える
  //ハートの一番高い部分のy座標を計算する
  float lasty = height/2;
  PVector mp0 = calcMidPoint(vertex[vertex.length-3], vertex[vertex.length-2]);
  float rad = PVector.dist(mp0, vertex[vertex.length-3]);
  float ang0 = atan2(vertex[vertex.length-3].y-mp0.y, vertex[vertex.length-3].x-mp0.x);
  float deg = degrees(ang0);
  for (int i = 0; i <= 180; i++) {
    float y = mp0.y + (rad*sin(radians(deg)));
    deg += 1;
    if (y < lasty) {
      lasty = y;
    }
  }
  PVector top = new PVector(vertex[vertex.length-1].x, lasty);
  PVector hcenter = calcMidPoint(vertex[vertex.length-1], top);
  tr = dist(hcenter.x, hcenter.y, center.x, center.y);
}

void draw() {
  translate(0, tr);
  if (b) {
    Pos = vertex[vc];

    float dist0 = PVector.dist(Pos, vertex[vc+1]);
    colorDist = ceil(dist0);

    //線の色を変える
    if (vc!=0 && vc%4 == 0) {
      amt = 0;
      ce0 = (ce0 < c.length-1 ? ce0+1 : 0); 
      ce1 = (ce1 < c.length-1 ? ce1+1 : 0);
    }
    
  } //b

  b = false;

  if (vc%4 == 0 || vc%4 == 3) { //直線部分
    //Posと次の頂点との距離
    float dist = PVector.dist(Pos, vertex[vc+1]);
    Ac = PVector.sub(vertex[vc+1], Pos); //次の頂点に向かうベクトルを計算
    Ac.normalize(); //単位ベクトル化

    if (dist>1) {
      Pos.add(Ac.x*SCALE, Ac.y*SCALE);
    } else {
      PVector m = new PVector();
      m = PVector.sub(vertex[vc+1], Pos);
      Pos.add(m.x, m.y);
    }

    if (dist<=0 && vc < vertex.length-2) { //線が角まで来たら
      b = true;
      b2 = true;
      vc += 1;
    }

    //ハートの丸い部分
  } else if (vc%4 == 1 || vc%4 == 2) {
    if (b2) {
      mp = calcMidPoint(vertex[vc], vertex[vc+1]);
      hRad = PVector.dist(mp, vertex[vc]);
      hAng = atan2(vertex[vc].y - mp.y, vertex[vc].x - mp.x);
      hDeg = degrees(hAng);
      angle = 0;
    }
    b2 = false;
    Pos.x = mp.x + (hRad*cos(radians(hDeg)));
    Pos.y = mp.y + (hRad*sin(radians(hDeg)));
    if (angle<180) {
      hDeg += 1;
      angle += 1;
    } else {
      if (vc < vertex.length-2) {
        vc += 1;
        b = true;
        b2 = true;
      }
    }
  }

  //線の色 
  if (vc%4 == 0) {
    amt = (colorDist<1/amtValue ? amt+0.03 : amt+amtValue); //次の頂点までの距離が短いときは+0.03,それ以外は+amtValue
  }

  if (vc%4 != 0 || vc == 0) { //(頂点を4で割って余りが1~3のとき、頂点が0のとき）
    fill(c[ce1]);
  } else { //(頂点を4で割って余りが0のとき、色がグラデーションで変わる）
    color interA = lerpColor(c[ce0], c[ce1], amt);
    fill(interA);
  }
  ellipse(Pos.x, Pos.y, thickness, thickness); //線を描く
}

//辺の中点を計算する
PVector calcMidPoint(PVector end1, PVector end2) {
  float mx, my;
  if (end1.x > end2.x) {
    mx = end2.x + ((end1.x - end2.x)/2);
  } else {
    mx = end1.x + ((end2.x - end1.x)/2);
  }
  if (end1.y > end2.y) {
    my = end2.y + ((end1.y - end2.y)/2);
  } else {
    my = end1.y + ((end2.y - end1.y)/2);
  }
  PVector cMP = new PVector(mx, my);
  return cMP;
}

void keyPressed() {
  if (key == 's' || key == 'S')saveFrame(timestamp()+"_####.png");
  if (key == ' ' ) { //ぐにゃぐにゃ
    fill(#f0f0f0);
    rect(0, 0, width, height);
    vc = 0;
    b = true;
    b2 = true;
    Pos.set(vertex[vc].x, vertex[vc].y);
  }
  if (key == 'R' || key == 'r') { //再描画
    fill(#f0f0f0);
    rect(0, 0, width, height);
    vc = 0;
    b = true;
    b2 = true;
    for (int i = 0; i < vertex.length; i++) {
      vertex[i].set(vertexX[i], vertexY[i]);
    }
  }
}


String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
