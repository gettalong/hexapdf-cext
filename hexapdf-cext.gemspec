require 'rake'
require_relative 'lib/hexapdf/cext/version'

PKG_FILES = FileList.new([
                           'ext/**/*',
                           'lib/**/*.rb',
                           'Rakefile',
                           'LICENSE',
                           'README.md',
                         ])

Gem::Specification.new do |s|
  s.name = 'hexapdf-cext'
  s.version = HexaPDF::CExt::VERSION
  s.summary = "Faster implementation of some HexaPDF algorithms in C for still more performance"
  s.license = 'MIT'

  s.files = PKG_FILES.to_a

  s.extensions = ['ext/hexapdf_cext/extconf.rb']
  s.require_path = 'lib'
  s.add_development_dependency('rake-compiler')
  s.required_ruby_version = '>= 2.4'

  s.author = 'Thomas Leitner'
  s.email = 't_leitner@gmx.at'
  s.homepage = "https://hexapdf.gettalong.org"
end
