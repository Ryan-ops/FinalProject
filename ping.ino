

  int const potPin1=A2;
  int const potPin2=A0;
  
void setup(){
  Serial.begin(9600);
}
void loop(){
  String data = "";
  data += analogRead(potPin1);
  data += '-';
  data += analogRead(potPin2);
  Serial.println(data);
  
}
