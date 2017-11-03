########################################################################################################################
#!!
#! @description: Generated operation description
#!
#! @input input_1: Generated description
#! @input input_2: Generated description
#!
#! @description: Generated operation description
#!
#! @output output_1: Generated description
#!
#!
#! @result SUCCESS: Operation completed successfully.
#! @result FAILURE: Failure occured during execution.
#!!#
########################################################################################################################

namespace: io.cloudslang.demo

operation:
  name: verify_url
  inputs:
    - tomcat_url:
        default: '443'
        required: false
  python_action:
    script: |
        import requests
        try:
            r = requests.head(tomcat_url)
            status_code = str(r.status_code)
            print("Status code: "+status_code)
        except requests.ConnectionError:
            print("failed to connect")

  outputs:
    - status_code

  results:
    - SUCCESS: ${status_code == '200'}
    - FAILURE