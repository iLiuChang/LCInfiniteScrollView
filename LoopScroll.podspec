
Pod::Spec.new do |s|
  s.name         = "LoopScroll"
  s.version      = "2.0.0"
  s.summary      = "An infinitely scrolling pagination control."
  s.homepage     = "https://github.com/iLiuChang/LoopScroll"
  s.license      = "MIT"
  s.authors      = { "liuchang" => "iliuchang@foxmail.com" }
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/iLiuChang/LoopScroll.git", :tag => s.version }
  s.swift_version = "5.0"
  s.requires_arc = true
  s.source_files = "Sources/*.{swift}"
  s.resource_bundles = { 'LCInfiniteScrollView' => ['Sources/PrivacyInfo.xcprivacy'] }
end
