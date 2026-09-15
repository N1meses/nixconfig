_: {
  aspects.finix.seat.seatd = {
    description = "Test Matrix: Selects seatd as the seat/session manager.";
    finix = _: { services.seatd.enable = true; };
  };
}
