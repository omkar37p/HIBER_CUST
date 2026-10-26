@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM SI - Vendor line per document'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_RCM_SI_VENDLINE
  as select from I_OperationalAcctgDocItem
{
  key CompanyCode,
  key FiscalYear,
  key AccountingDocument,
      max( Supplier )                       as Supplier,
      max( Plant )                          as Plant,
      max( DocumentDate )                   as DocumentDate,
      max( ClearingJournalEntry )           as ClearingJournalEntry,
      max( ClearingJournalEntryFiscalYear ) as ClearingJournalEntryFiscalYear,
      TaxCode
}
where DebitCreditCode      = 'H'
  and FinancialAccountType = 'K'
  and (    AccountingDocumentType = 'KR'
        or AccountingDocumentType = 'RE' )
  and Supplier <> ''
  and (
       TaxCode = 'R1'
    or TaxCode = 'R2'
    or TaxCode = 'R3'
    or TaxCode = 'R4'
    or TaxCode = 'C1'
    or TaxCode = 'C2'
    or TaxCode = 'C3'
    or TaxCode = 'C4'
  )
group by CompanyCode,
         FiscalYear,
         AccountingDocument,
         TaxCode
