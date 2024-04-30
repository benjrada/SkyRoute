// FlightCreatorController.cls
public with sharing class FlightCreatorController {
  @AuraEnabled(cacheable=false)
  public static String getAirportName(Id airportId) {
    Airport__c airport = [
      SELECT Name
      FROM Airport__c
      WHERE Id = :airportId
      LIMIT 1
    ];
    return airport != null ? airport.Name : null;
  }

  // Apex method to save flight record and return flight information
  @AuraEnabled(cacheable=false)
  public static Map<String, Object> saveFlightRecord(
    String departureAirport,
    String arrivalAirport
  ) {
    // Query airports to get latitude and longitude
    Airport__c departure = [
      SELECT Name, Latitude__c, Longitude__c
      FROM Airport__c
      WHERE IATACode__c = :departureAirport
      LIMIT 1
    ];
    Airport__c arrival = [
      SELECT Name, Latitude__c, Longitude__c
      FROM Airport__c
      WHERE IATACode__c = :arrivalAirport
      LIMIT 1
    ];
    if (departure == null) {
      throw new AuraHandledException(
        'Departure airport not found for the provided code: ' + departureAirport
      );
    }
    if (arrival == null) {
      throw new AuraHandledException(
        'Arrival airport not found for the provided code: ' + arrivalAirport
      );
    }

    // Calculate flight distance
    Decimal distance = calculateDistance(
      departure.Latitude__c,
      departure.Longitude__c,
      arrival.Latitude__c,
      arrival.Longitude__c
    );

    // Create flight record
    Flight__c newFlight = new Flight__c(
      departureAirport__c = departure.Id,
      arrivalAirport__c = arrival.Id,
      distance__c = distance
    );
    insert newFlight;

    // Query departure airport name
    String departureAirportName = departure.Name; //getAirportName(newFlight.departureAirport__c);

    // Query arrival airport name
    String arrivalAirportName = arrival.Name; //getAirportName(newFlight.arrivalAirport__c);

    // Return flight information
    // Prepare flight information map
    Map<String, Object> flightInfo = new Map<String, Object>();
    flightInfo.put('DepartureAirportName', departureAirportName);
    flightInfo.put('ArrivalAirportName', arrivalAirportName);
    flightInfo.put('FlightDistance', distance);

    return flightInfo;
  }

  // Apex method to calculate flight distance using Haversine formula
  public static Decimal calculateDistance(
    Decimal latitude1,
    Decimal longitude1,
    Decimal latitude2,
    Decimal longitude2
  ) {
    Integer earthRadius = 6371 * 1000; // in meters

    // Transform coordinates from degrees to radians
    Decimal latitudeRadians1 = latitude1 * Math.PI / 180;
    Decimal latitudeRadians2 = latitude2 * Math.PI / 180;
    // Latitude and longitude differences in radians
    Decimal latitudeDelta = (latitude2 - latitude1) * Math.PI / 180;
    Decimal longitudeDelta = (longitude2 - longitude1) * Math.PI / 180;

    Decimal a =
      Math.sin(latitudeDelta / 2) * Math.sin(latitudeDelta / 2) +
      Math.cos(latitudeRadians1) *
      Math.cos(latitudeRadians2) *
      Math.sin(longitudeDelta / 2) * Math.sin(longitudeDelta / 2);

    Decimal arc = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    Decimal distance = earthRadius * arc; // in meters

    return distance / 1000; // Convert meters to kilometers
  }
}
