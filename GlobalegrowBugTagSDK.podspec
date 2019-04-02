@version = "0.1.0"
@podName = "GlobalegrowBugTagSDK"
@baseURL = "gitlab.egomsl.com"
@basePath = "GB-APP-iOS/#{@podName}"
@baseSourcePath = "#{@podName} Example/#{@podName}"
@baseFilePath = "**/*.{h,m}"
@source_files = "#{@baseSourcePath}/#{@baseFilePath}"
@frameworkName = "#{@podName}"
Pod::Spec.new do |s|
  s.name          = "#{@podName}"
  s.version       = @version
  s.summary       = "可以提交页面问题和崩溃信息的SDK"
  s.homepage      = "http://#{@baseURL}/#{@basePath}"
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.author        = { "josercc" => "josercc@163.com" }
  s.platform      = :ios, '8.0'
  s.source        = { :git => "#{s.homepage}.git", :tag => "#{s.version}" }
  s.framework     = "UIKit"
  s.subspec 'Source' do |source|
    source.source_files = @source_files
  end
  s.default_subspecs = 'Source'
  s.dependency "WMDragView"
  s.dependency "Masonry"
  s.dependency "GBDeviceInfo"
  s.dependency "AFNetworkActivityLogger"
  s.dependency "FCFileManager"
  s.dependency "YYModel"
  s.dependency "SKYMD5Tool"
  s.dependency "AFNetworking"
  s.resource_bundles = {
    @podName => "#{@baseSourcePath}/images/*.{png}"
  }


end
