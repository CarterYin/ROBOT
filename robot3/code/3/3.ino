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