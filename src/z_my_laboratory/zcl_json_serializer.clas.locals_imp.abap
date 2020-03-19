*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

class lcl_test definition
    for testing risk level harmless
    inheriting from cl_aunit_assert .
  private section .
    methods:
      setup ,
      teardown ,
      test_scalar for testing ,
      test_struct for testing ,
      test_itab for testing ,
      test_deep for testing .
    types:
      begin of t_struct ,
        c1 type string ,
        c2 type string ,
      end of t_struct .
    data:
      serializer type ref to cl_trex_json_serializer ,
      result type string .
endclass .

class lcl_test implementation .
  method setup .
  endmethod .
  method teardown .
    clear serializer .
  endmethod .
  method test_scalar .
    data l_value type string .

    concatenate 'a''"&\'
      cl_abap_char_utilities=>newline
      cl_abap_char_utilities=>cr_lf
      cl_abap_char_utilities=>horizontal_tab
      cl_abap_char_utilities=>backspace
      cl_abap_char_utilities=>form_feed
      into l_value .

    create object serializer exporting data = l_value .
    serializer->serialize( ) .

    result = serializer->get_data( ) .
    assert_equals(
        exp = '"a\''\"\&\\\n\r\n\t\b\f"'
        act = result ) .

  endmethod .
  method test_struct .
    data l_struct type t_struct .

    l_struct-c1 = 'comp1' .
    l_struct-c2 = 'comp2' .

    create object serializer exporting data = l_struct .
    serializer->serialize( ) .

    result = serializer->get_data( ) .
    assert_equals(
        exp = '{c1: "comp1", c2: "comp2"}'
        act = result ) .
  endmethod .
  method test_itab .
    data l_itab type standard table of string .

    append 'line1' to l_itab .
    append 'line2' to l_itab .

    create object serializer exporting data = l_itab .
    serializer->serialize( ) .

    result = serializer->get_data( ) .
    assert_equals(
        exp = '["line1", "line2"]'
        act = result ) .
  endmethod .
  method test_deep .
    data:
      begin of l_deep ,
        itab1 type standard table of t_struct ,
        itab2 type standard table of t_struct ,
      end of l_deep ,
      l_row type t_struct .

    l_row-c1 = 'comp1' .
    l_row-c2 = 'comp2' .
    append l_row to l_deep-itab1 .
    append l_row to l_deep-itab1 .
    append l_row to l_deep-itab2 .
    append l_row to l_deep-itab2 .

    create object serializer exporting data = l_deep .
    serializer->serialize( ) .

    result = serializer->get_data( ) .

    constants c_exp_comp type string value '{c1: "comp1", c2: "comp2"}' .
    data l_expected type string value
          '{itab1: [&comp, &comp], itab2: [&comp, &comp]}' .
    replace all occurrences of '&comp' in l_expected with c_exp_comp .

    assert_equals(
        exp = l_expected
        act = result ) .
  endmethod .
endclass .
