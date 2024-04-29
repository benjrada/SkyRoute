public with sharing class FlightController {

    // Obtain airports from DB
    @AuraEnabled(cacheable=true)
    public static List<Airport__c> getAirports() {
        return [SELECT Id, IATACode__c FROM Airport__c ORDER BY IATACode__c];
    }

    // Save flight and serve flight info
    @AuraEnabled
    public static FlightInfo saveFlight(Id departureAirportId, Id arrivalAirportId) {
        
        Airport__c departureAirport = [SELECT Id, IATACode__c, Latitude__c, Longitude__c FROM Airport__c WHERE Id = :departureAirportId LIMIT 1];
        Airport__c arrivalAirport = [SELECT Id, IATACode__c, Latitude__c, Longitude__c FROM Airport__c WHERE Id = :arrivalAirportId LIMIT 1];

        Double distance = calculateDistance(departureAirport.Latitude__c, departureAirport.Longitude__c, arrivalAirport.Latitude__c, arrivalAirport.Longitude__c);

        // Create and save register
        Flight__c flight = new Flight__c(
            DepartureAirport__c = departureAirportId,
            ArrivalAirport__c = arrivalAirportId,
            Distance__c = distance
        );
        insert flight;

        // Return flight info
        return new FlightInfo(departureAirport.IATACode__c, arrivalAirport.IATACode__c, distance);
    }

    private static Decimal calculateDistance(Decimal latitude1, Decimal longitude1,
                                    Decimal latitude2, Decimal longitude2) {
        Integer earthRadius = 6371 * 1000; // in meters
        // Transform coordinates from degrees to radians
        Decimal latitudeRadians1 = latitude1 * Math.PI/180;
        Decimal latitudeRadians2 = latitude2 * Math.PI/180;
        // Latitude and longitude differences in radians
        Decimal latitudeDelta = (latitude2 - latitude1) * Math.PI/180;
        Decimal longitudeDelta = (longitude2 - longitude1) * Math.PI/180;
        Decimal a = Math.sin(latitudeDelta/2) * Math.sin(latitudeDelta/2) +
                    Math.cos(latitudeRadians1) * Math.cos(latitudeRadians2) *
                    Math.sin(longitudeDelta/2) * Math.sin(longitudeDelta/2);
        Decimal arc = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        Decimal distance = earthRadius * arc; // in metres
        return distance;
    }

    
    public class FlightInfo {
        @AuraEnabled
        public String departureAirportIATA {get; set;}
        @AuraEnabled
        public String arrivalAirportIATA {get; set;}
        @AuraEnabled
        public Double distance {get; set;}
        
        public FlightInfo(String departureAirportIATA, String arrivalAirportIATA, Double distance) {
            this.departureAirportIATA = departureAirportIATA;
            this.arrivalAirportIATA = arrivalAirportIATA;
            this.distance = distance;
        }
    }
}