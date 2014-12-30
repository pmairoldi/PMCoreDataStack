Pod::Spec.new do |s|

  s.name             = "PMCoreDataStack"
  s.version          = "0.1.0"
  s.summary          = "Core Data stack in Swift"
  s.homepage         = "https://github.com/petester42/PMCoreDataStack"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Pierre-Marc Airoldi" => "pierremarcairoldi@gmail.com" }
  s.social_media_url = 'https://twitter.com/petester42'
  s.source           = { :git => "https://github.com/petester42/PMCoreDataStack.git", :tag => s.version.to_s }
  s.platform         = :ios, '8.0'
  s.default_subspec  = "Core"

  s.subspec "Core" do |ss|
    ss.source_files = "Pod/CoreDataStorage.swift"
    ss.framework    = "Foundation"
    ss.framework    = "CoreData"
    ss.dependency   "LlamaKit"    
  end

  s.subspec "Reactive" do |ss|
    ss.source_files = "Pod/CoreDataTableViewController.swift", "Pod/CoreDataViewModel.swift"
    ss.framework    = "UIKit"
    ss.dependency   "PMCoreDataStack/Core"
    ss.dependency   "ReactiveCocoa"
    ss.dependency   "Swift-RAC-Macros"
  end

end