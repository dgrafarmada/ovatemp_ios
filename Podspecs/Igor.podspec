Pod::Spec.new do |s|
  s.name = "Igor"
  s.version = "1.0.0"
  s.summary = "A query engine that selects views in a iOS application."
  s.description = "Igor is a query engine that selects views in a iOS application, based on each view's class, properties, containment relationship to other views, and other characteristics."
  s.homepage = "https://github.com/dhemery/igor"
  s.author = { "Dale Emery" => "dale@dhemery.com"}

  s.source = { :git => "https://github.com/dhemery/igor.git", :tag => "igor-1.0" }
  s.platform = :ios, '6.0'
  s.source_files = 'igor/**/*.{h,m}'
  s.exclude_files = 'igor/engine/DEIgorSelfRegisteringSelectorEngine.m'

  s.requires_arc = true
  s.license = {:type => 'MIT', :file => 'README.md' }
end
