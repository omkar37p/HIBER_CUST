@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM SI - FI doc to Supplier Invoice map'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_RCM_SI_DOCMAP
  as select from I_JournalEntry
{                       
  key CompanyCode,              
  key FiscalYear,     
  key AccountingDocument,
      DocumentReferenceID,
      ReferenceDocumentType,
      cast( substring( OriginalReferenceDocument, 1, 10 ) as abap.char(10) ) as SupplierInvoice,
      cast( substring( OriginalReferenceDocument, 11, 4 ) as abap.numc(4) )  as SupplierInvoiceFiscalYear
}
