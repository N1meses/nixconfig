_: {
  aspects.seatSeatd.description = "Selects seatd as the seat/session manager.";
  aspects.seatSeatd.finix = _: { services.seatd.enable = true; };
  aspects.seatElogind.description = "Selects elogind as the seat/session manager.";
  aspects.seatElogind.finix = _: { services.elogind.enable = true; };
}
