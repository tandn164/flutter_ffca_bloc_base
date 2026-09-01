source 'https://rubygems.org'

# Pin CocoaPods for iOS. make init uses `bundle exec pod`, not a global pod.
gem 'cocoapods', '1.16.2'
gem 'fastlane', '2.231.1'

# concurrent-ruby >= 1.3.5 no longer loads `logger`, which crashes
# activesupport 6.1 (CocoaPods) with:
#   uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger
# Keep 1.3.4 until CocoaPods moves off activesupport 6.1 / 7.0.
gem 'concurrent-ruby', '1.3.4'
