Pod::Spec.new do |spec|
  spec.name                  = 'YAPPakistan'
  spec.version               = '0.1.0'
  spec.summary               = 'YAP Pakistan Module'

  spec.homepage              = 'https://bitbucket.org/yap-technology/ios-b2c-pk/'
  spec.source                = { :git => 'https://bitbucket.org/yap-technology/ios-b2c-pk.git',
                                 :tag => spec.version.to_s,
                                 :submodules => false }

  spec.license               = { :type => 'MIT', :file => 'LICENSE' }
  spec.author                = { 'Tayyab Akram' => 'tayyab.akram@digitify.com' }

  spec.platform              = :ios
  spec.ios.deployment_target = '11.4'
  spec.swift_version         = '5.0'

  spec.source_files          = 'YAPPakistan/Classes/**/*'
  spec.static_framework      = true

  spec.resource_bundles = {
    'YAPPakistan' => [
      'YAPPakistan/Assets/Assets.xcassets',
      'YAPPakistan/Assets/Resources/*.gif',
      'YAPPakistan/Assets/Resources/**/*.jpg',
      'YAPPakistan/Assets/Resources/**/*.jpeg',
      'YAPPakistan/Assets/Resources/**/*.json',
      'YAPPakistan/Assets/Resources/**/*.mp4',
      'YAPPakistan/Assets/Resources/**/*.png',
      'YAPPakistan/Assets/Resources/**/*.strings']
  }

  #MARK: Analytics
  spec.dependency 'Adjust', '~> 4.0'

  #MARK: Networking
  spec.dependency 'Alamofire', '5.6.1'

  #MARK: Private
  spec.dependency 'YAPCardScanner', '1.2.17'
  spec.dependency 'YAPCore', '~> 0'
  spec.dependency 'YAPComponents', '~> 0'

  #MARK: Reactive
  spec.dependency 'RxCocoa', '6.5.0'
  spec.dependency 'RxDataSources', '5.0.0'
  spec.dependency 'RxGesture', '4.0.4'
  spec.dependency 'RxOptional', '5.0.2'
  spec.dependency 'RxSwift', '6.5.0'
  spec.dependency 'RxSwiftExt', '6.0.1'
  spec.dependency 'RxTheme', '5.0.4'

  #MARK: UI
  spec.dependency 'SwiftyGif', '5.4.3'
  spec.dependency 'SDWebImage', '5.12.5'
  spec.dependency 'HWPanModal', '~> 0'
  spec.dependency 'FSPagerView', '~> 0.8.3'
  spec.dependency 'SwipeCellKit'
  spec.dependency 'MXParallaxHeader'

  #MARK: Utilities
  spec.dependency 'SwifterSwift', '~> 5.0'
  spec.dependency 'PhoneNumberKit', '3.3.4'

  #MARK: Google
  spec.dependency 'GoogleMaps'
  spec.dependency 'GooglePlaces'
end
