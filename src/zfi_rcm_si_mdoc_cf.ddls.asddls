@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RCM SI - Material doc custom fields'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_RCM_SI_MDOC_CF
  as select from I_MaterialDocumentItem_2
{
  key MaterialDocumentYear,
  key MaterialDocument,

      max( YY1_LRNO_MMI )       as LorryReceiptNo,
      max( YY1_EwayBillNo_MMI ) as EWayBillNo
}
group by MaterialDocumentYear,
         MaterialDocument
