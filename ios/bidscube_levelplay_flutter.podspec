Pod::Spec.new do |s|
  s.name             = 'bidscube_levelplay_flutter'
  s.version          = '2.0.0'
  s.summary          = 'Lightweight Bidscube LevelPlay wiring for Flutter'
  s.description      = 'Depends on LevelPlayMediationBidscubeAdapter; load/show via unity_levelplay_mediation.'
  s.homepage         = 'https://github.com/BidsCube/LevelPlay-SDK-Flutter'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Bidscube' => 'dev@bidscube.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'LevelPlayMediationBidscubeAdapter', '~> 1.0.0'
  s.platform = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
