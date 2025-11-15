#include <ezButton.h>

// 定义引脚
const int buttonPin = 2; // 开关引脚
const int ledPin = 11;   // LED 引脚

// 初始化 ezButton 对象。
// 默认情况下，ezButton 使用内部上拉电阻 (INPUT_PULLUP) 模式。
ezButton button(buttonPin); 

// 状态变量
int ledState = LOW; // 锁存 LED 的当前状态 (LOW=灭, HIGH=亮)

void setup() {
  // 设置 LED 引脚为输出模式
  pinMode(ledPin, OUTPUT);
  
  // 设置 ezButton 的防抖时间（可选，默认是 50ms）
  // 如果您觉得按键响应不好，可以适当调整这个值。
  button.setDebounceTime(50); // 设置 50 毫秒的防抖时间
  
  // 确保 LED 初始状态是灭的
  digitalWrite(ledPin, ledState);
  
  Serial.begin(9600);
  Serial.println("ezButton Toggle Switch Mode Ready.");
}

void loop() {
  // 1. 关键修改：将 button.read() 改为 button.loop()
  button.loop(); 

  // 2. 边沿检测：isPressed() 仅在检测到一次“按下”事件时返回 true
  if (button.isPressed()) {
    // 按下事件被触发，反转 LED 状态
    
    // 切换 LED 状态
    if (ledState == LOW) {
      ledState = HIGH; // 灭 -> 亮
    } else {
      ledState = LOW;  // 亮 -> 灭
    }
    
    // 更新 LED 输出
    digitalWrite(ledPin, ledState);
    
    Serial.print("LED Toggled. Current State: ");
    Serial.println(ledState == HIGH ? "ON" : "OFF");
  }
}