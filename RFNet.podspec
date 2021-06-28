#
# Be sure to run `pod lib lint RFNet.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RFNet'
  s.version          = '0.2.0'
  s.summary          = '基于Alamofire网络封装'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
基于AF 5.4.3,实现网络组件封装。加解密与基础参数集成,所有网络化配置遵循LSConfigNetProtocol,专类进行控制，完全解耦实际网络请求代码
                       DESC

  s.homepage         = 'https://github.com/Roffa/RFBaseNet'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zrf' => 'roffa@qq.com' }
  s.source           = { :git => 'https://github.com/Roffa/RFBaseNet.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.swift_version    = '5.0'
  s.ios.deployment_target = '10.0'
  s.dependency 'Alamofire'
  s.source_files = 'RFNet/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RFNet' => ['RFNet/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
