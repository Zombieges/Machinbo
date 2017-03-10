# Uncomment this line to define a global platform for your project
platform :ios, ‘10.1’
# Uncomment this line if you're using Swift
use_frameworks!

target 'Machinbo' do
    pod 'Bolts'
    pod 'GoogleMaps’
    pod 'MBProgressHUD'
    pod 'Parse'
    pod 'Google-Mobile-Ads-SDK'
    pod 'AWSCore', “2.4.9”
    pod 'AWSCognito', “2.4.9”
    pod 'AWSSNS', “2.4.9”
    pod 'RKNotificationHub'
    pod 'TwitterKit'
    pod 'Fabric'
    pod 'TwitterCore'
end

target 'MachinboTests' do
    
end

post_install do |installer|
    `find Pods -regex 'Pods/Parse.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)Parse\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
    
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
        
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = "3.0"
            target.build_configuration_list.set_setting('HEADER_SEARCH_PATHS', '')
        end
    end
end
