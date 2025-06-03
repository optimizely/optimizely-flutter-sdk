#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint optimizely_flutter_sdk.podspec` to validate before publishing.
#

Pod::Spec.new do |s|
  s.name                = 'optimizely_flutter_sdk'
  s.version             = '0.0.1'
  s.summary             = 'Optimizely experiment framework for iOS'
  s.homepage            = "https://docs.developers.optimizely.com/experimentation/v4.0.0-full-stack/docs"
  s.license             = { :type => "Apache License, Version 2.0", :file => "../LICENSE" }
  s.author              = { "Optimizely" => "support@optimizely.com" }
  s.source              = { :path => '.' }
  s.source_files        = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'OptimizelySwiftSDK', '5.1.1'
  s.platform            = :ios, '10.0'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version       = '5.0'
end
