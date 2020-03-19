class ZCL_Z_FLIGHTS_CDS definition
  public
  inheriting from CL_SADL_GTK_EXPOSURE_MPC
  final
  create public .

public section.
protected section.

  methods GET_PATHS
    redefinition .
  methods GET_TIMESTAMP
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_Z_FLIGHTS_CDS IMPLEMENTATION.


  method GET_PATHS.
et_paths = VALUE #(
( |CDS~Z_FLIGHTS_CDS| )
).
  endmethod.


  method GET_TIMESTAMP.
RV_TIMESTAMP = 20190531164812.
  endmethod.
ENDCLASS.
