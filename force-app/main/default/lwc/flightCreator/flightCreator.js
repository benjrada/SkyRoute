// flightCreator.js
import { LightningElement, track } from "lwc";
import saveFlightRecord from "@salesforce/apex/FlightCreatorController.saveFlightRecord";


export default class FlightCreator extends LightningElement {
  @track departureAirport;
  @track arrivalAirport;
  @track flightInfo;

  handleDepartureChange(event) {
    this.departureAirport = event.target.value;
  }

  handleArrivalChange(event) {
    this.arrivalAirport = event.target.value;
  }

  saveFlight() {
    saveFlightRecord({
      departureAirport: this.departureAirport,
      arrivalAirport: this.arrivalAirport
    })
      .then((result) => {
        this.flightInfo = result;
      })
      .catch((error) => {
        console.error("Error saving flight:", error);
        // Handle error appropriately (e.g., display error message)
      });
  }
}
