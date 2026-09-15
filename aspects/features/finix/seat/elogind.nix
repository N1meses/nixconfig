_: {
  aspects.finix.seat.elogind = {
    description = "Test Matrix: Selects elogind as the seat/session manager.";
    finix = _: { services.elogind.enable = true; };
  };
}
