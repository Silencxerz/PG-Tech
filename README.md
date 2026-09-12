# PG Tech — field interface

A menu and deployment repair for the existing Paradox Genetics technology showcase in Roblox Studio. The interface uses a forest-green palette, ivory typography, a live specimen preview, and four pages: Overview, Choose role, Specimen index, and Preferences.

This repository contains the six scripts changed for this interface pass. It is an integration patch, not the complete original game. The existing map, dinosaur meshes, third-party frameworks, and their source code are not bundled here. Original project attribution is retained below.

Roblox: **Entltysix**. Discord: **entitysixxer**.

Review entry point: [MenuController.client.luau](src/MenuController.client.luau). Demonstration place: [PG Tech](https://www.roblox.com/games/15601091446). The latest Studio edits must be published and reviewer access checked before submitting this demonstration.


## Studio integration

The connected PG Tech place already has these changes installed in its Edit data model. Save the place from Studio after stopping Play.

To install into another compatible copy:

1. Save a backup of the destination place and stop Play.
2. Run `node tools/build-installer.mjs` from this repository.
3. Open `dist/Install.luau`, copy its contents, and run them in Studio's Command Bar.
4. Press Play. Check loading, navigation, role selection, and character deployment before saving.

The installer verifies the required instance paths, compiles the supplied sources, backs up the affected scripts/menu, and installs the patch. It does not construct or reposition map geometry. It disables the superseded local scripts under the old menu and loading screen; their assets remain for compatibility and rollback.

| File | Studio destination | Responsibility |
| --- | --- | --- |
| `MenuView.luau` | `ServerStorage.GameUIs.Menu.Core.MenuView` | Colors, components, page layouts |
| `MenuController.client.luau` | `ServerStorage.GameUIs.Menu.Core` | Navigation, preview, preferences, deployment feedback |
| `Loading.client.luau` | `ReplicatedFirst.AssetLoader` | Loading screen and readiness handoff |
| `InterfaceLoader.server.luau` | `ServerScriptService.NetworkOwnership` | Clone available interface templates |
| `DeploymentService.luau` | `ServerScriptService._0xS0URCEC3X.Plugins.PlayerScripts.PlayerManager` | Validate roles/specimens and spawn characters |
| `DeploymentBootstrap.server.luau` | `ServerScriptService.PGDeploymentBootstrap` | Start deployment independently of the legacy loader |

## Reviewing the code

Start with `MenuController.client.luau`. Its `showPage`, `selectRole`, and `deploy` functions are the three main user interactions. `MenuView.Create` constructs their controls without making server requests.

The client invokes `ReplicatedStorage.PGDeployment` with a role and optional specimen name. `DeploymentService` checks the request on the server and returns `{ ok, message }`. The client keeps the menu visible on failure and hides it only after a successful response. The server also retains the old human `EnterGame` event for dependent interfaces.

The staff group/rank requirement is preserved from the original role configuration: group `12858014`, minimum rank `2`. Supported dinosaur rigs are EdmontosaurusMale, SuchomimusMale, and PadillasaurusMale. Character scripts and rigs must exist at the original `ClientDetails` and `ServerDetails` paths.

Press **M** after deployment to reopen the menu. **Return to field** closes it without respawning. Selecting a role and deploying again changes character. Menus do not pause the world. Music and reduced-motion preferences last for the current session.

## Validation and known limits

Verified in the connected Studio session: interface readiness, the new overview rendering, successful human and dinosaur deployment, and rejection of an invalid role. The six integration scripts compile. All 793 existing map parts retained their position, orientation, and size during this pass.

The original place still has unavailable audio/animation assets and legacy subsystem warnings. Studio DataStore writes are disabled in the current configuration. Those dependencies require a separate production readiness pass; this interface patch does not claim to repair every original subsystem.

An unrelated obfuscated script beneath the workspace Edmontosaurus rig attempted to load a failing external asset during testing. That specific script was disabled in the connected place. The installer does not redistribute it or make assumptions about unrelated scripts in other copies.

The old `Workspace.RemoteServer` combat handlers still need a security review before public multiplayer release; in particular, client-supplied damage and instance references are outside the scope of the new deployment validation. Asset permissions, mobile usability, group-denial behavior, and multiplayer latency still need dedicated testing.

## Credits and distribution

The existing place credits VitiateOtto, Petwal, A_ngelics, and ScorchingKami. This package preserves those names and does not claim authorship of the original game or its dependencies. No redistribution license for third-party assets is granted by this repository. Add your own contribution details and choose a license for the code you have authority to license before public distribution.
