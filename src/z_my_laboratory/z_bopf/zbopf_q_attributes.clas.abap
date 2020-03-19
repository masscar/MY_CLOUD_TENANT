class ZBOPF_Q_ATTRIBUTES definition
  public
  inheriting from /BOBF/CL_LIB_Q_SUPERCLASS
  final
  create public .

public section.
protected section.

  constants C_KEY type FIELDNAME value 'KEY' ##NO_TEXT.

  methods GET_QUERY_ENHANCE_TABLE
    redefinition .

private section.
ENDCLASS.



CLASS ZBOPF_Q_ATTRIBUTES IMPLEMENTATION.


  METHOD get_query_enhance_table.
*********************************************
***       DO_QUERY - WHERE AM I           ***
*********************************************
*CALL SEQUENCE FOR DO_QUERY:                *
*   split_selection_parameters (Redefine)   *
*-- get_query_enhance_table (Redefine)    --* current
*   checkncomplete_enh_tables               *
*   Filtering not requested attributes      *
*   build_from_clause_2                     *
*   extend_select_clauses (Redefine)        *
*   SELECT call                             *
*   - case no_data = abap_true              *
*     post_key_filtering (Redefine)         *
*   - case no_data = abap_false             *
*     get_result_data                       *
*       extend_result_data (Redefine)       *
*   Sorting                                 *
*   Cutting by query option maximum rows    *
*********************************************

    DATA:
      ls_res_enh       TYPE /scmtms/s_qdb_attr_enhance,
      ls_query_enhance LIKE LINE OF ct_query_enhance.


************
* query enhance entries
***********

    " STAGE ******************************************************************************************
    " /scmtms/d_trqstg

    ls_query_enhance-query_cat    = /scmtms/cl_q_superclass=>sc_querycat_gen.
    ls_query_enhance-query_key    = /scmtms/if_trq_c=>sc_query-stage-qdb_query_by_attributes.
    ls_query_enhance-attr_node_key = is_ctx-node_key.

    ls_query_enhance-node_attr     = c_db_key.
    ls_query_enhance-query_attr    = c_key.
    APPEND ls_query_enhance TO ct_query_enhance.

    " ROOT ******************************************************************************************
    " /scmtms/d_trqrot

    ls_query_enhance-query_cat    = /scmtms/cl_q_superclass=>sc_querycat_gen.
    ls_query_enhance-query_key    = /scmtms/if_trq_c=>sc_query-stage-qdb_query_by_attributes.
    ls_query_enhance-attr_node_key = /scmtms/if_trq_c=>sc_node-root.

    ls_query_enhance-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-trq_id.
    ls_query_enhance-query_attr    = /scmtms/if_trq_c=>sc_query_attribute-item-query_by_attributes-trq_id.
    ls_query_enhance-no_alpha_conv = abap_true.
    APPEND ls_query_enhance TO ct_query_enhance.

    ls_query_enhance-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-trq_type.
    ls_query_enhance-query_attr    = /scmtms/if_trq_c=>sc_query_attribute-item-query_by_attributes-trq_type.
    ls_query_enhance-no_alpha_conv = abap_true.
    APPEND ls_query_enhance TO ct_query_enhance.

    ls_query_enhance-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-trq_cat.
    ls_query_enhance-query_attr    = /scmtms/if_trq_c=>sc_query_attribute-item-query_by_attributes-trq_cat.
    ls_query_enhance-no_alpha_conv = abap_true.
    APPEND ls_query_enhance TO ct_query_enhance.

    ls_query_enhance-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-order_party_id.
    ls_query_enhance-query_attr    = /scmtms/if_trq_c=>sc_query_attribute-item-query_by_attributes-order_party_id.
    ls_query_enhance-no_alpha_conv = abap_true.
    APPEND ls_query_enhance TO ct_query_enhance.

    ls_query_enhance-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-lifecycle.
    ls_query_enhance-query_attr    = /scmtms/if_trq_c=>sc_query_attribute-item-query_by_attributes-lifecycle.
    ls_query_enhance-no_alpha_conv = abap_true.
    APPEND ls_query_enhance TO ct_query_enhance.

    ls_query_enhance-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-created_by.
    ls_query_enhance-query_attr    = /scmtms/if_trq_c=>sc_query_attribute-item-query_by_attributes-created_by.
    ls_query_enhance-no_alpha_conv = abap_true.
    APPEND ls_query_enhance TO ct_query_enhance.

    ls_query_enhance-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-created_on.
    ls_query_enhance-query_attr    = /scmtms/if_trq_c=>sc_query_attribute-item-query_by_attributes-created_on.
    ls_query_enhance-no_alpha_conv = abap_true.
    APPEND ls_query_enhance TO ct_query_enhance.

    ls_query_enhance-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-changed_by.
    ls_query_enhance-query_attr    = /scmtms/if_trq_c=>sc_query_attribute-item-query_by_attributes-changed_by.
    ls_query_enhance-no_alpha_conv = abap_true.
    APPEND ls_query_enhance TO ct_query_enhance.

    ls_query_enhance-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-changed_on.
    ls_query_enhance-query_attr    = /scmtms/if_trq_c=>sc_query_attribute-item-query_by_attributes-changed_on.
    ls_query_enhance-no_alpha_conv = abap_true.
    APPEND ls_query_enhance TO ct_query_enhance.


