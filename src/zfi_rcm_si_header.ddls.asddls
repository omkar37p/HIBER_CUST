@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM Self Invoice Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFI_RCM_SI_HEADER
  as select distinct from ZFI_RCM_SI_VENDLINE as vl

    inner join ZFI_RCM_SI_DOCMAP as map
      on  map.CompanyCode        = vl.CompanyCode
      and map.FiscalYear         = vl.FiscalYear
      and map.AccountingDocument = vl.AccountingDocument

    left outer join I_CompanyCode as cc
      on cc.CompanyCode = vl.CompanyCode
                                         
    left outer join I_SupplierInvoiceAPI01 as inv
      on  inv.SupplierInvoice       = map.SupplierInvoice
      and inv.FiscalYear            = map.SupplierInvoiceFiscalYear
      and map.ReferenceDocumentType = 'RMRP'
                                       
    left outer join I_Supplier as sup
      on sup.Supplier = vl.Supplier

    left outer join I_RegionText as reg
      on  reg.Country  = sup.Country
      and reg.Region   = sup.Region
      and reg.Language = 'E'
             
    left outer join ZFI_RCM_SI_CHEQUE as och
      on  och.PaymentCompanyCode = vl.CompanyCode
      and och.PaymentDocument    = vl.ClearingJournalEntry
                                  
    left outer join ZFI_RCM_SI_BANK as bankdet
      on  bankdet.CompanyCode        = vl.CompanyCode
      and bankdet.FiscalYear         = vl.ClearingJournalEntryFiscalYear
      and bankdet.AccountingDocument = vl.ClearingJournalEntry

    left outer join ZFI_RCM_SI_TAXABLE as tv
      on  tv.CompanyCode        = vl.CompanyCode
      and tv.FiscalYear         = vl.FiscalYear
      and tv.AccountingDocument = vl.AccountingDocument
     
    left outer join ZFI_RCM_SI_TAX_SUM as taxsum
      on  taxsum.CompanyCode        = vl.CompanyCode
      and taxsum.FiscalYear         = vl.FiscalYear
      and taxsum.AccountingDocument = vl.AccountingDocument

    left outer join I_OperationalAcctgDocItem as ss
      on  map.CompanyCode        = ss.CompanyCode
      and map.FiscalYear         = ss.FiscalYear
      and map.AccountingDocument = ss.AccountingDocument
      and ss.BusinessPlace <> ''
      

  composition [0..*] of ZFI_RCM_SI_ITEM as _Items
{
  key vl.CompanyCode,
  key vl.FiscalYear,
  key vl.AccountingDocument,

      map.DocumentReferenceID as InvoiceNumber,
      vl.DocumentDate         as InvoiceDate,
      vl.AccountingDocument   as RCMInvoiceNo,
      vl.DocumentDate         as RCMSelfInvoiceDate,

      vl.Supplier             as Supplier,
      sup.SupplierName        as SupplierName,
      sup.BPAddrStreetName    as SupplierAddress,
      sup.Region              as StateCode,
      reg.RegionName          as StateName,
      sup.TaxNumber3          as SupplierGSTIN,

      vl.Plant,

      'Smith Structures India Pvt Ltd' as CompanyName,

      case
        when vl.Plant = '' or vl.Plant = '2410' or vl.Plant = '2420'
          then 'New Block No. 358, Khata No. 570, Vansar, Taluka - Matar, Kheda, Gujarat - 387001'
        when vl.Plant = '3300'
          then 'Survey No. 317, 318, 319 & 320, Edur Road, Gumbli Village, Gummidipoondi Industrial Park, Gummidipoondi, Tiruvallur, Tamil Nadu, 601201'
        else ''
      end as CompanyAddress,

      case vl.CompanyCode
        when '2000' then '24AAQCS5395D1Z0'
        when '3000' then '24AFDFS1697F1ZW'
        else ''
      end as CompanyGSTIN,

      ss.BusinessPlace as PlaceofSupply,

      cc.Currency as DocumentCurrency,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      cast( tv.TaxableValue as abap.dec(23,2) ) as TaxableValue,

      taxsum.CGSTRate as CGSTRate,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      cast( taxsum.CGSTAmount as abap.dec(23,2) ) as CGSTAmount,

      taxsum.SGSTRate as SGSTRate,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      cast( taxsum.SGSTAmount as abap.dec(23,2) ) as SGSTAmount,

      taxsum.IGSTRate as IGSTRate,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      cast( taxsum.IGSTAmount as abap.dec(23,2) ) as IGSTAmount,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      cast(
       case
       when vl.TaxCode = 'R1'
        or vl.TaxCode = 'R2'
        or vl.TaxCode = 'R3'
        or vl.TaxCode = 'R4'
       then
       coalesce(
        cast(tv.TaxableValue as abap.dec(23,2)),
        cast(0 as abap.dec(23,2))
       )
       +
       case
        when coalesce(
          cast(taxsum.IGSTAmount as abap.dec(23,2)),
          cast(0 as abap.dec(23,2))
        ) <> 0
        then coalesce(
          cast(taxsum.IGSTAmount as abap.dec(23,2)),
          cast(0 as abap.dec(23,2))
        )
        else
          coalesce(
            cast(taxsum.CGSTAmount as abap.dec(23,2)),
            cast(0 as abap.dec(23,2))
          )
          +
          coalesce(
            cast(taxsum.SGSTAmount as abap.dec(23,2)),
            cast(0 as abap.dec(23,2))
          )
        end

       when vl.TaxCode = 'C1'
        or vl.TaxCode = 'C2'
        or vl.TaxCode = 'C3'
        or vl.TaxCode = 'C4'
       then coalesce(
      cast(tv.TaxableValue as abap.dec(23,2)),
      cast(0 as abap.dec(23,2))
      )

     else cast(0 as abap.dec(23,2))
     end
     as abap.dec(23,2)
     ) as TotalValue,

      och.OutgoingCheque as ChequeNo,

      case
        when och.ChequePaymentDate is null or och.ChequePaymentDate = '00000000'
          then ''
        else concat(
               concat( substring( cast( och.ChequePaymentDate as abap.char(8) ), 7, 2 ), '.' ),
               concat( concat( substring( cast( och.ChequePaymentDate as abap.char(8) ), 5, 2 ), '.' ),
                       substring( cast( och.ChequePaymentDate as abap.char(8) ), 1, 4 ) ) )
      end as ChequeDate,

      bankdet.BankName   as BankName,
      bankdet.BankBranch as BankBranch,

      _Items
}

