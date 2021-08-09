Pod::Spec.new do |spec|
  spec.name                  = 'YAPPakistan'
  spec.version               = '0.0.1'
  spec.summary               = 'YAP Pakistan'

  spec.homepage              = 'https://bitbucket.org/mb28/ios-b2c-pk/'
  spec.source                = { :git => 'https://bitbucket.org/mb28/ios-b2c-pk.git',
                                 :tag => 'v0.0.1' }

  spec.license               = { :type => 'Apache 2.0' }
  spec.authors               = { 'Tayyab Akram' => 'tayyab.akram@digitify.com' }
  
  spec.platform              = :ios
  spec.ios.deployment_target = '12.0'
  spec.swift_version         = '5.0'

  spec.source_files          = 'Source/**/*.swift'

  spec.resources             = ['Source/**/*.gif',
                                'Source/**/*.jpg',
                                'Source/**/*.jpeg',
                                'Source/**/*.json',
                                'Source/**/*.mp4',
                                'Source/**/*.png',
                                'Source/**/*.xcassets']

  spec.dependency 'YAPComponents'

end
