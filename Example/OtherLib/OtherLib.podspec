
Pod::Spec.new do |s|
  s.name             = 'OtherLib'
  s.version          = '0.1.0'
  s.summary          = 'A short description of OtherLib.'
  s.description      = <<-DESC
自己定义的第三方Pod库，依赖JSONCode宏
                       DESC

  s.homepage         = 'https://github.com/chaichai9323/OtherLib'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'chaichai9323' => 'chailintao@laien.io' }
  s.source           = { :git => 'https://github.com/chaichai9323/OtherLib.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'OtherLib/Classes/**/*'
  
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => "-Xfrontend -load-plugin-executable -Xfrontend $(PODS_BUILD_DIR)/JSONCode/release/JSONCodeMacros#JSONCodeMacros"
  }
  
  s.dependency 'JSONCode'
  
end
