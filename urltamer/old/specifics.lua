-- Specific things to do.

-- TODO allow specifying allowed usernames?
local redditlist = {[[:hard=true
:fun=disallow
^https*://pixel[.]redditmedia[.]com/pixel/of_doom[.]png.+
:fun=allow
^https*://.[.]thumbs[.]redditmedia[.]com/.+[.]jpg$
^https*://.[.]thumbs[.]redditmedia[.]com/.+[.]css
^https://www[.]reddit.com/api/login/.+]],
-- Give the rest little more time.
[[:block_late 1000
:marks=domains
:fun=mark
^https*://www[.]reddit.com/*.+
^https*://www[.]redditstatic[.]com/*.+
:require_mark domains]],
}

local reddit_apilist = {"comment", "del", "editusertext", "hide", "info", "marknsfw",
                 "morechildren", "report", "save", "saved_categories.json",
                 "sendreplies", "set_contest_mode", "set_subreddit_sticky",
                 "store_visits", "submit", "unhide", "unmarknsfw", "unsave", "vote",
}
for _, el in pairs(reddit_apilist) do
   table.insert(redditlist, 2, string.format("^https*://www.reddit.com/api/%s$", el))
end

shortlist["www.reddit.com"]  = {
   way=table.concat(redditlist,"\n")
}

--shortlist["www.wolfire.com"] = {response="monitor", tags="allow_script"}
shortlist["www.youtube.com"] = { -- Seems that i cant do much better easily.
   way=[[:hard=true
:fun=allow
^https*://i[.]ytimg[.]com/vi/.+/m*q*default[.]jpg$
^https://s[.]ytimg[.]com/yts/jsbin/www-pageframe-.+/www-pageframe[.]js^
^https://s[.]ytimg.com/yts/jsbin/www-en_US-[.]+/common[.]js^
:block_late 1600
^https*://clients1[.]google.com/generate_204$
^https*://s[.]ytimg[.]com/yts/jsbin/.+
^https*://s[.]ytimg[.]com/yts/cssbin/.+[.]css
^https*://s[.]ytimg[.]com/yts/img/favicon.+[.]ico$
:own_domain]]
}

shortlist["www.tvgids.nl"] = {
   way=[[:set_result no false
:hard=true
:fun=allow
^http://www[.]tvgids[.]nl/json/lists/.+
:block_late 1000
:marks=domains
:fun=mark
^https*://www[.]tvgids[.]nl/*.+
^https*://tvgidsassets[.]nl/*.+
:require_mark domains]]
}
shortlist["imgur.com"] = {
   way=[[:hardyes=true
:fun=allow
^http://.[.]imgur[.]com/.+]]
}

shortlist["duckduckgo.com"] = {
   -- TODO special redirect rule.
   -- https://duckduckgo.com/html/?q=.+
}
-- Exceptions instead?
local permissive = { way=[[:hard=true
:fun=allow
.+]]}

shortlist["en.wikipedia.org"] = permissive
shortlist["nl.wikipedia.org"] = permissive
shortlist["bits.wikimedia.org"] = permissive

shortlist["okturtles.slack.com"] = permissive


shortlist["github.com"] = { way=[[:hardyes=true
:fun allow
^https://github.com/.+/.+/issue_comments$
^https://github.com/.+/.+/pullrequest_comments$]]
}

shortlist["xkcd.com"] = { way=[[:nexthardyes=1
:fun=allow
^http://imgs.xkcd.com/comics/.+.png$]] }
