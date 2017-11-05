#include <Servo.h>
Servo myservo;
int pos=90;
int E1 = 5;     //M1 Speed Control
int E2 = 6;     //M2 Speed Control
int M1 = 4;    //M1 Direction Control
int M2 = 7;    //M1 Direction Control
//int pos=0;

void stop(void)                    //Stop
{
  digitalWrite(E1,LOW);   
  digitalWrite(E2,LOW);      
}   
void advance(char a,char b)          //Move forward
{
  analogWrite (E1,a);      //PWM Speed Control
  digitalWrite(M1,HIGH);    
  analogWrite (E2,b);    
  digitalWrite(M2,HIGH);
  delay(100);
  analogWrite (E1,0);      //PWM Speed Control
  digitalWrite(M1,HIGH);    
  analogWrite (E2,0);    
  digitalWrite(M2,HIGH);
}  
void back_off (char a,char b)          //Move backward
{
  analogWrite (E1,a);
  digitalWrite(M1,LOW);   
  analogWrite (E2,b);    
  digitalWrite(M2,LOW);
  delay(100);
  analogWrite (E1,0);
  digitalWrite(M1,LOW);   
  analogWrite (E2,0);    
  digitalWrite(M2,LOW);
}
void turn_L (char a,char b)             //Turn Left
{
  analogWrite (E1,a);
  digitalWrite(M1,LOW);    
  analogWrite (E2,b);    
  digitalWrite(M2,HIGH);
  delay(100);
  analogWrite (E1,0);
  digitalWrite(M1,LOW);   
  analogWrite (E2,0);    
  digitalWrite(M2,HIGH);
}
void turn_R (char a,char b)             //Turn Right
{
  analogWrite (E1,a);
  digitalWrite(M1,HIGH);    
  analogWrite (E2,b);    
  digitalWrite(M2,LOW);
  delay(100);
  analogWrite (E1,0);
  digitalWrite(M1,HIGH);   
  analogWrite (E2,0);    
  digitalWrite(M2,LOW);
}
void setup() {
  // put your setup code here, to run once:
  myservo.attach(9);
  Serial.begin(9600);
  int i;
  for(i=4;i<=7;i++)
    pinMode(i, OUTPUT);  
  while(Serial.read()>=0){}
}

void loop() {
 if(Serial.available()){
  char ch = Serial.read();
  switch(ch){
    case '1':
      pos++;
      break;
    case '2':
      pos--;
      break;
    case '3':
      advance (20,20);
      break;
    case '4':
      back_off(20,20);
      break;
  }
  myservo.write(pos);
  delay(15);
 }
  
  //myservo.write(pos);
  //delay(15);
  
  // put your main code here, to run repeatedly:
 /*for(pos = 30;pos<150;pos+=1)
  {
    myservo.write(pos);
    delay(15);
  }
  for(pos = 150;pos>=30;pos-=1)
  {
    myservo.write(pos);
    delay(15);
  }*/
}
