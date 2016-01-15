Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "RevSDK"
s.summary = "RevSDK accelerates networking requests passing through NSURLConnection"
s.requires_arc = true

s.version = "0.1.0"

s.license      = { :type => 'MIT', :text => <<-LICENSE
The MIT License (MIT)

Copyright (c) [2016] Rev Software, Inc

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICENSE
}

s.author = { "Rev Software, Inc" => "victor@revapm.com" }

s.homepage = "https://github.com/Andrey-C"

s.source = { :git => "https://github.com/Andrey-C/RevSDK.git", :tag => "#{s.version}"}

s.framework = "MessageUI"
s.dependency 'jsoncpp', '>= 0.6.beta.0'
#s.dependency 'ALALertBanner'

s.source_files = "RevSDK/**/*.{h, hpp, mm, m, cpp}"

other_ldflags = '$(inherited) -framework ' +
' -lz -lstdc++'

s.xcconfig     = {
'VALID_ARCHS' => {'armv7', 'armv7s', 'arm64'}
}

end