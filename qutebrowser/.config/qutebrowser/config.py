# Autogenerated config.py
# Documentation:
#   qute://help/configuring.html
#   qute://help/settings.html

# Uncomment this to still load settings configured via autoconfig.yml
# config.load_autoconfig()

# Aliases for commands. The keys of the given dictionary are the
# aliases, while the values are the commands they map to.
# Type: Dict
c.aliases = {
    'proxy-off': 'set content.proxy system',
    'proxy-on': 'set content.proxy http://192.168.49.1:8282/',
    'proxy-ssh': 'set content.proxy socks://localhost:9050/',
    'q': 'quit',
    'w': 'session-save',
    'wq': 'quit --save'
}

# Always restore open sites when qutebrowser is reopened.
# Type: Bool
c.auto_save.session = False

# List of URLs of lists which contain hosts to block.  The file can be
# in one of the following formats:  - An `/etc/hosts`-like file - One
# host per line - A zip-file of any of the above, with either only one
# file, or a file   named `hosts` (with any extension).  It's also
# possible to add a local file or directory via a `file://` URL. In case
# of a directory, all files in the directory are read as adblock lists.
# The file `~/.config/qutebrowser/blocked-hosts` is always read if it
# exists.
# Type: List of Url
c.content.host_blocking.lists = ['https://www.malwaredomainlist.com/hostslist/hosts.txt', 'http://someonewhocares.org/hosts/hosts', 'http://winhelp2002.mvps.org/hosts.zip', 'http://malwaredomains.lehigh.edu/files/justdomains.zip', 'https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&mimetype=plaintext']

# Enable JavaScript.
# Type: Bool
config.set('content.javascript.enabled', True, 'file://*')

# Enable JavaScript.
# Type: Bool
config.set('content.javascript.enabled', True, 'chrome://*/*')

# Enable JavaScript.
# Type: Bool
config.set('content.javascript.enabled', True, 'qute://*/*')

# Proxy to use. In addition to the listed values, you can use a
# `socks://...` or `http://...` URL.
# Type: Proxy
# Valid values:
#   - system: Use the system wide proxy.
#   - none: Don't use any proxy
c.content.proxy = 'system'

# Allow websites to register protocol handlers via
# `navigator.registerProtocolHandler`.
# Type: BoolAsk
# Valid values:
#   - true
#   - false
#   - ask
config.set('content.register_protocol_handler', True, 'https://mail.google.com/*')

# Editor (and arguments) to use for the `open-editor` command. The
# following placeholders are defined: * `{file}`: Filename of the file
# to be edited. * `{line}`: Line in which the caret is found in the
# text. * `{column}`: Column in which the caret is found in the text. *
# `{line0}`: Same as `{line}`, but starting from index 0. * `{column0}`:
# Same as `{column}`, but starting from index 0.
# Type: ShellCommand
c.editor.command = ['gedit', '{file}']

# Automatically enter insert mode if an editable element is focused
# after loading the page.
# Type: Bool
c.input.insert_mode.auto_load = True

# Page to open if :open -t/-b/-w is used without URL. Use `about:blank`
# for a blank page.
# Type: FuzzyUrl
c.url.default_page = 'https://arjvik.github.io/tab'

# Search engines which can be used via the address bar. Maps a search
# engine name (such as `DEFAULT`, or `ddg`) to a URL with a `{}`
# placeholder. The placeholder will be replaced by the search term, use
# `{{` and `}}` for literal `{`/`}` signs. The search engine named
# `DEFAULT` is used when `url.auto_search` is turned on and something
# else than a URL was entered to be opened. Other search engines can be
# used by prepending the search engine name to the search term, e.g.
# `:open google qutebrowser`.
# Type: Dict
c.url.searchengines = {'DEFAULT': 'https://google.com/search?query={}'}

# Page(s) to open at the start.
# Type: List of FuzzyUrl, or FuzzyUrl
c.url.start_pages = 'https://arjvik.github.io/tab'

# Bindings for normal mode
config.bind('<Alt+0>', 'tab-focus -1')
config.bind('<Alt+9>', 'tab-focus 9')
config.bind('<Alt+Left>', 'back')
config.bind('<Alt+Right>', 'forward')
config.bind('<Ctrl+Shift+e>', 'edit-url')
config.bind('[[', 'navigate decrement')
config.bind(']]', 'navigate increment')
config.bind('{{', 'navigate prev')
config.bind('}}', 'navigate next')
config.bind('<Ctrl+a>', None)
config.bind('<Ctrl+x>', None)
config.bind('q', None)
config.bind('qo', 'open https://outline.com/{url}')
config.bind('qp', 'spawn --userscript qute-lastpass')
config.bind('qu', 'open {url}?share')
config.bind('qbo', 'proxy-on')
config.bind('qbx', 'proxy-off')
config.bind('qbs', 'proxy-ssh')

# Bindings for insert mode
config.bind('<Alt+Left>', 'back', mode='insert')
config.bind('<Alt+Right>', 'forward', mode='insert')
config.bind('<Alt+0>', 'tab-focus -1', mode='insert')
config.bind('<Alt+1>', 'tab-focus 1', mode='insert')
config.bind('<Alt+2>', 'tab-focus 2', mode='insert')
config.bind('<Alt+3>', 'tab-focus 3', mode='insert')
config.bind('<Alt+4>', 'tab-focus 4', mode='insert')
config.bind('<Alt+5>', 'tab-focus 5', mode='insert')
config.bind('<Alt+6>', 'tab-focus 6', mode='insert')
config.bind('<Alt+7>', 'tab-focus 7', mode='insert')
config.bind('<Alt+8>', 'tab-focus 8', mode='insert')
config.bind('<Alt+9>', 'tab-focus 9', mode='insert')

# Qutebrowser Nord Theme
config.source('nord-qutebrowser.py')
