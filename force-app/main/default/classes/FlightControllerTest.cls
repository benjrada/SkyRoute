@isTest
private class FlightControllerTest {
    
    @testSetup
    static void setup() {
        List<Airport__c> airports = new List<Airport__c>{
            new Airport__c(IATACode__c='BCN', Latitude__c=37.7749, Longitude__c=-122.4194),  
            new Airport__c(IATACode__c='MAD', Latitude__c=34.0522, Longitude__c=-118.2437)   
        };
        insert airports;
    }

    @isTest
    static void testGetAirports() {
        Test.startTest();
        List<Airport__c> airports = FlightController.getAirports();
        Test.stopTest();
        
        // Asserts
        System.assertEquals(2, airports.size(), 'Expected 2 airports in the list.');
    }
    
    @isTest
    static void testSaveFlight() {
        List<Airport__c> airports = [SELECT Id FROM Airport__c];
        
        Test.startTest();
        FlightController.FlightInfo flightInfo = FlightController.saveFlight(airports[0].Id, airports[1].Id);
        Test.stopTest();
        
        // Asserts
        System.assertNotEquals(null, flightInfo, 'FlightInfo should not be null.');
        System.assertEquals('BCN', flightInfo.departureAirportIATA, 'Departure airport should be BCN.');
        System.assertEquals('MAD', flightInfo.arrivalAirportIATA, 'Arrival airport should be MAD.');
        
        Flight__c flight = [SELECT Id, Distance__c FROM Flight__c WHERE DepartureAirport__c = :airports[0].Id AND ArrivalAirport__c = :airports[1].Id LIMIT 1];
        System.assertNotEquals(null, flight, 'Flight record should have been created.');
        System.assertEquals(flightInfo.distance, flight.Distance__c, 'Distance in FlightInfo should match the flight record.');
    }
}
