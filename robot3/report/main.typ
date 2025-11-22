#import "template.typ": *
#import "@preview/cram-snap:0.2.2": *
#set outline(title: "目录")

#show: bubble.with(
  title: "机器人学研讨课3",
  author: "尹超",
  affiliation: "中国科学院大学\nUniversity of Chinese Academy of Sciences",
  // date: datetime.today().display(),
  subtitle: "实践报告",
  date: "2025.11.21",
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

= 实践任务2内容
运用触摸传感器实现伺服电机控制
== 代码实现
```cpp
#include <Servo.h>

// --- 引脚定义 ---
const int SENSOR_PIN = 2;  // 传感器连接引脚 (触摸或PIR)
const int SERVO_PIN = 9;   // 舵机控制引脚

// --- 变量定义 ---
Servo myServo;             // 创建舵机对象
int sensorState = 0;       // 存储传感器当前状态

void setup() {
  // 初始化串口通信，用于调试
  Serial.begin(9600);
  
  // 设置传感器引脚为输入模式
  pinMode(SENSOR_PIN, INPUT);
  
  // 将舵机连接到指定引脚
  myServo.attach(SERVO_PIN);
  
  // 初始化舵机位置为 0 度 (关门状态)
  myServo.write(0);
  Serial.println("系统启动：门已关闭 (0°)");
  delay(500);
}

void loop() {
  // 读取传感器状态
  sensorState = digitalRead(SENSOR_PIN);
  
  // --- 逻辑判断 ---
  // 大多数模块检测到物体/触摸时输出 HIGH (高电平)
  if (sensorState == HIGH) {
    
    // 检测到人/触摸 -> 开门
    Serial.println("检测到信号 -> 开门 (90°)");
    myServo.write(90); 
    
  } else {
    
    // 未检测到信号 -> 关门
    // Serial.println("无信号 -> 关门 (0°)"); // 注释掉以免串口刷屏
    myServo.write(0); 
    
  }
  
  //以此延时增加系统稳定性，避免舵机过度抖动
  delay(50); 
}
```
=== 代码说明
- 使用Servo库控制舵机，简化了舵机操作。
- 通过数字读取传感器状态，根据高低电平控制舵机开闭。
- 延时50毫秒以防止舵机频繁抖动，提高系统稳定性。

== 实验场景照片

#figure(
  image("assets/sj2.jpg", width: 100%),
   caption: "实践任务2 实验场景照片",
)

== 电路连线示意图

#figure(
  image("sketch/sj2.png", width: 60%),
   caption: "实践任务2 电路连线示意图",
)

== 运行实际效果
#link("assets/sj2.mp4")[点击查看视频演示 (sj2.mp4)]

#link("https://www.bilibili.com/video/BV15SUHBuEHd/?vd_source=800127bf08c7aa59280ffeb458e19abc")[点击查看B站视频演示]

#pagebreak()

= 实践任务3内容
读取超声传感器并控制步进电机转速

== 代码实现
```cpp
#include <Stepper.h>

// --- 1. 步进电机配置 ---
// 28BYJ-48 电机一圈的步数 (通常是 2048，但在Stepper库中为了简化通常按4步序控制)
// 为了让Stepper库工作顺畅，我们设为 2038 或使用简化的步序
const int STEPS_PER_REV = 2038; 

// 初始化步进电机对象 (注意引脚顺序: 8, 10, 9, 11 这是一个常见的坑，ULN2003需要跳线序)
Stepper myStepper(STEPS_PER_REV, 8, 10, 9, 11);

// --- 2. 超声波传感器配置 ---
const int TRIG_PIN = 6;
const int ECHO_PIN = 7;

// --- 变量 ---
long duration;
int distance;
int motorSpeed_RPM = 0; // 电机转速 (转/分钟)

void setup() {
  Serial.begin(9600);

  // 传感器引脚
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  Serial.println("系统启动：步进电机测距调速");
}

void loop() {
  // --- 第一步：测距 ---
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  duration = pulseIn(ECHO_PIN, HIGH);
  distance = duration * 0.034 / 2;

  // 限制最大距离，防止干扰
  if (distance > 50 || distance <= 0) distance = 50;

  // --- 第二步：计算转速 ---
  // 28BYJ-48 的物理极限转速大约是 15 RPM 左右，再快就会失步(只响不转)
  
  if (distance < 5) {
    // [停止区] 太近了
    motorSpeed_RPM = 0;
  } 
  else if (distance >= 5 && distance <= 30) {
    // [调速区] 距离 5-30cm，速度从 1 RPM 到 15 RPM 变化
    motorSpeed_RPM = map(distance, 5, 30, 1, 15);
  } 
  else {
    // [全速区]
    motorSpeed_RPM = 15; // 最大速度
  }

  // --- 第三步：执行电机动作 ---
  Serial.print("距离: ");
  Serial.print(distance);
  Serial.print(" cm -> 目标转速: ");
  Serial.println(motorSpeed_RPM);

  if (motorSpeed_RPM > 0) {
    // 设置速度
    myStepper.setSpeed(motorSpeed_RPM);
    // 让电机转动一小段距离 (比如说 50 步)
    // 为什么不转一整圈？因为步进电机转动是阻塞的，转完之前没法测距。
    // 转一点点 -> 测一次距 -> 调一次速，这样反应才灵敏。
    myStepper.step(50); 
  } else {
    // 速度为0时，为了释放电机线圈防止发热，可以什么都不做
    // 或者把引脚拉低 (Stepper库本身不带释放功能，此处仅暂停步进)
    delay(100); 
  }
}
```

