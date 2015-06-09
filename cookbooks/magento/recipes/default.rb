magento_version = "#{node['magento']['magento_version']}"
install_path = "#{node['magento']['install_path']}"
base_url = "#{node['magento']['base_url']}"
admin = "#{node['magento']['admin']}"
passwd = "#{node['magento']['passwd']}"
backend_frontname = "#{node['magento']['backend_frontname']}"

# download magento
execute "wget -P #{install_path} http://www.magentocommerce.com/downloads/assets/#{magento_version}/magento-#{magento_version}.tar.gz" do
  not_if "test -f #{install_path}/magento-#{magento_version}.tar.gz"
end

# unpack
execute "tar -zxvf #{install_path}/magento-#{magento_version}.tar.gz -C #{install_path}" do
  only_if "test -f #{install_path}/magento-#{magento_version}.tar.gz"
end

# move
execute "mv #{install_path}/magento/* #{install_path}/magento/.htaccess #{install_path}" do
  only_if "test -f #{install_path}/magento/.htaccess"
end

# remove archive
execute "rm -fr #{install_path}/magento-#{magento_version}.tar.gz #{install_path}/magento" do
  only_if "test -f #{install_path}/magento-#{magento_version}.tar.gz"
end

# Set correct? permissions
#execute "chmod -R o+w #{install_path}/media #{install_path}/var && chmod o+w #{install_path}/app/etc" do
#  only_if "test -f #{install_path}/index.php"
#end

# Set ugly permissions
execute "chmod -R 0777 #{install_path}" do
  only_if "test -f #{install_path}/index.php"
end

# Set owner
execute "chown -R www-data #{install_path}" do
  only_if "test -f #{install_path}/index.php"
end

# run installer
execute "/usr/bin/env php -f '#{install_path}/install.php' -- --license_agreement_accepted 'yes' --locale 'sv_SE' --timezone 'Europe/Stockholm' --db_host 'localhost' --db_name 'magento' --db_user 'root' --db_pass 'dev' --db_prefix '' --url '#{base_url}' --use_rewrites 'yes' --use_secure 'no' --secure_base_url '' --use_secure_admin 'no' --admin_username '#{admin}' --admin_lastname 'Doe' --admin_firstname 'John' --admin_email 'john.doe@example.com' --admin_password '#{passwd}' --session_save 'files' --admin_frontname 'admin' --backend_frontname '#{backend_frontname}' --default_currency 'SEK' --skip_url_validation 'yes'" do
  only_if "test -f #{install_path}/index.php"
end

# enable symlinks
execute "cd #{install_path} && n98-magerun dev:symlinks 0 --on" do
  only_if "test -f /usr/local/bin/n98-magerun"
end

