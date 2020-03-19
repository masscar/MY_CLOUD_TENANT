*&---------------------------------------------------------------------*
*& Report Z_CREATE_EXCEL_FILE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_CREATE_EXCEL_FILE.

DATA:
   GV_FULLPATH type STRING ,
   GO_EXCEL type ref to ZCL_EXCEL ,
   GO_WORKSHEET type ref to ZCL_EXCEL_WORKSHEET ,
   GO_HYPERLINK type ref to ZCL_EXCEL_HYPERLINK ,
   GO_COLUMN type ref to ZCL_EXCEL_COLUMN ,
   GO_STYLE type ref to ZCL_EXCEL_STYLE ,
   GO_XLS_WRITER type ref to ZIF_EXCEL_WRITER ,
   GV_XDATA type XSTRING ,
   GT_RAWDATA type SOLIX_TAB ,
   GV_BYTECOUNT type I ,
   GO_BORDER_DARK type ref to ZCL_EXCEL_STYLE_BORDER ,
   GO_STYLE_NORMAL type ref to ZCL_EXCEL_STYLE ,
   GO_STYLE_BOLD_FONT12 type ref to ZCL_EXCEL_STYLE ,
   GO_STYLE_BOLD_FONT10 type ref to ZCL_EXCEL_STYLE ,
   GO_STYLE_ITALIC_FONT11 type ref to ZCL_EXCEL_STYLE ,
   GO_STYLE_CONVERSION_RATES type ref to ZCL_EXCEL_STYLE ,
   GO_STYLE_BOLD_CENTERED type ref to ZCL_EXCEL_STYLE ,
   GO_STYLE_FIGURE_ID type ref to ZCL_EXCEL_STYLE ,
   GO_STYLE_GROUP_ID type ref to ZCL_EXCEL_STYLE ,
   GO_STYLE_FIGURE_VALUES type ref to ZCL_EXCEL_STYLE ,
   GO_STYLE_GROUP_VALUES type ref to ZCL_EXCEL_STYLE ,
   GO_STYLE_PERIODS type ref to ZCL_EXCEL_STYLE ,
   GO_STYLE_GRAY_CELLS type ref to ZCL_EXCEL_STYLE ,
   GS_CELL_BORDER_DOWN type ZEXCEL_S_CSTYLE_BORDERS ,
   GS_CELL_BORDER_RIGHT type ZEXCEL_S_CSTYLE_BORDERS ,
   GS_CELL_BORDER_RIGHT_DOWN type ZEXCEL_S_CSTYLE_BORDERS ,
   GS_CELL_BORDER_RIGHT_TOP type ZEXCEL_S_CSTYLE_BORDERS ,
   GS_CELL_BORDER_RIGHT_TOP_DOWN type ZEXCEL_S_CSTYLE_BORDERS ,
   GS_CELL_BORDER_ALL type ZEXCEL_S_CSTYLE_BORDERS .

START-OF-SELECTION .

  PERFORM PREPARE_DATA .
  PERFORM DOWNLOAD_TO_EXCEL .

FORM PREPARE_DATA .

  gv_fullpath = '/home/I025305/Documents/Customers/WLF_aba2xlsx_report.xlsx' .

  TRY .

* instantiate excel app and objects
    " Creates active sheet
    CREATE OBJECT go_excel .

    " Get active sheet
    go_worksheet = go_excel->get_active_worksheet( ) .

* create writer: ZCL_EXCEL_WRITER_2007      - Excel writer 2007
*              | ZCL_EXCEL_WRITER_CSV       - Excel writer 2007
*              | ZCL_EXCEL_WRITER_HUGE_FILE - Create huge XLSX file
*              | ZCL_EXCEL_WRITER_XLSM      - Excel with macro writer
    CREATE OBJECT go_xls_writer TYPE zcl_excel_writer_2007 .

  CATCH zcx_excel .
  ENDTRY .

*---
DATA:
  lv_column_width                      TYPE p ,
  lv_monat                             TYPE monat ,
  lv_column_number                     TYPE i ,
  lv_row_number                        TYPE i .


