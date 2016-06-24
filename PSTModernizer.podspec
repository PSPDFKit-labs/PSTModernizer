#
# Be sure to run `pod lib lint PSTModernizer.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'PSTModernizer'
  s.version          = '1.0.0'
  s.summary          = 'Makes it easier to support older versions of iOS by fixing things and adding missing methods'
  s.description      = <<-DESC
PSTModernizer carefully applies patches to UIKit and related Apple frameworks to fix known radars with the least impact. The current set of patches just applies to iOS 9 and nothing is executed on iOS 10, as the bugs have been fixed there.
                       DESC

  s.homepage         = 'https://github.com/PSPDFKit-labs/PSTModernizer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Peter Steinberger, PSPDFKit' => 'https://pspdfkit.com/' }
  s.source           = { :git => 'https://github.com/PSPDFKit-labs/PSTModernizer.git', :tag => s.version.to_s }
  s.source_files = 'PSTModernizer/**/*'
  s.social_media_url = 'https://twitter.com/steipete'

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.xcconfig = { 'CLANG_MODULES_AUTOLINK' => 'YES' }

end
