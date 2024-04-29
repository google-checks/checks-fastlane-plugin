# Google Checks plugin for Fastlane

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-checks)

The [Checks App Compliance fastlane
plugin](https://goo.gle/checks-fastlane-plugin) is an seamless way to automate
your iOS Checks analysis right from fastlane. This plugin lets you upload your
app to Checks by adding an action into your `Fastfile`. For additional
information about fastlane plugins, see the [fastlane
documentation](https://docs.fastlane.tools/plugins/using-plugins/).

Checks is a compliance platform from Google for mobile app developers that simplifies the path to privacy for development teams and the apps they’re building. Learn more at [checks.google.com](https://checks.google.com/).

## Requirements

To configure Checks to run in a pipeline, ensure you've fully onboarded and have retrieved key configuration inputs from
your Checks account and Google Cloud project.

### Create a Checks account and connect your app

Follow the [Quickstart](https://developers.google.com/checks/guide/getting-started/quickstart) documentation to create a Checks account and connect your first app.

### Target Checks account and app

When you run Checks in your CI/CD platform, you will need to assign the results
to a Checks account and an app that you've connected to that Checks account. To
do this, you'll need the Checks **Account ID** and **App ID**.

For your **Account ID**, visit your [Account Settings
page](https://checks.google.com/console/settings/account).

For your **App ID**, visit your [App Settings
page](https://checks.google.com/console/settings/apps).

### Authentication

A **service account** should be used when using Checks in an automation setup,
such as CI/CD. For more information on how to create and configure a service
account, see [Authenticate the
CLI](/checks/guide/cli/install-checks-cli#authenticate-service).

It is recommended to use CI environment variables to configure your JSON key.
For example:

```
CHECKS_CREDENTIALS=/my/path/to/serviceaccount.json
```

## Getting started

To add Checks to your fastlane configuration, run the following command from the
root of your iOS project:

```posix-terminal
fastlane add_plugin checks
```

Next, In a `./fastlane/Fastfile` lane, add a `checks_app_scan` block. The basic
way to use `checks_app_scan` with the required parameters is:

```ruby
checks_app_scan(
  account_id: "<your Checks account ID>",
  app_id: "<your Checks app ID>",
  binary_path: "<path to your .apk/.aab/.ipa>",
  service_account_file_path: ENV["SERVICE_ACCOUNT_JSON"],
)
```

List of all parameters:

## Variables

Name                      | Type    | Default | Description
:-----------------------: | :-----: | :-----: | :---------:
service_account_file_path | string  | –       | Path to your serviceaccount.json file. Please refer to [Authenticate Google Checks](https://developers.google.com/checks/guide/integrate/cli/install-checks-cli#authenticate-service) with a service account to generate a service account.
account_id                | string  | –       | Google Checks account ID from [Checks settings page](https://checks.area120.google.com/console/settings)
app_id                    | string  | –       | Google Checks application ID
binary_path               | string  | –       | Path to the application binary file: .apk, .aab or .ipa
generate_report           | boolean | true    | If `false` the action won't upload and run the report for binary_path. It is useful to test your authentication and other paramaters.
wait_for_report           | boolean | true    | If `false` the action won't wait for the report completion and the build will keep going.
severity_threshold        | string  | –       | With this option, only vulnerabilities of the specified level or higher are reported. Valid values are: `PRIORITY` `POTENTIAL` `OPPORTUNITY`.
fail_on                   | string  | –       | if `all` then action will fail if there are any failed checks following `severity_threshold` condition. It won't fail by default.
operation_id              | string  | –       | For development and testing purposes. If an upload is already in progress, or you want to analyse an existing upload.

## Example

By configuring the inputs to the Checks fastlane plugin, you can customize if
the Checks analysis should run in the background or as part of your testing
suite.

### Upload each new release to Checks and run the analysis in the background

```ruby
platform :ios do
  desc "My example app"
  lane :distribute do
    build_ios_app(...)
    checks_app_scan(
      account_id: "1234567890",
      app_id: "1234567890",
      binary_path: "./example-app.ipa",
      service_account_file_path: ENV["SERVICE_ACCOUNT_JSON"],
    )
    distribute_ios_app(...)
  end
end
```

### Run Checks as part of your Fastlane testing suite

```ruby
desc "Checks App Compliance analysis"
lane :test do |options|
  checks_app_scan(
    account_id: "1234567890",
    app_id: "1234567890",
    binary_path: "./example-app.ipa",
    service_account_file_path: ENV["SERVICE_ACCOUNT_JSON"],
    wait_for_report: true,
    severity_threshold: "PRIORITY",
    fail_on: "ALL",
  )
end
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use

```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this
repository.

## Troubleshooting

If you have trouble using plugins, check out the
[Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/)
guide.

## Using *fastlane* Plugins

For more information about how the `fastlane` plugin system works, check out the
[Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About *fastlane*

*fastlane* is the easiest way to automate beta deployments and releases for your
iOS and Android apps. To learn more, check out
[fastlane.tools](https://fastlane.tools).
