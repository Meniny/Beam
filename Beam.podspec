Pod::Spec.new do |s|
  s.name        = 'Beam'
  s.module_name = 'Beam'
  s.version     = '1.0.0'
  s.summary     = 'Beam - EventBus implementation written in Swift.'
  s.description      = <<-DESC
Beam is an EventBus implementation witch provides compile time safety and type checking.
DESC

  s.homepage    = 'https://github.com/Meniny/Beam'
  s.license     = { type: 'MIT', file: 'LICENSE.md' }
  s.authors     = { 'Elias Abel' => 'admin@meniny.cn' }
  s.social_media_url = 'https://meniny.cn/'

  s.ios.deployment_target     = '9.0'
  s.osx.deployment_target     = '10.10'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source              = { git: 'https://github.com/Meniny/Beam.git', tag: s.version.to_s }

  s.requires_arc        = true
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }
  s.swift_version       = '4.1'

  # s.dependency ""

  s.default_subspecs = 'Core'

  s.subspec 'Core' do |sp|
    sp.source_files  = 'Beam/Core/**/*.swift'
  end
end
