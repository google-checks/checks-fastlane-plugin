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
require_relative 'spec_helper'

describe Fastlane::Actions::ChecksAppScanAction do
  include SpecHelper
  describe '#run' do
    it "don't fail (default behavior)" do
      mock_files
      mock_google_credentials
      stubs = mock_http_server

      expect(FastlaneCore::UI).to receive(:important)
      expect(FastlaneCore::UI).not_to receive(:test_failure)

      Fastlane::FastFile.new.parse("lane :test do
          checks_app_scan(
            service_account_file_path: './iam.json',
            account_id: '1',
            app_id: '12',
            binary_path: './app-release.apk',
          )
      end").runner.execute(:test)

      expect(stubs[:upload]).to have_been_requested.times(1)
      expect(stubs[:operation_in_progress]).to have_been_requested.times(1)
      expect(stubs[:operation_done]).to have_been_requested.times(1)
      expect(stubs[:report]).to have_been_requested.times(1)
    end

    it "fail on all" do
      mock_files
      mock_google_credentials
      stubs = mock_http_server

      expect(FastlaneCore::UI).not_to receive(:important)
      expect(FastlaneCore::UI).to receive(:test_failure!)

      Fastlane::FastFile.new.parse("lane :test do
          checks_app_scan(
            service_account_file_path: './iam.json',
            account_id: '1',
            app_id: '12',
            binary_path: './app-release.apk',
            fail_on: 'all'
          )
      end").runner.execute(:test)

      expect(stubs[:upload]).to have_been_requested.times(1)
      expect(stubs[:operation_in_progress]).to have_been_requested.times(1)
      expect(stubs[:operation_done]).to have_been_requested.times(1)
      expect(stubs[:report]).to have_been_requested.times(1)
    end

    it "don't generate report" do
      mock_files
      mock_google_credentials
      stubs = mock_http_server

      expect(FastlaneCore::UI).to receive(:success)
      expect(FastlaneCore::UI).not_to receive(:important)
      expect(FastlaneCore::UI).not_to receive(:test_failure!)

      Fastlane::FastFile.new.parse("lane :test do
          checks_app_scan(
            service_account_file_path: './iam.json',
            account_id: '1',
            app_id: '12',
            binary_path: './app-release.apk',
            generate_report: false
          )
      end").runner.execute(:test)

      expect(stubs[:apps_list]).to have_been_requested.times(1)
      expect(stubs[:upload]).not_to have_been_requested
      expect(stubs[:operation_in_progress]).not_to have_been_requested
      expect(stubs[:operation_done]).not_to have_been_requested
      expect(stubs[:report]).not_to have_been_requested
    end

    it "don't wait for report" do
      mock_files
      mock_google_credentials
      stubs = mock_http_server

      expect(FastlaneCore::UI).to receive(:success).with("Driving the lane 'test' 🚀")
      expect(FastlaneCore::UI).to receive(:success).with("Skipping waiting for the report. Please visit https://checks.google.com to see the report.")
      expect(FastlaneCore::UI).not_to receive(:important)
      expect(FastlaneCore::UI).not_to receive(:test_failure!)

      Fastlane::FastFile.new.parse("lane :test do
          checks_app_scan(
            service_account_file_path: './iam.json',
            account_id: '1',
            app_id: '12',
            binary_path: './app-release.apk',
            wait_for_report: false
          )
      end").runner.execute(:test)

      expect(stubs[:upload]).to have_been_requested.times(1)
      expect(stubs[:operation_in_progress]).not_to have_been_requested
      expect(stubs[:operation_done]).not_to have_been_requested
      expect(stubs[:report]).not_to have_been_requested
    end

    it "wrong service account" do
      # TODO: make wrong-iam fail somewhere
      mock_files
      mock_google_credentials
      stubs = mock_http_server

      Fastlane::FastFile.new.parse("lane :test do
          checks_app_scan(
            service_account_file_path: './wrong-iam.json',
            account_id: '1',
            app_id: '12',
            binary_path: './app-release.apk',
          )
      end").runner.execute(:test)
    end

    it "wrong account id" do
      mock_files
      mock_google_credentials
      stubs = mock_http_server

      expect do
        Fastlane::FastFile.new.parse("lane :test do
            checks_app_scan(
              service_account_file_path: './iam.json',
              account_id: 'wrong-account-id',
              app_id: '12',
              binary_path: './app-release.apk',
            )
        end").runner.execute(:test)
      end.to raise_error("Error while uploading binary")

      expect(stubs[:upload_with_wrong_account_id]).to have_been_requested.times(1)
      expect(stubs[:upload]).not_to have_been_requested
      expect(stubs[:operation_in_progress]).not_to have_been_requested
      expect(stubs[:operation_done]).not_to have_been_requested
      expect(stubs[:report]).not_to have_been_requested
    end

    it "wrong app id" do
      mock_files
      mock_google_credentials
      stubs = mock_http_server

      expect do
        Fastlane::FastFile.new.parse("lane :test do
            checks_app_scan(
              service_account_file_path: './iam.json',
              account_id: '1',
              app_id: 'wrong-app-id',
              binary_path: './app-release.apk',
            )
        end").runner.execute(:test)
      end.to raise_error("Error while uploading binary")

      expect(stubs[:upload_with_app_id]).to have_been_requested.times(1)
      expect(stubs[:upload]).not_to have_been_requested
      expect(stubs[:operation_in_progress]).not_to have_been_requested
      expect(stubs[:operation_done]).not_to have_been_requested
      expect(stubs[:report]).not_to have_been_requested
    end

    it "wrong binary" do
      # TODO: ./not-app-release.apk is not a apk
      mock_files
      mock_google_credentials
      stubs = mock_http_server

      Fastlane::FastFile.new.parse("lane :test do
          checks_app_scan(
            service_account_file_path: './iam.json',
            account_id: '1',
            app_id: '12',
            binary_path: './not-app-release.apk',
          )
      end").runner.execute(:test)
    end

    it "missing service account" do
      mock_files
      mock_google_credentials
      stubs = mock_http_server

      expect do
        Fastlane::FastFile.new.parse("lane :test do
            checks_app_scan(
              account_id: '1',
              app_id: '12',
              binary_path: './app-release.apk',
            )
        end").runner.execute(:test)
      end.to raise_error("No value found for 'service_account_file_path'")
    end

    it "missing account id" do
      mock_files
      mock_google_credentials
      stubs = mock_http_server

      expect do
        Fastlane::FastFile.new.parse("lane :test do
            checks_app_scan(
              service_account_file_path: './iam.json',
              app_id: '12',
              binary_path: './app-release.apk',
            )
        end").runner.execute(:test)
      end.to raise_error("No value found for 'account_id'")
    end

    it "missing app id" do
      mock_files
      mock_google_credentials
      stubs = mock_http_server

      expect do
        Fastlane::FastFile.new.parse("lane :test do
            checks_app_scan(
              service_account_file_path: './iam.json',
              account_id: '1',
              binary_path: './app-release.apk',
            )
        end").runner.execute(:test)
      end.to raise_error("No value found for 'app_id'")
    end

    it "missing binary path" do
      mock_files
      mock_google_credentials
      stubs = mock_http_server

      expect do
        Fastlane::FastFile.new.parse("lane :test do
            checks_app_scan(
              service_account_file_path: './iam.json',
              account_id: '1',
              app_id: '12',
            )
        end").runner.execute(:test)
      end.to raise_error("No value found for 'binary_path'")
    end

    it "dont generate report" do
      mock_files
      mock_google_credentials
      stubs = mock_http_server

      Fastlane::FastFile.new.parse("lane :test do
          checks_app_scan(
            service_account_file_path: './iam.json',
            account_id: '1',
            app_id: '12',
            binary_path: './app-release.apk',
            generate_report: false
          )
      end").runner.execute(:test)

      expect(stubs[:apps_list]).to have_been_requested.times(1)
      expect(stubs[:upload]).not_to have_been_requested
      expect(stubs[:operation_in_progress]).not_to have_been_requested
      expect(stubs[:operation_done]).not_to have_been_requested
      expect(stubs[:report]).not_to have_been_requested
    end

    it "dont wait for report" do
      mock_files
      mock_google_credentials
      stubs = mock_http_server

      Fastlane::FastFile.new.parse("lane :test do
          checks_app_scan(
            service_account_file_path: './iam.json',
            account_id: '1',
            app_id: '12',
            binary_path: './app-release.apk',
            wait_for_report: false
          )
      end").runner.execute(:test)

      expect(stubs[:apps_list]).not_to have_been_requested
      expect(stubs[:upload]).to have_been_requested.times(1)
      expect(stubs[:operation_in_progress]).not_to have_been_requested
      expect(stubs[:operation_done]).not_to have_been_requested
      expect(stubs[:report]).not_to have_been_requested
    end
  end
end
