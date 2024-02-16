# checks plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-checks)

## Getting Started

This project is a [*fastlane*](https://github.com/fastlane/fastlane) plugin for
[Checks](https://checks.google.com). To get started with
`fastlane-plugin-checks`, add it to your project by running:

```bash
fastlane add_plugin checks
```

## About upload_to_checks

Minimum way to use upload_to_checks with the required parameters:

```
upload_to_checks(
  account_id: "<your Checks account ID>",
  app_id: "<your Checks app ID>",
  binary_path: "<path to your .apk/.aab/.ipa>",
  service_account_file_path: "<path to your service account JSON>",
)
```

List of all parameters:

## Variables

Name                      | Type    | Default | Description
:-----------------------: | :-----: | :-----: | :---------:
service_account_file_path | string  | –       | Path to your serviceaccount.json file. Please refer to [Authenticate Google Checks](https://developers.google.com/checks/guide/integrate/cli/install-checks-cli#authenticate-service) with a service account to generate a service account.
account_id                | string  | –       | Google Checks account ID from [Checks settings page](https://checks.area120.google.com/console/settings)
app_id                    | string  | –       | Google Checks application ID
binary_path               | string  | –       | path to the application binary file: .apk, .aab or .ipa
generate_report           | boolean | true    | If `false` the action won't upload and run the report for binary_path. It is useful to test your authentication and other paramaters.
wait_for_report           | boolean | true    | If `false` the action won't wait for the report completion and the build will keep going.
severity_threshold        | string  | –       | Valid values are: `PRIORITY` `POTENTIAL` `OPPORTUNITY`
fail_on                   | string  | –       | if `all` then action will fail if there are any failed checks following `severity_threshold` condition. It won't fail by default.
operation_id              | string  | –       | For development and testing purposes. If an upload is already in progress, or you want to analyse an existing upload.

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this
plugin. Try it by cloning the repo, running `fastlane install_plugins` and
`bundle exec fastlane test`.

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
