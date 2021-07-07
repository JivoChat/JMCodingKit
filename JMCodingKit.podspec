Pod::Spec.new do |s|
  s.name        = "JMCodingKit"
  s.version     = "5.0.2"
  s.summary     = "JMCodingKit makes it easy to deal with JsonElement data in Swift"
  s.homepage    = "https://github.com/JivoChat/JMCodingKit"
  s.license     = { :type => "MIT" }
  s.authors     = { "JivoChat" => "info@jivochat.com" }

  s.requires_arc = true
  s.swift_version = "5.0"
  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "8.0"
  s.watchos.deployment_target = "3.0"
  s.tvos.deployment_target = "9.0"
  s.source   = { :git => "https://github.com/JivoChat/JMCodingKit.git", :tag => s.version }
  # s.source   = { :git => "/Users/macbook/Documents/Xcode\ Projects/mobile-ios/Shared/Libraries/JMCodingKit", :tag => s.version }
  s.source_files = "OrderedMap/*.swift", "FlexibleWorkzone/*.swift", "FlexibleCoder/*.swift", "JsonCoder/*.swift"
  # s.source_files = 'Products/**/*.*'
  # s.public_header_files = "Products/JMCodingKit.framework/Headers/*.h"
  # s.source_files = "Products/JMCodingKit.framework/Headers/*.h"
  # s.vendored_frameworks = "Products/JMCodingKit.framework"
  s.exclude_files = ['Info.plist', "JMCodingKit/**/*.*"]
  # s.exclude_files = ['**/Info*.plist']
end
