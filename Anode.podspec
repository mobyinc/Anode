#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "Anode"
  s.version          = "1.0.0"
  s.summary          = "Moby Anode library for data access and server communication."
  s.description      = <<-DESC
                       DESC
  s.homepage         = "http://builtbymoby.com/"
  s.screenshots      = 
  s.license          = 'MIT'
  s.author           = { "mobyjames" => "james@builtbymoby.com" }
  s.source           = { :git => "git@github.com:mobyjames/Anode.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'Anode/**'

  s.public_header_files = 'Anode/*.h'
end
