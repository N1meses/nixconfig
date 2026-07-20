_: {
  aspects.seatSeatd.finix = _: { services.seatd.enable = true; };
  aspects.seatElogind.finix = _: { services.elogind.enable = true; };
}
