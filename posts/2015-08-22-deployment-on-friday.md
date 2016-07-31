There's a lot of reasons to not deploy code to production on a Friday. If something goes wrong, you
might end up spending your Friday night, or worst, your entire weekend, fixing some issue. But
there's no reasons Friday should be different from any other day. It's not OK to spend a night
during the week fixing an issue in production.

To be in a place where you can deploy code at any time requires a few things: tools, automation and
culture.

In my team, every body is on call: SWEs and SREs. We all share the same responsibilities. There's no
rule saying that deploying on Friday is forbidden. We don't do continuous deployment, and we also
don't have a schedule saying which days of the week we deploy.

Artifacts are build by our build system and pushed to some archives. We don't deploy artifacts that
we build on a developer laptop.

Before deploying an artifact to production, we usually run it as a a canary on some shards.
Depending of the service, it can be for a few hours up to a couple of weeks. Once we are confident
in this artifact, after reviewing our dashboards, we know it's going to be safe to deploy it.

We communicate with the team (and outside the team) before doing a deployment. A deploy starts with
a ticket in Jira, saying what we are going to deploy, how long it will take, and what are the steps
to validate, and do a rollback. At least one another person need to  review the ticket and give his
consent. If that person has some concerns, the deploy is pushed back, and we figure out what's
wrong. On-call has to ACK the procedure before starting too.

Our deployments are hooked with our alerts. If something goes wrong, the deployment is paused, or
roll backed.

Once it becomes easy to build test deploy and rollback, then there's no reasons to not deploy code on
Friday.
