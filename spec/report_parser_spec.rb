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

describe Fastlane::Checks::ReportParser do
  describe '' do
    it "severity_threshold=PRIORITY" do
      parser = Fastlane::Checks::ReportParser.new(Fastlane::Checks::ReportParser::PRIORITY)
      report = {
        "checks" => [
          { "severity" => "PRIORITY", "state" => "FAILED", type: "Priority Check (failed)" },
          { "severity" => "PRIORITY", "state" => "SUCCESS", type: "Priority Check (success)" },
          { "severity" => "PRIORITY", "state" => "UNCHECKED", type: "Priority Check (unchecked)" },
          { "severity" => "POTENTIAL", "state" => "FAILED", type: "Potential Check (failed)" },
          { "severity" => "POTENTIAL", "state" => "SUCCESS", type: "Potential Check (success)" },
          { "severity" => "POTENTIAL", "state" => "UNCHECKED", type: "Potential Check (unchecked)" },
          { "severity" => "OPPORTUNITY", "state" => "FAILED", type: "Opportunity Check (failed)" },
          { "severity" => "OPPORTUNITY", "state" => "SUCCESS", type: "Opportunity Check (success)" },
          { "severity" => "OPPORTUNITY", "state" => "UNCHECKED", type: "Opportunity Check (unchecked)" }
        ]
      }
      failing_checks = parser.parse(report)
      expect(failing_checks.length).to eq(1)
      expect(failing_checks[0]['severity']).to eq("PRIORITY")
    end

    it "severity_threshold=POTENTIAL" do
      parser = Fastlane::Checks::ReportParser.new(Fastlane::Checks::ReportParser::POTENTIAL)
      report = {
        "checks" => [
          { "severity" => "PRIORITY", "state" => "FAILED", type: "Priority Check (failed)" },
          { "severity" => "PRIORITY", "state" => "SUCCESS", type: "Priority Check (success)" },
          { "severity" => "PRIORITY", "state" => "UNCHECKED", type: "Priority Check (unchecked)" },
          { "severity" => "POTENTIAL", "state" => "FAILED", type: "Potential Check (failed)" },
          { "severity" => "POTENTIAL", "state" => "SUCCESS", type: "Potential Check (success)" },
          { "severity" => "POTENTIAL", "state" => "UNCHECKED", type: "Potential Check (unchecked)" },
          { "severity" => "OPPORTUNITY", "state" => "FAILED", type: "Opportunity Check (failed)" },
          { "severity" => "OPPORTUNITY", "state" => "SUCCESS", type: "Opportunity Check (success)" },
          { "severity" => "OPPORTUNITY", "state" => "UNCHECKED", type: "Opportunity Check (unchecked)" }
        ]
      }
      failing_checks = parser.parse(report)
      expect(failing_checks.length).to eq(2)
      expect(failing_checks[0]['severity']).to eq("PRIORITY")
      expect(failing_checks[1]['severity']).to eq("POTENTIAL")
    end

    it "severity_threshold=OPPORTUNITY" do
      parser = Fastlane::Checks::ReportParser.new(Fastlane::Checks::ReportParser::OPPORTUNITY)
      report = {
        "checks" => [
          { "severity" => "PRIORITY", "state" => "FAILED", type: "Priority Check (failed)" },
          { "severity" => "PRIORITY", "state" => "SUCCESS", type: "Priority Check (success)" },
          { "severity" => "PRIORITY", "state" => "UNCHECKED", type: "Priority Check (unchecked)" },
          { "severity" => "POTENTIAL", "state" => "FAILED", type: "Potential Check (failed)" },
          { "severity" => "POTENTIAL", "state" => "SUCCESS", type: "Potential Check (success)" },
          { "severity" => "POTENTIAL", "state" => "UNCHECKED", type: "Potential Check (unchecked)" },
          { "severity" => "OPPORTUNITY", "state" => "FAILED", type: "Opportunity Check (failed)" },
          { "severity" => "OPPORTUNITY", "state" => "SUCCESS", type: "Opportunity Check (success)" },
          { "severity" => "OPPORTUNITY", "state" => "UNCHECKED", type: "Opportunity Check (unchecked)" }
        ]
      }
      failing_checks = parser.parse(report)
      expect(failing_checks.length).to eq(3)
      expect(failing_checks[0]['severity']).to eq("PRIORITY")
      expect(failing_checks[1]['severity']).to eq("POTENTIAL")
      expect(failing_checks[2]['severity']).to eq("OPPORTUNITY")
    end
  end
end