* set styles
  go_style_normal                                      = go_excel->add_new_style( ) .
  go_style_normal->font->name                          = zcl_excel_style_font=>c_name_calibri .
  go_style_normal->font->scheme                        = zcl_excel_style_font=>c_scheme_none .

  go_style_bold_font12                                 = go_excel->add_new_style( ) .
  go_style_bold_font12->font->name                     = zcl_excel_style_font=>c_name_calibri .
  go_style_bold_font12->font->bold                     = abap_true .
  go_style_bold_font12->font->size                     = 12 .
  go_style_bold_font12->font->scheme                   = zcl_excel_style_font=>c_scheme_none .

  go_style_bold_font10                                 = go_excel->add_new_style( ) .
  go_style_bold_font10->font->name                     = zcl_excel_style_font=>c_name_calibri .
  go_style_bold_font10->font->bold                     = abap_true .
  go_style_bold_font10->font->size                     = 10 .
  go_style_bold_font10->font->scheme                   = zcl_excel_style_font=>c_scheme_none .

  go_style_italic_font11                               = go_excel->add_new_style( ) .
  go_style_italic_font11->font->name                   = zcl_excel_style_font=>c_name_calibri .
  go_style_italic_font11->font->italic                 = abap_true .
  go_style_italic_font11->font->size                   = 11 .
  go_style_italic_font11->font->scheme                 = zcl_excel_style_font=>c_scheme_none .

  CREATE OBJECT go_border_dark .
  go_border_dark->border_color-rgb                     = zcl_excel_style_color=>c_black .
  go_border_dark->border_style                         = zcl_excel_style_border=>c_border_thin .

  gs_cell_border_down-down-border_color-rgb            = zcl_excel_style_color=>c_black .
  gs_cell_border_down-down-border_style                = zcl_excel_style_border=>c_border_thin .

  gs_cell_border_right-right-border_color-rgb          = zcl_excel_style_color=>c_black .
  gs_cell_border_right-right-border_style              = zcl_excel_style_border=>c_border_thin .

  gs_cell_border_right_down-right-border_color-rgb     = zcl_excel_style_color=>c_black .
  gs_cell_border_right_down-right-border_style         = zcl_excel_style_border=>c_border_thin .
  gs_cell_border_right_down-down-border_color-rgb      = zcl_excel_style_color=>c_black .
  gs_cell_border_right_down-down-border_style          = zcl_excel_style_border=>c_border_thin .

  gs_cell_border_right_top-right-border_color-rgb      = zcl_excel_style_color=>c_black .
  gs_cell_border_right_top-right-border_style          = zcl_excel_style_border=>c_border_thin .
  gs_cell_border_right_top-top-border_color-rgb        = zcl_excel_style_color=>c_black .
  gs_cell_border_right_top-top-border_style            = zcl_excel_style_border=>c_border_thin .

  gs_cell_border_right_top_down-right-border_color-rgb = zcl_excel_style_color=>c_black .
  gs_cell_border_right_top_down-right-border_style     = zcl_excel_style_border=>c_border_thin .
  gs_cell_border_right_top_down-top-border_color-rgb   = zcl_excel_style_color=>c_black .
  gs_cell_border_right_top_down-top-border_style       = zcl_excel_style_border=>c_border_thin .
  gs_cell_border_right_top_down-down-border_color-rgb  = zcl_excel_style_color=>c_black .
  gs_cell_border_right_top_down-down-border_style      = zcl_excel_style_border=>c_border_thin .

  gs_cell_border_all-allborders-border_color-rgb       = zcl_excel_style_color=>c_black .
  gs_cell_border_all-allborders-border_style           = zcl_excel_style_border=>c_border_thin .

  go_style_conversion_rates                            = go_excel->add_new_style( ) .
  go_style_conversion_rates->font->name                = zcl_excel_style_font=>c_name_calibri .
  go_style_conversion_rates->font->size                = 11 .
  go_style_conversion_rates->font->scheme              = zcl_excel_style_font=>c_scheme_none .
  go_style_conversion_rates->borders->allborders       = go_border_dark .
  go_style_conversion_rates->alignment->horizontal     = zcl_excel_style_alignment=>c_horizontal_center .
  go_style_conversion_rates->number_format->format_code = '#,##0.00' . "zcl_excel_style_number_format=>c_format_xlsx38 .

  go_style_bold_centered                               = go_excel->add_new_style( ) .
  go_style_bold_centered->font->name                   = zcl_excel_style_font=>c_name_calibri .
  go_style_bold_centered->font->bold                   = abap_true .
  go_style_bold_centered->font->size                   = 10 .
  go_style_bold_centered->alignment->horizontal        = zcl_excel_style_alignment=>c_horizontal_center .
  go_style_bold_centered->font->scheme                 = zcl_excel_style_font=>c_scheme_none .

  go_style_figure_id                                   = go_excel->add_new_style( ) .
  go_style_figure_id->font->name                       = zcl_excel_style_font=>c_name_calibri .
  go_style_figure_id->font->italic                     = abap_true .
  go_style_figure_id->font->size                       = 10 .
  go_style_figure_id->font->scheme                     = zcl_excel_style_font=>c_scheme_none .
  CREATE OBJECT go_style_figure_id->borders .
  CREATE OBJECT go_style_figure_id->borders->right .
  go_style_figure_id->borders->right->border_color-rgb = zcl_excel_style_color=>c_black .
  go_style_figure_id->borders->right->border_style     = zcl_excel_style_border=>c_border_thin .

  go_style_group_id                                    = go_excel->add_new_style( ) .
  go_style_group_id->font->name                        = zcl_excel_style_font=>c_name_calibri .
  go_style_group_id->font->bold                        = abap_true .
  go_style_group_id->font->size                        = 10 .
  go_style_group_id->font->scheme                      = zcl_excel_style_font=>c_scheme_none .
  CREATE OBJECT go_style_group_id->borders .
  CREATE OBJECT go_style_group_id->borders->right .
  go_style_group_id->borders->right->border_color-rgb  = zcl_excel_style_color=>c_black .
  go_style_group_id->borders->right->border_style      = zcl_excel_style_border=>c_border_thin .

  go_style_figure_values                               = go_excel->add_new_style( ) .
  go_style_figure_values->font->name                   = zcl_excel_style_font=>c_name_calibri .
  go_style_figure_values->font->italic                 = abap_true .
  go_style_figure_values->font->size                   = 10 .
  go_style_figure_values->font->scheme                 = zcl_excel_style_font=>c_scheme_none .
  go_style_figure_values->number_format->format_code   = '#,##0.000' . "zcl_excel_style_number_format=>c_format_number_comma_sep1 .  "'#,##0.00' . "zcl_excel_style_number_format=>c_format_xlsx38 .

  go_style_group_values                                = go_excel->add_new_style( ) .
  go_style_group_values->font->name                    = zcl_excel_style_font=>c_name_calibri .
  go_style_group_values->font->size                    = 10 .
  go_style_group_values->font->scheme                  = zcl_excel_style_font=>c_scheme_none .
  go_style_group_values->number_format->format_code    = '#,##0.000' . "zcl_excel_style_number_format=>c_format_number_comma_sep1 .  "'#,##0.00'

  go_style_periods                                     = go_excel->add_new_style( ) .
  go_style_periods->font->name                         = zcl_excel_style_font=>c_name_calibri .
  go_style_periods->font->size                         = 10 .
  go_style_periods->font->bold                         = abap_true .
  go_style_periods->alignment->horizontal              = zcl_excel_style_alignment=>c_horizontal_center_continuous .
  go_style_periods->font->scheme                       = zcl_excel_style_font=>c_scheme_none .
  go_style_periods->fill->fgcolor-rgb                  = 'FFEBF1DE' . "zcl_excel_style_color=>c_red .
  go_style_periods->fill->filltype                     = zcl_excel_style_fill=>c_fill_solid .
  CREATE OBJECT go_style_periods->borders .
  CREATE OBJECT go_style_periods->borders->right .
  go_style_periods->borders->right->border_color-rgb   = zcl_excel_style_color=>c_black .
  go_style_periods->borders->right->border_style       = zcl_excel_style_border=>c_border_thin .

  go_style_gray_cells                                  = go_excel->add_new_style( ) .
  go_style_gray_cells->font->bold                      = abap_true .
  go_style_gray_cells->font->size                      = 10 .
  go_style_gray_cells->font->name                      = zcl_excel_style_font=>c_name_calibri .
  go_style_gray_cells->font->scheme                    = zcl_excel_style_font=>c_scheme_none .
  go_style_gray_cells->fill->fgcolor-rgb               = 'FFEBF1DE' . "zcl_excel_style_color=>c_red .
  go_style_gray_cells->fill->filltype                  = zcl_excel_style_fill=>c_fill_solid .


