---
date: 2009-06-17T00:00:00Z
summary: In which I path xmobar for Debian SID
title: xmobar on debian SID
---

If you are using [xmonad](http://www.xmonad.org/) and [xmobar](http://projects.haskell.org/xmobar/) on [Debian SID](http://www.debian.org/) on a laptop, and don't see any battery information, you may have test this [solution](http://5e6n1.wordpress.com/2009/03/30/xmobar-battery-plugin-using-sysfs-not-procfs/).

If this didn't solve your problem, try this patch on SysfsBatt.hs :

```diff
52c52
<     let path = sysfsPath ++ p ++ "/charge_full"
---
>     let path = sysfsPath ++ p ++ "/energy_full"
62c62
<     let path = sysfsPath ++ p ++ "/charge_now"
---
>     let path = sysfsPath ++ p ++ "/energy_now"
74c74
<     else showWithColors (printf "%.2f%%") stateInPercentage
---
>     else showWithColors (printf "Batt: %.2f%%") stateInPercentage
```

Then as before:

```bash
% runhaskell Setup.lhs configure --user
% runhaskell Setup.lhs build
% runhaskell Setup.lhs install --user
```

Battery information should be visible.
