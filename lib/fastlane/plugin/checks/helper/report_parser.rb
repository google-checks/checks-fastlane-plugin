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

module Fastlane
  module Checks
    class ReportParser
      OPPORTUNITY = "OPPORTUNITY"
      POTENTIAL = "POTENTIAL"
      PRIORITY = "PRIORITY"

      public_constant :OPPORTUNITY, :POTENTIAL, :PRIORITY

      def initialize(severity_threshold)
        @severity_threshold = severity_threshold
      end

      def is_severity_included_in_threshold(severity)
        case @severity_threshold
        when OPPORTUNITY
          return severity == PRIORITY || severity == POTENTIAL || severity == OPPORTUNITY
        when POTENTIAL
          return severity == PRIORITY || severity == POTENTIAL
        when PRIORITY
          return severity == PRIORITY
        end
      end

      def parse(report)
        failing_checks = []
        report["checks"].each do |check|
          if check['state'] == "FAILED" && is_severity_included_in_threshold(check['severity'])
            failing_checks << check
          end
        end
        return failing_checks
      end
    end
  end
end
