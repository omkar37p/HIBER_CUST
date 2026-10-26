////@AccessControl.authorizationCheck: #NOT_REQUIRED
////@EndUserText.label: 'RCM Self Invoice Item'
////@Metadata.ignorePropagatedAnnotations: true
////define view entity ZFI_RCM_SI_ITEM
////  as select distinct from I_MaterialDocumentItem_2 as mdi
////
////    left outer join I_MaterialDocumentHeader_2 as mdh
////      on  mdh.MaterialDocument     = mdi.MaterialDocument
////      and mdh.MaterialDocumentYear = mdi.MaterialDocumentYear
////
////    left outer join I_ProductText as ptxt
////      on  ptxt.Product  = mdi.Material
////      and ptxt.Language = 'E'
////
////    left outer join I_PurchaseOrderItemAPI01 as po
////      on  po.PurchaseOrder     = mdi.PurchaseOrder
////      and po.PurchaseOrderItem = mdi.PurchaseOrderItem
////      
////    left outer join ZFI_RCM_SI_HEADER as hdr
////      on  hdr.CompanyCode = mdi.CompanyCode
////      and hdr.FiscalYear  = mdi.MaterialDocumentYear   
////
////    association to parent ZFI_RCM_SI_HEADER as _Header
////      on  _Header.CompanyCode = $projection.CompanyCode
////      and _Header.FiscalYear  = $projection.FiscalYear
////      and _Header.InvoiceNumber  = $projection.InvoiceNumber
////{
////  key hdr.InvoiceNumber as InvoiceNumber,
////
////      mdi.CompanyCode as CompanyCode,
////
////      mdi.MaterialDocumentYear as FiscalYear,
////      
////      ptxt.ProductName as DescriptionOfService,
////
////      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
////      mdi.QuantityInBaseUnit as Quantity,
////
////      mdi.MaterialBaseUnit,
////
////      mdi.PurchaseOrder,
////
////      mdi.PurchaseOrderItem,
////
////      mdi.Material,
////
////      cast(
////        po.NetPriceAmount
////        as abap.dec(15,2)
////      ) as PORate,
////
////      cast(
////        cast(
////          mdi.QuantityInBaseUnit
////          as abap.dec(15,3)
////        )
////        *
////        cast(
////          po.NetPriceAmount
////          as abap.dec(15,2)
////        )
////        as abap.dec(17,2)
////      ) as Amount,
////
////      _Header
////}
//
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//
//@EndUserText.label: 'RCM Self Invoice Item'
//
//@Metadata.ignorePropagatedAnnotations: true
//
//define view entity ZFI_RCM_SI_ITEM
//
//  as select distinct from I_MaterialDocumentItem_2 as mdi
//
//    left outer join I_MaterialDocumentHeader_2 as mdh
//      on  mdh.MaterialDocument     = mdi.MaterialDocument
//      and mdh.MaterialDocumentYear = mdi.MaterialDocumentYear
//
//    left outer join I_ProductText as ptxt
//      on  ptxt.Product  = mdi.Material
//      and ptxt.Language = 'E'
//
//    left outer join I_PurchaseOrderItemAPI01 as po
//      on  po.PurchaseOrder     = mdi.PurchaseOrder
//      and po.PurchaseOrderItem = mdi.PurchaseOrderItem
//
//    left outer join I_AccountingDocumentJournal(
//                         P_Language: $session.system_language
//                       ) as adj
//      on  adj.CompanyCode      = mdi.CompanyCode
//      and adj.FiscalYear       = mdi.MaterialDocumentYear
//      and adj.ReferenceDocument = mdi.MaterialDocument
//
//    left outer join ZFI_RCM_SI_HEADER as hdr
//      on  hdr.CompanyCode       = mdi.CompanyCode
//      and hdr.FiscalYear        = mdi.MaterialDocumentYear
//      and hdr.AccountingDocument = adj.AccountingDocument
//
//    association to parent ZFI_RCM_SI_HEADER as _Header
//      on  _Header.CompanyCode        = $projection.CompanyCode
//      and _Header.FiscalYear         = $projection.FiscalYear
//      and _Header.AccountingDocument = $projection.AccountingDocument
//
//{
//  
//
//  key mdi.MaterialDocument     as MaterialDocument,
//  
//  key mdi.CompanyCode          as CompanyCode,
//
//  key mdi.MaterialDocumentYear as FiscalYear,
//
//  key adj.AccountingDocument   as AccountingDocument,
//
//      hdr.InvoiceNumber        as InvoiceNumber,
//
//      ptxt.ProductName        as DescriptionOfService,
//
//      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
//      mdi.QuantityInBaseUnit  as Quantity,
//
//      mdi.MaterialBaseUnit,
//
//      mdi.PurchaseOrder,
//
//      mdi.PurchaseOrderItem,
//
//      mdi.Material,
//
//      cast(
//        po.NetPriceAmount
//        as abap.dec(15,2)
//      ) as PORate,
//
//      cast(
//        cast(
//          mdi.QuantityInBaseUnit
//          as abap.dec(15,3)
//        )
//        *
//        cast(
//          po.NetPriceAmount
//          as abap.dec(15,2)
//        )
//        as abap.dec(17,2)
//      ) as Amount,
//
//      _Header
//
//}

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM Self Invoice Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_RCM_SI_ITEM
  as select from ZFI_RCM_SI_DOCMAP as map

    inner join ZFI_RCM_SI_ITEM_AGG as itm
      on  itm.SupplierInvoice       = map.SupplierInvoice
      and itm.FiscalYear            = map.SupplierInvoiceFiscalYear
      and map.ReferenceDocumentType = 'RMRP'

    left outer join I_PurchaseOrderItemAPI01 as po
      on  po.PurchaseOrder     = itm.PurchaseOrder
      and po.PurchaseOrderItem = itm.PurchaseOrderItem

    left outer join I_ProductText as ptxt
      on  ptxt.Product  = po.Material
      and ptxt.Language = 'E'

    left outer join I_ProductPlantBasic as ppl
      on  ppl.Product = po.Material
      and ppl.Plant   = po.Plant
      
    left outer join ZFI_RCM_SI_MDOC_CF as mcf
      on  mcf.MaterialDocument     = itm.MaterialDocument
      and mcf.MaterialDocumentYear = itm.FiscalYear  

  association to parent ZFI_RCM_SI_HEADER as _Header
    on  _Header.CompanyCode        = $projection.CompanyCode
    and _Header.FiscalYear         = $projection.FiscalYear
    and _Header.AccountingDocument = $projection.AccountingDocument
{
  key map.CompanyCode,
  key map.FiscalYear,
  key map.AccountingDocument,
  key itm.SupplierInvoiceItem,

      map.DocumentReferenceID as InvoiceNumber,
      itm.MaterialDocument,

      coalesce( ptxt.ProductName, po.PurchaseOrderItemText ) as DescriptionOfService,

      ppl.ConsumptionTaxCtrlCode as HSNCode,
      
      mcf.LorryReceiptNo,
      mcf.EWayBillNo,

      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      itm.Quantity,
      itm.PurchaseOrderQuantityUnit,

      itm.PurchaseOrder,
      itm.PurchaseOrderItem,
      po.Material,

      cast( po.NetPriceAmount as abap.dec(15,2) ) as PORate,

      itm.DocumentCurrency,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      itm.Amount,

      _Header
}
