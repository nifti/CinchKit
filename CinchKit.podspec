Pod::Spec.new do |s|
  s.name = 'CinchKit'
  s.version = '0.1.0'
  s.license = 'MIT'
  s.summary = 'Cinch iOS SDK'
  s.homepage = 'https://github.com/nifti/CinchKit'
  s.social_media_url = 'http://twitter.com/theRyanFitz'
  s.authors = { 'Ryan Fitzgerald' => 'ryan.fitz1@gmail.com' }
  s.source = { :git => 'https://github.com/nifti/CinchKit.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.source_files = 'CinchKit/**/*.swift'
  s.requires_arc = true

  s.dependency 'Alamofire', '~> 1.2'
  s.dependency 'SwiftyJSON', '~> 2.2.0'
  s.dependency 'KeychainAccess', '~> 1.2'
end
