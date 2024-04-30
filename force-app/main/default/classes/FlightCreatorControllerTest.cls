@isTest
private class FlightCreatorControllerTest {
  @isTest
  static void testSaveFlightRecord() {
    // Create test airport records with required fields
    Airport__c departureAirport = new Airport__c(
      Name = 'Test Departure Airport',
      IATACode__c = 'ABC',
      Latitude__c = 10.0,
      Longitude__c = 20.0
    );
    Airport__c arrivalAirport = new Airport__c(
      Name = 'Test Arrival Airport',
      IATACode__c = 'DEF',
      Latitude__c = 30.0,
      Longitude__c = 40.0
    );
    insert new List<Airport__c>{ departureAirport, arrivalAirport };

    // Call the Apex method
    Map<String, Object> flightInfo = FlightCreatorController.saveFlightRecord(
      departureAirport.IATACode__c,
      arrivalAirport.IATACode__c
    );

    // Verify that flight information is returned
    System.assertNotEquals(
      null,
      flightInfo,
      'Flight information should not be null'
    );
    System.assertNotEquals(
      null,
      flightInfo.get('DepartureAirportName'),
      'Departure airport name should not be null'
    );
    System.assertNotEquals(
      null,
      flightInfo.get('ArrivalAirportName'),
      'Arrival airport name should not be null'
    );
    System.assertNotEquals(
      null,
      flightInfo.get('FlightDistance'),
      'Flight distance should not be null'
    );
  }

  @isTest
  static void testGetAirportName() {
    // Create test airport record with required fields
    Airport__c testAirport = new Airport__c(
      Name = 'Test Airport',
      IATACode__c = 'GHI',
      Latitude__c = 10.0,
      Longitude__c = 20.0
    );
    insert testAirport;

    // Call the Apex method
    String airportName = FlightCreatorController.getAirportName(testAirport.Id);

    // Verify that airport name is returned
    System.assertNotEquals(
      null,
      airportName,
      'Airport name should not be null'
    );
    System.assertEquals(
      'Test Airport',
      airportName,
      'Airport name should match expected value'
    );
  }

  @isTest
  static void testCalculateDistance() {
    // Test coordinates
    Decimal latitude1 = 10.0;
    Decimal longitude1 = 20.0;
    Decimal latitude2 = 30.0;
    Decimal longitude2 = 40.0;

    // Call the Apex method
    Decimal distance = FlightCreatorController.calculateDistance(
      latitude1,
      longitude1,
      latitude2,
      longitude2
    );

    // Verify that distance is calculated correctly
    System.assertNotEquals(null, distance, 'Distance should not be null');
    System.assertEquals(
      3040.6028,
      distance.setScale(4),
      'Distance should match expected value'
    );
  }
}
