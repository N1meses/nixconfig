_: {
  aspects.finix.seatSeatd = {
    description = "Selects seatd as the seat/session manager.";
    finix = _: { services.seatd.enable = true; };
  };
  aspects.finix.seatElogind = {
    description = "Selects elogind as the seat/session manager.";
    finix = _: { services.elogind.enable = true; };
  };
}
