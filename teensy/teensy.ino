#include <Servo.h>
#include <AccelStepper.h>

AccelStepper m0(1, 3, 6); // pin 3 = step, pin 6 = direction
AccelStepper m1(1, 4, 7); // pin 4 = step, pin 7 = direction
Servo pen;
const int LED = 13;
const int PEN = 23;
const int BUTTON = 12;

const int PEN_UP = 180;
const int PEN_DOWN = 90;

const int MAX = 200;
const int SPEED = (float)60;

const int CMDSIZE = 2000;
char cmd[CMDSIZE + 1];

int pen_current = -1;

void cmd_zero() {
  m0.setCurrentPosition(0);
  m1.setCurrentPosition(0);  
}
  
  
void readline() {
  for(int i = 0; i < CMDSIZE; ) {
    if (Serial.available()) {
      cmd[i] = Serial.read();
      if (cmd[i] == '\n' || cmd[i] == '\r') {
        cmd[i] = 0;
        return;
      }
      else {
        i++;
      }
    }
  }
}

void led(bool state) {
  digitalWrite(LED, state ? HIGH : LOW); 
}
 
 
void wait_for_button() {
  Serial.println("[Click!]");
  Serial.send_now();
  while(digitalRead(BUTTON)) {
    led((millis() / 250) & 1);
  }
  led(0);
}

void cmd_pen(int pos) {
  if (pen_current == pos)
    return;
  int dir = pen_current < pos ? 1 : -1;
  
  for (int a = pen_current; a != pos; a += dir) {
    pen.write(a);
    delay(10);
  }
  pen_current = pos;
}

int get_int(char ** c) {
  int n = 0;
  int sign = 1;
  while(isspace(**c)) (*c)++;
  if (!isdigit(**c) && **c!='-') return 0;
  if (**c == '-') {
      sign = -1;
      (*c)++;
  }
  while(isdigit(**c)) {
    n = 10*n + (**c - '0');
    (*c)++;
  }
  if (**c == ',') {
    (*c)++;
  }  
  return sign * n;
}

void cmd_move() {
  char * c = cmd + 1;
  while (*c) {
    int m0pos = get_int(&c);
    int m1pos = get_int(&c);

    int d0 = abs(m0pos - m0.currentPosition());
    int d1 = abs(m1pos - m1.currentPosition());

    Serial.print("move: ");
    Serial.print(m0pos); Serial.print(" ");
    Serial.print(m1pos); Serial.println("");    

    
    float d = (d0 > d1) ? d0 : d1;
    Serial.print("distance: ");
    Serial.print(d0); Serial.print(" ");
    Serial.print(d1); Serial.print(" -> ");    
    Serial.print(d); Serial.println(" ");    
    
    m0.moveTo(m0pos);    
    m1.moveTo(m1pos);
    float spd0 = fabs(SPEED * d0/d);
    float spd1 = fabs(SPEED * d1/d);
    Serial.print("speed: ");    
    Serial.print(spd0); Serial.print(" ");
    Serial.print(spd1); Serial.println(" ");    
   
    m0.setSpeed(spd0);
    m1.setSpeed(spd1);    
    
    while (m0.currentPosition() != m0pos || m1.currentPosition() != m1pos) {
      m0.runSpeedToPosition();
      m1.runSpeedToPosition();
    }
  }
}

void do_cmd() {
  switch(toupper(cmd[0])) {
  case 'M':
    cmd_move();
    break;
  case 'Z':
    cmd_zero();
    break;
  case 'U':
    cmd_pen(PEN_UP);
    break;
  case 'D':
    cmd_pen(PEN_DOWN);
    break;    
  default:
    Serial.print("unknown: ");
    Serial.println(cmd);
    return;   
  }
  Serial.println("ok");
}


void setup() {
  Serial.begin(115200);
  
  Serial.println("Startup");
  pinMode(LED, OUTPUT);
  pinMode(BUTTON, INPUT_PULLUP);  

  cmd_zero();

  m0.setMaxSpeed(SPEED);
  m1.setMaxSpeed(SPEED);
  
  pen.attach(PEN);
  
  
  cmd_pen(PEN_UP);   
}

void loop() {  
  
  readline();
  do_cmd();
  
}

