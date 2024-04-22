#
# Be sure to run `pod lib lint JSONCode.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JSONCode'
  s.version          = '1.0.0'
  s.summary          = 'A short description of JSONCode.'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://github.com/chaichai9323/JSONCode'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'chaichai9323' => 'chailintao@laien.io' }
  s.source           = { :git => 'https://github.com/chaichai9323/JSONCode.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.swift_version = '5.0'
  s.ios.deployment_target = '13.0'
  
  s.source_files = 'Sources/JSONCode/**/*'
  
  s.preserve_paths = 'Package.swift', 'Sources/JSONCodeMacros'
  
  script = <<-SCRIPT
  env -i PATH="$PATH" "$SHELL" -l -c "swift build -c release --package-path \\"$PODS_TARGET_SRCROOT\\" --build-path \\"${PODS_BUILD_DIR}/JSONCode\\""
  SCRIPT
  
  s.script_phase = {
    :name => 'Build JSONCode macro plugin',
    :script => script,
    :execution_position => :before_compile
  }
  
  cfg = "-Xfrontend -load-plugin-executable -Xfrontend $(PODS_BUILD_DIR)/JSONCode/release/JSONCodeMacros#JSONCodeMacros"
  s.user_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => cfg
  }
  #  s.pod_target_xcconfig = {
  #    'OTHER_SWIFT_FLAGS' => cfg,
  #  }
  
#  s.xcconfig = {
#    'OTHER_SWIFT_FLAGS' => cfg
#  }

end
