# Info-function sorting by importance.

`Class.newlist(args)`, if exists, can return a list of new infofun objects.
`nil` is interpreted as `{}`. `args.creator` contains the creator, and
`args.e` contains the entry as provided.

`Class.newlist` does not exist, `{Class.new({ creator = creator, e=entry })}`
is used.

Otherwise `:priority()` indicating a priority. Want to have
importance-based-on-context. I.e. image-viewing, the image has high importance,
file-viewing, it just shows as filename.(maybe tiny-fied version)

## Use is listview
*Listview* additionally requires a `:html(state)` method. Currently does not
support javascript.
