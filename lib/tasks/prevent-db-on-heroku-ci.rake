Rake::Task["db:schema:load"].clear
task "db:schema:load" => :environment do
end

Rake::Task["db:migrate"].clear
task "db:migrate" => :environment do
end
