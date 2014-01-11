---
layout: post
summary: In which I path xmobar for Debian SID
title: xmobar on debian SID
type: codex
---

If you are using [xmonad](http://www.xmonad.org/) and [xmobar](http://projects.haskell.org/xmobar/) on [Debian SID](http://www.debian.org/) on a laptop, and don't see any battery information, you may have test this [solution](http://5e6n1.wordpress.com/2009/03/30/xmobar-battery-plugin-using-sysfs-not-procfs/).

If this didn't solve your problem, try this patch on SysfsBatt.hs :

{% highlight diff %}
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
{% endhighlight %}

Then as before:

{% highlight bash %}
% runhaskell Setup.lhs configure --user
% runhaskell Setup.lhs build
% runhaskell Setup.lhs install --user
{% endhighlight %}

Battery information should be visible.
