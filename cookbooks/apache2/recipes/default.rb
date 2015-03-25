apache_default_config = "/etc/apache2/sites-available/000-default.conf"

package "apache2" do
  action :install
  package_name "apache2-mpm-prefork"
end

service "apache2" do
  service_name "apache2"

  restart_command "/usr/sbin/invoke-rc.d apache2 restart && sleep 1"
  reload_command "/usr/sbin/invoke-rc.d apache2 reload && sleep 1"

  supports [:restart, :reload, :status]
  action :enable
end

# enable mod rewrite
execute "/usr/sbin/a2enmod rewrite" do
  notifies :restart, "service[apache2]"
  not_if do (::File.symlink?("/etc/apache2/mods-enabled/rewrite.load") and
    ((::File.exists?("/etc/apache2/mods-available/rewrite.conf"))?
      (::File.symlink?("/etc/apache2/mods-enabled/rewrite.conf")):(true)))
  end
end

# allow override for default site
execute "set-vhost" do
  command "rm #{apache_default_config} && cp /vagrant/cookbooks/apache2/recipes/000-default.conf.template #{apache_default_config}"
end


# remove /var/www
directory "/var/www" do
  action :delete
  ignore_failure true
  recursive true
end

directory "/var/www" do
  action :create
  ignore_failure true
  recursive true
end

# link to /var/www
link "/var/www/html" do
  to "/vagrant/magento"
end

service "apache2" do
  action :start
end
