I've nothing exciting to write about so I'll share a prank I did a few years ago (because I'm kinda proud of this one).

To protect the innocent, I'll change all the names.

I was working at a company named $LF. One of my colleague ($NG), always looks at his keyboard when he types. Some time he can type for a few minutes. Then he looks at his screen, only to realize that it's full of typo, or worse, that he had typed in the wrong window. This used to really bother me, because I know he's been typing for years, but I was not sure if he was looking at his keyboard because he needs to, or just because his head is too heavy to look at the screen.

So one day, while everybody (except $GM) were away taking a break, I decided to conduct an experiment.

The french keyboard uses the [AZERTY](http://en.wikipedia.org/wiki/Azerty) layout. $NG uses the [best editor in the world](http://www.gnu.org/software/emacs/), where the *x* key is *really* important (try to do something without 'Meta-x'). He also uses a laptop, connected to an external monitor and with an external keyboard. So I decided to swap the *x* and the *w* letter on the external keyboard, by switching the caps. The actual *x* and *w* were still at the same place, only the label on the key was switched.

When he came back from the break, he starts typing as usual. Quickly he realized that something was wrong, and he did a lot of things to figure out what. Among them:

-   verify that the content of `xmodmaprc` was correct, and then tweak it
-   reinitialize the layout with `setxkbmap`
-   use a tool (maybe `showkey` ?) to see what was the actual code send from the keyboard while hitting the key
-   probably recompiled a bunch of stuff
-   definitely upgraded his Linux distribution

At this point, he understood that when hitting *x*, *w* was received, and for *w*, *x*. He rebooted his laptop (because when in doubt, you should "[tried turning it off and on again](http://www.youtube.com/watch?v=nn2FB1P_Mn8)"). But the problem was still there.

If I remember correctly, that's when he decided to look at the laptop's keyboard and tried to use it, only to realize that it was working correctly! So he asked the ops guy, $GM, who was sitting next to me, if there was a spare keyboard somewhere. I slowly turned my head toward $GM, whispering 'noooo' to him, and he replied to $NG "nop, sorry, no spare keyboard, ".

The other developers started to realize that something was wrong with $NG, but no one said or did anything yet. We were about 30 minutes in the experiment now.

Because he still had work to do, he tried to cop with the problem, and every time he needed a *x* or a *w*, he would type something, stop, look at the screen, sigh/grumble, and use the laptop's keyboard to fix all the *w* and *x*. That was difficult to miss, and soon other people asked him what was wrong, and so that's when I revealed .

When I explained what I did he was surprised, starred at the two keyboards for a while, and saw that, effectively, the keys were swapped! I'm pretty sure the rest of the team made fun of him but I don't really remember exactly how.

I consider the experiment to be a success: I proved that he need to look at his keyboard to type, and I'm also confident that I can reproduce it with the same subject multiple time and obtain the same result again.
