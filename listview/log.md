**NOTE not sure**

# Log/message system
A log system keeps tracks of messages. Messages can come from anywhere. Could be
chats, emails, errors, "feed your cat", WARNING REACTOR OVERHEATING.

Systems that can enter messages can indicate things like:

* Time `time` used as identifier, `claimtime`, `re_assesstime`.
* The `kind` of message and where it `origin`ated.
* `title`, `description`, `tags`, and `uri`.
* `data`, `data_uri` priority in `datatags`


It will follow the principle of "good defaults, fully user-definable". Priority
might not be taken at face value. Basically the user/defaults determine what
things look like, if you want that, you have to define the priorities properly.

Users will have filters so they can view the relevant messages.

#### Priorities in `tags`
These are to-be-interpreted strings, you may have a list of them.
Users may write functions that look into the entries themselves to determine
priority.

`warn` shows up interrupting the user. Only critical things.

`blip` may have a notifier show up. (doesnt imply)

`blip0[.][%d]+` fraction-of a `blip`. When enough accumulates, a notifier shows up.

`envelope` will make the indicator that a log entry came in go on. Implied by `warn`
`envelope0[.][%d]+` again does fractional ones.

`show` shows up in the default message-list the user is looking at. Implied by
`warn` and`envelope`.

`show_dt=[%d]+[.]*[%d]+` shows in the list for some amount of time.

`delete` delete it. Implies not the above.

`hide` hide unless the user indicates to see it.

`done`, `todo`

`slowlane` might indicate you dont want to search or update it often in any way.
Might put that on another table?

Perhaps these will be prepended by something indicating their use.

### Log kinds

`entry.kind` is the kind name. The kind itself is kept in `log_log[kind]` should
have. `kind.name`, `kind.title`, `kind.tags`, `kind.description`, `kind.url`

And it should return something changing internal values with `kind.assess(entry_data)`.

Note that you might want to just use `data_uri` to refer to stuff in your own 
storage system.

### Log entries

`enter(kind, from, data, data_uri, uri, title, description, tags)` enters an entry into the
system.

Makes a html display, may use the log chrome environment, first arg reserved.

    entry.html_list_el(reserved)

(Optional)

    entry.text_list_el(reserved)

All other data will be done by the logging system. I dont want it possible to
cheat and store something different in the DB than you claim.

Claim a it has some priority. The user/default may not adopt it.
(even if not adopted it may use the output)

    entry.priority()

Re-assess self. Result may not be adopted if user overrides.

    entry.re_assess()

URL to for instance a `luakit://` page.

    entry.url()
