source 'https://rubygems.org'

# Pin CocoaPods for iOS. make init uses `bundle exec pod`, not a global pod.
gem 'cocoapods', '1.16.2'
gem 'fastlane', '2.231.1'
gem 'fastlane-plugin-firebase_app_distribution', '~> 0.10'
# Ruby 3.4 removed BigDecimal from default gems; CocoaPods/ActiveSupport still
# requires it at runtime.
gem 'bigdecimal', '~> 3.1'

# concurrent-ruby >= 1.3.5 no longer loads `logger`, which crashes
# activesupport 6.1 (CocoaPods) with:
#   uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger
# Keep 1.3.4 until CocoaPods moves off activesupport 6.1 / 7.0.
gem 'concurrent-ruby', '1.3.4'
