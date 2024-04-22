#
# Be sure to run `pod lib lint JSONCode.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JSONCodeSwiftMacro'
  s.version          = '1.0.0'
  s.summary          = 'Define a macro. Parse json using the Codable'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description      = <<-DESC
  使用swift提供Codable协议解析Json,提供了自定义的key的处理,如果模型是class类型且是子类的话声明成JSONCodeSub，否则声明成JSONCode
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
  
  s.preserve_paths = 'Package.swift', 'Sources', "Tests"
  
 script = <<-SCRIPT
 env -i PATH="$PATH" "$SHELL" -l -c "swift build -v -c release --package-path $PODS_TARGET_SRCROOT --scratch-path $PODS_TARGET_SRCROOT/Macro"
 SCRIPT
 
 s.script_phase = {
   :name => 'Build JSONCode macro plugin',
   :script => script,
   :execution_position => :before_compile
 }

 s.xcconfig = {
   'OTHER_SWIFT_FLAGS' => "-load-plugin-executable $(PODS_ROOT)/#{s.name}/Macro/release/JSONCodeMacros#JSONCodeMacros"
 }

end
