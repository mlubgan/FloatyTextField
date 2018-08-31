#
# Be sure to run `pod lib lint FloatyTextField.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FloatyTextField'
  s.version          = '0.1.2'
  s.summary          = 'FloatyTextField provides material design inspired TextField and TextView.'
  s.swift_version = '4.0'
  s.description      = <<-DESC
    FloatyTextField provides material design inspired TextField and TextView. Feel free to report issues.
                       DESC

  s.homepage         = 'https://github.com/mlubgan/FloatyTextField'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Michał Łubgan' => 'm.lubgan@fivedottwelve.com' }
  s.source           = { :git => 'https://github.com/mlubgan/FloatyTextField.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'FloatyTextField/Classes/**/*'
  s.ios.framework = 'UIKit'
  s.dependency 'SnapKit'
end
