@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM Self Invoice - Tax Amounts'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_RCM_SI_TAX_AMT
  as select from I_OperationalAcctgDocItem as tax
{
  key tax.CompanyCode         as CompanyCode,
  key tax.FiscalYear          as FiscalYear,
  key tax.AccountingDocument  as AccountingDocument,

      tax.CompanyCodeCurrency as DocumentCurrency,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        case
          when tax.TransactionTypeDetermination = 'JIC'
            or tax.TransactionTypeDetermination = 'JCN'
          then cast( tax.AbsoluteAmountInCoCodeCrcy as abap.dec(23,2) )
          else cast( 0 as abap.dec(23,2) )
        end
      ) as CGSTAmount,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        case
          when tax.TransactionTypeDetermination = 'JIS'
            or tax.TransactionTypeDetermination = 'JSN'
          then cast( tax.AbsoluteAmountInCoCodeCrcy as abap.dec(23,2) )
          else cast( 0 as abap.dec(23,2) )
        end
      ) as SGSTAmount,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum(
        case
          when tax.TransactionTypeDetermination = 'JII'
            or tax.TransactionTypeDetermination = 'JIN'
          then cast( tax.AbsoluteAmountInCoCodeCrcy as abap.dec(23,2) )
          else cast( 0 as abap.dec(23,2) )
        end
      ) as IGSTAmount
}
where
     tax.TransactionTypeDetermination = 'JIC'
  or tax.TransactionTypeDetermination = 'JCN'
  or tax.TransactionTypeDetermination = 'JIS'
  or tax.TransactionTypeDetermination = 'JSN'
  or tax.TransactionTypeDetermination = 'JII'
  or tax.TransactionTypeDetermination = 'JIN'
group by
  tax.CompanyCode,
  tax.FiscalYear,
  tax.AccountingDocument,
  tax.CompanyCodeCurrency
