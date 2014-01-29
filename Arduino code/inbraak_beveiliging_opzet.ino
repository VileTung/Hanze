/*
programatuur voor project "beveiliging"
gemaakt door Jorn Claassens
08-01-2014
laatste update
29-01-2014 - 12:47
*/
//ingangen
int ISleutel = 3;//aansluiting van de sleutel voor de voordeur

//sensoren altijd hoog (1). laag(0) in geval van alarm
int SGlas  = 7;//sensor voor glasbreuk
int SRaam  = 6;//sensor voor openen van ramen (raamcontact)
int SPir   = 5;//sensor voor beweging 
int SLaser = 4;//sensor voor passeren (break beam)

//uitgangen
int OSirene = 12;//uitgang voor de sirene
int OFlits  = 9;//uitgang voor het flitslicht
int OTel    = 8;//uitgang voor de telefoonkiezer

//variabelen
int AlarmActief = 0;//opslag of alarm (1 = alarm, 0 = rust)
int SysteemActief = 0;//Systeem actief =1, systeem uit =0

const int Aantal = 4;//totaal aantal sensoren
int Sensor[Aantal+1];//array om alle sensoren samen te pakken ([sensoren+1])
char SensorNaam[Aantal+1][10]={ //array voor het opslaan van de sensornamen ([sensoren+1][lengte naam+1])
                      "Glas",
                      "Raam",
                      "Pir",
                      "Laser"};
                      
int Vorige[Aantal+1]; //opslaan van vorige stand van de sensoren voor het detecteren van verandering

boolean Sl2 = true;    //detecteren van verandering in de staat van de sleutelschakelaar
long VorigTimer = 0;   //variabel om op te slaan wanneer de sleutelschakelaar om is gehaald
long SchakTimer = 10000;//tijd in msec dat de arduino wacht op een reactie van de PC anders is er geen verbinding

String inString = ""; //string voor de inkomende gegevens van de PC                      

#include <SoftwareSerial.h>        //aanmaken van een softwarematige serial port
SoftwareSerial logSerial(10, 11);  //poort komt op de pinnen 10(RX) en 11(TX)
#include <Time.h>                  //bibliotheek om d tijd bij te houden

void setup(){
  pinMode(SRaam, HIGH);
  //ingangen en uitgangen defineren
  pinMode(ISleutel,INPUT);
  pinMode(SGlas,INPUT);
  pinMode(SRaam,INPUT);
  pinMode(SPir,INPUT);
  pinMode(SLaser,INPUT);
  pinMode(OSirene,OUTPUT);
  pinMode(OFlits,OUTPUT);
  pinMode(OTel,OUTPUT);
  
  //seriele communicatie opzetten
  Serial.begin(115200);
  
  //RTC-activeren
    //wordt een bibliotheek i.p.v een RTC 
  
  //SD-kaart activeren
  //SD-kaart voor het loggen communiceerd via een serieele poort
  logSerial.begin(9600);
}
//----------------------------------------------------------------------------------------------------------------------------------

