#
#  Be sure to run `pod spec lint YAPCore.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "YAPCore"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of YAPCore."
  spec.homepage     = 'https://github.com/Tayyab Akram/YAPPakistan'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }

  spec.author       = { "Umer Afzal" => "umer.afzal@digitify.com" }
  spec.source       = { :git => 'https://github.com/umerafzal/YAPCore.git',
                        :tag => spec.version.to_s }
                        
  spec.ios.deployment_target = '11.0'
  spec.source_files = 'YAPCore/Coordinator/**/*'
  
    #MARK: RxSwift Extension
  spec.dependency 'RxSwift', '6.2.0'
  spec.dependency 'RxSwiftExt', '6.0.1'

end
