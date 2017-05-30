Pod::Spec.new do |s|
  s.name         = "RealmIO"
  s.version      = "1.0"
  s.summary      = ""
  s.description  = <<-DESC
    Your description here.
  DESC
  s.homepage     = "https://github.com/ukitaka/RealmIO"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "ukitaka" => "yuki.takahashi.1126@gmail.com" }
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/ukitaka/RealmIO.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
  s.dependency 'RealmSwift' "~> v2.2.0"
end
