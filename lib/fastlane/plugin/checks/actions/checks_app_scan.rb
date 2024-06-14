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

require 'fastlane_core/ui/ui'
require 'fastlane/action'
require 'json'
require 'ostruct'
require 'tty-spinner'

require_relative '../helper/credentials'
require_relative '../helper/checks_service'
require_relative '../helper/report_parser'
require_relative '../options'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)
  module Actions
    class ChecksAppScanAction < Action
      def self.run(params) # rubocop:disable Metrics/PerceivedComplexity
        # required parameters
        service_account_file_path = params[:service_account_file_path]
        project_id = params[:project_id]
        account_id = params[:account_id]
        app_id = params[:app_id]
        binary_path = params[:binary_path]

        # optional parameters
        fail_on = params[:fail_on]
        operation_id = params[:operation_id]
        generate_report = params[:generate_report]
        wait_for_report = params[:wait_for_report]
        severity_threshold = params[:severity_threshold]

        credentials = Fastlane::Checks::Credentials.new(key_file_path: service_account_file_path)
        service = Fastlane::Checks::GoogleChecksService.new(credentials, project_id, account_id, app_id)

        if generate_report
          if operation_id.nil?
            upload_spinner = TTY::Spinner.new("[:spinner] Uploading #{binary_path} to Google Checks...", format: :dots)
            upload_spinner.auto_spin
            begin
              upload_response = service.upload_binary(binary_path)
            rescue StandardError => e
              UI.error(e)
              UI.abort_with_message!("Error while uploading binary")
            end
            upload_spinner.success("Done")
          end

          if wait_for_report == false
            UI.success("Skipping waiting for the report. Please visit https://checks.google.com to see the report.")
          else
            if operation_id.nil?
              operation_id = Fastlane::Checks::GoogleChecksService.operation_id_from_name(upload_response["name"])
            end

            waiting_spinner = TTY::Spinner.new("[:spinner] Waiting for the report for operation id=#{operation_id}", format: :dots)
            waiting_spinner.auto_spin

            report_id, operation_response = service.wait_for_report(operation_id)

            if report_id.nil?
              waiting_spinner.error("Done")
              UI.abort_with_message!("Failed to fetch the report")
            else
              waiting_spinner.success("Done")
              report_response = service.report(report_id)
              report_parser = Fastlane::Checks::ReportParser.new(severity_threshold)
              failing_checks = report_parser.parse(report_response)
              if failing_checks.empty? # rubocop:disable Metrics/BlockNesting
                UI.success("No issues  # rubocop:disable Metrics/BlockNestingdetected")
                UI.success("Report console URL: #{operation_response['response']['resultsUri']}")
              else
                UI.error("#{failing_checks.length} issues detected:")
                failing_checks.each do |check|
                  UI.error("Type: #{check['type']}. Details: #{check}")
                end
                if fail_on == 'all' # rubocop:disable Metrics/BlockNesting
                  UI.test_failure!("Report console URL: #{operation_response['response']['resultsUri']}")
                else
                  UI.important("Report console URL: #{operation_response['response']['resultsUri']}")
                end
              end
            end
          end
        else
          response = service.apps_list
          UI.message(response)
        end
      end

      def self.description
        "Checks App Compliance scan"
      end

      def self.authors
        ["boertel"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Upload your mobile app to Checks to run an App Compliance scan"
      end

      def self.available_options
        Fastlane::Checks::Options.available_options
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
