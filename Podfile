# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'PodoMarket' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PodoMarket
pod 'Firebase'
pod 'Firebase/Auth'
pod 'Firebase/Core'
pod 'Firebase/Messaging'
pod 'Firebase/Firestore'
pod 'Firebase/Database'
pod 'Firebase/Analytics'
pod 'Firebase/Storage'
#pod 'Firebase/InAppMessagingDisplay'
pod 'Firebase/RemoteConfig'

pod 'Toast-Swift', '~> 5.0.0'
pod 'SDWebImage', '~> 5.0'
pod 'SideMenu', '~>6.0.0'
pod 'SnapKit', '~> 5.0.0'
pod 'TextFieldEffects'
pod 'ObjectMapper', '~>3.1'
pod 'NVActivityIndicatorView'

# Workaround for Cocoapods issue #7606
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
end
