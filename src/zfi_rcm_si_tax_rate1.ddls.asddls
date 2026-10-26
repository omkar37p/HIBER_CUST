@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM Self Invoice - Tax Rates'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_RCM_SI_TAX_RATE1
  as select from I_AccountingDocumentJournal( P_Language: $session.system_language )  as jr

    inner join I_TaxCodeRate as tr
      on  tr.TaxCode                      =  jr.TaxCode
      and tr.Country                      =  'IN'
      and tr.CndnRecordValidityStartDate  <= jr.PostingDate
      and tr.CndnRecordValidityEndDate    >= jr.PostingDate
{
  key jr.CompanyCode        as CompanyCode,
  key jr.FiscalYear         as FiscalYear,
  key jr.AccountingDocument as AccountingDocument,

      max(
        case
          when tr.VATConditionType = 'JICG'
            or tr.VATConditionType = 'JICN'
          then cast( tr.ConditionRateRatio as abap.dec(15,3) )
          else cast( 0 as abap.dec(15,3) )
        end
      ) as CGSTRate,

      max(
        case
          when tr.VATConditionType = 'JISG'
            or tr.VATConditionType = 'JISN'
          then cast( tr.ConditionRateRatio as abap.dec(15,3) )
          else cast( 0 as abap.dec(15,3) )
        end
      ) as SGSTRate,

      max(
        case
          when tr.VATConditionType = 'JIIG'
            or tr.VATConditionType = 'JIIN'
          then cast( tr.ConditionRateRatio as abap.dec(15,3) )
          else cast( 0 as abap.dec(15,3) )
        end
      ) as IGSTRate
}
where
      jr.Ledger  =  '0L'
  and jr.TaxCode <> ''
group by
  jr.CompanyCode,
  jr.FiscalYear,
  jr.AccountingDocument
