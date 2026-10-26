@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM Self Invoice Header Consumption'
@Metadata.allowExtensions: true
@ObjectModel.supportedCapabilities: [ #OUTPUT_FORM_DATA_PROVIDER ]
define root view entity ZC_FI_RCM_SI_HEADER
provider contract transactional_query
  as projection on ZFI_RCM_SI_HEADER

{
  key CompanyCode,
  key FiscalYear,
  key AccountingDocument,
      InvoiceNumber,
      InvoiceDate,

      RCMInvoiceNo,
      RCMSelfInvoiceDate,

      Supplier,
      SupplierName,
      SupplierAddress,

      StateCode,
      StateName,
      SupplierGSTIN,
      
      Plant,

      CompanyName,
      CompanyAddress,
      CompanyGSTIN,

      PlaceofSupply,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      TaxableValue,

      DocumentCurrency,

      CGSTRate,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      CGSTAmount,

      SGSTRate,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      SGSTAmount,

      IGSTRate,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      IGSTAmount,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      TotalValue,

      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZFI_RCM_PRINT'
      virtual AmountInWords : abap.char(255),

      ChequeNo,
      ChequeDate,
      
      BankName,
      BankBranch,

      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZFI_RCM_PRINT'
      virtual FileName : abap.char(50),

      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZFI_RCM_PRINT'
      @Semantics.mimeType: true
      virtual MimeType : abap.char(50),

      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZFI_RCM_PRINT'
      @Semantics.largeObject: {
        mimeType: 'MimeType',
        fileName: 'FileName',
        contentDispositionPreference: #ATTACHMENT
      }
      virtual Attachment : abap.rawstring(0),
      _Items : redirected to composition child ZC_FI_RCM_SI_ITEM

}
