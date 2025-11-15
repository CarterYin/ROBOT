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