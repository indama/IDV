#
#  Be sure to run `pod spec lint IDValidationSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|


  spec.name         = "IDValidationSDK"
  spec.version      = "1.0.0"
  spec.summary      = "A short description of IDValidationSDK."

  spec.swift_version = "4.2"
 
  spec.description  = "A complete description of IDValidationSDK"


  spec.homepage     = "http://EXAMPLE/IDValidationSDK"
 

  spec.license      = "MIT (example)"

  spec.author             = { "Rahim Abdullayev" => "rakhim@medyear.com" }
 

  spec.source       = { :git => "https://github.com/indama/IDVSDK.git", :tag => "#{spec.version}" }

  spec.source_files  = "Classes", "Classes/**/*.{h,m}"
  spec.exclude_files = "Classes/Exclude"


  spec.dependency  'GoogleMLKit/BarcodeScanning'
  spec.dependency  'GoogleMLKit/FaceDetection'
  spec.dependency  'GoogleMLKit/ImageLabeling'
  spec.dependency  'GoogleMLKit/TextRecognition'
  spec.dependency  'GoogleMLKit/ObjectDetection'
    
  spec.dependency  'AWSRekognition'
  spec.dependency  'ZImageCropper'
  spec.dependency  'SnapKit'
  spec.dependency  'FFGlobalAlertController'

end
