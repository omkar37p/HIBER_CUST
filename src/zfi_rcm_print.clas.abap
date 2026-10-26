*CLASS zfi_rcm_print DEFINITION
*
*  PUBLIC
*  FINAL
*  CREATE PUBLIC.
*  PUBLIC SECTION.
*    INTERFACES if_sadl_exit_calc_element_read.
*    CLASS-METHODS:
*      get_pdf
*        IMPORTING
*          im_company_code        TYPE ZC_FI_RCM_SI_HEADER-CompanyCode
*          im_fiscal_year         TYPE ZC_FI_RCM_SI_HEADER-FiscalYear
*          im_accounting_document TYPE ZC_FI_RCM_SI_HEADER-AccountingDocument
*
*        RETURNING VALUE(rt_v_pdf) TYPE xstring
*        RAISING
*          cx_fp_fdp_error
*          cx_fp_form_reader
*          cx_fp_ads_util.
*
*    CLASS-DATA:
*      mc_duplicate_call TYPE abap_boolean.
*
*  PROTECTED SECTION.
*
*  PRIVATE SECTION.
*
*ENDCLASS.
*
*CLASS zfi_rcm_print IMPLEMENTATION.
*
*  METHOD if_sadl_exit_calc_element_read~calculate.
*
*    DATA:
*      lt_rcm_form TYPE STANDARD TABLE OF ZC_FI_RCM_SI_HEADER,
*      ls_rcm_form TYPE ZC_FI_RCM_SI_HEADER.
*
*    lt_rcm_form = CORRESPONDING #( it_original_data ).
*
*    LOOP AT lt_rcm_form ASSIGNING FIELD-SYMBOL(<fs_s_header>).
*
*      IF line_exists(
*           it_requested_calc_elements[ table_line = 'ATTACHMENT' ]
*         )
*         AND mc_duplicate_call IS INITIAL.
*
*        TRY.
*
*            <fs_s_header>-attachment = get_pdf(
*             im_company_code         = <fs_s_header>-CompanyCode
*             im_fiscal_year          = <fs_s_header>-FiscalYear
*             im_accounting_document  = <fs_s_header>-AccountingDocument
*              ).
*
*
*          CATCH cx_fp_fdp_error
*                cx_fp_form_reader
*                cx_fp_ads_util
*                INTO DATA(lx_data).
*
*            DATA(lv_message) = lx_data->get_text( ).
*
*        ENDTRY.
*
*      ENDIF.
*
*      <fs_s_header>-filename = |{ <fs_s_header>-AccountingDocument ALPHA = OUT }_RCM_SELF_INVOICE.pdf|.
*      <fs_s_header>-mimetype = 'application/pdf'.
*
*    ENDLOOP.
*
*    ct_calculated_data = CORRESPONDING #( lt_rcm_form ).
*  ENDMETHOD.
*
*  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
*
*    APPEND 'COMPANYCODE'
*      TO et_requested_orig_elements.
*
*    APPEND 'FISCALYEAR'
*      TO et_requested_orig_elements.
*
*    APPEND 'ACCOUNTINGDOCUMENT'
*      TO et_requested_orig_elements.
*
*  ENDMETHOD.
*
*  METHOD get_pdf.
*
*    mc_duplicate_call = abap_true.
*
*    DATA(lo_fdp_api) = cl_fp_fdp_services=>get_instance(
*        iv_max_depth          = 1
*        iv_service_definition = 'ZFI_RCM_PRINT_SD'
*      ).
*
*    DATA(lt_keys) =
*      lo_fdp_api->get_keys( ).
*
*    lt_keys[
*      name = 'COMPANYCODE'
*    ]-value = im_company_code.
*
*    lt_keys[
*      name = 'FISCALYEAR'
*    ]-value = im_fiscal_year.
*
*    lt_keys[
*      name = 'ACCOUNTINGDOCUMENT'
*    ]-value = im_accounting_document.
*
*    DATA(lv_data) = lo_fdp_api->read_to_xml_v2(
*        it_select = lt_keys
*      ).
*
*    DATA(lo_reader) =
*      cl_fp_form_reader=>create_form_reader( 'ZFI_RCM_SI_FORM' ).
*
*    DATA(ls_layout) = lo_reader->get_layout( ).
*
*    cl_fp_ads_util=>render_pdf(
*
*      EXPORTING
*        iv_xml_data = lv_data
*        iv_xdp_layout = ls_layout
*        iv_locale = 'en_US'
*      IMPORTING
*        ev_pdf = rt_v_pdf
*    ).
*
*    mc_duplicate_call = abap_false.
*
*  ENDMETHOD.
*ENDCLASS.

