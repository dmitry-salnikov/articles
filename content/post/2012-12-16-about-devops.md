---
date: 2012-12-16T00:00:00Z
title: About DevOps
---

There's a lot of talk about what is or what is not DevOps, and I'll
throw my opinion in the mix.

Until a few weeks ago, at [work](http://saymedia.com), we had mostly
two teams: the engineering team and the ops team.  Our workflow was
(to simplify) the following:

 * engineers develop services and applications
 * they push their change to Jenkins
 * a build pass and is pushed to CI
 * a few times a week, engineers ask Ops to push the change to
   production

There's already a lot of articles about the kind of frictions created
by this (who owns what; engineers would blame ops when the push was
failing (or the other way around); it's hard for ops to know what's
wrong when something is broken in production; etc).

A few weeks ago it was decided to create a new team to improve
engineers efficiency, and the team was named "DevOps".  At first I was
not sure it was the right name for this team, but now I don't think it
matters.

I was not sure the name was appropriate because of this 
[article](http://continuousdelivery.com/2012/10/theres-no-such-thing-as-a-devops-team/)
(and a few other to respond), explaining why you don't want a DevOps
team, but instead you want the whole organization to be DevOps.  We
need engineers to own their applications, to be able to push when they
want, but also to monitor, know what's wrong or slow, etc.

The **work** [hachi](https://github.com/hachi) and I will have to do is to
help engineers and ops to *be* the DevOps.  Our team responsibility is
to choose, evaluate and integrate tools.  We will also provide
libraries, documentation, training and support.  *We* are not the
DevOps.  Our **goals** are to create this culture, to give more
responsibilities to engineers, and to free Ops from the work of
pushing code.  The **success** of this team will be measured by the
adoption of our work by engineers and ops.

So yes, I agree that you don't want a dedicated DevOps team, but you
still need a team coming from different background (hachi is coming
from Ops and I'm an engineer) to build that culture.