* set header
  TRY .
    go_worksheet->set_cell( ip_column = 'A' ip_row = 1 ip_value = 'A1' ip_abap_type = cl_abap_typedescr=>typekind_string ip_style = go_style_bold_font12->get_guid( ) ) .
    go_worksheet->get_row( ip_row = 1 )->set_row_height( ip_row_height = '15.00' ) .

    go_worksheet->set_cell( ip_column = 'B' ip_row = 1 ip_value = '' ) .
    go_worksheet->set_cell_formula( ip_column = 'B' ip_row = 1 ip_formula = '=SUM(10+3)' ) .


  CATCH zcx_excel .
  ENDTRY .

ENDFORM .

FORM DOWNLOAD_TO_EXCEL .

  TRY .
* convert into binary format
    gv_xdata = go_xls_writer->write_file( go_excel ) .
    gt_rawdata = cl_bcs_convert=>xstring_to_solix( iv_xstring  = gv_xdata ) .
    gv_bytecount = xstrlen( gv_xdata ) .


* execute download
    cl_gui_frontend_services=>gui_download(
      EXPORTING  bin_filesize = gv_bytecount
                 filename     = gv_fullpath
                 filetype     = 'BIN'
      CHANGING   data_tab     = gt_rawdata
    ) .

  CATCH zcx_excel .
  ENDTRY .

