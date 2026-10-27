---
title: "Standing Up Paperclip: My First Agent Dashboard on the Tailnet"
date: 2026-10-05T12:00:00Z
draft: false
tags: [paperclip, agents, tailscale, automation, devops]
summary: "Setting up Paperclip as a control plane for my AI agents and shipping a first project: a simple status dashboard live at http://dash on my Tailscale tailnet."
---

## Why Paperclip

I've been running more and more work through AI agents, but coordination was ad hoc, scattered terminal sessions, no shared record of what any agent was doing, no way for one agent to hand work to another. Paperclip is the fix: it's a control plane for task coordination and governance between agents. Think of it as a lightweight project-management layer, except the "employees" picking up tickets are AI agents running in short execution windows called **heartbeats**.

Each heartbeat an agent wakes up, checks its assigned issues, does real work, leaves a comment or status update, and exits. No agent runs continuously, Paperclip wakes them on triggers: a new assignment, a comment, an approval decision, a scheduled monitor. That model maps cleanly onto how I actually want to work with agents: fire off a task, let the agent own it end-to-end, come back later to a clear record of what happened.

## The Setup

The core pieces:

- **Paperclip API** running locally at `http://127.0.0.1:3100`, backed by a company (`mtnLyons.dev`) and at least one registered agent identity.
- **Agent credentials**, each agent run gets `PAPERCLIP_AGENT_ID`, `PAPERCLIP_COMPANY_ID`, `PAPERCLIP_API_URL`, and a short-lived run JWT injected automatically. No hardcoded API URLs, no keys pasted into prompts.
- **Hermes as the agent runtime**, my existing Hermes gateway agent (`Hermes`) is the one actually picking up and executing Paperclip issues, authenticated via `Authorization: Bearer $PAPERCLIP_API_KEY` against `/v1/runs` on the gateway's own API server.

Everything in Paperclip revolves around issues (aka tasks, the UI says "task," the API still says "issue," same thing). An agent checks out an issue, works it, and must land in an explicit final state before the heartbeat ends: `done`, `in_review` (waiting on a real reviewer or scheduled monitor), or `blocked` (naming exactly who needs to act). No leaving things in limbo with a comment that says "someone should check this", if there's no live path back to the issue, that's treated as an invalid disposition.

The governance model is the part I like most: issue-thread interactions (confirmations, checklists, structured questions) give agents a real way to ask for a decision instead of improvising a yes/no in prose, and approvals gate anything with real-world consequences, spend, deployments, hiring. It's a surprisingly complete little bureaucracy, built for a non-human workforce.

## First Project: A Status Dashboard

To prove the loop end-to-end, assign a project, let an agent build it, verify the result, I had an agent stand up a small dashboard page. Nothing fancy: a single-page status view, served as a static site, reachable only from inside my Tailscale tailnet.

The result is live at **`http://dash`** on my tailnet. No public exposure, no port-forwarding, no TLS cert juggling, Tailscale's MagicDNS resolves the hostname across every device on the tailnet, and the dashboard container just needs to listen on the right interface.

What made this a good first project:

1. **Small, verifiable scope.** A dashboard page is easy to check with my own eyes, either it loads and shows real data, or it doesn't.
2. **Real infrastructure, low blast radius.** It touches networking (Tailscale), a running service, and a build step, without needing production credentials or customer-facing risk.
3. **Clear definition of done.** "Reachable at `http://dash` and showing live status" is unambiguous, exactly the kind of crisp final-disposition check Paperclip's workflow pushes agents toward.

## What's Next

Now that the loop works, issue assigned, agent picks it up, works autonomously inside a heartbeat, reports back with a verifiable artifact, I'm comfortable handing Paperclip bigger things. Next up is wiring in more agents with distinct roles (a "reviewer" agent that just evaluates other agents' work, scheduled routines for recurring maintenance) and letting the dashboard grow from a single status page into an actual overview of everything running on the tailnet.
