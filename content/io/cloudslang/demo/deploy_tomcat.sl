########################################################################################################################
#!!
#! @description: Generated flow description
#!
#! @input input_1: Generated description
#! @input input_2: Generated description
#!
#! @output output_1: Generated description
#!
#! @result SUCCESS: Flow completed successfully.
#! @result FAILURE: Failure occurred during execution.
#!!#
########################################################################################################################

namespace: io.cloudslang.demo
imports:
  base: io.cloudslang.base
  vm: io.cloudslang.vmware.vcenter.virtual_machines

flow:
    name: deploy_tomcat

    inputs:
      - hostname
      - username
      - password
      - image: "Ubuntu"
      - folder: "Partners"

    workflow:
      - uuid_generator:
          do:
            base.utils.uuid_generator: null
          publish:
            - uuid: '${new_uuid}'
          navigate:
            - SUCCESS: trim
      - trim:
          do:
            base.strings.substring:
              - origin_string: '${"stu4383-"+uuid}'
              - end_index: '13'
          publish:
            - id: '${new_string}'
          navigate:
            - FAILURE: FAILURE
            - SUCCESS: clone_vm
      - clone_vm:
          do:
            vm.clone_virtual_machine:
              - host: '${hostname}'
              - hostname: 'trnesxi1.eswdc.net'
              - username: '${username}'
              - password: '${password}'
              - data_center_name: 'CAPA1 Datacenter'
              - is_template: 'false'
              - virtual_machine_name: '${image}'
              - clone_name: '${id}'
              - folder_name: '${folder}'
          navigate:
            - FAILURE: FAILURE
            - SUCCESS: power_on
      - power_on:
          do:
            vm.power_on_virtual_machine:
              - host: '${hostname}'
              - username: '${username}'
              - password: '${password}'
              - virtual_machine_name: '${id}'
          navigate:
            - FAILURE: FAILURE
            - SUCCESS: sleep
      - sleep:
          do:
            base.utils.sleep:
              - seconds: '30'
          navigate:
            - FAILURE: FAILURE
            - SUCCESS: get_details
      - get_details:
          do:
            vm.get_virtual_machine_details:
              - host: '${hostname}'
              - username: '${username}'
              - password: '${password}'
              - hostname: 'trnesxi1.eswdc.net'
              - virtual_machine_name: '${id}'
          publish:
              - details: '${return_result}'
          navigate:
            - FAILURE: FAILURE
            - SUCCESS: get_ip
      - get_ip:
          do:
            base.json.get_value:
              - json_input: '${details}'
              - json_path: 'ipAddress'
          publish:
              - ip: '${return_result}'
          navigate:
            - FAILURE: FAILURE
            - SUCCESS: deploy_tomcat
      - deploy_tomcat:
          do:
            base.os.linux.samples.deploy_tomcat_on_ubuntu:
              - host: '${ip}'
              - root_password: 'admin123'
              - user_password: 'admin123'
              - java_version: "openjdk-7-jdk"
              - download_url: "http://www-us.apache.org/dist/tomcat/tomcat-8/v8.5.23/bin/apache-tomcat-8.5.23.tar.gz"
              - file_name: "apache-tomcat-8.5.23.tar.gz"
              - source_path: "/opt/apache-tomcat/bin"
              - script_file_name: "startup.sh"
          publish:
              - tomcat_url: '${"http://" + host + ":8080"}'
          navigate:
            - SUCCESS: verify_url
            - INSTALL_JAVA_FAILURE: FAILURE
            - SSH_VERIFY_GROUP_EXIST_FAILURE: FAILURE
            - CHECK_GROUP_FAILURE: FAILURE
            - ADD_GROUP_FAILURE: FAILURE
            - ADD_USER_FAILURE: FAILURE
            - CREATE_DOWNLOADING_FOLDER_FAILURE: FAILURE
            - DOWNLOAD_TOMCAT_APPLICATION_FAILURE: FAILURE
            - UNTAR_TOMCAT_APPLICATION_FAILURE: FAILURE
            - CREATE_SYMLINK_FAILURE: FAILURE
            - INSTALL_TOMCAT_APPLICATION_FAILURE: FAILURE
            - CHANGE_TOMCAT_FOLDER_OWNERSHIP_FAILURE: FAILURE
            - CHANGE_DOWNLOAD_TOMCAT_FOLDER_OWNERSHIP_FAILURE: FAILURE
            - CREATE_INITIALIZATION_FOLDER_FAILURE: FAILURE
            - UPLOAD_INIT_CONFIG_FILE_FAILURE: FAILURE
            - CHANGE_PERMISSIONS_FAILURE: FAILURE
            - START_TOMCAT_APPLICATION_FAILURE: FAILURE
      - verify_url:
          do:
            verify_url:
              - tomcat_url: '${tomcat_url}'
          publish:
              - status_code
          navigate:
            - SUCCESS: SUCCESS
            - FAILURE: FAILURE
    results:
      - SUCCESS
      - FAILURE