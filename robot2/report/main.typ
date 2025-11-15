#import "template.typ": *
#import "@preview/cram-snap:0.2.2": *
#set outline(title: "目录")

#show: bubble.with(
  title: "机器人学研讨课2",
  author: "尹超",
  affiliation: "中国科学院大学\nUniversity of Chinese Academy of Sciences",
  // date: datetime.today().display(),
  subtitle: "实践报告",
  date: "2025.11.14",
  year: "2025",
  class: "2313AI",
  other: ("Template:https://github.com/hzkonor/bubble-template",
  "GitHub:https://github.com/CarterYin"),
  //main-color: "4DA6FF", //set the main color
  logo: image("cas_logo/CAS_logo.png"), //set the logo
  //"My GitHub:https://github.com/CarterYin"
) 

#outline()
#pagebreak()

= 实践任务1内容
通过开关及电位器点亮并调节LED亮度

要求：
+ 尝试使用外接下拉电阻或使用单片机内部上拉电阻读取开关状态；

+ 尝试使用数字输出，按住开关时LED亮，松开开关时LED灭；

+ 尝试使用模拟输出，通过电位器调节LED亮度；

+ 尝试使用数字输出，通过每按一下开关切换LED当前状态（可使用ezButton library）；

+ 针对1-4，通过Serial Monitor反馈相关信号；

= Question 1
+ 尝试使用外接下拉电阻或使用单片机内部上拉电阻读取开关状态；

== 代码实现
```cpp
const int DIN_PIN = 7;

void setup(){
  pinMode(DIN_PIN,INPUT_PULLUP);
  Serial.begin(9600);
}

void loop(){
  int value;

  value = digitalRead(DIN_PIN);
  Serial.println(value);

  delay(1000);
}
```
=== 代码说明
+ 使用单片机内部上拉电阻读取开关状态；
+ 当开关闭合时，读取值为0，断开时读取值为1。

== 实验场景照片

#figure(
  image("assets/q1.jpg", width: 100%),
   caption: "Question 1 实验场景照片",
)

== 电路连线示意图

#figure(
  image("sketch/q1.png", width: 60%),
   caption: "Question 1 电路连线示意图",
)

== 运行实际效果
#link("assets/q1.mp4")[点击查看视频演示 (q1.mp4)]

#link("https://www.bilibili.com/video/BV1ktCuBTEy8/?vd_source=800127bf08c7aa59280ffeb458e19abc")[点击查看B站视频演示]
= Question 2
+ 尝试使用数字输出，按住开关时LED亮，松开开关时LED灭；

== 代码实现
```cpp
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
```
=== 代码说明
+ 使用单片机内部上拉电阻读取开关状态；
+ 当开关闭合时，LED点亮，断开时LED熄灭。

== 实验场景照片
#figure(
  image("assets/q2.jpg", width: 90%),
   caption: "Question 2 实验场景照片",
)

== 电路连线示意图

#figure(
  image("sketch/q2.png", width: 60%),
   caption: "Question 2 电路连线示意图",
)

== 运行实际效果
#link("assets/q2.mp4")[点击查看视频演示 (q2.mp4)]

#link("https://www.bilibili.com/video/BV1ktCuBTEaT/?vd_source=800127bf08c7aa59280ffeb458e19abc")[点击查看B站视频演示]
= Question 3
+ 尝试使用模拟输出，通过电位器调节LED亮度；

== 代码实现
```cpp
// 定义引脚
const int potPin = A0;    // 电位器连接到模拟输入 A0
const int ledPin = 9;     // LED 连接到支持 PWM 的数字引脚 9

void setup() {
  // 设置 LED 引脚为输出模式
  pinMode(ledPin, OUTPUT);
  
  // 初始化串口，用于调试和查看数值（可选）
  Serial.begin(9600);
  Serial.println("LED Brightness Control Ready.");
}

void loop() {
  // 1. 读取电位器的模拟值 (0 到 1023)
  int potValue = analogRead(potPin);

  // 2. 将模拟值 (0-1023) 映射到 PWM 范围 (0-255)
  // map() 函数用于线性转换数值范围
  int brightness = map(potValue, 0, 1023, 0, 255);

  // 3. 使用模拟输出 (analogWrite) 设置 LED 亮度
  // analogWrite() 实际是输出 PWM 信号
  analogWrite(ledPin, brightness);

  // 4. 串口输出当前值（可选）
  Serial.print("Pot Value: ");
  Serial.print(potValue);
  Serial.print(" -> Brightness (PWM): ");
  Serial.println(brightness);

  // 稍作延迟，保持稳定读取
  delay(10); 
}
```
=== 代码说明
+ 读取电位器的模拟值，并将其映射到PWM范围以调节LED亮度；
+ 通过串口监视器输出电位器值和对应的PWM亮度值。

== 实验场景照片
#figure(
  image("assets/q3.jpg", width: 84%),
   caption: "Question 3 实验场景照片",
)

== 电路连线示意图

#figure(
  image("sketch/q3.png", width: 60%),
   caption: "Question 3 电路连线示意图",
)

== 运行实际效果
#link("assets/q3.mp4")[点击查看视频演示 (q3.mp4)]

#link("https://www.bilibili.com/video/BV1AtCuBMEpJ/?vd_source=800127bf08c7aa59280ffeb458e19abc")[点击查看B站视频演示]

= Question 4
+ 尝试使用数字输出，通过每按一下开关切换LED当前状态（可使用ezButton library）；
== 代码实现
```cpp
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
```
=== 代码说明
+ 使用ezButton库处理按键输入，避免按键抖动问题；
+ 每次按下开关时，切换LED的当前状态（亮/灭）。

== 实验场景照片
#figure(
  image("assets/q4.jpg", width: 84%),
   caption: "Question 4 实验场景照片",
)
== 电路连线示意图

#figure(
  image("sketch/q2.png", width: 60%),
   caption: "Question 4 电路连线示意图",
)

== 运行实际效果
#link("assets/q4.mp4")[点击查看视频演示 (q4.mp4)]

#link("https://www.bilibili.com/video/BV1AtCuBMEp3/?vd_source=800127bf08c7aa59280ffeb458e19abc")[点击查看B站视频演示]