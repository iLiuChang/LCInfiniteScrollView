
Pod::Spec.new do |s|
  s.name         = "LoopScroll"
  s.version      = "1.0.0"
  s.summary      = "An infinitely looping scrolling control implemented using UICollectionView."
  s.homepage     = "https://github.com/iLiuChang/LoopScroll"
  s.license      = "MIT"
  s.authors      = { "liuchang" => "iliuchang@foxmail.com" }
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/iLiuChang/LoopScroll.git", :tag => s.version }
  s.swift_version = "5.0"
  s.requires_arc = true
  s.source_files = "Sources/*.{swift}"
  s.resource_bundles = { 'LoopScroll' => ['Sources/PrivacyInfo.xcprivacy'] }
end
