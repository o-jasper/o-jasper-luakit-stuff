-- Specific things to do.
local Public = {}

Public["www.reddit.com"] = function(info, result)
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
         if string.match(info.uri, string.format("^https*://www.reddit.com/api/%s$", el)) then
            result.allow = true
         end
      end
   end
end

-- Oh, np stands for non-participation. It means you should not act like a 
--  vote-brigade and stuff.
Public["www.np.reddit.com"] = Public["www.reddit.com"]

Public["www.youtube.com"] = function(info, result)
   handler.everywhere(info, result,
                  {"^https://s[.]ytimg[.]com/yts/jsbin/www-pageframe-.+/www-pageframe[.]js^",
                   "^https://s[.]ytimg.com/yts/jsbin/www-en_US-[.]+/common[.]js^",
                   "^https*://clients1[.]google.com/generate_204$",
                   "^https*://s[.]ytimg[.]com/yts/jsbin/.+",
                   "^https*://s[.]ytimg[.]com/yts/cssbin/.+[.]css",
                   "^https*://s[.]ytimg[.]com/yts/img/favicon.+[.]ico$"
                  })
   -- Images are not time-limited.
   if string.match(info.uri, "^https*://i[.]ytimg[.]com/vi/.+/m*q*default[.]jpg$") then
      result.allow = true
   end
end

Public["www.tvgids.nl"] = function(info, result)
   handler.everywhere(info, result, {"^http://www[.]tvgids[.]nl/json/lists/.+",
                                 "^https*://www[.]tvgids[.]nl/*.+",
                                 "^https*://tvgidsassets[.]nl/*.+"})
end

Public["imgur.com"] = function(info, result)
   handler.everywhere(info, result, "^http://.[.]imgur[.]com/.+")
end
Public["i.imgur.com"] = function(info, result)
   handler.everywhere(info, result, "^http://.[.]imgur[.]com/.+")
end

--Public["duckduckgo.com"] = {
--   -- TODO special redirect rule.
--   -- https://duckduckgo.com/html/?q=.+
--}
-- Exceptions instead?
local function permissive(info, result)
   --print("permissive", info.uri, info.vuri)
   result.allow = true
end

Public["en.wikipedia.org"] = permissive
Public["nl.wikipedia.org"] = permissive
Public["bits.wikimedia.org"] = permissive

Public["okturtles.slack.com"] = permissive

function bland_info(info, from_to)
   for k,v in pairs(from_to) do
      if string.match(info.uri, k) then
         if type(v) == "function"  then
            if v(info) then return true end
         else
            result.allow = true
            if v == "s" then
               result.redirect = string.sub(k, 2, #k - 2)
            else
               result.redirect = v
            end
            return true
         end
      end
   end
end

Public["github.com"] = function(info, result)
   handler.everywhere(info, result,
                      {"^https://github.com/.+/.+/issue_comments$",
                       "^https://github.com/.+/.+/pullrequest_comments$",
                       "^https://avatars[%d]+.githubusercontent.com/.+",
                       "^https://assets[-]cdn.github.com/assets/.+"
                      })
end

Public["xkcd.com"] = function(info, result)
   handler.everywhere(info, result, "^http://imgs.xkcd.com/comics/.+.png$")
end

Public["&about:blank$"] = permissive

Public["stackoverflow.com"] = function(info, result)
   handler.everywhere(info, result)
   bland_info(info, {["^http://cdn.sstatic.net/stackoverflow/all.css.+"] = "s"})
end

Public["fileformat.info"] = function(info, result)
   handler.everywhere(info, result, {"^https*://emoji.fileformat.info/gemoji/.+[.]png$"})
end

return Public
