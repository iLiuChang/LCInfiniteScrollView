Pod::Spec.new do |s|
  s.name         = "SwiftInfiniteScrollView"
  s.version      = "1.1.2"
  s.summary      = "An infinite scroll control implemented with two views."
  s.homepage     = "https://github.com/iLiuChang/LCInfiniteScrollView"
  s.license      = "MIT"
  s.author       = "LiuChang"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/iLiuChang/LCInfiniteScrollView.git", :tag => s.version }
  s.source_files  =  "SwiftInfiniteScrollView/*.{swift}"
  s.requires_arc = true
  s.swift_version = "4.0"
end