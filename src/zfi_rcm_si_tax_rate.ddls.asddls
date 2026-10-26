@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM Self Invoice - GST Rates'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_RCM_SI_TAX_RATE
  as select from I_AccountingDocumentJournal( P_Language: $session.system_language ) as jrnl

    inner join I_TaxCodeRate as rate
      on rate.TaxCode = jrnl.TaxCode
{
  key jrnl.CompanyCode,
  key jrnl.FiscalYear,
  key jrnl.AccountingDocument,

      max( case when rate.VATConditionType = 'JICG'
                then cast( rate.ConditionRateRatio as abap.dec(13,3) ) end ) as CGSTRate,

      max( case when rate.VATConditionType = 'JISG'
                then cast( rate.ConditionRateRatio as abap.dec(13,3) ) end ) as SGSTRate,

      max( case when rate.VATConditionType = 'JIIG'
                then cast( rate.ConditionRateRatio as abap.dec(13,3) ) end ) as IGSTRate
}
where jrnl.Ledger  =  '0L'
  and jrnl.TaxCode <> ''
  and ( rate.VATConditionType = 'JICG'
     or rate.VATConditionType = 'JISG'
     or rate.VATConditionType = 'JIIG' )
group by
  jrnl.CompanyCode,
  jrnl.FiscalYear,
  jrnl.AccountingDocument
