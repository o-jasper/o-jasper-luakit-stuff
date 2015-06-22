# Info-function sorting by importance.

`Class.maybe_new(args)` may or may not create a new instance.(really low priority,
it just doesnt make a new one)

Currently, basically only `:priority()` indicating a priority. Want to have
importance-based-on-context. I.e. image-viewing, the image has high importance,
file-viewing, it just shows as filename.(maybe tiny-fied version)

If there are dditionally requires paged-chrome interfacing to make html of entries.
(sorted and selected by priority.
