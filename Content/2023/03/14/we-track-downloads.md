date: 2023-03-14T18:05:46+0000
tweet: 1635703788211142676
%%%

We track downloads with `Progress` (`NSProgress`) and add that as a child of the `Progress` shown in the UI. Trouble is, `Progress` can only be added a child once, but the user can pop and push UI many times while downloading. Wondering if this is just not appropriate use of `addChild`.
