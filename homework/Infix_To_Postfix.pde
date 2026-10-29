ArrayList<String> stack = new ArrayList<String>();
String infixInput = "3 + 5 * ( 2 - 8 )"; // 초기 기본 수식
String postfixResult = "";
float finalAnswer = 0;
boolean hasError = false;

void setup() {
  size(700, 400);
  background(30);
  
  // 초기 수식 계산
  calculate();
}

void draw() {
  background(30);
  
  // 타이틀 및 안내
  fill(150);
  textSize(14);
  text("수식을 입력한 후 ENTER를 누르세요. (백스페이스로 수정 가능)", 50, 60);
  
  // 1. Infix 입력창 (현재 사용자가 수정 중인 수식)
  fill(255);
  textSize(22);
  text("Infix (입력): " + infixInput, 50, 120);
  
  // 커서 깜빡임 효과 (선택사항)
  if ((frameCount / 30) % 2 == 0) {
    float cursorX = 50 + textWidth("Infix (입력): " + infixInput);
    rect(cursorX + 2, 100, 2, 24);
  }
  
  // 구분선
  stroke(70);
  line(50, 160, 650, 160);
  
  // 2. 변환 및 계산 결과 출력
  fill(180, 220, 255);
  textSize(18);
  text("Postfix (후위 표기식): " + postfixResult, 50, 210);
  
  if (hasError) {
    fill(255, 100, 100);
    text("Result (결과): 수식 오류 (괄호나 연산자를 확인하세요)", 50, 260);
  } else {
    fill(100, 255, 100);
    text("Result (결과): " + finalAnswer, 50, 260);
  }
}

// 키보드 입력 처리 함수
void keyPressed() {
  if (key == ENTER || key == RETURN) {
    calculate(); // 엔터를 누르면 계산 실행
  } else if (key == BACKSPACE) {
    if (infixInput.length() > 0) {
      infixInput = infixInput.substring(0, infixInput.length() - 1); // 마지막 글자 지우기
    }
  } else if (key != CODED && key != ESC && key != TAB) {
    infixInput += key; // 문자 추가
  }
}

// 계산 로직 총괄
void calculate() {
  try {
    hasError = false;
    postfixResult = infixToPostfix(infixInput);
    finalAnswer = evaluatePostfix(postfixResult);
  } catch (Exception e) {
    hasError = true;
    finalAnswer = 0;
  }
}

// 연산자 우선순위 반환
int precedence(String op) {
  if (op.equals("+") || op.equals("-")) return 1;
  if (op.equals("*") || op.equals("/")) return 2;
  return 0;
}

// 공백 없이 붙여 쓴 수식도 토큰으로 쪼개주는 파서 구현
String[] tokenize(String input) {
  ArrayList<String> tokens = new ArrayList<String>();
  String numberBuffer = "";
  
  for (int i = 0; i < input.length(); i++) {
    char c = input.charAt(i);
    
    if (c == ' ') continue; // 공백은 무시
    
    if (Character.isDigit(c) || c == '.') {
      numberBuffer += c; // 숫자인 경우 버퍼에 축적
    } else {
      if (!numberBuffer.equals("")) {
        tokens.add(numberBuffer);
        numberBuffer = "";
      }
      tokens.add(String.valueOf(c)); // 연산자나 괄호 추가
    }
  }
  if (!numberBuffer.equals("")) {
    tokens.add(numberBuffer);
  }
  
  return tokens.toArray(new String[0]);
}

// Infix -> Postfix 변환
String infixToPostfix(String infix) {
  String[] tokens = tokenize(infix);
  ArrayList<String> opStack = new ArrayList<String>();
  String postfix = "";
  
  for (String token : tokens) {
    if (isNumeric(token)) {
      postfix += token + " ";
    } else if (token.equals("(")) {
      opStack.add(token);
    } else if (token.equals(")")) {
      while (!opStack.isEmpty() && !opStack.get(opStack.size() - 1).equals("(")) {
        postfix += opStack.remove(opStack.size() - 1) + " ";
      }
      if (!opStack.isEmpty()) opStack.remove(opStack.size() - 1); 
    } else if (token.equals("+") || token.equals("-") || token.equals("*") || token.equals("/")) { 
      while (!opStack.isEmpty() && precedence(opStack.get(opStack.size() - 1)) >= precedence(token)) {
        postfix += opStack.remove(opStack.size() - 1) + " ";
      }
      opStack.add(token);
    }
  }
  
  while (!opStack.isEmpty()) {
    postfix += opStack.remove(opStack.size() - 1) + " ";
  }
  
  return trim(postfix);
}

// Postfix 계산
float evaluatePostfix(String postfix) {
  if (postfix.equals("")) return 0;
  
  String[] tokens = split(postfix, ' ');
  ArrayList<Float> valStack = new ArrayList<Float>();
  
  for (String token : tokens) {
    if (isNumeric(token)) {
      valStack.add(float(token));
    } else if (token.equals("+") || token.equals("-") || token.equals("*") || token.equals("/")) {
      if (valStack.size() < 2) throw new RuntimeException("Invalid Expression");
      float b = valStack.remove(valStack.size() - 1);
      float a = valStack.remove(valStack.size() - 1);
      float res = 0;
      
      if (token.equals("+")) res = a + b;
      else if (token.equals("-")) res = a - b;
      else if (token.equals("*")) res = a * b; 
      else if (token.equals("/")) {
        if (b == 0) throw new RuntimeException("Divide by zero");
        res = a / b;
      }
      valStack.add(res);
    }
  }
  
  if (valStack.size() != 1) throw new RuntimeException("Invalid Expression");
  return valStack.get(0);
}

boolean isNumeric(String str) {
  try {
    Float.parseFloat(str);
    return true;
  } catch(NumberFormatException e) {
    return false;
  }
}
