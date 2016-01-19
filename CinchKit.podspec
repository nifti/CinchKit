Pod::Spec.new do |s|
  s.name = 'CinchKit'
  s.version = '1.6.0'
  s.license = 'MIT'
  s.summary = 'Cinch iOS SDK'
  s.homepage = 'https://github.com/nifti/CinchKit'
  s.social_media_url = 'http://twitter.com/theRyanFitz'
  s.authors = { 
    'Ryan Fitzgerald' => 'ryan.fitz1@gmail.com',
    'Mikhail Vetoshkin' => 'mvetoshkin@gmail.com'
  }
  s.source = { :git => 'https://github.com/nifti/CinchKit.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.source_files = 'CinchKit/**/*.swift'
  s.requires_arc = true

  s.dependency 'Alamofire', '~> 3.1.4'
  s.dependency 'SwiftyJSON', '~> 2.3.2'
  s.dependency 'KeychainAccess', '~> 2.3.3'
end
