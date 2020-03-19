*&---------------------------------------------------------------------*
*& Report ZHANA_RDA_SCENARIO_EDITOR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHANA_RDA_SCENARIO_EDITOR.

TYPES: BEGIN OF t_context_wa,
          tabname   TYPE rda_context-tabname,
          mainprog  TYPE rda_context-mainprog,
          jobname   TYPE rda_context-jobname,
       END OF t_context_wa,

       t_context TYPE STANDARD TABLE OF t_context_wa WITH DEFAULT KEY,

       BEGIN OF t_scenario_wa,
         name        TYPE rda_control-scenario,
         version     TYPE rda_control-version,
         description TYPE rda_control-description,
         context     TYPE t_context,
       END OF t_scenario_wa.

DATA: lt_tables TYPE TABLE OF t_context_wa,
      lv_table  TYPE t_context_wa,
      lv_rda_scenario TYPE rda_scenario,
      lv_rdacontrol   TYPE rda_control.

DATA: ls_fieldcat TYPE slis_fieldcat_alv,
      lt_fieldcatelog TYPE slis_t_fieldcat_alv.

DATA  gt_events TYPE  slis_t_event.

DATA: gr_table TYPE REF TO cl_salv_table.

CLEAR ls_fieldcat.
ls_fieldcat-col_pos   = 1.
ls_fieldcat-fieldname = 'TABNAME' .
ls_fieldcat-tabname   = 'DD02L'.
ls_fieldcat-seltext_m = 'Table'.
ls_fieldcat-outputlen = '36'.
ls_fieldcat-edit      = 'X'.
ls_fieldcat-ref_tabname   = 'DD02L'.
ls_fieldcat-ref_fieldname = 'TABNAME'.
ls_fieldcat-input     = 'X'.
APPEND ls_fieldcat TO lt_fieldcatelog.

CLEAR ls_fieldcat.
ls_fieldcat-col_pos  = 2.
ls_fieldcat-fieldname = 'MAINPROG'.
ls_fieldcat-tabname = 'MAINPROG'.
ls_fieldcat-seltext_m = 'Main program'.
ls_fieldcat-outputlen = '36'.
ls_fieldcat-edit      = 'X'.
APPEND ls_fieldcat TO lt_fieldcatelog.

CLEAR ls_fieldcat.
ls_fieldcat-col_pos  = 3.
ls_fieldcat-fieldname = 'JOBNAME'.
ls_fieldcat-tabname = 'JOBNAME'.
ls_fieldcat-seltext_m = 'Jobname'.
ls_fieldcat-outputlen = '36'.
ls_fieldcat-edit      = 'X'.
APPEND ls_fieldcat TO lt_fieldcatelog.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING  i_callback_program       = sy-cprog
             i_callback_pf_status_set = 'SET_PF_STATUS'
             i_callback_user_command  = 'USER_COMMAND '
             it_fieldcat              = lt_fieldcatelog
*  IMPORTING  E_EXIT_CAUSED_BY_CALLER  =
*             ES_EXIT_CAUSED_BY_USER   =
  TABLES     t_outtab                 = lt_tables
  EXCEPTIONS program_error            = 1
             OTHERS                   = 2 .

IF sy-subrc <> 0.

ENDIF.

*&———————————————————————*

*&      Form  USER_COMMAND

*&———————————————————————*

*       text

*———————————————————————-*

*      –>R_UCOMM      text

*      –>RS_SELFIELD  text

*———————————————————————-*

