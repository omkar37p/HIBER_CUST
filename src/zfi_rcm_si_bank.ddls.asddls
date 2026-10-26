@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM Self Invoice Bank Details'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_RCM_SI_BANK
  as select distinct from I_AccountingDocumentJournal(
                              P_Language: $session.system_language
                           ) as adj
                                
    inner join I_HouseBankAccountLinkage as hbal
      on hbal.HouseBank = adj.HouseBank
     and hbal.CompanyCode = adj.CompanyCode 
          
    left outer join I_Bank_2 as bank
      on bank.BankInternalID = hbal.BankInternalID
     and bank.BankCountry    = hbal.BankCountry 
         
{
  key adj.CompanyCode,
  key adj.FiscalYear,
  key adj.AccountingDocument,
                       
//      hbal.HouseBank      as HouseBank,
      max ( hbal.BankName )       as BankName,
//      hbal.BankInternalID as BankInternalID,
      max ( bank.BankBranch )     as BankBranch
}
                
where
      adj.Ledger = '0L'
  and adj.HouseBank <> ''
  
group by 
      adj.CompanyCode,
      adj.FiscalYear,
      adj.AccountingDocument      
