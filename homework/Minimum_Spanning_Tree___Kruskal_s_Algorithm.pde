import java.util.ArrayList;
import java.util.Collections;

ArrayList<PVector> vertices = new ArrayList<PVector>();
ArrayList<Edge> mst = new ArrayList<Edge>();
int selectedVertex = -1; // 드래그 중인 점 인덱스
float totalWeight = 0;

void setup() {
  size(800, 600);
  // 초기 기본 정점 8개 배치
  for (int i = 0; i < 8; i++) {
    vertices.add(new PVector(random(100, width - 100), random(100, height - 100)));
  }
  calculateKruskal();
}

void draw() {
  background(245); // 밝은 배경 테마

  // 1. 계산된 MST 간선 및 가중치(거리) 표시
  for (Edge e : mst) {
    stroke(30, 130, 230);
    strokeWeight(3);
    line(e.u.x, e.u.y, e.v.x, e.v.y);

    // 간선 중앙에 거리(가중치) 텍스트 표시
    float midX = (e.u.x + e.v.x) / 2;
    float midY = (e.u.y + e.v.y) / 2;
    fill(245);
    noStroke();
    rectMode(CENTER);
    rect(midX, midY, 36, 18, 4);
    
    fill(60);
    textAlign(CENTER, CENTER);
    textSize(11);
    text(int(e.weight), midX, midY);
  }

  // 2. 정점(노드) 및 번호 그리기
  for (int i = 0; i < vertices.size(); i++) {
    PVector v = vertices.get(i);
    stroke(30, 130, 230);
    strokeWeight(2);
    fill(i == selectedVertex ? color(255, 200, 0) : color(255));
    ellipse(v.x, v.y, 24, 24);

    fill(30);
    textAlign(CENTER, CENTER);
    textSize(12);
    text(i, v.x, v.y);
  }

  // 3. 상단 안내 및 정보 표시
  fill(40);
  textAlign(LEFT, TOP);
  textSize(13);
  text("Left Click: Add Node  |  Drag Node: Move  |  Right Click Node: Delete  |  C: Clear", 20, 20);
  text("Total MST Cost: " + int(totalWeight) + "  (Nodes: " + vertices.size() + ", Edges: " + mst.size() + ")", 20, 42);
}

void mousePressed() {
  // 기존 정점을 클릭했는지 확인
  for (int i = vertices.size() - 1; i >= 0; i--) {
    if (dist(mouseX, mouseY, vertices.get(i).x, vertices.get(i).y) < 15) {
      if (mouseButton == LEFT) {
        selectedVertex = i; // 드래그 시작
      } else if (mouseButton == RIGHT) {
        vertices.remove(i); // 우클릭 시 삭제
        calculateKruskal();
      }
      return;
    }
  }

  // 빈 공간 좌클릭 시 새 정점 추가
  if (mouseButton == LEFT) {
    vertices.add(new PVector(mouseX, mouseY));
    selectedVertex = vertices.size() - 1;
    calculateKruskal();
  }
}

void mouseDragged() {
  // 정점 드래그 시 실시간으로 MST 재계산
  if (selectedVertex != -1) {
    vertices.get(selectedVertex).set(mouseX, mouseY);
    calculateKruskal();
  }
}

void mouseReleased() {
  selectedVertex = -1;
}

void keyPressed() {
  if (key == 'c' || key == 'C') {
    vertices.clear();
    mst.clear();
    totalWeight = 0;
  }
}

// 크루스칼 알고리즘 즉시 계산
void calculateKruskal() {
  mst.clear();
  totalWeight = 0;
  if (vertices.size() < 2) return;

  ArrayList<Edge> allEdges = new ArrayList<Edge>();
  for (int i = 0; i < vertices.size(); i++) {
    for (int j = i + 1; j < vertices.size(); j++) {
      allEdges.add(new Edge(i, j, vertices.get(i), vertices.get(j)));
    }
  }

  Collections.sort(allEdges);
  UnionFind uf = new UnionFind(vertices.size());

  for (Edge e : allEdges) {
    if (uf.union(e.uIndex, e.vIndex)) {
      mst.add(e);
      totalWeight += e.weight;
      if (mst.size() == vertices.size() - 1) break;
    }
  }
}

class Edge implements Comparable<Edge> {
  int uIndex, vIndex;
  PVector u, v;
  float weight;

  Edge(int uIndex, int vIndex, PVector u, PVector v) {
    this.uIndex = uIndex;
    this.vIndex = vIndex;
    this.u = u;
    this.v = v;
    this.weight = dist(u.x, u.y, v.x, v.y);
  }

  @Override
  public int compareTo(Edge other) {
    return Float.compare(this.weight, other.weight);
  }
}

class UnionFind {
  int[] parent;

  UnionFind(int size) {
    parent = new int[size];
    for (int i = 0; i < size; i++) parent[i] = i;
  }

  int find(int i) {
    if (parent[i] == i) return i;
    return parent[i] = find(parent[i]);
  }

  boolean union(int i, int j) {
    int rootI = find(i);
    int rootJ = find(j);
    if (rootI != rootJ) {
      parent[rootI] = rootJ;
      return true;
    }
    return false;
  }
}
