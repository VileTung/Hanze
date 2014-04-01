//Input van de PIC
const int inputPin0 = 2;
const int inputPin1 = 3;
const int inputPin2 = 4;
const int inputPin3 = 5;
const int inputPin4 = 6;
const int inputPin5 = 7;
const int inputPin6 = 8;
const int inputPin7 = 9;

//Status
int Pin0, Pin1, Pin2, Pin3, Pin4, Pin5, Pin6, Pin7, oudePin0, oudePin1, oudePin2, oudePin3, oudePin4, oudePin5, oudePin6, oudePin7 = 0;

//Omgezet naar dec
int totaal, decPin0, decPin1, decPin2, decPin3, decPin4, decPin5, decPin6, decPin7 = 0;

//Oude hartslag waarde
int oudeWaarde;

void setup() {

  //Pin mode aangeven
  pinMode(inputPin0, INPUT);
  pinMode(inputPin1, INPUT);
  pinMode(inputPin2, INPUT);
  pinMode(inputPin3, INPUT);
  pinMode(inputPin4, INPUT);
  pinMode(inputPin5, INPUT);
  pinMode(inputPin6, INPUT);
  pinMode(inputPin7, INPUT);

  //Seriële communicatie
  Serial.begin(115200);

}

void loop() {

  //Pinnen uitlezen
  Pin0 = digitalRead(inputPin0);
  Pin1 = digitalRead(inputPin1);
  Pin2 = digitalRead(inputPin2);
  Pin3 = digitalRead(inputPin3);
  Pin4 = digitalRead(inputPin4);
  Pin5 = digitalRead(inputPin5);
  Pin6 = digitalRead(inputPin6);
  Pin7 = digitalRead(inputPin7);

  //Omzetten naar decimaal
  decPin0 = Pin0 * 1;
  decPin1 = Pin1 * 2;
  decPin2 = Pin2 * 4;
  decPin3 = Pin3 * 8;
  decPin4 = Pin4 * 16;
  decPin5 = Pin5 * 32;
  decPin6 = Pin6 * 64;
  decPin7 = Pin7 * 128;

  //Alles nu optellen
  totaal = decPin0 + decPin1 + decPin2 + decPin3 + decPin4 + decPin5 + decPin6 + decPin7;

  //Alleen waarde sturen als deze verandert is
  if (totaal != oudeWaarde)
  {
    //Totaal serieel doorsturen
    Serial.print(totaal);
  }

  //Oude waarde onthouden
  oudeWaarde = totaal;

  delay(200);

}
