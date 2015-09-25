# Be sure to run `pod lib lint Anode.podspec' to ensure this is a
# valid spec before submitting.
Pod::Spec.new do |s|
  s.name             = "Anode"
  s.version          = "1.1.0"
  s.summary          = "Connect iOS apps to backend services using repeatable patterns."

  s.description      = <<-DESC
                       DESC

  s.homepage         = "https://github.com/mobyinc/Anode"
  s.license          = 'COMERCIAL'
  s.author           = { "mobyjames" => "james@mobyinc.com" }
  s.source           = { :git => "https://github.com/mobyinc/Anode.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/builtbymoby'

  s.platform     = :ios, '8.0'
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
