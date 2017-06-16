# Be sure to run `pod lib lint Anode.podspec' to ensure this is a
# valid spec before submitting.
Pod::Spec.new do |s|
  s.name             = "Anode"
  s.version          = "1.1.1"
  s.summary          = "Connect mobile apps to backend services using simple middleware and native plugins."

  s.description      = "Connect mobile apps to backend services using simple middleware and native plugins. Anode comes with an example Rails project that shows how to setup your backend and connector SDKs for iOS and Android."

  s.homepage         = "https://github.com/mobyinc/Anode"
  s.license          = 'COMERCIAL'
  s.author           = { "mobyjames" => "james@mobyinc.com" }
  s.source           = { :git => "https://github.com/mobyinc/Anode.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/builtbymoby'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Anode' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks =  'Foundation', 'MobileCoreServices', 'SystemConfiguration'
  s.dependency 'AFNetworking', '~> 1.3'
  s.dependency 'ActiveSupportInflector', '~> 0.0'
end
