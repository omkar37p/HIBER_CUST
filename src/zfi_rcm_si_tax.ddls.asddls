@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM Self Invoice Tax'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_RCM_SI_TAX
  as select distinct from I_SupplierInvoiceTaxAPI01 as tax

left outer join I_TaxCodeRate as rate
on rate.TaxCode = tax.TaxCode

left outer join I_SupplierInvoiceAPI01 as inv
on  inv.SupplierInvoice = tax.SupplierInvoice
and inv.FiscalYear      = tax.FiscalYear

{
  key tax.SupplierInvoice,
  key tax.FiscalYear,
  key tax.TaxCode,

      tax.DocumentCurrency,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      inv.InvoiceGrossAmount as InvoiceGrossAmount,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      tax.TaxAmount,

      rate.ConditionRateRatio,

      case
        when
             ( tax.TaxCode = 'R2'
               or tax.TaxCode = 'R4' )
             and rate.VATConditionType = 'ZICR'

        then cast(
               rate.ConditionRateRatio
               as abap.dec(15,3)
             )

        else cast(
               0
               as abap.dec(15,3)
             )
      end as CGSTRate,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      case
        when
             ( tax.TaxCode = 'R2'
               or tax.TaxCode = 'R4' )
             and rate.VATConditionType = 'ZICR'

        then cast(
               tax.TaxAmount
               as abap.dec(15,2)
             )

        else cast(
               0
               as abap.dec(15,2)
             )
      end as CGSTAmount,

      case
        when
             ( tax.TaxCode = 'R2'
               or tax.TaxCode = 'R4' )
             and rate.VATConditionType = 'ZISR'

        then cast(
               rate.ConditionRateRatio
               as abap.dec(15,3)
             )

        else cast(
               0
               as abap.dec(15,3)
             )
      end as SGSTRate,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      case
        when
             ( tax.TaxCode = 'R2'
               or tax.TaxCode = 'R4' )
             and rate.VATConditionType = 'ZISR'

        then cast(
               tax.TaxAmount
               as abap.dec(15,2)
             )

        else cast(
               0
               as abap.dec(15,2)
             )
      end as SGSTAmount,

      case
        when
             ( tax.TaxCode = 'R1'
               or tax.TaxCode = 'R3' )
             and rate.VATConditionType = 'ZRIN'

        then cast(
               rate.ConditionRateRatio
               as abap.dec(15,3)
             )

        else cast(
               0
               as abap.dec(15,3)
             )
      end as IGSTRate,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      case
        when
             ( tax.TaxCode = 'R1'
               or tax.TaxCode = 'R3' )
             and rate.VATConditionType = 'ZRIN'

        then cast(
               tax.TaxAmount
               as abap.dec(15,2)
             )

        else cast(
               0
               as abap.dec(15,2)
             )
      end as IGSTAmount

}
