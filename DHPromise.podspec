Pod::Spec.new do |s|
 s.name = 'DHPromise'
 s.version = '0.1'
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'A simple Promises framework in Swift'
 s.homepage = 'https://www.github.com/thedavidharris/DHPromise'
 s.social_media_url = 'https://www.twitter.com/thedavidharris'
 s.authors = { "David Harris" => "davidaharris@outlook.com" }
 s.source = { :git => "https://github.com/thedavidharris/DHPromise.git", :tag => "v"+s.version.to_s }
 s.source_files = 'Sources/*'
 s.platforms = { :ios => "8.0", :osx => "10.10", :tvos => "9.0", :watchos => "2.0" }
 s.requires_arc = true
 s.swift_version = '4.0'

end
