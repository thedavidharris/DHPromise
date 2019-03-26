Pod::Spec.new do |s|
 s.name = 'Futura'
 s.version = '1.1'
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'A simple Promises framework in Swift'
 s.homepage = 'http://davidharris.io'
 s.social_media_url = 'https://twitter.com/thedavidharris'
 s.authors = { "David Harris" => "davidaharris@outlook.com" }
 s.source = { :git => "https://github.com/thedavidharris/Futura.git", :tag => "v"+s.version.to_s }
 s.source_files = "Sources/*.swift"
 s.swift_version = '4.2'
 s.platforms = { :ios => "10.0", :osx => "10.10", :tvos => "9.0", :watchos => "2.0" }
 s.requires_arc = true

end
