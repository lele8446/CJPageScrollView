#
#  Be sure to run `pod spec lint CJPageScrollView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "CJPageScrollView"
  s.version      = "1.0.7"
  s.summary      = "CJPageScrollView可实现任意多个页面的左右滚动切换，以及支持若干焦点图的无限循环滚动，定时自动循环滚动"

#  s.description  = <<-DESC
#                   DESC

  s.homepage     = "https://github.com/lele8446/CJPageScrollView"
  
#  s.license      = "MIT"
  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }

  s.author       = { "lele8446" => "lele8446@foxmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/lele8446/CJPageScrollView.git", :tag => "#{s.version}" }
  s.source_files  = "PageScrollView/*"

end
