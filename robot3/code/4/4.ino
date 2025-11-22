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