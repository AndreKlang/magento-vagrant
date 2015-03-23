
# install som general stuff
package "htop"
package "zip"
package "unzip"
package "redis-tools"

# install modman
execute "wget https://raw.githubusercontent.com/colinmollenhour/modman/master/modman && sudo mv modman /usr/local/bin/modman && sudo chmod +x /usr/local/bin/modman" do
  not_if "test -f /usr/local/bin/modman"
end

