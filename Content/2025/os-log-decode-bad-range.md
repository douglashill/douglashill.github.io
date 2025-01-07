title: `decode: bad range` with `os_log_with_type`
description: Today’s weird low-level issue: Calls to `os_log_with_type` will log `<decode: bad range for [%{public}@] got [offs:318 len:1238 within:0]>` if the message has a length from 966 to 1989. The workaround is to [split the message in two]().
date: 2025-01-07T16:44:36+0000
%%%

Today’s weird low-level issue: Calls to

```
os_log_with_type(logger, level, "%{public}@", message);
```

will log

```
<decode: bad range for [%{public}@] got [offs:318 len:1238 within:0]>
```

if the message has a length from 966 to 1989. The workaround is to split the message in two:

```
let length = message.length;
if (length >= 966 && length < 966 + 1024) {
    os_log_with_type(logger, level, "%{public}@%{public}@", [message substringToIndex:length / 2], [message substringFromIndex:length / 2]);
} else {
    os_log_with_type(logger, level, "%{public}@", message);
}
```
