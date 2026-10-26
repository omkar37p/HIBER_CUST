//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'RCM Self Invoice Tax Summary'
//@Metadata.ignorePropagatedAnnotations: true
//define view entity ZFI_RCM_SI_TAX_SUM
//  as select from I_OperationalAcctgDocTaxItem as tax
//                       
//    left outer join ZFI_RCM_SI_TAX_RATE as rt
//      on  rt.CompanyCode        = tax.CompanyCode
//      and rt.FiscalYear         = tax.FiscalYear
//      and rt.AccountingDocument = tax.AccountingDocument
//{                   
//  key tax.CompanyCode,
//  key tax.FiscalYear,
//  key tax.AccountingDocument,
//      tax.CompanyCodeCurrency as DocumentCurrency,
//                   
//      max( rt.CGSTRate ) as CGSTRate,
//      max( rt.SGSTRate ) as SGSTRate,
//      max( rt.IGSTRate ) as IGSTRate,
//                      
//      @Semantics.amount.currencyCode: 'DocumentCurrency'
//      sum( case when tax.TransactionTypeDetermination = 'JIC'
//                then cast( tax.TaxAmountInCoCodeCrcy as abap.dec(23,2) )
//                else cast( 0 as abap.dec(23,2) ) end ) as CGSTAmount,
//                                 
//      @Semantics.amount.currencyCode: 'DocumentCurrency'
//      sum( case when tax.TransactionTypeDetermination = 'JIS'
//                then cast( tax.TaxAmountInCoCodeCrcy as abap.dec(23,2) )
//                else cast( 0 as abap.dec(23,2) ) end ) as SGSTAmount,
//                              
//      @Semantics.amount.currencyCode: 'DocumentCurrency'
//      sum( case when tax.TransactionTypeDetermination = 'JII'
//                then cast( tax.TaxAmountInCoCodeCrcy as abap.dec(23,2) )
//                else cast( 0 as abap.dec(23,2) ) end ) as IGSTAmount
//}
//where tax.TransactionTypeDetermination = 'JIC'
//   or tax.TransactionTypeDetermination = 'JIS'
//   or tax.TransactionTypeDetermination = 'JII'
//group by
//  tax.CompanyCode,
//  tax.FiscalYear,
//  tax.AccountingDocument,
//  tax.CompanyCodeCurrency


@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM Self Invoice Tax Summary'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_RCM_SI_TAX_SUM
  as select from ZFI_RCM_SI_TAX_AMT as amt

    left outer join ZFI_RCM_SI_TAX_RATE1 as rt
      on  rt.CompanyCode        = amt.CompanyCode
      and rt.FiscalYear         = amt.FiscalYear
      and rt.AccountingDocument = amt.AccountingDocument
{
  key amt.CompanyCode,
  key amt.FiscalYear,
  key amt.AccountingDocument,

      amt.DocumentCurrency,

      rt.CGSTRate,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      amt.CGSTAmount,

      rt.SGSTRate,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      amt.SGSTAmount,

      rt.IGSTRate,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      amt.IGSTAmount
}

