---
layout: post
title: Talking about technology at conferences or meet-up.
summary: In which I particularly enjoyed a talk from MesosCon, and hope to see more like this one
---

I'm more and more annoyed by how the tech community is super enthusiastic about new pieces of
technology, and how hard they try to convince you it's the best next thing in the world. Way too
often, at conferences or meet-ups, the talks tend to glorify a product or a technology, and only
focus on how it will make your life easier. It's too common to have someone do a demo on stage on
how to build, in 5 minutes, a trivial application running with X many instances in a container in
the cloud and be like "see how easy it was !?".

What will not be mentioned is how your team is going to transition to this technology or
infrastructure; what are the traps hiding; what will not work; what are the real limitations (can it
scale to more than 10 instances ? 100 instances ? 10k instances ?); how do you manage it in your
data-center; in your cloud; how easy is it to debug;  what are the current issues that people running
it in production have met; what's the worst case scenario for an incident; how long can it take to
recover; and way too many other things.

Over the last few days, I binge-watched many of the
[MesosCon](https://www.youtube.com/playlist?list=PLVjgeV_avap2arug3vIz8c6l72rvh9poV)'s' videos. One of the
talk I really enjoyed was by [Joseph Smith](https://twitter.com/Yasumoto). In [his
talk](https://www.youtube.com/watch?v=nNrh-gdu9m4&index=8&list=PLVjgeV_avap2arug3vIz8c6l72rvh9poV),
he shared about various ways Mesos and Aurora failed at Twitter.

Joseph's talk was the opposite of what I described earlier. He mentioned at length issues and
problems we've encountered running Aurora. Some of the issues he explored were recent (from a couple
of weeks ago); some were pretty old and are fixed by now; and also what would be the worst case
scenario that could happen. This is exactly what I want to hear when someone introduces a piece of
technology. I need to be aware of them. It doesn't mean that I'm going to be scared and will not use
it.

I believe this is important. The public who come to a talk is, most of the time, here to learn about
a piece of technology. They might have some prior knowledge, but most of them don't. They want to
learn what can be done with it; how to use it; how it's an improvement. But more importantly, we
need to talk about the cost and path to adopt the piece of technology. Going from a simple demo
running on 2 hosts to a something running on production with hundred of thousands of users and on
thousands of instances is a different story.

And yes, these could be questions asked by the public at the end of the talk. But not everybody
feel comfortable asking them out loud in front of their peers.

I feel the same way about post-mortems. Companies should share them more frequently. Some companies
are [pretty good about it](https://github.com/danluu/post-mortems). I can understand, if your
product is not a service for developers, that you might not want to share them on your blog to not
scare your users. But we should still share them during conferences. Maybe there's even an
opportunity for a meet-up focused on post-Mort em ?

Talking about issues and how difficult it might be to adopt something is not doing is disservice to
something you really enjoy working with.