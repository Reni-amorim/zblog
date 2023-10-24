namespace :deploy do
    desc 'Generate Puma systemd service configuration'
    task :generate_puma_systemd_config do
      on roles(:app) do
        within current_path do
          execute :puma, :systemd, :config, 'TEMPLATE_PATH', 'OUTPUT_PATH'
        end
      end
    end
  end