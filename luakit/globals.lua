-- Global variables for luakit
globals = {
    homepage            = "http://luakit.org/",
 -- homepage            = "http://github.com/mason-larobina/luakit",
    scroll_step         = 40,
    zoom_step           = 0.1,
    max_cmd_history     = 100,
    max_srch_history    = 100,
 -- http_proxy          = "http://example.com:3128",
    download_dir        = (os.getenv("HOME") .. "/Downloads"),
    default_window_size = "800x600",

 -- Disables loading of hostnames from /etc/hosts (for large host files)
 -- load_etc_hosts      = false,
 -- Disables checking if a filepath exists in search_open function
 -- check_filepath      = false,
}

-- Make useragent
--local arch = string.match(({luakit.spawn_sync("uname -sm")})[2], "([^\n]*)")
--local lkv  = string.format("luakit/%s", luakit.version)
--local wkv  = string.format("WebKitGTK+/%d.%d.%d", luakit.webkit_major_version, luakit.webkit_minor_version, luakit.webkit_micro_version)
--local awkv = string.format("AppleWebKit/%s.%s+", luakit.webkit_user_agent_major_version, luakit.webkit_user_agent_minor_version)
--globals.useragent = string.format("Mozilla/5.0 (%s) %s %s %s", arch, awkv, wkv, lkv)
globals.useragent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; da; rv:1.9.1) Gecko/20090624 Firefox/3.5 (.NET CLR 3.5.30729)2011-04-19 15:42:12"
-- Search common locations for a ca file which is used for ssl connection validation.
local ca_files = {
    -- $XDG_DATA_HOME/luakit/ca-certificates.crt
    luakit.data_dir .. "/ca-certificates.crt",
    "/etc/certs/ca-certificates.crt",
    "/etc/ssl/certs/ca-certificates.crt",
}
-- Use the first ca-file found
for _, ca_file in ipairs(ca_files) do
    if os.exists(ca_file) then
        soup.ssl_ca_file = ca_file
        break
    end
end

-- Change to stop navigation sites with invalid or expired ssl certificates
soup.ssl_strict = false

-- Set cookie acceptance policy
cookie_policy = { always = 0, never = 1, no_third_party = 2 }
soup.accept_policy = cookie_policy.always

-- List of search engines. Each item must contain a single %s which is
-- replaced by URI encoded search terms. All other occurances of the percent
-- character (%) may need to be escaped by placing another % before or after
-- it to avoid collisions with lua's string.format characters.
-- See: http://www.lua.org/manual/5.1/manual.html#pdf-string.format
search_engines = {
    luakit      = "http://luakit.org/search/index/luakit?q=%s",
    google      = "http://google.de/search?q=%s",
    duckduckgo  = "http://duckduckgo.com/?q=%s",
    wikipedia   = "http://de.wikipedia.org/wiki/Special:Search?search=%s",
    debbugs     = "http://bugs.debian.org/%s",
    imdb        = "http://imdb.com/find?s=all&q=%s",
    sourceforge = "http://sf.net/search/?words=%s",
}

-- Set google as fallback search engine
search_engines.default = search_engines.google
-- Use this instead to disable auto-searching
--search_engines.default = "%s"

-- Per-domain webview properties
-- See http://webkitgtk.org/reference/webkitgtk-WebKitWebSettings.html
domain_props = {
    ["all"] = {
        --enable_scripts          = false,
        enable_scripts          = true,
        enable_plugins          = false,
        enable_private_browsing = false,
        user_stylesheet_uri     = "",
    },
    ["jw.org"] = {
        enable_scripts            = true,
        enable_private_browsing   = true,
    },
    ["google.com"] = {
        enable_scripts            = true,
        enable_private_browsing   = true,
    },
    ["google.de"] = {
        enable_scripts            = true,
        enable_private_browsing   = true,
    },
    ["vimeo.com"] = {
        enable_scripts   = true,
        enable_plugins   = true,
        enable_private_browsing   = true,
    },
    ["github.com"] = {
        enable_scripts   = true,
        enable_plugins   = true,
        enable_private_browsing   = true,
    },
    ["youtube.com"] = {
        enable_scripts = true,
        enable_plugins = true,
    },
    ["vimcasts.org"] = {
        enable_scripts   = true,
        enable_plugins   = true,
        enable_private_browsing   = true,
    },
 --[[
    ["bbs.archlinux.org"] = {
        user_stylesheet_uri     = "file://" .. luakit.data_dir .. "/styles/dark.css",
        enable_private_browsing = true,
    }, ]]
}

-- vim: et:sw=4:ts=8:sts=4:tw=80
