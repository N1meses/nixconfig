_: {
  aspects.finix.seatSeatd = {
    description = "Test Matrix: Selects seatd as the seat/session manager.";
    finix = _: { services.seatd.enable = true; };
  };
  aspects.finix.seatElogind = {
    description = "Test Matrix: Selects elogind as the seat/session manager.";
    finix = _: { services.elogind.enable = true; };
  };
}
