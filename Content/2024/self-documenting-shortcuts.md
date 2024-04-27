date: 2024-04-27T09:41:57+01:00
%%%

Trying to write self-documenting ‘code’ in Shortcuts by using clear variable names. This is just to disable a thing, which I think is very common in programming, but it’s so cumbersome. Hoping we get a Swift environment for Shortcuts at some point.

![Screenshot of iPad Shortcuts app with the following steps: Comment: “While ‘Delete folder if empty’ does in fact delete the folder, the ‘Run Shortcut’ action then fails with ‘Couldn’t communicate with a helper application’, which prevents *this* shortcut from running further. Therefore disable this cleanup. (It’s also annoying having to confirm the deletion every time.)”; Text: “false”; Set variable “Enable Empty Folder Cleanup” to “Text”; If “Enable Empty Folder Cleanup” “is” “true”; Get file from “Content” at path “Path/”; If “File” “has any value”; Run “Delete folder if empty”; End If; End If](self-documenting-shortcuts.png)
