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
require 'fastlane_core/configuration/config_item'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)
  module Checks
    class Options
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :service_account_file_path,
                                       description: "Path to your service account json file. Please refer to https://developers.google.com/checks/guide/integrate/cli/install-checks-cli#authenticate-service to get your private key JSON file",
                                       optional: false,
                                       verify_block: proc do |value|
                                                       UI.user_error!("Could not find file at path '#{value}'") unless File.exist?(value)
                                                     end),
          FastlaneCore::ConfigItem.new(key: :project_id,
                                       description: "Google Cloud Platform project name",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :account_id,
                                       description: "Google Checks Account Id",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :app_id,
                                       description: "Google Checks App Id",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :operation_id,
                                       description: "Operation ID",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :severity_threshold,
                                       description: "severity threshold. Possible values: PRIORITY, POTENTIAL, OPPORTUNITY",
                                       default_value: "PRIORITY",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Invalid value '#{value}'") unless ['PRIORITY', 'POTENTIAL', 'OPPORTUNITY'].include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :binary_path,
                                       description: "Path to the app",
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("App file not found at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :generate_report,
                                       description: "skip generating report",
                                       default_value: true,
                                       type: Fastlane::Boolean),
          FastlaneCore::ConfigItem.new(key: :wait_for_report,
                                       description: "Wait for report to complete",
                                       default_value: true,
                                       type: Fastlane::Boolean),
          FastlaneCore::ConfigItem.new(key: :fail_on,
                                       description: "action will fail if the report contains issues with severity equal or higher than the specified value. Possible values: all, never",
                                       default_value: "never",
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("Invalid value '#{value}'") unless ['all', 'never'].include?(value)
                                       end)
        ]
      end

      def self.set_default_property(hash_obj, property, default)
        unless hash_obj.key?(property)
          hash_obj[property] = default
        end
      end
    end
  end
end
