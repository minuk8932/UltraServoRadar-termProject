#include <Servo.h>

// 초음파 센서의 트리거와 에코핀 정의 (우노보드에 본인이 연결한대로 선언)
const int trigPin = 10;
const int echoPin = 11;

// 서보 모터를 제어할 서보 객체 선언// 서보 모터를 제어할 서보 객체 선언
Servo myServo;

void setup() {
  Serial.begin(9600);
  pinMode(trigPin, OUTPUT);   // 트리거 핀을 출력으로 설정
  pinMode(echoPin, INPUT);    // 에코 핀을 입력으로 설정
  myServo.attach(12);         // 서보모터와 연결된 핀 정의
}

void loop() {
  float dist;

  // 서보모터를 15 ~ 170도까지 회전시킴, 즉 초음파센서가 해당 범위내에서 물체의 접근을 감지
  for(int i=15;i<=170;i++){
    myServo.write(i);
    delay(2);
    dist = calculateDistance(); // 서보모터가 돌면서 물체가 얼마나 접근했는지 초음파센서로 계산한 값을 실시간으로 넘기기 위한 값 

    // 시리얼 모니터에 값이 제대로 들어오는지 확인
    Serial.print(i);
    Serial.print(",");
    Serial.print(dist);
    Serial.print("\n");
  }
  
  // 아래의 반복문을 통해 실제 레이더 처럼 왕복으로 움직이며 감지하는 것이 가능하게함
  for(int i=170; i>15; i--) { 
    myServo.write(i);
    delay(2);
    dist = calculateDistance();

    Serial.print(i);
    Serial.print(",");
    Serial.print(dist);
    Serial.print("\n");
  }
}

// 거리 변수에 들어갈 값을 계산해주는 함수로써, 초음파 센서로부터 거리를 계산해 그 값을 레이더에 띄워줌
float calculateDistance(){ 
  unsigned long duration;
  float distance;
  
  digitalWrite(trigPin, LOW);
  digitalWrite(echoPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  // 에코핀의 값을 읽어와, 초음파가 이동한 시간(micro second)을 duration으로 받고
  duration = pulseIn(echoPin, HIGH);
  // duration / 2 (초음파가 해당 물체까지 갔다 오는 거리는 왕복이므로) / 29 (음속은 1cm 당 29마이크로초이므로)를 통해 거리를 계산
  distance = duration/29.0/2.0;
  
  return distance;
}
