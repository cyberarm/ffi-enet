# frozen_string_literal: true

require_relative "lib/ffi-enet/version"

Gem::Specification.new do |spec|
  spec.name = "ffi-enet"
  spec.version = ENet::VERSION
  spec.authors = ["Cyberarm"]
  spec.email = ["matthewlikesrobots@gmail.com"]

  spec.summary = "FFI interface to the enet networking library."
  spec.description = "FFI interface to the enet networking library. Includes rENet-like API to simplify enet usage."
  spec.homepage = "https://github.com/cyberarm/ffi-enet"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/cyberarm/ffi-enet"
  spec.metadata["changelog_uri"] = "https://github.com/cyberarm/ffi-enet/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "lib64"]

  spec.add_dependency "ffi", "~> 1.15"
end
