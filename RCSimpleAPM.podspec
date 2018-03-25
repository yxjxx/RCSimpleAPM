#
# Be sure to run `pod lib lint RCSimpleAPM.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RCSimpleAPM'
  s.version          = '0.1.0'
  s.summary          = 'RCSimpleAPM monitor your app\'s cpu and memory and display a visual result.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
RCSimpleAPM is developed during debug BDWebImage's performance issues, it is very simply currently, and need improve.
                       DESC

  s.homepage         = 'https://github.com/yxjxx/RCSimpleAPM'
  s.screenshots     = 'https://ws1.sinaimg.cn/large/006tKfTcly1fpp5ifkf7kj30ku112wfj.jpg',
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yxjxx' => 'yangjing.rico@bytedance.com' }
  s.source           = { :git => 'https://github.com/yxjxx/RCSimpleAPM.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/yxjxx'

  s.ios.deployment_target = '8.0'

  s.source_files = 'RCSimpleAPM/Classes/**/*'
  s.dependency 'PerformanceChart'
  s.frameworks = 'Foundation','UIKit'
  
  # s.resource_bundles = {
  #   'RCSimpleAPM' => ['RCSimpleAPM/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
