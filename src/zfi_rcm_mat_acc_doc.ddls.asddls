@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Document Accounting Document'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_RCM_MAT_ACC_DOC
  as select distinct from I_JournalEntry as je
{
  key je.CompanyCode,
  key je.FiscalYear,

      je.AccountingDocument,

      je.OriginalReferenceDocument
}
where je.BusinessTransactionType = 'RMWA'
