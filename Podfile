# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

use_frameworks!

inhibit_all_warnings!

target 'Exhbt' do
  # Pods for Exhbt
  pod 'CBGPromise'
  pod 'FBSDKLoginKit', '~> 12.2.1'
  pod 'Firebase/Analytics', '~>8.10.0'
  pod 'Firebase/Auth', '~> 8.10.0'
  pod 'Firebase/Crashlytics', '~> 8.10.0'
  pod 'Firebase/DynamicLinks', '~> 8.10.0'
  pod 'Firebase/Firestore', '~> 8.10.0'
  pod 'Firebase/Storage', '~> 8.10.0'
  pod 'lottie-ios', '~> 3.3.0'
  pod 'SnapKit', '~> 5.0.1'

end


post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
