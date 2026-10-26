@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM SI - Cheque per payment document'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_RCM_SI_CHEQUE
  as select from I_OutgoingCheck
{                                
  key PaymentCompanyCode,
  key PaymentDocument,
      max( OutgoingCheque )    as OutgoingCheque,
      max( ChequePaymentDate ) as ChequePaymentDate
}
group by PaymentCompanyCode,
         PaymentDocument
