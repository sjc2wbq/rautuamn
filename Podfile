platform :ios, "8.0"
use_frameworks!

target "RautumnProject" do
pod ‘XCGLogger’
pod ‘ObjectMapper’
pod ‘MBProgressHUD’
pod ‘SDWebImage’
pod ‘KxMenu’
pod ‘FMDB’
pod ‘AFNetworking’
pod 'IBAnimatable'
pod 'RegexKitLite'
pod 'RxDataSources', '~> 1.0'
pod 'MJRefresh'
pod 'SwiftLocation', '>= 1.0.6'
pod 'IQKeyboardManager'
pod ‘YUSegment’
pod 'Pages'
pod ‘NVActivityIndicatorView’
pod ‘CryptoSwift’
pod 'NSObject+Rx'
pod 'SwiftyDrop', '~>3.0'
pod "Popover"
pod 'SDCycleScrollView'
pod ‘KMPlaceholderTextView’
pod 'LTInfiniteScrollViewSwift'
pod 'Eureka', '~> 2.0.0-beta.1'
pod 'SDAutoLayout’
pod 'SimpleAlert’
pod 'BetterSegmentedControl', '~> 0.7'
pod 'KSPhotoBrowser'
pod 'Then', '~> 2.1'
pod 'swiftScan', :git => 'https://github.com/CNKCQ/swiftScan.git', :branch => 'Swift3.0'
pod 'ARSLineProgress'
pod 'Masonry'
pod 'FDFullscreenPopGesture'
pod 'SwiftyStoreKit'
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
end

