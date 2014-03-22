### dns.he.net Linux/OS X dynamic dns updater

A very basic updater for dynamic DNS services provided by <http://dns.he.net/>. 

## Instructions:

 1. Edit dns.he.net_updater.sh in a text editor, and modify the hostname and password fields.
 2. If desired, set $use_ifconfig='yes' and $iface='eth0'. Otherwise, the script will use http://checkip.dns.he.net to determine your public IP address.
 3. If necessary, `chmod +x dns.he.net_updater.sh`.
 4. Run dns.he.net_updater.sh.
 5. Use the included LaunchDaemon to schedule the updates. Or cron. Whatever floats your boat.

License: MIT.<br />Warranty: None.

Enjoy!
