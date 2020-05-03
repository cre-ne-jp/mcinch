Gem::Specification.new do |s|
  s.name = 'mcinch'
  s.version = '2.3.4'
  s.summary = 'A Cinch fork for easy embedding into app'
  s.description = 'A wrapper of Cinch (an IRC bot building framework) for easy embedding into another application'
  s.authors = ['ocha']
  s.email = ['ochaochaocha3@mgail.com']
  s.required_ruby_version = '>= 2.5'
  s.files = Dir[
    'LICENSE',
    'README.md',
    'README_OLD.md',
    '.yardopts',
    '{docs,lib,examples}/**/*',
  ]
  s.has_rdoc = "yard"
  s.license = "MIT"
end
