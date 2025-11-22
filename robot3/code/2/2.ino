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