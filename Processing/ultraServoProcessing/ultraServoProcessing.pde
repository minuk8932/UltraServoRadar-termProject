import processing.serial.*;

// 시리얼 포트를 통해 데이터를 읽어오기 위한 라이브러리
import java.awt.event.KeyEvent;
import java.io.IOException;

/*   Arduino Radar Project
 *
 *   Updated version. Fits any screen resolution!
 *   Just change the values in the size() function,
 *   with your screen resolution.
 *      
 *  by Dejan Nedelkovski, 
 *  www.HowToMechatronics.com
 *
 *  프로세싱 코드 출처입니다. draw 관련 메소드는 대부분 그대로 따왔습니다.
 *  draw 관련 메소드(drawRadar(), drawLine() 등)를 통해 레이더와 뒷 배경을 깔끔하게 그려냅니다. 
 *
 */

Serial myPort = null; // 포트를 받아올 객체를 선언

int index1=0;
String angle="";
String distance="";
String data="";
String noObject = "";
float pixsDistance = 0.0;
int iAngle = 0, iDistance = 0;

void setup() {  
 size (1200, 700); // 자신이 원하는 사이즈에 맞게 설정
 smooth();
 
 // 내 포트 번호를 설정해 연결 시도
 // 형식 new Serial(this, "OS별 USB 포트 번호", 9600); : 운영체제마다 번호 형식이 다름을 주의
 myPort = new Serial(this, "/dev/cu.usbmodem1421", 9600);
 
 // 줄 바꿈을 통해 데이터를 읽어옴, 'ultraServo.ino'에서 시리얼에 데이터를 띄울때 끝에 '\n'가 있었기 때문에
 // 관련 내용은 아래의 serialEvent 메소드 설명을 참조해 주세요. 
 myPort.bufferUntil('\n');
}

void draw() {   
  // 레이더 기본색 : 녹색
  fill(98,245,31);
  noStroke();
  fill(0,4);
  // 레이더 침 부분
  rect(0, 0, width, height-height*0.065); 
  
  fill(98,245,31);
  
  // 레이더를 그려주는 메소드 호출
  drawRadar(); 
  drawLine();
  drawObject();
  drawText();
}

// 시리얼을 통해 데이터를 받아오고, 이벤트를 작동시키는 메소드
void serialEvent (Serial myPort) {
  // 함수가 불릴때 마다 위에서 '\n' 기준으로 끊어 받는 데이터를 변수에 담아줌
  data = myPort.readStringUntil('\n');
  // 관련데이터를 한줄만 받아오고
  data = data.substring(0,data.length()-1);
  
  // 받아온 데이터를 각도와, 거리를 따로 구분하기위해 ','로 다시 끊어서 각 변수에 담아줌
  index1 = data.indexOf(",");
  angle = data.substring(0, index1); 
  distance = data.substring(index1+1, data.length());
 
  // 받아온 값들은 문자열이므로 형변환 해서 정수형 변수에 할당
  iAngle = int(angle);
  iDistance = int(distance);
}

void drawRadar() {
  pushMatrix();
  
  translate(width/2,height-height*0.074);
  noFill();
  // 배경선의 굵기
  strokeWeight(2);
  stroke(98,245,31);
  
  // 상단 원형 배경
  arc(0,0,(width-width*0.0625),(width-width*0.0625),PI,TWO_PI);
  arc(0,0,(width-width*0.27),(width-width*0.27),PI,TWO_PI);
  arc(0,0,(width-width*0.479),(width-width*0.479),PI,TWO_PI);
  arc(0,0,(width-width*0.687),(width-width*0.687),PI,TWO_PI);
  
  // 각에 해당하는 배경 선
  line(-width/2,0,width/2,0);
  line(0,0,(-width/2)*cos(radians(30)),(-width/2)*sin(radians(30)));
  line(0,0,(-width/2)*cos(radians(60)),(-width/2)*sin(radians(60)));
  line(0,0,(-width/2)*cos(radians(90)),(-width/2)*sin(radians(90)));
  line(0,0,(-width/2)*cos(radians(120)),(-width/2)*sin(radians(120)));
  line(0,0,(-width/2)*cos(radians(150)),(-width/2)*sin(radians(150)));
  line((-width/2)*cos(radians(30)),0,width/2,0);
  popMatrix();
}

