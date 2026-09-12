# Submission preparation

Submit the GitHub file page for `src/MenuController.client.luau`, not the repository homepage or the generated installer. This is one controller with its own responsibility; the other scripts are supporting dependencies, not concatenated into the submission.

The first line identifies Discord `entitysixxer` and Roblox `Entltysix`. It does not claim the accounts are connected through GitHub. Confirm these are the accounts on the application.

## Demonstration walkthrough

1. Publish the updated PG Tech place from Studio under the linked personal Roblox account. Verify a reviewer can join it.
2. Join a fresh session and show the loading screen handing off to Overview.
3. Switch between Choose role, Specimen index, and Preferences. Toggle reduced motion to compare transitions and the preview camera.
4. Choose Test subjects, return to Overview, and enter the field.
5. Press M to reopen the menu; Return to field should close it without respawning.
6. Select a dinosaur and demonstrate deployment. Explain the existing rig/animation dependencies if an asset is unavailable.

## Explain before submitting

The comments in the script are a review draft. Revise them in your own words after understanding and testing the implementation; the application specifically requires your own explanations.

- Why layout construction is delegated to MenuView while navigation state remains in the controller.
- Why the server checks role permissions and specimen names even though the UI offers fixed choices.
- Why InvokeServer is wrapped in pcall and a separate task, and why a local timeout cannot cancel server deployment.
- How the request version prevents a late response from overwriting newer UI state.
- How bounding-box coordinates, a bounded trigonometric orbit, and CFrame.lookAt frame the specimen.
- Why viewport resizing uses property signals, while smooth camera motion uses RenderStepped.
- Why connections to long-lived services must be disconnected when the menu is destroyed.

Do not combine the installer or other modules to inflate the line count. The controller alone exceeds 200 nonblank, noncomment lines. Passing these mechanical requirements does not guarantee acceptance; reviewers assess your understanding and the working demo.
