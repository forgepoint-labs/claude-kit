# Week 1: Install Claude Code and run your first agentic session

## Audience

You. Solo ForgePoint operator.

## Time

About 2 hours: 30 minutes prep, 45 minutes walkthrough, 45 minutes exercise.

## Objectives

By the end of this week you can:

1. Run `claude` in any repo and have a productive session.
2. Generate a starter `CLAUDE.md` with `/init` and recognize what belongs in it.
3. Switch between **plan mode** and **acceptEdits mode** deliberately.
4. Capture one concrete improvement idea for your daily flow.

If you can already do all four, do the exercise anyway and skip ahead to Week 2 next session.

## Prereqs

* macOS, Linux, or Windows with WSL2.
* A Claude account on a paid plan (Pro at minimum, Max recommended for this curriculum because Auto mode and Agent Teams require it).
* Git, Node 22+ installed.
* One ForgePoint repo cloned locally to use as the practice target. The `forgepoint-labs/website` repo is a good first target.

## Prep (30 min)

1. Install Claude Code from the [download page](https://code.claude.com).
2. Run `claude --version` to confirm it's on PATH.
3. Run `claude` once to authenticate. Pick the right account and confirm the model is Sonnet 4.6 or Opus 4.6+ in the status line.
4. Open the `forgepoint-labs/website` repo in your editor of choice and have a separate terminal pointed at the same directory.

## Walkthrough (45 min)

### Step 1: Open a session in your target repo

```bash
cd ~/Desktop/PARA/2\ Areas/work/career/forgepoint/website
claude
```

You should see Claude land in the repo and report a few things it noticed about the project. If it doesn't, run `/help` to confirm the session is healthy.

### Step 2: Run `/init`

```text
/init
```

Claude scans the codebase and proposes a starter `CLAUDE.md`. **Do not accept it blindly.** Read it, decide what belongs and what doesn't.

A good first CLAUDE.md includes:

* Build, test, lint, and deploy commands you actually use.
* Code style rules that differ from defaults.
* Branching and PR conventions.
* One or two architectural decisions Claude can't infer from code.

Cut anything that's:

* Standard for the language or framework (Claude already knows).
* Likely to change weekly (CLAUDE.md is committed; that's a maintenance tax).
* Pasted from a stale README.

Save the trimmed version. Commit it on a feature branch.

### Step 3: Switch into plan mode

In the running session, hit **Shift+Tab** until the status line shows `plan`.

Ask Claude:

```text
Plan how you would add a /uses page to this site that lists the tools, services, and gear ForgePoint relies on. Don't write any code yet.
```

Read the plan. It will propose files, components, and a rough sequence. If something is wrong, tell Claude what to fix and it will replan.

### Step 4: Switch to acceptEdits and execute one step

Hit **Shift+Tab** again until you see `acceptEdits`. Pick one small piece of the plan and have Claude execute just that piece. Watch what files it touches.

When Claude finishes, run:

* `npm run lint`
* `npm run build` (or whatever the repo uses)

If anything breaks, ask Claude to fix it. Don't hand-fix unless Claude is stuck.

### Step 5: Wrap up the session

Run `/cost` (API users) or `/stats` (subscription users) to see what you spent. Note the number; it's your first data point.

Type `/clear` to end the session cleanly.

## Exercise (45 min)

Pick one small task in `forgepoint-labs/website` that you've been putting off. Examples:

* Fix the favicon set across light and dark mode.
* Wire up a simple contact form that hits a Formspree or Resend endpoint.
* Add a `/changelog` page that reads from `CHANGELOG.md`.
* Audit the README for accuracy.

Constraints:

* Do the entire task with Claude. Use plan mode first, acceptEdits to execute, run the build to verify.
* Open a real PR. Use the conventional-commit format (`feat(scope): ...`).
* Capture one thing you'd change about your CLAUDE.md based on what you saw Claude get wrong.

## Done when

* [ ] `CLAUDE.md` is committed to a feature branch in your target repo.
* [ ] You ran a session in plan mode and switched to acceptEdits at least once.
* [ ] One real PR is open against the repo.
* [ ] You wrote one CLAUDE.md improvement idea in your journal.

## Reflect

Capture quick answers in your journal:

1. What did Claude get wrong that surprised you?
2. What command or interaction felt slow or awkward?
3. What's the one thing you want to learn next?

These feed into Week 2 (CLAUDE.md and skills) and the Week 12 retrospective.

## Resources

* [Claude Code quickstart](https://code.claude.com/docs/quickstart)
* [Permission modes reference](https://code.claude.com/docs/permissions) for the difference between `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, and `bypassPermissions`.
* `docs/glossary.md` in this repo for plain-English definitions of every term you'll encounter.