CLASS zfi_rcm_print DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.

    CLASS-METHODS get_pdf
      IMPORTING
        im_company_code        TYPE zc_fi_rcm_si_header-CompanyCode
        im_fiscal_year         TYPE zc_fi_rcm_si_header-FiscalYear
        im_accounting_document TYPE zc_fi_rcm_si_header-AccountingDocument
      RETURNING
        VALUE(rt_v_pdf)        TYPE xstring
      RAISING
        cx_fp_fdp_error
        cx_fp_form_reader
        cx_fp_ads_util.

    CLASS-METHODS amount_in_words
      IMPORTING
        iv_amount       TYPE decfloat34
      RETURNING
        VALUE(rv_words) TYPE string.

    CLASS-DATA mc_duplicate_call TYPE abap_boolean.

  PROTECTED SECTION.

  PRIVATE SECTION.
    CLASS-METHODS number_to_words
      IMPORTING
        iv_number       TYPE int8
      RETURNING
        VALUE(rv_words) TYPE string.

ENDCLASS.



CLASS ZFI_RCM_PRINT IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA lt_rcm_form TYPE STANDARD TABLE OF zc_fi_rcm_si_header WITH DEFAULT KEY.

    lt_rcm_form = CORRESPONDING #( it_original_data ).

    DATA(lv_words_req) = xsdbool( line_exists( it_requested_calc_elements[ table_line = 'AMOUNTINWORDS' ] ) ).
    DATA(lv_pdf_req)   = xsdbool( line_exists( it_requested_calc_elements[ table_line = 'ATTACHMENT' ] ) ).

    LOOP AT lt_rcm_form ASSIGNING FIELD-SYMBOL(<fs_s_header>).

      IF lv_words_req = abap_true.
        <fs_s_header>-AmountInWords = amount_in_words( CONV decfloat34( <fs_s_header>-TotalValue ) ).
      ENDIF.

      " PDF only for single-entity read (download), not for the whole list
      IF lv_pdf_req = abap_true
         AND mc_duplicate_call = abap_false
         AND lines( lt_rcm_form ) = 1.
        TRY.
            <fs_s_header>-Attachment = get_pdf(
              im_company_code        = <fs_s_header>-CompanyCode
              im_fiscal_year         = <fs_s_header>-FiscalYear
              im_accounting_document = <fs_s_header>-AccountingDocument ).
          CATCH cx_fp_fdp_error cx_fp_form_reader cx_fp_ads_util.
            CLEAR <fs_s_header>-Attachment.
        ENDTRY.
      ENDIF.

      <fs_s_header>-FileName = |{ <fs_s_header>-AccountingDocument ALPHA = OUT }_RCM_SELF_INVOICE.pdf|.
      <fs_s_header>-MimeType = 'application/pdf'.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_rcm_form ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    " et_requested_orig_elements is a SORTED table -> use INSERT INTO TABLE, never APPEND
    LOOP AT it_requested_calc_elements INTO DATA(lv_calc_element).
      CASE lv_calc_element.
        WHEN 'AMOUNTINWORDS'.
          INSERT CONV #( 'TOTALVALUE' ) INTO TABLE et_requested_orig_elements.
        WHEN 'ATTACHMENT' OR 'FILENAME' OR 'MIMETYPE'.
          INSERT CONV #( 'COMPANYCODE' )        INTO TABLE et_requested_orig_elements.
          INSERT CONV #( 'FISCALYEAR' )         INTO TABLE et_requested_orig_elements.
          INSERT CONV #( 'ACCOUNTINGDOCUMENT' ) INTO TABLE et_requested_orig_elements.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_pdf.

    mc_duplicate_call = abap_true.

    TRY.
        DATA(lo_fdp_api) = cl_fp_fdp_services=>get_instance(
                             iv_max_depth          = 1
                             iv_service_definition = 'ZFI_RCM_PRINT_SD' ).

        DATA(lt_keys) = lo_fdp_api->get_keys( ).

        LOOP AT lt_keys ASSIGNING FIELD-SYMBOL(<fs_key>).
          CASE <fs_key>-name.
            WHEN 'COMPANYCODE'.
              <fs_key>-value = im_company_code.
            WHEN 'FISCALYEAR'.
              <fs_key>-value = im_fiscal_year.
            WHEN 'ACCOUNTINGDOCUMENT'.
              <fs_key>-value = im_accounting_document.
          ENDCASE.
        ENDLOOP.

        DATA(lv_data) = lo_fdp_api->read_to_xml_v2( it_select = lt_keys ).

        DATA(lo_reader) = cl_fp_form_reader=>create_form_reader( 'ZFI_RCM_SI_FORM' ).
        DATA(ls_layout) = lo_reader->get_layout( ).

        cl_fp_ads_util=>render_pdf(
          EXPORTING
            iv_xml_data   = lv_data
            iv_xdp_layout = ls_layout
            iv_locale     = 'en_US'
          IMPORTING
            ev_pdf        = rt_v_pdf ).

      CLEANUP.
        mc_duplicate_call = abap_false.
    ENDTRY.

    mc_duplicate_call = abap_false.

  ENDMETHOD.


  METHOD amount_in_words.

    DATA(lv_amount) = abs( iv_amount ).
    DATA(lv_rupees) = CONV int8( trunc( lv_amount ) ).
    DATA(lv_paise)  = CONV int8( round( val = ( lv_amount - lv_rupees ) * 100 dec = 0 ) ).

    IF lv_paise = 100.
      lv_rupees = lv_rupees + 1.
      lv_paise  = 0.
    ENDIF.

    rv_words = COND #( WHEN lv_rupees = 0 THEN `Zero` ELSE number_to_words( lv_rupees ) ).
    rv_words = |{ rv_words } Rupees|.

    IF lv_paise > 0.
      rv_words = |{ rv_words } and { number_to_words( lv_paise ) } Paise|.
    ENDIF.

    rv_words = |{ rv_words } Only|.
    CONDENSE rv_words.

  ENDMETHOD.


  METHOD number_to_words.

    DATA(lt_ones) = VALUE string_table(
      ( `One` ) ( `Two` ) ( `Three` ) ( `Four` ) ( `Five` ) ( `Six` ) ( `Seven` )
      ( `Eight` ) ( `Nine` ) ( `Ten` ) ( `Eleven` ) ( `Twelve` ) ( `Thirteen` )
      ( `Fourteen` ) ( `Fifteen` ) ( `Sixteen` ) ( `Seventeen` ) ( `Eighteen` )
      ( `Nineteen` ) ).

    DATA(lt_tens) = VALUE string_table(
      ( `` ) ( `Twenty` ) ( `Thirty` ) ( `Forty` ) ( `Fifty` )
      ( `Sixty` ) ( `Seventy` ) ( `Eighty` ) ( `Ninety` ) ).

    DATA(lv_n) = iv_number.

    IF lv_n >= 10000000.
      rv_words = |{ rv_words } { number_to_words( lv_n DIV 10000000 ) } Crore|.
      lv_n = lv_n MOD 10000000.
    ENDIF.

    IF lv_n >= 100000.
      rv_words = |{ rv_words } { number_to_words( lv_n DIV 100000 ) } Lakh|.
      lv_n = lv_n MOD 100000.
    ENDIF.

    IF lv_n >= 1000.
      rv_words = |{ rv_words } { number_to_words( lv_n DIV 1000 ) } Thousand|.
      lv_n = lv_n MOD 1000.
    ENDIF.

    IF lv_n >= 100.
      rv_words = |{ rv_words } { lt_ones[ lv_n DIV 100 ] } Hundred|.
      lv_n = lv_n MOD 100.
    ENDIF.

    IF lv_n > 0.
      IF lv_n < 20.
        rv_words = |{ rv_words } { lt_ones[ lv_n ] }|.
      ELSE.
        rv_words = |{ rv_words } { lt_tens[ lv_n DIV 10 ] }|.
        IF lv_n MOD 10 > 0.
          rv_words = |{ rv_words } { lt_ones[ lv_n MOD 10 ] }|.
        ENDIF.
      ENDIF.
    ENDIF.

    CONDENSE rv_words.

  ENDMETHOD.
ENDCLASS.
