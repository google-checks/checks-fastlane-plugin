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

require 'googleauth'
require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)
  module Checks
    class Credentials
      def initialize(key_file_path: nil)
        @key_file_path = key_file_path
      end

      def get_google_credential(scopes)
        File.open(File.expand_path(@key_file_path), "r") do |file|
          options = {
            json_key_io: file,
            scope: scopes
          }
          begin
            return Google::Auth::ServiceAccountCredentials.make_creds(options)
          rescue StandardError => e
            UI.abort_with_message!("Failed to read service account file: #{e.message}")
          end
        end
      end
    end
  end
end
