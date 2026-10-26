@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM Self Invoice - Taxable Value'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_RCM_SI_TAXABLE
  as select from I_AccountingDocumentJournal( P_Language: $session.system_language ) as jrnl
{                       
  key jrnl.CompanyCode,
  key jrnl.FiscalYear,
  key jrnl.AccountingDocument,
      jrnl.CompanyCodeCurrency,
                            
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( cast( jrnl.DebitAmountInCoCodeCrcy  as abap.dec(23,2) ) ) as DebitAmount,
              
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( cast( jrnl.CreditAmountInCoCodeCrcy as abap.dec(23,2) ) ) as CreditAmount,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( cast( jrnl.DebitAmountInCoCodeCrcy  as abap.dec(23,2) ) )
    + sum( cast( jrnl.CreditAmountInCoCodeCrcy as abap.dec(23,2) ) ) as TaxableValue
}
where jrnl.Ledger = '0L'
  and ( jrnl.TransactionTypeDetermination = ''
     or jrnl.TransactionTypeDetermination is null )
group by
  jrnl.CompanyCode,
  jrnl.FiscalYear,
  jrnl.AccountingDocument,
  jrnl.CompanyCodeCurrency
