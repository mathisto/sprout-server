# Sprout Server API Documentation

## Overview

The Sprout Server API allows ESP32 devices to send moisture readings for plants. The API is designed to be simple and easy to use with microcontrollers.

## Endpoints

### POST /api/readings

Submit a new moisture reading for a plant.

#### Request Parameters

| Parameter | Type    | Required | Description                               |
|-----------|---------|----------|-------------------------------------------|
| slug      | string  | Yes      | Unique identifier for the plant/device    |
| moisture  | integer | Yes      | Moisture level (0-100)                    |
| name      | string  | No       | Plant name (will update if provided)      |
| species   | string  | No       | Plant species (will update if provided)   |
| location  | string  | No       | Plant location (will update if provided)  |

#### Example Request

```
POST /api/readings
Content-Type: application/json

{
  "slug": "plant-001",
  "moisture": 75,
  "name": "Monstera",
  "species": "Monstera Deliciosa",
  "location": "Living Room"
}
```

#### Success Response

```json
{
  "success": true,
  "reading_id": 123,
  "timestamp": "2023-06-15T10:30:00Z"
}
```

#### Error Responses

**Missing required parameters:**

```json
{
  "success": false,
  "errors": ["Missing required parameter: slug", "Missing required parameter: moisture"]
}
```

**Invalid moisture value:**

```json
{
  "success": false,
  "errors": ["Moisture level must be between 0 and 100"]
}
```

**Server error:**

```json
{
  "success": false,
  "errors": ["Internal server error"]
}
```

## ESP32 Sample Code

Here's a simple example of how to send data from an ESP32 device using Arduino:

```cpp
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
const char* serverUrl = "http://your-server.com/api/readings";

// Plant/device unique identifier
const char* deviceSlug = "plant-001";

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  
  Serial.println("Connected to WiFi");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    // Read moisture from sensor (example using analog pin)
    int moistureRaw = analogRead(A0);
    
    // Convert to percentage (adjust min/max values based on your sensor)
    int moisturePercent = map(moistureRaw, 3200, 1400, 0, 100);
    moisturePercent = constrain(moisturePercent, 0, 100);
    
    // Create JSON payload
    StaticJsonDocument<200> doc;
    doc["slug"] = deviceSlug;
    doc["moisture"] = moisturePercent;
    doc["name"] = "My Plant";
    doc["species"] = "Unknown";
    doc["location"] = "Living Room";
    
    String jsonPayload;
    serializeJson(doc, jsonPayload);
    
    // Send HTTP POST request
    HTTPClient http;
    http.begin(serverUrl);
    http.addHeader("Content-Type", "application/json");
    
    int httpCode = http.POST(jsonPayload);
    
    if (httpCode > 0) {
      String response = http.getString();
      Serial.println("HTTP Response: " + response);
    } else {
      Serial.println("Error on HTTP request");
    }
    
    http.end();
  }
  
  // Wait before next reading (e.g., 30 minutes)
  delay(30 * 60 * 1000);
}
```

## Authentication

Currently, the API does not require authentication. In a production environment, consider adding an API key or other authentication method. 