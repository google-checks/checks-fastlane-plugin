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

require 'faraday'
require 'googleauth'

module Fastlane
  module Checks
    class GoogleChecksService
      BASE_URL = "https://checks.googleapis.com"
      OAUTH_SCOPES = ["https://www.googleapis.com/auth/checks"]
      DEFAULT_TIMEOUT = 45 * 60 # 30 minutes
      CHECK_OPERATION_INTERVAL = 60 # 1 minute

      private_constant :BASE_URL
      private_constant :DEFAULT_TIMEOUT
      private_constant :CHECK_OPERATION_INTERVAL

      def initialize(credentials, project_id, account_id, app_id)
        @account_id = account_id
        @app_id = app_id
        @auth = credentials.get_google_credential(OAUTH_SCOPES)
        @project_id ||= @auth.project_id

        default_headers = @auth.apply({})
        default_headers["X-Goog-User-Project"] = @project_id
        @connection = Faraday.new(url: BASE_URL, headers: default_headers)
      end

      def apps_list
        get("/v1alpha/accounts/#{@account_id}/apps/")
      end

      def upload_binary(binary_path)
        binary_data = File.binread(binary_path)
        path = "/upload/v1alpha/accounts/#{@account_id}/apps/#{@app_id}/reports:analyzeUpload"
        response = @connection.post(path) do |req|
          req.headers['X-Goog-Upload-Protocol'] = 'raw'
          req.headers['Content-Type'] = 'application/octet-stream'
          req.body = binary_data
        end
        handle_response(response)
      end

      def check_operation(operation_id)
        get("/v1alpha/accounts/#{@account_id}/apps/#{@app_id}/operations/#{operation_id}")
      end

      def report(report_id)
        params = {
          "fields" => "name,checks(type,state,severity)"
        }
        get("/v1alpha/accounts/#{@account_id}/apps/#{@app_id}/reports/#{report_id}", params)
      end

      def get(path, params = {})
        response = @connection.get(path, params)
        handle_response(response)
      end

      def wait_for_report(operation_id)
        started_at = Time.now
        operation_response = nil
        loop do
          operation_response = check_operation(operation_id)
          has_timeout = Time.now - started_at > DEFAULT_TIMEOUT
          break if operation_response["done"] || has_timeout

          sleep(CHECK_OPERATION_INTERVAL)
        end
        if operation_response["response"]
          [
            GoogleChecksService.report_id_from_name(operation_response["response"]["name"]),
            operation_response
          ]
        end
      end

      def self.operation_id_from_name(name)
        name.split("/").last
      end

      def self.report_id_from_name(name)
        name.split("/").last
      end

      private

      def handle_response(response)
        if response.success?
          JSON.parse(response.body)
        else
          raise "HTTP request to checks.google.com failed with\nstatus: #{response.status}\nbody:\n#{response.body}"
        end
      end
    end
  end
end
