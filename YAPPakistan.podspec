#
# Be sure to run `pod lib lint YAPPakistan.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YAPPakistan'
  s.version          = '0.1.0'
  s.summary          = 'A short description of YAPPakistan.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

 # s.description      = <<-DESC
#TODO: Add long description of the pod here.
#                       DESC

  s.homepage         = 'https://github.com/Tayyab Akram/YAPPakistan'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tayyab Akram' => 'tayyab.akram@digitify.com' }
  s.source           = { :git => 'https://github.com/Tayyab Akram/YAPPakistan.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.4'

  s.source_files = 'YAPPakistan/Classes/**/*'
  
  #s.resource_bundles = {
  #  'YAPPakistan' => ['YAPPakistan/Assets/**/*']
  #}

  s.resources = [ 'YAPPakistan/Assets/**/*.gif',
                  'YAPPakistan/Assets/**/*.jpg',
                  'YAPPakistan/Assets/**/*.jpeg',
                  'YAPPakistan/Assets/**/*.json',
                  'YAPPakistan/Assets/**/*.mp4',
                  'YAPPakistan/Assets/**/*.png',
                  'YAPPakistan/Assets/**/*.strings',
                  'YAPPakistan/Assets/**/*.xcassets',
                  'YAPPakistan/Assets/**/*.swift']

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  #s.static_framework = true

  #MARK: YapUIKIT
  s.dependency 'YAPComponents'
  
  #MARK: Networking
  s.dependency 'Alamofire', '5.4.3'
  
  #MARK: RxSwift Extension
  s.dependency 'RxSwift', '6.2.0'
  s.dependency 'RxCocoa', '6.2.0'
  s.dependency 'RxSwiftExt', '6.0.1'
  s.dependency 'RxGesture', '4.0.2'
  s.dependency 'RxDataSources', '5.0.0'
  s.dependency 'RxOptional', '5.0.2'
  s.dependency 'RxTheme', '5.0.4'
  
  #MARK: UI
  s.dependency 'SwiftyGif', '5.4.0'
  s.dependency 'PhoneNumberKit', '3.3.3'
  s.dependency 'SwiftRichString', '3.7.2'
  s.dependency 'Localize-Swift', '3.2.0'
  s.dependency 'Localize-Swift', '3.2.0'
  s.dependency 'HWPanModal', '0.8.9'
  
  #MARK: UIImage
  s.dependency 'SDWebImage', '5.11.1'
  
  #MARK: Swift Extension
  s.dependency 'SwifterSwift', '5.2.0'
  
  #MARK: Tools
  s.dependency 'R.swift', '5.4.0'
  
  
end
