// 그래프 탐색 시각화 프로그램 (BFS / DFS)
int[][] graph = {
  {1, 2, 7},   // 1번 노드와 연결된 노드들 (0-indexed: 0, 1, 6)
  {0, 6},      // 2번 노드
  {0, 3, 4},   // 3번 노드
  {2, 4},      // 4번 노드
  {2, 3},      // 5번 노드
  {6},         // 6번 노드
  {1, 5, 7},   // 7번 노드
  {0, 6}       // 8번 노드 (인덱스 7)
};

String[] names = { "1", "2", "3", "4", "5", "6", "7", "8" };

// 각 노드의 화면 좌표 (x, y)
float[][] pos = {
  {500, 100}, // 1번
  {240, 230}, // 2번
  {730, 230}, // 3번
  {650, 440}, // 4번
  {870, 440}, // 5번
  {100, 570}, // 6번
  {240, 440}, // 7번
  {410, 300}  // 8번
};

int totalNodes = 8;
String searchType = ""; // 현재 진행 중인 탐색 종류 (BFS / DFS)
ArrayList<Integer> traversalOrder = new ArrayList<Integer>(); // 탐색 순서 기록
boolean[] visited;

void setup() {
  size(1000, 700);
  smooth();
  visited = new boolean[totalNodes];
}

void draw() {
  background(255);
  
  // 1. 상단 안내 텍스트
  fill(0);
  textSize(22);
  textAlign(CENTER, TOP);
  text("GraphSearch", width / 2, 20);
  
  textSize(16);
  textAlign(LEFT, TOP);
  text("b: BFS    d: DFS    r: reset", 40, 70);
  
  // 2. 간선(선) 먼저 그리기
  stroke(200);
  strokeWeight(3);
  for (int i = 0; i < totalNodes; i++) {
    for (int j = 0; j < graph[i].length; j++) {
      int neighbor = graph[i][j];
      // 중복 그려짐 방지를 위해 i < neighbor 조건 혹은 양방향 선 그리기
      if (i < neighbor) {
        line(pos[i][0], pos[i][1], pos[neighbor][0], pos[neighbor][1]);
      }
    }
  }
  
  // 3. 탐색된 순서에 따라 강조선 그리기 (오렌지색 간선)
  for (int i = 0; i < traversalOrder.size() - 1; i++) {
    int u = traversalOrder.get(i);
    int v = traversalOrder.get(i + 1);
    stroke(243, 156, 18); // 스크린샷의 오렌지색 선
    strokeWeight(4);
    line(pos[u][0], pos[u][1], pos[v][0], pos[v][1]);
  }
  
  // 4. 노드(원과 번호) 그리기
  for (int i = 0; i < totalNodes; i++) {
    // 탐색된 노드 중 마지막(가장 최근) 노드는 빨간색, 나머지는 파란색/회색
    if (traversalOrder.size() > 0 && traversalOrder.get(traversalOrder.size() - 1) == i) {
      fill(231, 76, 60); // 빨간색 (현재 위치)
    } else if (traversalOrder.contains(i)) {
      fill(52, 152, 219); // 파란색 (방문한 노드)
    } else {
      fill(127, 140, 141); // 회색 (미방문 노드)
    }
    
    stroke(44, 62, 80);
    strokeWeight(2);
    ellipse(pos[i][0], pos[i][1], 55, 55);
    
    // 노드 번호 텍스트
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(18);
    text(names[i], pos[i][0], pos[i][1]);
    
    // 노드 라벨 (#1, #2 등)
    fill(100);
    textSize(12);
    text("#" + (i + 1), pos[i][0] + 30, pos[i][1] - 25);
  }
  
  // 5. 하단 탐색 순서 결과 텍스트 출력
  fill(0);
  textSize(16);
  textAlign(LEFT, BOTTOM);
  String resultStr = searchType + " 탐색 순서: ";
  for (int i = 0; i < traversalOrder.size(); i++) {
    resultStr += names[traversalOrder.get(i)];
    if (i < traversalOrder.size() - 1) resultStr += " -> ";
  }
  text(resultStr, 40, height - 40);
}

// 키보드 인터랙션 (b, d, r)
void keyPressed() {
  if (key == 'b' || key == 'B') {
    resetSearch();
    searchType = "BFS";
    runBFS(0); // 1번 노드(인덱스 0)부터 시작
  } else if (key == 'd' || key == 'D') {
    resetSearch();
    searchType = "DFS";
    runDFS(0); // 1번 노드(인덱스 0)부터 시작
  } else if (key == 'r' || key == 'R') {
    resetSearch();
  }
}

void resetSearch() {
  traversalOrder.clear();
  visited = new boolean[totalNodes];
  searchType = "";
}

// 너비 우선 탐색 (BFS) 구현
void runBFS(int startNode) {
  ArrayList<Integer> queue = new ArrayList<Integer>();
  queue.add(startNode);
  visited[startNode] = true;
  
  while (!queue.isEmpty()) {
    int curr = queue.remove(0);
    traversalOrder.add(curr);
    
    for (int i = 0; i < graph[curr].length; i++) {
      int next = graph[curr][i];
      if (!visited[next]) {
        visited[next] = true;
        queue.add(next);
      }
    }
  }
}

// 깊이 우선 탐색 (DFS) 구현
void runDFS(int curr) {
  visited[curr] = true;
  traversalOrder.add(curr);
  
  for (int i = 0; i < graph[curr].length; i++) {
    int next = graph[curr][i];
    if (!visited[next]) {
      runDFS(next);
    }
  }
}
