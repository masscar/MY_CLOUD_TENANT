class ZCL_Z_EPM_SADL_GW_DEV__DPC_EXT definition
  public
  inheriting from ZCL_Z_EPM_SADL_GW_DEV__DPC
  create public .

public section.
protected section.

  methods PRODUCTCATEGORIE_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_Z_EPM_SADL_GW_DEV__DPC_EXT IMPLEMENTATION.


  method PRODUCTCATEGORIE_GET_ENTITYSET.

"this method was redefined to calculate the number of products per category method productcategorie_get_entityset.

field-symbols:<fs_entityset> like line of et_entityset[].

call method super->productcategorie_get_entityset
exporting  iv_entity_name = iv_entity_name
iv_entity_set_name = iv_entity_set_name
iv_source_name = iv_source_name
it_filter_select_options = it_filter_select_options[]
is_paging = is_paging
it_key_tab = it_key_tab[]
it_navigation_path = it_navigation_path
it_order = it_order[]
iv_filter_string = iv_filter_string
iv_search_string = iv_search_string
io_tech_request_context = io_tech_request_context
importing et_entityset = et_entityset[]
es_response_context = es_response_context.

"get number of products per category
loop at et_entityset[] assigning <fs_entityset>.
*select count(*) from ( if_epm_product_header=>gc_db_table_name ) into <fs_entityset>-numberofproducts
data lv_tablename type tabname16 .
select count(*) from (lv_tablename) into <fs_entityset>-numberofproducts
where category = <fs_entityset>-category.

endloop .

endmethod .
ENDCLASS.
