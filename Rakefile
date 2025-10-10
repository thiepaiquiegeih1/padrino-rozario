require 'bundler/setup'
require 'padrino-core/cli/rake'
require 'padrino'

PadrinoTasks.use(:database)
PadrinoTasks.use(:activerecord)
PadrinoTasks.init
begin
  require 'navvy'
  require 'navvy/job/active_record'
  require 'navvy/tasks'
rescue LoadError
  task :navvy do
    abort "Couldn't find Navvy." << 
      "Please run `gem install navvy` to use Navvy's tasks."
  end
end
