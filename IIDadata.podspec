#
# Be sure to run `pod lib lint IIDadata.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IIDadata'
  s.version          = '0.2.3'
  s.summary          = 'Access Dadata address suggestions and reverse geocoding APIs.'

  s.swift_versions   = '5.2'

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  This package provides access to Dadata address suggestions and reverse geocoding APIs. Any of Dadata API settings for address suggestions are available.
  DESC

  s.homepage         = 'https://github.com/illabo/IIDadata'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { type: 'MIT', file: './LICENSE' }
  s.author           = { 'Ilya Yachin' => 'uin153974748@gmail.com' }
  s.source           = { git: 'https://github.com/illabo/IIDadata.git',
                         branch: 'release',
                         tag: s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'IIDadata/Sources/**/*.swift'

  # s.resource_bundles = {
  #   'IIDadata' => ['IIDadata/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
