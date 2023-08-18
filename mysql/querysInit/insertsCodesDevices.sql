USE `laziot` ;

INSERT INTO `codeDevice` (`textCode`, `device`, `typeDevice`, `linkedTo`, `active`) VALUES
('
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <Ultrasonic.h>

//Credenciais de acesso à rede
#define WIFI_SSID "#ssid#"
#define WIFI_PASSWORD "#ssidPassword#"

#define pino_trigger 2
#define pino_echo 0

WiFiClient espClient;
PubSubClient client(espClient);
StaticJsonDocument<200> doc;

//Credenciais de acesso ao broker mqtt
const char* mqttServer = "#ipMqttServer#";
const int mqttPort = #portMqttServer#;

String clientUniqueHash = "#uniqueHashCode#";
String wifiMacString = "";

String msgTrigger = "";
String msgInit = "";

int indexLoop = 0;
int loopExec = 0;

float distCMSensor;
float totalCMRead;

Ultrasonic ultrasonic(pino_trigger, pino_echo);

void setup() {
  Serial.begin(115200);
  
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connecting to WiFi..");
  }

  wifiMacString = WiFi.macAddress();
  msgInit = "{@@dispositivo@@:@@"+wifiMacString+"@@, @@tipo@@:@@emissor@@, @@token@@:@@"+clientUniqueHash+"@@}";
  
  msgTrigger = "{@@dispositivo@@:@@"+wifiMacString+"@@, @@token@@:@@"+clientUniqueHash+"@@, @@tipo@@:@@emissor@@}";

  Serial.println("Connected to the WiFi network");
  Serial.println(wifiMacString);

  client.setServer(mqttServer, mqttPort);

  while (!client.connected()) {
    Serial.println("Connecting to MQTT...");
    
    String clientMqtt = "client:"+wifiMacString;
    if (client.connect(clientMqtt.c_str())) {

      Serial.println("connected");
      String fila = "iot/"+clientUniqueHash+"/"+wifiMacString;
      client.subscribe((char*) fila.c_str());
      client.publish("initialization", msgInit.c_str());

    } else {

      Serial.print("failed with state ");
      Serial.print(client.state());
      delay(2000);

    }
  }
}

void loop() {
  
  distCMSensor = ultrasonic.convert(ultrasonic.timing(), Ultrasonic::CM);
  
  if(distCMSensor <= #distSensor#){
    totalCMRead += distCMSensor;
    indexLoop += 1;

    if(indexLoop >= 25){
      float value = totalCMRead/indexLoop;

      String strMsg = "{ @@dispositivo@@:@@"+wifiMacString+"@@, @@valorSensor@@:"+value+"}";

      indexLoop = 0;
      totalCMRead = 0;
      client.publish("trigger", strMsg.c_str());
    }
  }
  
  loopExec = loopExec +1;
  if(loopExec-5 == 5){
    String msgOk = "emissorOk"; 
    client.publish("emissor", msgOk.c_str());
    loopExec = 0;
  }

  delay(50);
}
', "esp01", "emissor", "sr-501", 1),
('#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
 
//Credenciais de acesso à rede
#define WIFI_SSID "#ssid#"
#define WIFI_PASSWORD "#ssidPassword#"

WiFiClient espClient;
PubSubClient client(espClient);
StaticJsonDocument<200> doc;

//Credenciais de acesso ao broker mqtt
const char* mqttServer = "#ipMqttServer#";
const int mqttPort = #portMqttServer#;

String clientUniqueHash = "#uniqueHashCode#";
String wifiMacString = "";
String msgInit = "";

String filaCallBackEvent = "";
String msgCallBackEvent = "";

String evento = "";
String ioPin  = "";

byte gpio00 =  0;
bool gpio00State = false;

byte gpio02 =  2;
bool gpio02State = false;

int loopExec = 0;

void setup() {
  Serial.begin(115200);

  pinMode(gpio00, OUTPUT);
  pinMode(gpio02, OUTPUT);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
 
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connecting to WiFi..");
    
  }
  
  wifiMacString = WiFi.macAddress();
  msgInit = "{@@dispositivo@@:@@"+wifiMacString+"@@, @@tipo@@:@@receptor@@, @@token@@:@@"+clientUniqueHash+"@@}";
  
  Serial.println("Connected to the WiFi network");
  Serial.println(wifiMacString);

  client.setServer(mqttServer, mqttPort);
  client.setCallback(callback);
 
  while (!client.connected()) {
    Serial.println("Connecting to MQTT...");

    String clientMqtt = "client:"+wifiMacString;
    if (client.connect(clientMqtt.c_str())) {
 
      Serial.println("connected");
      filaCallBackEvent = "deviceEventResponse/"+clientUniqueHash+"/"+wifiMacString;
      String fila = "iot/"+clientUniqueHash+"/"+wifiMacString;
      client.subscribe((char*) fila.c_str());
      client.publish("initialization", msgInit.c_str());

    } else {

      Serial.print("failed with state ");
      Serial.print(client.state());
      delay(2000);
 
    }
  }
}
 
void callback(char* topic, byte* payload, unsigned int length) {
  String msg = "";

  Serial.print("Message:");
  for (int i = 0; i < length; i++) {
    msg = msg + (char)payload[i];
  }

  DeserializationError error = deserializeJson(doc, msg);

  if (error) {
    Serial.print(F("deserializeJson() failed: "));
    Serial.println(error.f_str());
    return;
  } else {
    evento = doc["eventId"].as<String>();
    ioPin  = doc["triggerPin"].as<String>();
    callExecFromTriggerMqtt();
  }

}

void callExecFromTriggerMqtt(){
  byte triggerPin = ioPin.toInt();
  if(triggerPin == 0){
      digitalWrite(gpio00, gpio00State);  //Liga rele 1
      gpio00State = !gpio00State;
  }else if(triggerPin == 2){
    digitalWrite(gpio02, gpio02State);   //Liga rele 2
    gpio02State = !gpio02State;
  }
  returnExecutedEvent();
}

void returnExecutedEvent(){
  String msgCallBackEvent = "{@@eventId@@:@@"+evento+"@@}";
  client.publish(filaCallBackEvent.c_str(), msgCallBackEvent.c_str());
}

void loop() {
  client.loop();

  loopExec = loopExec +1;
  if(loopExec-5 == 5){
    String msgOk = "receptorOk"; 
    client.publish("receptorOk", msgOk.c_str());
    loopExec = 0;
  }

  delay(50);
}
', "esp01", "receptor", "módulo relé 2 vias", 1);