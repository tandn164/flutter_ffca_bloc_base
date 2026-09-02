# Run with project_bundle exec ruby tool/release/test_ios_signing.rb.
# Evaluate the real lane up to build_app; never archive, contact Apple, or upload.
require 'fastlane'
require 'gym'

class SigningProbe
  attr_reader :options, :match_options

  def default_platform(*) = nil
  def platform(*) = yield
  def desc(*) = nil
  def lane(*) = yield
  def match(**options) = @match_options = options

  def build_app(**options)
    @options = options
    throw :build_captured
  end

  def run
    catch(:build_captured) do
      instance_eval(File.read(File.expand_path('../../apps/sample_app/ios/fastlane/Fastfile', __dir__)), 'Fastfile')
    end
  end
end

def check(condition, message)
  raise message unless condition
end

original_env = ENV.to_h
begin
  ENV.update('FLAVOR' => 'dev', 'APP_NAME' => 'sample_app', 'BUILD_NAME' => '1.0.0', 'BUILD_NUMBER' => '1')
  count = 0
  %w[firebase testflight-internal export-ipa].each do |destination|
    %w[automatic match].each do |signing|
      ENV.update('DESTINATION' => destination, 'SIGNING' => signing)
      ENV.delete('IOS_TEAM_ID')
      probe = SigningProbe.new
      probe.run
      options = probe.options
      expected = destination == 'firebase' ? 'ad-hoc' : 'app-store'
      check(options[:export_method] == expected, 'Wrong export method')
      if signing == 'automatic'
        check(options[:xcargs].include?('CODE_SIGN_STYLE=Automatic -allowProvisioningUpdates'), 'Archive updates missing')
        check(options[:export_xcargs] == '-allowProvisioningUpdates', 'Export updates missing')
        check(options[:export_options] == { signingStyle: 'automatic' }, 'Automatic export missing')
        check(options[:skip_profile_detection], 'Profile detection could force manual signing')
        check(!options[:export_team_id], 'Default should preserve project team')
        check(!probe.match_options, 'Automatic invoked Match')
      else
        check(probe.match_options == { type: destination == 'firebase' ? 'adhoc' : 'appstore', readonly: true }, 'Match changed')
        check(!options[:xcargs].include?('allowProvisioningUpdates') && !options[:export_xcargs], 'Match must stay readonly')
      end
      # Verify new option values against the actual pinned gym option schema.
      %i[export_method export_xcargs export_options skip_profile_detection].each do |key|
        Gym::Options.available_options.find { |item| item.key == key }.verify!(options[key]) if options.key?(key)
      end
      count += 1
    end
  end
  ENV.update('SIGNING' => 'automatic', 'IOS_TEAM_ID' => 'ABCDEFGHIJ')
  probe = SigningProbe.new
  probe.run
  check(probe.options[:xcargs].include?('DEVELOPMENT_TEAM=ABCDEFGHIJ'), 'Archive team override missing')
  check(probe.options[:export_team_id] == 'ABCDEFGHIJ', 'Export team override missing')
  puts "#{count + 1} iOS signing checks passed; no build, provisioning, or upload performed."
ensure
  ENV.replace(original_env)
end
