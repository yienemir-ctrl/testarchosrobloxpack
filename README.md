# Byte Rush - ArchOS Roblox + Vercel + GitHub

Byte Rush is a 15-round mini-game with Math and Sequences modes. This package includes a playable static website, an ArchScript source file for **ArchOS Code inside the user's Roblox ArchOS**, and Windows scripts for publishing.

## Ready-to-run commands (Windows CMD)

1. Unzip the package to a folder.
2. Open **CMD** in that folder. You can type `cmd` into File Explorer's address bar.
3. Run:

```bat
DEPLOY.bat
```

Or double-click **DEPLOY.bat**. The script detects the folder, creates a local Git repository if needed, connects it to `https://github.com/yienemir-ctrl/testarchosrobloxpack.git`, commits any changes, handles an existing `main` history, pushes to GitHub, and runs Vercel CLI for production web deployment.

**Prerequisites:** Git for Windows; Node.js LTS (which includes `npx`) **or** an already installed Vercel CLI. Git and Vercel login may require a one-time interactive browser authentication. The script does not store tokens, passwords, or secrets. Git commit author info is requested if not already configured. Running it again publishes later changes.

**Important:** When Vercel first asks which project to use, choose a **new Byte Rush project**, not the existing `site-five-drab-14.vercel.app` ArchOS documentation website. This package deliberately does not overwrite the existing ArchOS website. Actual Vercel permissions and a signed-in account are required.

## GitHub

Target repository: https://github.com/yienemir-ctrl/testarchosrobloxpack

The BAT does the equivalent of:

```bat
git init
git add -A
git commit -m "Update Byte Rush ArchOS app and web preview"
git branch -M main
git remote add origin https://github.com/yienemir-ctrl/testarchosrobloxpack.git
git push -u origin main
```

It also checks for an existing `origin` and existing GitHub history so repeat runs are safer. It will not silently overwrite a different GitHub remote.

## Deploy to Vercel

`index.html` is the deployable web game at the project root. `vercel.json` enables a static website. `DEPLOY.bat` runs the Vercel CLI (`vercel deploy --prod --yes` or `npx --yes vercel deploy --prod --yes`) after a successful GitHub push.

The public URL is printed by Vercel on successful deployment. No Vercel URL can be promised before a deployment actually succeeds.

## Install in Roblox ArchOS

The Roblox native app is **not** installed by pushing a website to GitHub or Vercel. In the linked Roblox ArchOS:

1. Open the **ArchOS Code** app.
2. Create a project named `byte-rush`.
3. Paste the contents of **main.arch** into its `main.arch` editor.
4. Use **Build** to generate the app's `.archapp` in ArchOS.
5. Open it from your ArchOS app launcher or Software Center.

This code uses the hosted ArchOS documentation's `ui.window`, `ui.label`, `ui.button`, `ui.setText` and `ui.notify` functions. Whether these APIs work in your current Roblox build must be tested in that environment; we cannot deploy or launch it from a local Windows BAT without an ArchOS deployment/API integration.

## Play and test

- Double-click `PLAY_WEB.bat` to launch the offline browser version.
- Double-click `TEST.bat` for Node-based smoke tests, or `node tests\preview.test.js` in CMD.
- Choose an answer by clicking or with keys 1-4. `R` restarts and `M` switches modes.

## Files

```
testarchosrobloxpack/
  DEPLOY.bat         GitHub push + Vercel deployment
  TEST.bat           Browser-game smoke tests
  PLAY_WEB.bat       Open game locally in browser
  index.html         Vercel website entry point
  main.arch          Roblox ArchOS Code / ArchScript source
  vercel.json        Vercel config
  preview/index.html Offline preview (same web game)
  tests/preview.test.js
  LICENSE
```

The built `.archapp` is **not included** because only the Roblox ArchOS runtime/compiler can build and validate that package.
