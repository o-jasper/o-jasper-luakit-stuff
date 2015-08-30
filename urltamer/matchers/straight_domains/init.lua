-- Specific things to do.
local Public = {}

local handler = require "urltamer.handler"

Public["www.reddit.com"] = function(info, result)
   handler.everywhere(info, result,
                  {"^https?://.[.]thumbs[.]redditmedia[.]com/.+[.]jpg$",
                   "^https?://.[.]thumbs[.]redditmedia[.]com/.+[.]css",
                   "^https://www[.]reddit[.]com/api/login/.+",
                   "^https?://www[.]reddit[.]com/*",
                   "^https?://www[.]redditstatic[.]com/*"})
   if info:uri_match("^https?://pixel[.]redditmedia[.]com/pixel/of_doom[.]png") then
      result.allow = false
      result.disallow = true
   else  -- And allow some api stuff.
      local apilist = {"comment", "del", "editusertext", "hide", "info", "marknsfw",
                       "morechildren", "report", "save", "saved_categories.json",
                       "sendreplies", "set_contest_mode", "set_subreddit_sticky",
                       "store_visits", "submit", "unhide", "unmarknsfw", "unsave", "vote",
      }
      for _, el in pairs(apilist) do
         if string.match(info.uri, string.format("^https?://www[.]reddit[.]com/api/%s$", el)) then
            result.allow = true
         end
      end
   end
end

-- Oh, np stands for non-participation. It means you should not act like a 
--  vote-brigade and stuff.
Public["np.reddit.com"] = Public["www.reddit.com"]

Public["www.youtube.com"] = function(info, result)
   handler.everywhere(info, result,
                  {"^https://s[.]ytimg[.]com/yts/jsbin/www-pageframe-.+/www-pageframe[.]js^",
                   "^https://s[.]ytimg.com/yts/jsbin/www-en_US-[.]+/common[.]js^",
                   "^https?://clients1[.]google.com/generate_204$",
                   "^https?://s[.]ytimg[.]com/yts/jsbin/.+",
                   "^https?://s[.]ytimg[.]com/yts/cssbin/.+[.]css",
                   "^https?://s[.]ytimg[.]com/yts/img/favicon.+[.]ico$"
                  })
   -- Images are not time-limited.
   if string.match(info.uri, "^https?://i[.]ytimg[.]com/vi/.+/m*q*default[.]jpg$") then
      result.allow = true
   end
end

Public["www.tvgids.nl"] = function(info, result)
   handler.everywhere(info, result, {"^http://www[.]tvgids[.]nl/json/lists/.+",
                                 "^https?://www[.]tvgids[.]nl/*.+",
                                 "^https?://tvgidsassets[.]nl/*.+"})
end

-- Allow that other one too.
Public["imgur.com"] = function(info, result)
   handler.everywhere(info, result, "^https?://.[.]imgur[.]com/.+")
end
Public["i.imgur.com"] = function(info, result)
   handler.everywhere(info, result, "^https?://.[.]imgur[.]com/.+")
end

Public["gfycat.com"] = function(info, result)
   handler.everywhere(info, result, "^https?://assets[.]gfycat[.]com/")
end

--Public["duckduckgo.com"] = {
--   -- TODO special redirect rule.
--   -- https://duckduckgo.com/html/?q=.+
--}

Public["en.wikipedia.org"] = handler.permissive
Public["nl.wikipedia.org"] = handler.permissive
Public["bits.wikimedia.org"] = handler.permissive

Public["simple.wikipedia.org"] = function(info, result)
   handler.everywhere(info, result, {
                         "^https?://meta[.]wikimedia[.]org",
                         "^https?://en[.]wikipedia[.]org",
                         "^https?://upload[.]wikimedia[.]org",
   })
end

Public["okturtles.slack.com"] = handler.permissive

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
                      {"^https://github[.]com/.+/.+/issue_comments$",
                       "^https://github[.]com/.+/.+/pullrequest_comments$",
                       "^https://avatars[%d]+.githubusercontent[.]com/",
                       "^https://assets[-]cdn[.]github[.]com/assets/",
                       "^https://raw[.]githubusercontent[.]com/"
                      })
end

Public["xkcd.com"] = function(info, result)
   handler.everywhere(info, result,
                      {"^https?://imgs[.]xkcd[.]com/comics/.+[.]png$",
                       "^https?://imgs[.]xkcd[.]com/s/.+[.]jpg$"
   })
end

Public["&about:blank$"] = handler.permissive

Public["stackoverflow.com"] = function(info, result)
   handler.everywhere(info, result)
   bland_info(info, {["^http://cdn[.]sstatic[.]net/stackoverflow/all[.]css"] = "s"})
end

Public["fileformat.info"] = function(info, result)
   handler.everywhere(info, result, {"^https?://emoji[.]fileformat[.]info/gemoji/.+[.]png$"})
end

Public["firstlook.org"] = function(info, result)
   handler.everywhere(info, result,
                      {"^https?://prod[%d]*-cdn[%d]+[.]cdn[.]firstlook[.]org"
   })
   
end

Public["www.reuters.com"] = function(info, result)
   handler.everywhere(info, result,
                      {"^s[%d]?[.]reutersmedia[.]net",
                       "^https?://cdn[.]betrad[.]com/pub/icon[%d]?[.]png$"
   })
end

Public["www.wsj.com"] = function(info, result)
   handler.everywhere(info, result,
                      { "^https?://asset[.]wsj[.]net" })
end

Public["www.rollingstone.com"] = function(info, result)
   handler.everywhere(info, result,
                      { "^https?://asset[.]rollingstone[.]com" })
end

Public["www.bloomberg.com"] = function(info, result)
   handler.everywhere(info, result, "^https?://assets.bwbx.io")
end

Public["bitbucket.org"] = function(info, result)
   handler.everywhere(info, result, "^https?://[%w]+[.]cloudfront.net/.+[.]css$")
end

Public["twitter.com"] =  function(info, result)
   handler.everywhere(info, result, "^https?://abs[.]twimg[.]com/a/.+")
end

Public["arstechnica.com"] = function(info, result)
   handler.everywhere(info, result,
                      "^https?://cdn[.]arstechnica[.]net/wp-content/themes/arstechnica/assets/css/")
end

Public["fsf.org"] = function(info, result)
   handler.everywhere(info, result, "^https?://static[.]fsf[.]org/")
end

Public["developer.mozilla.org"] = function(info, result)
   handler.everywhere(info, result,
                      "^https?://developer[.]cdn[.]mozilla[.]net/media/css/.+[.].css")
end

Public["archive.is"] = function(info, result)
   handler.everywhere(info, result,
                      "^https?://archive.today/")
end
Public["archive.today"] = function(info, result)
   handler.everywhere(info, result,
                      "^https?://archive.is/")
end

Public["amazon.com"] = function(info, result)
   handler.everywhere(info, result,
                      { "^https?://z-ecx[.]images-amazon[.]com",
                        "^https?://images-na[.]ssl-images-amazon[.]com" })
end

Public["boingboing.net"] = function(info, result)
   handler.everywhere(info, result,
                      "^https?://media[.]boingboing[.]net")
end

Public["www.indiegogo.com"] = function(info, result)
   handler.everywhere(info, result,
                      "^https?://g[%d]+[.]iggcdn[.]com/assets/.+[.]css$")
end

return Public
