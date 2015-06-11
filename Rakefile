require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  namespace :armrest do
    desc 'Run tests for the ArmRest module'
    RSpec::Core::RakeTask.new(:module) do |t|
      t.pattern = ['spec/armrest_module_spec.rb']
    end

    desc 'Run tests for the ArmRest::ArmRestManager base class'
    RSpec::Core::RakeTask.new(:manager) do |t|
      t.pattern = ['spec/armrest_manager_spec.rb']
    end
  end
end

task :default => :spec
