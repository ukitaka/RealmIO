Pod::Spec.new do |s|
  s.name         = "RealmIO"
  s.version      = "2.1.0"
  s.summary      = "RealmIO makes Realm operation more safely, reusable and composable by using reader monad."
  s.description  = <<-DESC
  RealmIO makes Realm operation more safely, reusable and composable by using reader monad.
  - Define Realm operation as `RealmIO`
  - Run Realm operation with `realm.run(io:)`
  - Compose realm operation with `flatMap`
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
  s.dependency 'RealmSwift',  '~> 3.1'
end
