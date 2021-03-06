This conversation happened twice in the last few weeks at work, the first time during my 1:1 with my manager, and a second time with the whole team.

We were investigating [Riemann](http://riemann.io/), and we started to discuss what it would means to adopt this technology in our stack. Riemann is written in Clojure, and no one at work is really familiar with this language (except for me, and I'm don't consider myself efficient with it).

The question is how do you deal with a new tool when there's only one person in the team that can read the code, and therefore contribute to the project to add features, fix bugs, etc. Are we supposed to be familiar with the code of the things that we use?

I've never read the code of MySQL, I've read parts of Apache's code, and I've never looked at the source of the Linux' kernel. At the same time, I usually read the code of the Perl and Python libraries I use frequently, I've also read the source of statsd and Graphite (two other tools that we looked at) in order to understand what they do and hunt for issues (in the way we use them) or bugs.

I see two ways to approach this question so far: as a developer and as a user. As a developer, I consider that I **have to** read and understand the code of the libraries my code depends on (we've found some serious issues in libraries we use daily because of this approach).

For services we use in the infrastructure, it depends of the size of the tool and it's community. For a new product, or when the documentation is too sparse, or when the community is rather small, it's a good thing to be able to look at the code and explain what it does. For bigger projects (MySQL, Apache, Riak), so far I've relied on the experiences people had with the tools, the community.

I'll conclude this post with an anecdote. Last Thursday we were trying to understand why the CPU load on the Graphite's box went over the roof when we added about 25% more metrics to it. With Abe and Hachi we said "ok let's dig into this problem". You could have guessed who are the ops while looking at the scene. We were looking for the same things: reads and write. Abe and Hachi started to do that with the help of `strace`, while I started to walk through the code. I think the two ways are valid, at least you can use one to correlate the other, and they gave you different information (`strace` will help you to time the operations, while the code would explain what you're writing and reading).

I'm curious to hear how other approach this problem.
