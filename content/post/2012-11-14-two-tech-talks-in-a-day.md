---
date: 2012-11-14T00:00:00Z
summary: In which I write a summary for two tech talks.
title: Two tech. talks in a day
---

Today I assisted to two tech. talks.  One of them was our "Reading Group" session at lunch and the second one was the Python meetup tonight.

## Say's tech talk

I'm trying to organize at [work](http://saymedia.com), every two weeks during lunch time, a session where engineers can discuss about an article, tool, or paper they find interesting.  Today we were a very small group (only 4 peoples), and we talked about two tools that [Masa](http://sekimura.typepad.com/blog/) wanted to explore: [Kage](https://github.com/cookpad/kage) and [HTTP Archive](http://www.igvita.com/2012/08/28/web-performance-power-tool-http-archive-har/).

### Kage

We talked about Kage first (kah-geh means "shadow" in Japanese).  Masa started to explain what was the goal of the tool and how it works.  Basically, it's a proxy that will send your HTTP request to your production and stage environment.  The basic [example](https://github.com/cookpad/kage/blob/master/examples/proxy.rb) show how easy it is to write a simple proxy with a few rules to dispatch only your GET request to your two environments, and then compare the payload returned.

It's using [em-proxy](https://github.com/igrigorik/em-proxy/) which is a DSL to write proxy for EventMachine.  We then discussed where we could use it in our architecture and what benefit we could get from it, but for now we don't have any plan to use it.

### HAR

Then the second thing we talked about what HAR.  You can find more detailed information on [Ilya's blog](http://www.igvita.com/2012/08/28/web-performance-power-tool-http-archive-har/) and on this [gist](https://gist.github.com/3500508).  To summarize, HAR is an HTTP archive [format](http://www.softwareishard.com/blog/har-12-spec/).  When you use the developers tools in Chrome, you can see the request and their response time, but you can also save this information in the HAR format.

There's a few tools then to analyse this data, like YSlow, or browse them with the HARviewer.  Another interesting thing is that you don't have to use a browser to get them, you can use [Phantomjs](http://phantomjs.org).  Masa and Kyle talked about it and if they could use that with Nagios, or with Jenkins to measure the response time.

## SF Python Meetup

The last talk of the day was the [SF Python Meetup](http://www.meetup.com/sfpython/) after a 4 or 5 months break, at the Yelp headquarter.  We were supposed to have some lightning talks to start, but we only had one, from someone who think that "lightning talk" means "publicity for Google and ho by the way, we're hiring" (yeah like no one in the room knew that ...).

Then David Schachter presented [How to Speed Up A Python Program 114,000 times](http://www.rtortell.com/SF_Python_Meetup_slides_public.pdf).  He showed us how he improved the performance of a script by 114,000 times.  I will start by saying the talk was interesting and that David was an entertaining speaker.  He went through some optimization he used, like using multiprocessing modules, [cython](http://cython.org), and some more difficult optimization he was not able to get from cython (like the permuted vector code).

He had a very strong opinion about cluster and I really disagree with him.  One of his complains was that cluster are hard, are young, and we don't have any tools, so we should not use them.  But we've been using cluster in universities and laboratories for years now.  Even if the tools are still not very great, they exist, and they work.  And more importantly to me, the fact that he spend 12 weeks on optimizing his program, and doing stuff that I would not be able to do, he proved that optimizing is *also* very hard, and that doesn't seem easier to me that using a cluster.

All in all, that was a good day, and I learned new things.  Now I need to find a subject for our next reading group session.

