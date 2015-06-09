require 'rake'
require 'rake/clean'
require 'rake/testtask'

CLEAN.include('**/*.tar', '**/*.zip', '**/*.gz', '**/*.bz2')
CLEAN.include('**/*.rbc', '**/*.gem', '**/*.tmp')

namespace 'gem' do
  desc 'Create the azure-armrest gem'
  task :create => [:clean] do
    require 'rubygems/package'
    spec = eval(IO.read('azure-armrest.gemspec'))
    Gem::Package.build(spec)
  end

  desc 'Install the azure-armrest gem'
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

Rake::TestTask.new do |t|
  t.test_files = ['spec/*.rb']
  t.verbose = true
  t.warning = true
end

namespace :spec do
  namespace :armrest do
    Rake::TestTask.new(:module) do |t|
      t.test_files = ['spec/armrest_module_spec.rb']
      t.verbose = true
      t.warning = true
    end
  end
end

task :default => :test
task :spec => :test