************
* result enhance entries
***********

    ls_res_enh-query_key     = /scmtms/if_trq_c=>sc_query-stage-qdb_query_by_attributes.

    " STAGE ******************************************************************************************
    " /scmtms/d_trqstg
    ls_res_enh-attr_node_key = is_ctx-node_key.

    ls_res_enh-node_attr     = c_db_key.
    ls_res_enh-result_attr   = c_key.
    APPEND ls_res_enh TO ct_result_enhance.

    ls_res_enh-node_attr     = c_parent_key.
    ls_res_enh-result_attr   = c_root_key.
    APPEND ls_res_enh TO ct_result_enhance.

    " ROOT ******************************************************************************************
    " /scmtms/d_trqrot
    ls_res_enh-attr_node_key = /scmtms/if_trq_c=>sc_node-root.

    ls_res_enh-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-trq_id.
    ls_res_enh-result_attr   = /scmtms/if_trq_c=>sc_query_result_type_attribute-stage-qdb_query_by_attributes-trq_id.
    APPEND ls_res_enh TO ct_result_enhance.

    ls_res_enh-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-trq_type.
    ls_res_enh-result_attr   = /scmtms/if_trq_c=>sc_query_result_type_attribute-stage-qdb_query_by_attributes-trq_type.
    APPEND ls_res_enh TO ct_result_enhance.

    ls_res_enh-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-trq_cat.
    ls_res_enh-result_attr   = /scmtms/if_trq_c=>sc_query_result_type_attribute-stage-qdb_query_by_attributes-trq_cat.
    APPEND ls_res_enh TO ct_result_enhance.

    ls_res_enh-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-order_party_id.
    ls_res_enh-result_attr   = /scmtms/if_trq_c=>sc_query_result_type_attribute-stage-qdb_query_by_attributes-order_party_id.
    APPEND ls_res_enh TO ct_result_enhance.

    ls_res_enh-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-order_party_key.
    ls_res_enh-result_attr   = /scmtms/if_trq_c=>sc_query_result_type_attribute-stage-qdb_query_by_attributes-order_party_key.
    APPEND ls_res_enh TO ct_result_enhance.

    ls_res_enh-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-lifecycle.
    ls_res_enh-result_attr   = /scmtms/if_trq_c=>sc_query_result_type_attribute-stage-qdb_query_by_attributes-lifecycle.
    APPEND ls_res_enh TO ct_result_enhance.

    ls_res_enh-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-created_by.
    ls_res_enh-result_attr   = /scmtms/if_trq_c=>sc_query_result_type_attribute-stage-qdb_query_by_attributes-created_by.
    APPEND ls_res_enh TO ct_result_enhance.

    ls_res_enh-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-created_on.
    ls_res_enh-result_attr   = /scmtms/if_trq_c=>sc_query_result_type_attribute-stage-qdb_query_by_attributes-created_on.
    APPEND ls_res_enh TO ct_result_enhance.

    ls_res_enh-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-changed_by.
    ls_res_enh-result_attr   = /scmtms/if_trq_c=>sc_query_result_type_attribute-stage-qdb_query_by_attributes-changed_by.
    APPEND ls_res_enh TO ct_result_enhance.

    ls_res_enh-node_attr     = /scmtms/if_trq_c=>sc_node_attribute-root-changed_on.
    ls_res_enh-result_attr   = /scmtms/if_trq_c=>sc_query_result_type_attribute-stage-qdb_query_by_attributes-changed_on.
    APPEND ls_res_enh TO ct_result_enhance.


  ENDMETHOD.
ENDCLASS.
