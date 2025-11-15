const int buttonPin = 2;
const int ledPin = 11;

int buttonState = 0;

void setup() {
  pinMode(ledPin, OUTPUT);
  // *** 关键修改：激活内部上拉电阻 ***
  pinMode(buttonPin, INPUT_PULLUP); 
}

void loop() {
  buttonState = digitalRead(buttonPin);

  // *** 逻辑：当按钮被按下时 (LOW)，灯亮 (HIGH) ***
  if(buttonState == LOW){
      digitalWrite(ledPin, HIGH); // 灯亮
  } else {
      digitalWrite(ledPin, LOW);  // 灯灭
  }
}