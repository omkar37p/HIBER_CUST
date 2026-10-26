//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'RCM Self Invoice Item Consumption'
//@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
//@ObjectModel.supportedCapabilities: [#ANALYTICAL_QUERY]
//@Metadata.allowExtensions: true
//define view entity ZC_FI_RCM_SI_ITEM
//  as projection on ZFI_RCM_SI_ITEM
//
//{
//    key MaterialDocument,
//    key CompanyCode,
//    key FiscalYear,
//    key AccountingDocument,
//    InvoiceNumber,
//    DescriptionOfService,
//
//    @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
//    Quantity,
//
//    MaterialBaseUnit,
//
//    PurchaseOrder,
//    PurchaseOrderItem,
//    Material,
//
//    PORate,
//    Amount,
//    
//    _Header : redirected to parent ZC_FI_RCM_SI_HEADER
//}

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM Self Invoice Item Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_FI_RCM_SI_ITEM
  as projection on ZFI_RCM_SI_ITEM
{
  key CompanyCode,
  key FiscalYear,
  key AccountingDocument,
  key SupplierInvoiceItem,
      InvoiceNumber,
      MaterialDocument,
      DescriptionOfService,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      Quantity,
      PurchaseOrderQuantityUnit,
      HSNCode,
      LorryReceiptNo,
      EWayBillNo,
      PurchaseOrder,
      PurchaseOrderItem,
      Material,
      PORate,
      DocumentCurrency,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      Amount,
      _Header : redirected to parent ZC_FI_RCM_SI_HEADER
}
