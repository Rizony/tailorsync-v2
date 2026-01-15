enum InvoiceStatus {
  /// Invoice has been issued and is payable
  issued,

  /// Invoice has been cancelled and is no longer payable
  cancelled, 
  paid, 
  partiallyPaid,
}