ENDFORM .

FORM READ_TEMPLATE .


DATA:
  excel           TYPE REF TO zcl_excel,
  lo_excel_writer TYPE REF TO zif_excel_writer,
  reader          TYPE REF TO zif_excel_reader.
DATA: ex  TYPE REF TO zcx_excel,
      msg TYPE string.

DATA: worksheet      TYPE REF TO zcl_excel_worksheet,
      highest_column TYPE zexcel_cell_column,
      highest_row    TYPE int4,
      column         TYPE zexcel_cell_column VALUE 1,
      col_str        TYPE zexcel_cell_column_alpha,
      row            TYPE int4               VALUE 1,
      value          TYPE zexcel_cell_value.
DATA: lv_workdir        TYPE string,
      output_file_path  TYPE string,
      input_file_path   TYPE string,
      lv_file_separator TYPE c,
      lv_column_width_f TYPE f ,
      lv_column_width_p TYPE p DECIMALS 2 ,
      lv_row_height_f   TYPE f,
      lv_row_height_p   TYPE p DECIMALS 2 .



  TRY .
    input_file_path = '/home/I025305/Documents/Customers/ROSNEFT/ROSNET RTSA_SAP_S4_Functional_Specification 7.1.6_Payroll reporting_final (RTSA review).xlsx' .
    CREATE OBJECT reader TYPE zcl_excel_reader_2007 .
    excel = reader->load_file( input_file_path ) .
    worksheet = excel->get_active_worksheet( ).
    highest_column = worksheet->get_highest_column( ).
    highest_row    = worksheet->get_highest_row( ).
    lv_column_width_f = lv_column_width_p = worksheet->get_column( 'A' )->get_width( ) .
    lv_column_width_f = lv_column_width_p = worksheet->get_column( 'B' )->get_width( ) .
    lv_row_height_f   = lv_row_height_p   = worksheet->get_row( 27 )->get_row_height( ) .
    lv_row_height_f   = lv_row_height_p   = worksheet->get_row( 28 )->get_row_height( ) .


  CATCH zcx_excel INTO ex.    " Exceptions for ABAP2XLSX
    msg = ex->get_text( ).
    WRITE: / msg.

  ENDTRY .

ENDFORM .
