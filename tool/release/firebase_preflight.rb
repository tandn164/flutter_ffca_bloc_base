# Read-only check using the same pinned plugin and credentials as the upload.
require 'fastlane'
require 'fastlane/plugin/firebase_app_distribution'

begin
  Fastlane::Actions::FirebaseAppDistributionGetLatestReleaseAction.run(
    app: ENV.fetch('FIREBASE_APP_ID'),
    service_credentials_file: ENV['FIREBASE_SERVICE_CREDENTIALS_FILE'],
    debug: false
  )
  puts 'Firebase authentication and release-list access verified (no upload performed).'
rescue StandardError
  # Avoid dumping SDK exceptions that may contain credential or response details.
  warn 'Firebase preflight failed: check credentials, app ID, App Distribution setup, IAM permissions, and network access.'
  exit 1
end
