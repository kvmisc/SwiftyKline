source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '15.0'
inhibit_all_warnings!
use_frameworks!

target 'klineapp' do
pod 'SnapKit'
pod 'SwiftyJSON'

pod 'DGCharts'
pod 'Starscream'
end

target 'SwiftyKline' do
pod 'DGCharts'
pod 'Starscream'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|

    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 12.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end

  end
end
