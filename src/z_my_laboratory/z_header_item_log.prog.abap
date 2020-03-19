*&---------------------------------------------------------------------*
*& Report Z_HEADER_ITEM_LOG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_HEADER_ITEM_LOG.

DATA gs_header TYPE zheader .
DATA gs_item TYPE zitem .

CLEAR gs_header .
gs_header-mandt = sy-mandt .
gs_header-guid  = CL_SYSTEM_UUID=>IF_SYSTEM_UUID_STATIC~CREATE_UUID_C32( ) .
gs_header-codice_1 = 1 .
gs_header-codice_2 = 1 .
gs_header-codice_3 = 1 .
INSERT zheader FROM gs_header .

CLEAR gs_item .
gs_item-mandt = sy-mandt .
gs_item-guid_h  = gs_header-guid .
gs_item-guid_i  = CL_SYSTEM_UUID=>IF_SYSTEM_UUID_STATIC~CREATE_UUID_C32( ) .
gs_item-valore_1 = 10 .
gs_item-valore_2 = 10 .
gs_item-valore_3 = 10 .
INSERT zitem FROM gs_item .

CLEAR gs_item .
gs_item-mandt = sy-mandt .
gs_item-guid_h  = gs_header-guid .
gs_item-guid_i  = CL_SYSTEM_UUID=>IF_SYSTEM_UUID_STATIC~CREATE_UUID_C32( ) .
gs_item-valore_1 = 20 .
gs_item-valore_2 = 20 .
gs_item-valore_3 = 20 .
INSERT zitem FROM gs_item .

UPDATE zheader
   SET codice_1 = 2
 WHERE guid = gs_header-guid .
UPDATE zheader
   SET codice_2 = 2
 WHERE guid = gs_header-guid .
UPDATE zheader
   SET codice_3 = 2
 WHERE guid = gs_header-guid .

UPDATE zitem
   SET valore_1 = 25
 WHERE guid_i = gs_item-guid_i .
UPDATE zitem
   SET valore_2 = 25
 WHERE guid_i = gs_item-guid_i .
UPDATE zitem
   SET valore_3 = 25
 WHERE guid_i = gs_item-guid_i .

COMMIT WORK AND WAIT .