FORM user_command  USING r_ucomm LIKE sy-ucomm

                         rs_selfield TYPE slis_selfield.

  DATA: lc_ref_alv TYPE REF TO cl_gui_alv_grid.

  DATA: lt_sval TYPE TABLE OF sval,

        lv_sval TYPE sval,

        lv_rdacontext   TYPE rda_context,

        lt_rdacontrol   TYPE TABLE OF rda_control.

  DATA: lv_scenario  TYPE t_scenario_wa,

        lvxml_string TYPE string,

        ltxml_string TYPE TABLE OF string,

        lv_filename  TYPE string,

        lv_filename2 TYPE string,

        lv_path      TYPE string.

  DATA: ad_fdcat TYPE slis_fieldcat_alv,

        lt_ad_fdcat TYPE slis_t_fieldcat_alv,

        lv_selfsel  TYPE slis_selfield,

        lv_count    TYPE i,

        lv_message  TYPE string ,
        lv_msgv1    TYPE msgv1 .


  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING  e_grid = lc_ref_alv.

  IF NOT lc_ref_alv IS INITIAL.

    CALL METHOD lc_ref_alv->check_changed_data .

  ENDIF.


  CASE r_ucomm.

    WHEN 'ADD'.
      CLEAR lv_table.
      APPEND lv_table TO lt_tables.
      rs_selfield-refresh = 'X'.

    WHEN 'REM'.
      IF rs_selfield-tabindex > 0.
        DELETE lt_tables INDEX rs_selfield-tabindex.
        rs_selfield-refresh = 'X'.
      ENDIF.

    WHEN 'LOAD'.
      ad_fdcat-col_pos = 1.
      ad_fdcat-fieldname = 'SCENARIO'.
      ad_fdcat-tabname = 'RDA_CONTROL'.
      ad_fdcat-seltext_l = 'Scenario'.
      ad_fdcat-hotspot = 'X'.
      APPEND ad_fdcat TO lt_ad_fdcat.

      SELECT * FROM rda_control INTO TABLE lt_rdacontrol.

      CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
        EXPORTING  i_title       = 'Select a scenario'
                   i_selection   = 'X'
                   i_tabname     = 'RDA_CONTROL'
                   it_fieldcat   = lt_ad_fdcat
        IMPORTING  es_selfield   = lv_selfsel
        TABLES     t_outtab      = lt_rdacontrol
        EXCEPTIONS program_error = 1
                   OTHERS        = 2.

      IF sy-subrc = 0.

        CLEAR lt_tables.

        lv_rda_scenario = lv_selfsel-value.

        SELECT SINGLE * INTO lv_rdacontrol FROM rda_control WHERE scenario = lv_rda_scenario.

        SELECT * INTO lv_rdacontext FROM rda_context WHERE scenario = lv_rda_scenario.
          CLEAR lv_table.
          lv_table-tabname  = lv_rdacontext-tabname.
          lv_table-mainprog = lv_rdacontext-mainprog.
          lv_table-jobname  = lv_rdacontext-jobname.
          APPEND lv_table TO lt_tables.

        ENDSELECT.

        rs_selfield-refresh = 'X'.

      ENDIF.

    WHEN 'SAVE'.

      lv_scenario-context = lt_tables.
      IF NOT lv_rdacontrol IS INITIAL.
        lv_scenario-name        = lv_rdacontrol-scenario.
        lv_scenario-version     = lv_rdacontrol-version.
        lv_scenario-description = lv_rdacontrol-description.

      ELSE.
        lv_sval-fieldname = 'SCENARIO'.
        lv_sval-tabname   = 'RDA_CONTROL'.
        lv_sval-comp_tab  = 'RDA_CONTROL'.
        lv_sval-comp_field  = 'SCENARIO'.
        APPEND lv_sval TO lt_sval.

        CLEAR lv_sval.
        lv_sval-fieldname = 'VERSION'.
        lv_sval-tabname   = 'RDA_CONTROL'.
        lv_sval-value     = '1'.
        APPEND lv_sval TO lt_sval.

        CLEAR lv_sval.
        lv_sval-fieldname = 'DESCRIPTION'.
        lv_sval-tabname   = 'RDA_CONTROL'.
        lv_sval-fieldtext = 'Description'.
        APPEND lv_sval TO lt_sval.

        CALL FUNCTION 'POPUP_GET_VALUES'
          EXPORTING  popup_title     = 'Scenario information'
          TABLES     fields          = lt_sval
          EXCEPTIONS error_in_fields = 1
                     OTHERS          = 2.

        READ TABLE lt_sval INTO lv_sval INDEX 1.
        lv_scenario-name        = lv_sval-value.
        READ TABLE lt_sval INTO lv_sval INDEX 2.
        lv_scenario-version     = lv_sval-value.
        READ TABLE lt_sval INTO lv_sval INDEX 3.
        lv_scenario-description = lv_sval-value.
      ENDIF.

      CALL METHOD cl_gui_frontend_services=>file_save_dialog
        EXPORTING  window_title      = 'Save XML file to'
                   initial_directory = ''
                   default_extension = cl_gui_frontend_services=>filetype_xml
                   file_filter       = cl_gui_frontend_services=>filetype_xml
        CHANGING   filename          = lv_filename2
                   path              = lv_path
                   fullpath          = lv_filename.

      CALL TRANSFORMATION id
        SOURCE format_version = '1'
               scenario = lv_scenario
        RESULT XML lvxml_string .

      APPEND lvxml_string TO ltxml_string.

      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING  filename                = lv_filename
        TABLES     data_tab                = ltxml_string
        EXCEPTIONS file_write_error        = 1
                   no_batch                = 2
                   gui_refuse_filetransfer = 3
                   invalid_type            = 4
                   no_authority            = 5
                   unknown_error           = 6
                   header_not_allowed      = 7
                   separator_not_allowed   = 8
                   filesize_not_allowed    = 9
                   header_too_long         = 10
                   dp_error_create         = 11
                   dp_error_send           = 12
                   dp_error_write          = 13
                   unknown_dp_error        = 14
                   access_denied           = 15
                   dp_out_of_memory        = 16
                   disk_full               = 17
                   dp_timeout              = 18
                   file_not_found          = 19
                   dataprovider_exception  = 20
                   control_flush_error     = 21
                   OTHERS                  = 22.

      IF sy-subrc = 0.

        lv_message = |Scenario { lv_scenario-name } saved| .

        lv_msgv1 = lv_message .
        CALL FUNCTION 'POPUP_DISPLAY_MESSAGE'
          EXPORTING  titel     = 'File saved'
                     msgid     = '00'
                     msgty     = 'I'
                     msgno     = '001'
                     msgv1     = lv_msgv1 .

      ENDIF.

    WHEN 'CHECK'.

      LOOP AT lt_tables INTO lv_table.

        CLEAR lv_count.

        SELECT COUNT(*) INTO lv_count FROM dd02l WHERE tabname = lv_table-tabname.

        IF lv_count = 0.
          lv_message = |Table { lv_table-tabname } doesn't exist!| .

          lv_msgv1 = lv_message .
          CALL FUNCTION 'POPUP_DISPLAY_MESSAGE'
            EXPORTING  titel     = 'Error'
                       msgid     = '00'
                       msgty     = 'I'
                       msgno     = '001'
                       msgv1     = lv_msgv1 .

        ENDIF.

        CLEAR lv_count.

        SELECT COUNT(*) INTO lv_count FROM trdir WHERE name = lv_table-mainprog.

        IF lv_count = 0.

          lv_message = |Program { lv_table-mainprog } doesn't exist!| .

          lv_msgv1 = lv_message .
          CALL FUNCTION 'POPUP_DISPLAY_MESSAGE'
            EXPORTING  titel     = 'Error'
                       msgid     = '00'
                       msgty     = 'I'
                       msgno     = '001'
                       msgv1     = lv_msgv1 .

        ENDIF.

      ENDLOOP.

    WHEN OTHERS.

      LEAVE PROGRAM.

  ENDCASE.

ENDFORM.                    "user_command

*&———————————————————————*

*&      Form  SET_PF_STATUS

*&———————————————————————*

*       text

*———————————————————————-*

*      –>RT_EXTAB   text

*———————————————————————-*

FORM set_pf_status USING rt_extab TYPE slis_t_extab.

  SET PF-STATUS 'ZHANA_TOOLBAR' EXCLUDING rt_extab .

ENDFORM.                    "SET_PF_STATUS