// 물체 감지시 나타낼 그림
void drawObject() {
  pushMatrix();
  // 움직일때마다 실시간의 레이더 위치를 그려주기 위함
  translate(width/2,height-height*0.074);
  // 물체 감지하는 부분의 레이더 굵기
  strokeWeight(3);
  // 물체가 감지되었을때 빨간색으로 변경
  stroke(255,10,10);
  
  // 단위 환산
  pixsDistance = iDistance*((height-height*0.1666)*0.025);

  
  if(iDistance<40){
    // 초음파센서 감지 거리의 제한에 맞춰 그 안에 물체가 감지되었을 때 
    line(pixsDistance*cos(radians(iAngle)),-pixsDistance*sin(radians(iAngle)),(width-width*0.505)*cos(radians(iAngle)),-(width-width*0.505)*sin(radians(iAngle)));
  }
  
  popMatrix();
}

void drawLine() {
  pushMatrix();
  // 레이더 기본 색과 굵기
  strokeWeight(3);
  stroke(30,250,60);
  translate(width/2,height-height*0.074);
  line(0,0,(height-height*0.12)*cos(radians(iAngle)),-(height-height*0.12)*sin(radians(iAngle))); // draws the line according to the angle
  popMatrix();
}

void drawText() {
  
  pushMatrix();
  
  if(iDistance>40) {          // 거리가 40보다 클땐 초음파 센서에 감지되지 않는 영역
    noObject = "Out of Range";
  }
  else {                      // 감지가 된 경우
    noObject = "In Range";
  }
  
  fill(0,0,0);
  noStroke();
  rect(0, height-height*0.0648, width, height);
  fill(98,245,31);
  textSize(15);
  
  text("10cm",width-width*0.3854,height-height*0.0833);
  text("20cm",width-width*0.281,height-height*0.0833);
  text("30cm",width-width*0.177,height-height*0.0833);
  text("40cm",width-width*0.0729,height-height*0.0833);
  textSize(20);
  text("Object: " + noObject, width-width*0.875, height-height*0.0277);
  text("Angle: " + iAngle +" °", width-width*0.48, height-height*0.0277);
  text("Distance: ", width-width*0.26, height-height*0.0277);
  
  // 물체가 감지된 경우 글자 입력
  if(iDistance<40) {
    text("        " + iDistance +" cm", width-width*0.225, height-height*0.0277);
  }
  
  textSize(10);
  fill(98,245,60);
  translate((width-width*0.4994)+width/2*cos(radians(30)),(height-height*0.0907)-width/2*sin(radians(30)));
  rotate(-radians(-60));
  text("30°",0,0);
  resetMatrix();
  translate((width-width*0.503)+width/2*cos(radians(60)),(height-height*0.0888)-width/2*sin(radians(60)));
  rotate(-radians(-30));
  text("60°",0,0);
  resetMatrix();
  translate((width-width*0.507)+width/2*cos(radians(90)),(height-height*0.0833)-width/2*sin(radians(90)));
  rotate(radians(0));
  text("90°",0,0);
  resetMatrix();
  translate(width-width*0.513+width/2*cos(radians(120)),(height-height*0.07129)-width/2*sin(radians(120)));
  rotate(radians(-30));
  text("120°",0,0);
  resetMatrix();
  translate((width-width*0.5104)+width/2*cos(radians(150)),(height-height*0.0574)-width/2*sin(radians(150)));
  rotate(radians(-60));
  text("150°",0,0);
  popMatrix(); 
}