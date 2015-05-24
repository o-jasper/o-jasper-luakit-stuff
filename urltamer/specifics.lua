-- Specific things to do.

shortlist["www.reddit.com"] = function(info, result)
   handler.everywhere(info, result,
                  {"^https*://.[.]thumbs[.]redditmedia[.]com/.+[.]jpg$",
                   "^https*://.[.]thumbs[.]redditmedia[.]com/.+[.]css",
                   "^https://www[.]reddit.com/api/login/.+",
                   "^https*://www[.]reddit.com/*.+",
                   "^https*://www[.]redditstatic[.]com/*.+"})
   if info:uri_match("^https*://pixel[.]redditmedia[.]com/pixel/of_doom[.]png.+") then
      result.allow = false
      result.disallow = true
   else  -- And allow some api stuff.
      local apilist = {"comment", "del", "editusertext", "hide", "info", "marknsfw",
                       "morechildren", "report", "save", "saved_categories.json",
                       "sendreplies", "set_contest_mode", "set_subreddit_sticky",
                       "store_visits", "submit", "unhide", "unmarknsfw", "unsave", "vote",
      }
      for _, el in pairs(apilist) do
         if string.match(info.uri, string.format("^https://www.reddit.com/api/%s$", el)) then
            result.allow = true
         end
      end
   end
end

shortlist["www.youtube.com"] = function(info, result)
   handler.everywhere(info, result,
                  {"^https*://i[.]ytimg[.]com/vi/.+/m*q*default[.]jpg$",
                   "^https://s[.]ytimg[.]com/yts/jsbin/www-pageframe-.+/www-pageframe[.]js^",
                   "^https://s[.]ytimg.com/yts/jsbin/www-en_US-[.]+/common[.]js^",
                   "^https*://clients1[.]google.com/generate_204$",
                   "^https*://s[.]ytimg[.]com/yts/jsbin/.+",
                   "^https*://s[.]ytimg[.]com/yts/cssbin/.+[.]css",
                   "^https*://s[.]ytimg[.]com/yts/img/favicon.+[.]ico$"
                  })
end

shortlist["www.tvgids.nl"] = function(info, result)
   handler.everywhere(info, result, {"^http://www[.]tvgids[.]nl/json/lists/.+",
                                 "^https*://www[.]tvgids[.]nl/*.+",
                                 "^https*://tvgidsassets[.]nl/*.+"})
end

shortlist["imgur.com"] = function(info, result)
   handler.everywhere(info, result, "^http://.[.]imgur[.]com/.+")
end

--shortlist["duckduckgo.com"] = {
--   -- TODO special redirect rule.
--   -- https://duckduckgo.com/html/?q=.+
--}
-- Exceptions instead?
function permissive(info, result)
   result.allow = true
end

shortlist["en.wikipedia.org"] = permissive
shortlist["nl.wikipedia.org"] = permissive
shortlist["bits.wikimedia.org"] = permissive

shortlist["okturtles.slack.com"] = permissive

shortlist["github.com"] = function(info, result)
   handler.everywhere(info, result, {"^https://github.com/.+/.+/issue_comments$",
                                 "^https://github.com/.+/.+/pullrequest_comments$",
                                 "^https://avatars[%d]+.githubusercontent.com/.+",
                                 "^https://assets[-]cdn.github.com/assets/.+"
                                })
end

shortlist["xkcd.com"] = function(info, result)
   handler.everywhere(info, result, "^http://imgs.xkcd.com/comics/.+.png$")
end

pattern_shortlist["^luakit://.+"] = permissive