void loop(){
  //serial poort uitlezen
  String inData;
  while (Serial.available() > 0)
    {
        char inChar = Serial.read();
        inData += inChar;
 //      Serial.println(inChar); //voor debuggen

        // Process message when new line character is recieved //==44 ook mogelijk om string af te sluiten (dit is , in ASCII)
        if (inChar == '\n')
        {
            //gegevens doorsturen
            switch (gegevensin(inData)){
             case 1://heartbeat
               heartbeat();
               break;
             case 2://reset
                 alarmReset("Reset");
               break;
             case 3://verbinden
               Serial.println("VB");//naar PC sturen dat de arduino verbonden is
             break;
             case 4://alarmsysteem activeren
               if (Sensor[1]==HIGH){
                 SysteemActief = 1;
                 Serial.println("SA");//systeem geactiveerd
                 eventOpslag("Actief");
               }
               else if (Sensor[1]==LOW){
                 Serial.println("AM");//systeem activeren mislukt
               }
             break;
             case 5://alarmsysteem deactiveren
               SysteemActief = 0;
               Serial.println("SD"); //systeem gedeactiveerd
               eventOpslag("Deactief");
             break; 
             case 6://stil alarm vanaf de pc
               alarm2("Stil");
             break;
             case 7://Sleutel reactie van de PC
               VorigTimer = 0;
             break;
            }
            inData = "";  //maak de ingekomen string weer leeg
        }
    }
    delay(10); //korte vertaging om foutloos gegevens in te kunnen lezen

  //uitlezen sensoren
    //elke sensor krijgt zijn eigen plek in de array
  Sensor[0] = digitalRead(SGlas);
  Sensor[1] = digitalRead(SRaam);
  Sensor[2] = digitalRead(SPir);
  Sensor[3] = digitalRead(SLaser);
 //sensoren in de gaten houden
  char Naam[10];                             //variabel om de naam van de getriggerde sensor door te sturen
  if (SysteemActief == 1){
      for (int i=0; i<Aantal; i++){           //arrays vergelijken
       if ( Vorige[i] > Sensor[i]){           //kijken of de sensor van 1 naar 0 is gegaan
           //selecteer juiste alarm
           strncpy(Naam, SensorNaam[i], 10); //naam uit de char array omzetten in een char strncpy(varuit, vararray[plaats], aantal plaatsen in varuit)
           alarm1(Naam);                    //alleen sensoren doorsturen wanneer ze getriggert worden
           }
        }
     for (int i=0; i<Aantal; i++){         //array overkopieren
     Vorige[i] = Sensor[i];
   }
 }

//code voor de sleutel schakelaar
  unsigned long HuidigTimer = millis(); //huidige tijd van de timer
  boolean Sl;                           //onthouden van de huidige stand van de schakelaar
  Sl = digitalRead(ISleutel);           //huidige stand van de schakelaar toekennen aan het variabel
  if((HuidigTimer - VorigTimer > SchakTimer) && (VorigTimer != 0)) { //timer zonder delay
    VorigTimer = 0;
    if (SysteemActief == 1){            //systeem deactiveren als die aan staat
      SysteemActief = 0;
    }
    else if (SysteemActief == 0){       //systeem actieveren als die uit staat
      SysteemActief = 1;
    }
  }
  
  if (Sl != Sl2){                     //detecteer of de sleutel van stand verandert
    if (Sl == false){                 //Wanneer de schakelaar is ingedrukt (schakelaar is altijd hoog)
       Serial.println("SL");          //stuur de PC dat de sluetelschakelaar omgehaald is
       VorigTimer = HuidigTimer;      //timers gelijk zetten om te detecteren of er verbinding is met de PC
    }
     Sl2 = Sl;                       //staat van de schakelaar overkopieren om later te vergelijken
     delay(10);                      //delay om soepel te schakelen
  }
}

//----------------------------------------------------------------------------------------------------------------------------------
int gegevensin(String gegevens){
  //uitgelezen gegevens van de seriele poort verwerken
  String command = "";                 //opslag van het ingekomen commando
  int Tdata[] = {00, 00, 13, 01, 14}; //array voor tijd en datum {uur, min, dag, maand, jaar}
  int uit = 0;
  
  command = getValue(gegevens, ';',0); //eerste plaats in de string is het commando
  for (int i = 0; i<5; i++){
    Tdata[i] = stringToNumber(getValue(gegevens, ';',i+1)); //plaatsen na het commando zijn de tijd en datum
  }
  //RCT gelijk zetten met de computer/gestuurde tijd
   setTime(Tdata[0], Tdata[1], 00, Tdata[2], Tdata[3], Tdata[4]);//setTime(uur,min,sec,dag,maand,jaar);
  
  //comando's terugsturen
    //HB (heartbeat) = 1
    //RS (reset)     = 2
  if (command == "HB"){return 1;}//heartbeat
  if (command == "RS"){return 2;}//reset
  if (command == "VB"){return 3;}//verbinden
  if (command == "SA"){return 4;}//alarmsysteem actieveren
  if (command == "SD"){return 5;}//alarmsysteem deactieveren
  if (command == "ST"){return 6;}//stil alarm vanaf de pc
  if (command == "SL"){return 7;}//Sleutel reactie van de PC
}

