#
#  Be sure to run `pod spec lint PlanOutKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "PlanOutKit"
  spec.version      = "0.1.4"
  spec.summary      = "PlanOut interpreter implementation in Swift."
  spec.description  = <<-DESC
    A Swift implementation of PlanOut interpreter, for Swift or Objective-C backed front-ends. The implementation (tries to) follow standards defined by the Python implementation of PlanOut interpreter and also its Java implementation (planout4j).
                   DESC
  spec.homepage     = "https://github.com/traveloka/PlanOutKit"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.authors            = {
    "David Christiandy" => "david.christiandy@gmail.com",
    "Irvi Aini" => "irvi.fa@gmail.com"
  }
  spec.platform       = :ios, "10.0"
  spec.swift_version  = "5.0"
  spec.source       = { :git => "git@github.com:traveloka/PlanOutKit.git", :tag => "#{spec.version}" }
  spec.source_files  = "Source/**/*.swift"
end
