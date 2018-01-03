#
# Be sure to run `pod lib lint AssetChecker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AssetChecker'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AssetChecker.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Because Image Assets files are not safe, if an asset is ever deleted, nothing will warn you that an image is broken in your code.  AssetChecker lints your asset catalog.
                       DESC

  s.homepage         = 'https://github.com/joeboyscout04/AssetChecker'
  s.screenshots     = 'https://raw.githubusercontent.com/s4cha/AssetChecker/master/xcodeScreenshot.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sacha Durand Saint Omer' => 'sachadso@gmail.com' }
  s.source           = { :git => 'https://github.com/joeboyscout04/AssetChecker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Classes/**/*'
  s.preserve_paths = [ 'run' ]

end
