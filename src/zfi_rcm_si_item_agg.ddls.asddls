@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM SI - Invoice items aggregated'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_RCM_SI_ITEM_AGG
  as select from I_SuplrInvcItemPurOrdRefAPI01
{
  key SupplierInvoice,
  key FiscalYear,
  key PurchaseOrderQuantityUnit,
  key DocumentCurrency,

      min( SupplierInvoiceItem ) as SupplierInvoiceItem,
      min( PurchaseOrder )       as PurchaseOrder,
      min( PurchaseOrderItem )   as PurchaseOrderItem,
      min( ReferenceDocument )   as MaterialDocument,

      sum( cast( QuantityInPurchaseOrderUnit as abap.dec(15,3) ) ) as Quantity,
      sum( cast( SupplierInvoiceItemAmount   as abap.dec(17,2) ) ) as Amount
}
group by SupplierInvoice,
         FiscalYear,
         PurchaseOrderQuantityUnit,
         DocumentCurrency
