#
# Be sure to run `pod lib lint FPRealm.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "FPRealm"
  s.version          = "0.1.0"
  s.summary          = "FP in Realm"
  s.description      = <<-DESC
                        Functional programming interface for Realm
                       DESC

  s.homepage         = "https://github.com/ukitaka/FPRealm"
  s.license          = 'MIT'
  s.author           = { "ukitaka" => "yuki.takahashi.1126@gmail.com" }
  s.source           = { :git => "https://github.com/ukitaka/FPRealm.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'FPRealm/Classes/**/*'
  s.resource_bundles = {
    'FPRealm' => ['FPRealm/Assets/*.png']
  }

  s.dependency 'Realm'
  s.dependency 'BrightFutures'
end
