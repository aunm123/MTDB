#

Pod::Spec.new do |s|

  s.name         = "MTDB"
  s.version      = "0.0.1"
  s.summary      = "Dic for FMDB"

  s.description  = <<-DESC
                   DESC

  s.homepage     = "http://EXAMPLE/MTDB"

  s.license = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Tim" => "aunm123@yeah.net" }

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/aunm123/MTDB.git", :tag => "#{s.version}" }

  s.source_files  = "Class", "Class/**/*.{h,m}"

  s.public_header_files = "Class/**/*.h"dependency

  s.dependency "FMDB", "~> 2.5"

end
