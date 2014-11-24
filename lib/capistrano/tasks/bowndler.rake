desc 'Install Bundler and Bower dependencies with Bowndler'
task :bowndler do
  on roles(:app) do
    within release_path do
      execute :bundle, 'exec bowndler update'
    end
  end
end

before 'deploy:compile_assets', :bowndler
