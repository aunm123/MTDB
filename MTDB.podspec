Pod::Spec.new do |spec|
spec.name         = 'MTDB'
spec.version      = '0.3.1'
spec.license      = 'MIT'
spec.summary      = 'Extension of FMDB'
spec.homepage     = 'https://github.com/aunm123/MTDB'
spec.author       = { 'Tim' => 'aunm123@yeah.net' }
spec.source       = { :git => 'https://github.com/aunm123/MTDB.git', :tag => "#{spec.version}" }
spec.source_files = 'Class/**/*'
spec.public_header_files = "Class/**/*.h"
spec.requires_arc = true
spec.dependency 'FMDB', '~> 2.5'
end
