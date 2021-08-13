#include <Servo.h>

Servo servo;
int posicion = 0;

int boton1 = 0;
int boton2 = 0;
int bomba = 13;

int modo1;
int modo2;

int ledPin = 7;
int cmd = -1;
int flag = 0;

void setup() {

  pinMode(6,INPUT_PULLUP);
  pinMode(5,INPUT_PULLUP);
  pinMode(3,INPUT);

  servo.attach(11);
  pinMode(2, INPUT);
  pinMode(2, INPUT);
  pinMode(8, OUTPUT);
  pinMode(9, OUTPUT);
  pinMode(bomba, OUTPUT);
  
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);
  Serial.begin(9600);
}

void loop() {

  modo1 = digitalRead(6);
  modo2 = digitalRead(5);

  if(modo1 == 0) {
    if (Serial.available() > 0) {
    cmd = Serial.read();
    flag = 1;
  }

  if (flag == 1) {
    if (cmd == '0') {
      digitalWrite(ledPin, LOW);
      Serial.println("LED: off");

      servo.write(180);
    digitalWrite(8, LOW);
    digitalWrite(9, LOW);
    digitalWrite(bomba, LOW);
      
    } else if (cmd == '1') {
      digitalWrite(ledPin, HIGH);
      Serial.println("Regando planta 1");
      Serial.println("LED: on");

      servo.write(0);
      delay(500);
      digitalWrite(8, HIGH);
      digitalWrite(bomba, HIGH);
      
    } else if (cmd == '3') {
      servo.write(90);
      delay(500);
      digitalWrite(9, HIGH);
      Serial.println("Regando planta 3");
      digitalWrite(bomba, HIGH);
    }
    else {
      Serial.print("unknown command: ");
      Serial.write(cmd);
      Serial.print(" (");
      Serial.print(cmd, DEC);
      Serial.print(")");

      Serial.println();
    }

    flag = 0;    
    cmd = 65;
    }
  
    Serial.flush();
    delay(100);
  } else if (modo2 == 0) {
    digitalWrite(9, HIGH);
    delay(500);
    digitalWrite(9, LOW);
    delay(500);
  }
  
  
}