=== 代码说明
- 使用Stepper库控制步进电机，简化了控制逻辑。
- 超声波传感器测距后，根据距离调整电机转速，距离越近，转速越慢。
- 通过map函数线性映射距离到转速，实现平滑调速效果。
== 实验场景照片
#figure(
  image("assets/sj3.jpg", width: 100%),
   caption: "实践任务3 实验场景照片",
)
== 电路连线示意图
#figure(
  image("sketch/sj3.png", width: 60%),
   caption: "实践任务3 电路连线示意图",
)
== 运行实际效果
#link("assets/sj3.mp4")[点击查看视频演示 (sj3.mp4)]

#link("https://www.bilibili.com/video/BV1eSUHBuEfU/?vd_source=800127bf08c7aa59280ffeb458e19abc")[点击查看B站视频演示]


#pagebreak()
= 实践任务4内容
通过串口交互实现步进电机控制

== 代码实现
```cpp
#include <Stepper.h>

// --- 定义电机参数 ---
// 28BYJ-48 电机一圈的步数约为 2048
const int STEPS_PER_REV = 2048; 

// 初始化步进电机
// 注意：为了适配 28BYJ-48 和 Stepper 库，引脚顺序必须是 8, 10, 9, 11
Stepper myStepper(STEPS_PER_REV, 8, 10, 9, 11);

// --- 全局变量 ---
long currentPosition = 0; // 记录当前电机所在的绝对位置 (步数)

void setup() {
  // 初始化串口通信
  Serial.begin(9600);
  
  // 设置一个默认速度，避免未设置时不动
  myStepper.setSpeed(10); 

  Serial.println("--- 步进电机串口控制系统 ---");
  Serial.println("请输入指令格式: 速度(RPM),位置(步数),0");
  Serial.println("例如: 10,2048,0  (以10的速度转到一圈的位置)");
  Serial.println("例如: 15,0,0     (以15的速度回到原点)");
  Serial.println("------------------------------");
}

void loop() {
  // 检查串口是否有数据输入
  if (Serial.available() > 0) {
    
    // --- 1. 解析输入的三个数值 ---
    // parseInt() 会自动查找输入流中的整数，跳过非数字字符(如逗号)
    int inputSpeed = Serial.parseInt();    // 第1个数值：速度
    long inputTargetPos = Serial.parseInt(); // 第2个数值：目标位置
    int inputTrigger = Serial.parseInt();  // 第3个数值：启动标志(0)

    // 读取并丢弃剩余的换行符，防止下一次循环误读
    while (Serial.available() > 0) {
      char t = Serial.read(); 
      if (t == '\n') break; 
    }

    // --- 2. 判断指令是否有效 ---
    // 只有当第3个数是 0 时才执行
    if (inputTrigger == 0) {
      
      // (A) 限制速度范围 (28BYJ-48 物理极限约 15 RPM)
      if (inputSpeed > 15) {
        inputSpeed = 15;
        Serial.println("提示: 速度已限制为最大值 15 RPM");
      }
      if (inputSpeed < 1) inputSpeed = 1;

      // (B) 设置速度
      myStepper.setSpeed(inputSpeed);

      // (C) 计算需要移动的相对步数
      long stepsToMove = inputTargetPos - currentPosition;

      // (D) 打印反馈信息
      Serial.print("收到指令 -> 速度: ");
      Serial.print(inputSpeed);
      Serial.print(" RPM | 目标位置: ");
      Serial.print(inputTargetPos);
      Serial.print(" | 当前位置: ");
      Serial.print(currentPosition);
      Serial.print(" | 需要走: ");
      Serial.println(stepsToMove);

      // (E) 执行移动 (这一步是阻塞的，转完才会继续)
      if (stepsToMove != 0) {
        myStepper.step(stepsToMove);
        
        // (F) 更新当前位置
        currentPosition = inputTargetPos; 
        
        Serial.println(">>> 动作完成，等待新指令...");
      } else {
        Serial.println(">>> 已经在目标位置，无需移动。");
      }
      
    } 
  }
}
```
=== 代码说明
- 使用Stepper库简化步进电机控制。
- 通过串口接收三个整数：速度(RPM)、目标位置(步数)、启动标志(0)。
- 根据输入的速度和目标位置计算相对步数并执行移动。
- 当前位置通过全局变量currentPosition跟踪，确保每次移动都是相对于绝对位置。
== 实验场景照片
#figure(
  image("assets/sj3.jpg", width: 100%),
   caption: "实践任务4 实验场景照片",
)
== 电路连线示意图
#figure(
  image("sketch/sj3.png", width: 60%),
   caption: "实践任务4 电路连线示意图",
)
== 运行实际效果
#link("assets/sj4.mp4")[点击查看视频演示 (sj4.mp4)]

#link("https://www.bilibili.com/video/BV1eSUHBuEi2/?vd_source=800127bf08c7aa59280ffeb458e19abc")[点击查看B站视频演示]