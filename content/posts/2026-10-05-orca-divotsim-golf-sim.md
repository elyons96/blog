---
title: "Agents On the Go: Orca, Opencode, and the Start of DivotSim"
date: 2026-10-05T12:30:00Z
draft: false
tags: [orca, opencode, agents, worktrees, golf-sim, divotsim, mobile]
summary: "How I set up Orca to manage my AI agents across workspaces and from my phone, and how I'm using opencode inside it to start building DivotSim — a golf simulator project."
---

## The Problem: Agents Trapped on One Machine

My AI agent workflow kept hitting the same wall: a session tied to one terminal on one machine means I can only check on or steer an agent when I'm sitting at that desk. If I kick off a long-running coding task and then leave the house, I'm either waiting until I get back or SSHing in from my phone and squinting at a tmux pane. Neither is great.

Orca solves this by managing agent work as **worktrees** — isolated, git-backed workspaces that Orca tracks independently of any single terminal session. An agent (Claude Code, Codex, opencode, whatever) runs inside a worktree, and Orca gives me a consistent interface to spawn it, read its terminal output, send it input, and hand it off to another agent — all without caring whether I'm at my desk or on my phone.

## Setting Up Orca for Multi-Workspace Agents

The pieces that matter:

- **Folder contexts and worktrees** — instead of running agents loose in my main repo checkout, Orca spins up a child worktree per task. Each agent gets its own isolated branch/directory, so parallel agents never step on each other's uncommitted changes.
- **Managed terminals** — Orca owns the PTY for each spawned agent session. I can read what's happened in a terminal, wait on it, or send it new input from any client talking to Orca, not just the one that started it.
- **Mobile access** — because Orca itself is the thing holding session state (not my terminal emulator), I can check in from my phone, read what an agent did while I was away, and steer it with a new instruction, then close the app. The agent keeps going; Orca keeps the connection.
- **Handoff between agents** — when one agent's work needs a different tool or a fresh perspective (e.g., a coding agent hands off to a review agent), Orca supports that as a first-class operation instead of me manually copying context between sessions.

This turns "my agent workflow" from "a terminal I have to keep open" into "a set of durable workspaces I dip into from whatever device is in my hand."

## Running Opencode Inside Orca

Inside these Orca-managed worktrees, I've been running **opencode** as the actual coding agent — it's the one doing the file edits, running builds, and iterating on code inside the isolated worktree Orca hands it. Orca doesn't replace opencode; it's the harness around it: spin up the worktree, launch opencode in it, and give me a channel to watch and interject regardless of where I am.

The combination gives me:

- A clean, disposable worktree per feature/experiment, so opencode can go off and make a mess without threatening my main branch.
- The ability to glance at progress from my phone between meetings, instead of babysitting a terminal.
- A spot to hand off to a different agent (or back to me) once opencode's part of the job is done.

## First Real Project: DivotSim

With the setup proven on smaller tasks, I pointed opencode-in-Orca at something I actually want to exist: **DivotSim**, a golf simulator software project. The goal is a from-scratch attempt at simulator software — the kind of thing that normally means wrestling with physics for ball flight, course/overlay rendering, and hardware input from a launch monitor or camera system.

Why this project is a good stress test for the Orca + opencode setup:

- **Long-horizon and iterative.** Golf sim physics and rendering aren't a one-shot task — it's a project that benefits from an agent working in long, semi-autonomous stretches inside its own worktree while I check in periodically rather than babysit every step.
- **Lets me validate mobile steering for real.** Golf sim development has clear, visually/numerically checkable milestones (does the ball flight model feel right, does the overlay render), which makes it easy to review progress and redirect from a phone between other things.
- **Isolated risk.** It's a greenfield project in its own worktree — perfect for letting opencode experiment aggressively without any chance of touching work that matters elsewhere.

It's early — right now DivotSim is still in the "get the core simulation loop stood up" phase — but the point of this post is the infrastructure, not the finished product: I now have a setup where an agent can grind on a genuinely hard, multi-week build, and I can check on it and redirect it from wherever I happen to be, not just from my desk.

I'll follow up with a dedicated DivotSim post once there's something worth looking at — ball flight physics, a rendered course, or at least a demo that doesn't immediately crash.
