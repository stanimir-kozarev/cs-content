#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
namespace: io.cloudslang.paas.heroku.applications

imports:
  lists: io.cloudslang.base.lists
  json: io.cloudslang.base.json
  strings: io.cloudslang.base.strings

flow:
  name: test_create_application
  inputs:
    - username
    - password
    - name:
        default: None
        required: false
    - region:
        default: None
        required: false
    - stack:
        default: None
        required: false

  workflow:
    - create_application:
        do:
          create_application:
            - username
            - password
            - name
            - region
            - stack
        publish:
          - return_result
          - error_message
          - return_code
          - status_code
        navigate:
          SUCCESS: check_result
          CREATE_EMPTY_JSON_FAILURE: CREATE_EMPTY_JSON_FAILURE
          ADD_NAME_FAILURE: ADD_NAME_FAILURE
          ADD_REGION_FAILURE: ADD_REGION_FAILURE
          ADD_STACK_FAILURE: ADD_STACK_FAILURE
          CREATE_APPLICATION_FAILURE: CREATE_APPLICATION_FAILURE
          GET_ID_FAILURE: GET_ID_FAILURE
          GET_NAME_FAILURE: GET_NAME_FAILURE
          GET_CREATED_AT_FAILURE: GET_CREATED_AT_FAILURE

    - check_result:
        do:
          lists.compare_lists:
            - list_1: ${[str(error_message), int(return_code), int(status_code)]}
            - list_2: ['', 0, 201]
        navigate:
          SUCCESS: get_id
          FAILURE: CHECK_RESULT_FAILURE

    - get_id:
        do:
          json.get_value:
            - json_input: ${return_result}
            - json_path: ['id']
        publish:
          - id: ${value}
        navigate:
          SUCCESS: check_id_is_present
          FAILURE: GET_ID_FAILURE

    - check_id_is_present:
        do:
          strings.string_equals:
            - first_string: ${id}
            - second_string: None
        navigate:
          SUCCESS: ID_IS_NOT_PRESENT
          FAILURE: get_name_from_response

    - get_name_from_response:
        do:
          json.get_value:
            - json_input: ${return_result}
            - json_path: ['name']
        publish:
          - checked_name: ${value}
        navigate:
          SUCCESS: check_name_is_present
          FAILURE: GET_NAME_FAILURE

    - check_name_is_present:
        do:
          strings.string_equals:
            - first_string: ${checked_name}
            - second_string: None
        navigate:
          SUCCESS: CHECK_NAME_IS_NOT_PRESENT
          FAILURE: verify_names

    - verify_names:
        do:
          strings.string_equals:
            - first_string: ${checked_name}
            - second_string: ${name if name in locals() else checked_name}
        navigate:
          SUCCESS: get_created_at
          FAILURE: NAMES_ARE_NOT_THE_SAME

    - get_created_at:
        do:
          json.get_value:
            - json_input: ${return_result}
            - json_path: ['created_at']
        publish:
          - created_at: ${value}
        navigate:
          SUCCESS: check_created_at_is_present
          FAILURE: GET_CREATED_AT_FAILURE

    - check_created_at_is_present:
        do:
          strings.string_equals:
            - first_string: ${created_at}
            - second_string: None
        navigate:
          SUCCESS: CREATED_AT_IS_NOT_PRESENT
          FAILURE: SUCCESS

  outputs:
    - return_result
    - error_message
    - return_code
    - status_code
    - id
    - checked_name
    - created_at

  results:
    - SUCCESS
    - CREATE_EMPTY_JSON_FAILURE
    - ADD_NAME_FAILURE
    - ADD_REGION_FAILURE
    - ADD_STACK_FAILURE
    - CREATE_APPLICATION_FAILURE
    - GET_ID_FAILURE
    - GET_NAME_FAILURE
    - GET_CREATED_AT_FAILURE
    - CHECK_RESULT_FAILURE
    - GET_ID_FAILURE
    - ID_IS_NOT_PRESENT
    - GET_NAME_FAILURE
    - CHECK_NAME_IS_NOT_PRESENT
    - NAMES_ARE_NOT_THE_SAME
    - GET_CREATED_AT_FAILURE
    - CREATED_AT_IS_NOT_PRESENT