//----------------------------------------------------------------------------------------------------------------------------------
  //gedeelte maakt van een string een integer
    //http://christianscode.blogspot.nl/2012/05/convert-string-to-integer.html
  int stringToNumber(String thisString) {
    int i, value, length;                  //variabelen aanmaken
    length = thisString.length();          //lengte van de string bepalen
    char blah[(length+1)];                 //karakter array aanmaken array[lengte]
    for(i=0; i<length; i++) {              //hele string karakter voor karakter door
      blah[i] = thisString.charAt(i);      //ieder karakter uit de string in de array plaatsen
    }
    blah[i]=0;                            //array afsluiten
    value = atoi(blah);                   //array omzetten in een getal
    return value;                         //getal teruggeven 
  }
  //----------------------------------------------------------------------------------------------------------------------------------
  //gedeelte geeft de mogelijkheid een gekozen gedeeldte uit de string te lezen
    //http://stackoverflow.com/questions/9072320/split-string-into-string-array
  String getValue(String data, char separator, int index){
    int found = 0;  //aantal gevonden splitsingen
    int strIndex[] = {0, -1};
    int maxIndex = data.length()-1; //maximale lengte van de string bepalen

    for(int i=0; i<=maxIndex && found<=index; i++){ //gaat de gehele string door maar stop als found>index
      if(data.charAt(i)==separator || i==maxIndex){ //kijkt of het karrakter op pos. i = separator of i = maxIndex(einde van de string)
          found++;                                  //voorwarden voldaan? ja Ã©Ã©n splitsing gevonden
          strIndex[0] = strIndex[1]+1;              //slaat op hoe lang het gedeeldte tussen de gekozen spliting is en de volgende (het gekozen antwoord)
          strIndex[1] = (i == maxIndex) ? i+1 : i;  //is i=maxIndex?, ja dan strIndex[1] = i+1, nee dan strIndex=i
      }
    }

    return found>index ? data.substring(strIndex[0], strIndex[1]) : ""; //is found>index?, ja dan is result text uit de string vanaf plaats strIndex[0] t/m strIndex[1], nee result = ""
  }

//----------------------------------------------------------------------------------------------------------------------------------
void alarm1(char Naam[10]){ //alarm met geluid e.d.
//alarm aanzetten
//telefoonkiezer activeren
digitalWrite(OTel, HIGH);
//flitslicht activeren
digitalWrite(OFlits, HIGH);
//sirene activeren
digitalWrite(OSirene, HIGH);
//event doorsturen
eventDoorstuur(Naam);
//event opslaan
eventOpslag(Naam);
}

//----------------------------------------------------------------------------------------------------------------------------------
void alarm2(char Naam[10]){ //stil alarm
//alarm aanzetten
//telefoonkiezer activeren
digitalWrite(OTel, HIGH);
//event doorsturen
eventDoorstuur(Naam);
//event opslaan
eventOpslag(Naam);
}

//------------------------------------------------------------------------------------------------------------------------------------

void alarmReset (char Naam[10]){
 //alles weer LOW maken
  //telefoonkiezer
   digitalWrite(OTel, LOW);
  //flitslicht
  digitalWrite(OFlits, LOW);
  //sirene
  digitalWrite(OSirene, LOW);
  AlarmActief = 0;
//event doorsturen
eventDoorstuur(Naam);
//event opslaan
eventOpslag(Naam);
}

//----------------------------------------------------------------------------------------------------------------------------------
void eventOpslag(char Naam[10]){ //opslaan van de alarmen
//event opslaan op geheugen
  //uur;min;dag;maand;jaar;alarm actief ja/nee;naam van de event
  logSerial.print(hour());//tijd en datum e.d.
  logSerial.print(';');//;
  logSerial.print(minute());
  logSerial.print(';');//;
  logSerial.print(day());
  logSerial.print(';');//;
  logSerial.print(month());
  logSerial.print(';');//;
  logSerial.print(year());
  logSerial.print(';');//;
  logSerial.print(SysteemActief);//alarm actief ja/nee
  logSerial.print(';');//;
  logSerial.println(Naam);//naam van de event
}

//----------------------------------------------------------------------------------------------------------------------------------
void eventDoorstuur(char Naam[10]){
//event doorsturen
  Serial.print("AL");
  Serial.print(';');//;
  Serial.println(Naam);//naam van de event
}

//----------------------------------------------------------------------------------------------------------------------------------
void heartbeat(){ //heartbeat communicatie met de PC
//klok gelijk zetten met de PC
//bericht terugsturen naar de PC
  //uur;min;dag-maand-jaar;alarm actief ja/nee
  Serial.print("HB");//tijd en datum e.d.
  Serial.print(';');//;
  Serial.print(hour());//tijd en datum e.d.
  Serial.print(';');//;
  Serial.print(minute());
  Serial.print(';');//;
  Serial.print(day());
  Serial.print(';');//;
  Serial.print(month());
  Serial.print(';');//;
  Serial.print(year());
  Serial.print(';');//;
  Serial.println(SysteemActief);//alarm actief ja/nee
}
//--------------------------------------------------------------------------------------------------------------------------------
