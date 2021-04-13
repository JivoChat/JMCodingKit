Pod::Spec.new do |s|
  s.name        = "JMCodingKit"
  s.version     = "5.0.0"
  s.summary     = "JMCodingKit makes it easy to deal with JsonElement data in Swift"
  s.homepage    = "https://github.com/SwiftyJSON/SwiftyJSON"
  s.license     = { :type => "MIT" }
  s.authors     = { "lingoer" => "lingoerer@gmail.com", "tangplin" => "tangplin@gmail.com" }

  s.requires_arc = true
  s.swift_version = "5.0"
  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "8.0"
  s.watchos.deployment_target = "3.0"
  s.tvos.deployment_target = "9.0"
  s.source   = { :git => "https://github.com/SwiftyJSON/SwiftyJSON.git", :tag => s.version }
  s.source_files = "OrderedMap/*.swift", "FlexibleWorkzone/*.swift", "FlexibleCoder/*.swift", "JsonCoder/*.swift"
end
