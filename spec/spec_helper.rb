# Copyright 2024 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'simplecov'

# SimpleCov.minimum_coverage 95
SimpleCov.start

# This module is only used to check the environment is currently a testing env
module SpecHelper
  def mock_files
    allow(File).to receive(:exist?).and_return(true)
    temp_file = Tempfile.new('example')
    allow(File).to receive(:binread).and_return(File.binread(temp_file))
  end

  def mock_google_credentials
    allow_any_instance_of(Fastlane::Checks::Credentials).to receive(:get_google_credential).and_return(MockGoogleCredentials.new)
  end

  def mock_http_server
    apps_list = stub_request(:get, 'https://checks.googleapis.com/v1alpha/accounts/1/apps/').to_return(status: 200, body: '{"apps": [{"name": "/accounts/1/apps/12", "appId": "12"}]}')

    upload = stub_request(:post, 'https://checks.googleapis.com/upload/v1alpha/accounts/1/apps/12/reports:analyzeUpload')
             .to_return(status: 200, body: '{"name": "/accounts/1/apps/12/operations/123"}')

    forbidden_body = '{"error": { "code": 403, "message": "The caller does not have permission", "status": "PERMISSION_DENIED" }}'
    upload_with_wrong_account_id = stub_request(:post, 'https://checks.googleapis.com/upload/v1alpha/accounts/wrong-account-id/apps/12/reports:analyzeUpload')
                                   .to_return(status: 403, body: forbidden_body)
    upload_with_app_id = stub_request(:post, 'https://checks.googleapis.com/upload/v1alpha/accounts/1/apps/wrong-app-id/reports:analyzeUpload')
                         .to_return(status: 403, body: forbidden_body)

    operation_in_progress = stub_request(:get, 'https://checks.googleapis.com/v1alpha/accounts/1/apps/12/operations/123')
                            .to_return(status: 200, body: '{"done": false}')

    operation_done = stub_request(:get, 'https://checks.googleapis.com/v1alpha/accounts/1/apps/12/operations/123')
                     .to_return(status: 200, body: '{"done": true, "response": {"resultsUri": "https://checks.area120.google.com/console/dashboard/456?a=789", "name": "/accounts/1/apps/12/reports/1234"}}')

    checks = <<-CHECKS
      [
        { "severity": "PRIORITY", "state": "FAILED", "type": "Priority Check (failed)" },
        { "severity": "PRIORITY", "state": "SUCCESS", "type": "Priority Check (success)" },
        { "severity": "PRIORITY", "state": "UNCHECKED", "type": "Priority Check (unchecked)" },
        { "severity": "POTENTIAL", "state": "FAILED", "type": "Potential Check (failed)" },
        { "severity": "POTENTIAL", "state": "SUCCESS", "type": "Potential Check (success)" },
        { "severity": "POTENTIAL", "state": "UNCHECKED", "type": "Potential Check (unchecked)" },
        { "severity": "OPPORTUNITY", "state": "FAILED", "type": "Opportunity Check (failed)" },
        { "severity": "OPPORTUNITY", "state": "SUCCESS", "type": "Opportunity Check (success)" },
        { "severity": "OPPORTUNITY", "state": "UNCHECKED", "type": "Opportunity Check (unchecked)" }
      ]
    CHECKS

    report = stub_request(:get, 'https://checks.googleapis.com/v1alpha/accounts/1/apps/12/reports/1234?fields=name,checks(type,state,severity)')
             .to_return(status: 200, body: "{ \"checks\": #{checks} }")

    return {
      apps_list: apps_list,
      upload: upload,
      operation_in_progress: operation_in_progress,
      operation_done: operation_done,
      report: report,
      upload_with_wrong_account_id: upload_with_wrong_account_id,
      upload_with_app_id: upload_with_app_id
    }
  end

  class MockGoogleCredentials
    attr_accessor :project_id

    def initialize
      @project_id = '1234'
    end

    def apply(arg)
      return {}
    end
  end
end

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/checks' # import the actual plugin
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)
