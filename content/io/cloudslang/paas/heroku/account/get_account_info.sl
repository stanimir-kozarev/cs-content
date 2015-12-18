#################################################### 
# This flow performs an REST API call in order to get the details of the Heroku account
# 
# Inputs: 
#   - username - the Heroku username - Example: 'someone@mailprovider.com'
#   - password - the Heroku used for authentication
#
# Outputs: 
#   - return_result - the response of the operation in case of success, the error message otherwise 
#   - error_message - return_result if status_code is not '200'
#   - return_code - '0' if success, '-1' otherwise 
#   - status_code - the code returned by the operation 
####################################################

namespace: io.cloudslang.paas.heroku.account

imports:
  rest: io.cloudslang.base.network.rest

flow:
  name: get_account_info
  inputs:
    - username
    - password
  workflow:
    - details_account:
        do:
          rest.http_client_get:
            - url: "https://api.heroku.com/account"
            - username
            - password
            - headers: "Accept:application/vnd.heroku+json; version=3"
            - content_type: "application/json"
        publish:
          - return_result
          - error_message
          - return_code
          - status_code
  outputs:
    - return_result
    - error_message
    - return_code
    - status_code