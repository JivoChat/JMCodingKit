Pod::Spec.new do |spec|
  spec.name        = "JMCodingKit"
  spec.version     = "6.0.0"
  spec.summary     = "JMCodingKit makes it easy to deal with JsonElement data in Swift"
  spec.homepage    = "https://github.com/JivoChat/JMCodingKit"
  spec.license     = { :type => "MIT" }
  spec.authors     = { "JivoChat" => "info@jivochat.com" }

  spec.requires_arc = true
  spec.swift_version = "5.0"
  spec.osx.deployment_target = "10.10"
  spec.ios.deployment_target = "12.0"
  spec.source   = { :git => "https://github.com/JivoChat/JMCodingKit.git", :tag => "v#{spec.version}" }
  # s.source   = { :git => "/Users/macbook/Documents/Xcode\ Projects/mobile-ios/Shared/Libraries/JMCodingKit", :tag => s.version }
  spec.source_files = "OrderedMap/*.swift", "FlexibleWorkzone/*.swift", "FlexibleCoder/*.swift", "JsonCoder/*.swift"
  # s.source_files = 'Products/**/*.*'
  # s.public_header_files = "Products/JMCodingKit.framework/Headers/*.h"
  # s.source_files = "Products/JMCodingKit.framework/Headers/*.h"
  # s.vendored_frameworks = "Products/JMCodingKit.framework"
  spec.exclude_files = ['Info.plist', "JMCodingKit/**/*.*", "Package.swift"]
  # s.exclude_files = ['**/Info*.plist']
end
