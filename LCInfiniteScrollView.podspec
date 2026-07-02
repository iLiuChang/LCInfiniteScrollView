
Pod::Spec.new do |s|
  s.name         = "LCInfiniteScrollView"
  s.version      = "2.0.0"
  s.summary      = "An infinite scrolling control that supports horizontal or vertical directions."
  s.homepage     = "https://github.com/iLiuChang/LCInfiniteScrollView"
  s.license      = "MIT"
  s.authors      = { "liuchang" => "iliuchang@foxmail.com" }
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/iLiuChang/LCInfiniteScrollView.git", :tag => s.version }
  s.swift_version = "5.0"
  s.requires_arc = true
  s.source_files = "Sources/*.{swift}"
  s.resource_bundles = { 'LCInfiniteScrollView' => ['Sources/PrivacyInfo.xcprivacy'] }
end
