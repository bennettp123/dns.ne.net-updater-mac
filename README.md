### dns.he.net OS X dynamic dns updater

A very basic updater for dynamic DNS services provided by <http://dns.he.net/>. Very trivial to convert for use with other dynamic DNS providers.

## Instructions:

 1. Edit dns.he.net_updater.sh in a text editor, and modify the hostname and password fields.
 2. By default, a custom IP is not sent. If you wish to send a custom IP address, uncomment the two lines below the myip variable.
 3. If necessary, `chmod +x dns.he.net_updater.sh`.
 4. Run dns.he.net_updater.sh.
 5. [Optional]: Use the included LaunchDaemon to schedule the updates.
 
License: Freeware.<br />Warranty: None.

Enjoy!