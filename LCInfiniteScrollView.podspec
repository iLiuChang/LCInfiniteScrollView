
Pod::Spec.new do |s|
  s.name         = "LCInfiniteScrollView"
  s.version      = "1.0.0"
  s.summary      = "无限滚动"
  s.homepage     = "https://github.com/iLiuChang/LCInfiniteScrollView"
  s.license      = "MIT"
  s.author       = "LiuChang"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/iLiuChang/LCInfiniteScrollView.git", :tag => s.version }
  s.requires_arc = true
  s.source_files = "LCInfiniteScrollView/*.{h,m}"
  s.framework    = "UIKit"
  s.requires_arc = true
end
