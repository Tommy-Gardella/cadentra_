Allowing "Claude" to edit this project
=====================================

This file outlines options for enabling edits by an entity named "Claude." Pick one and provide details so I can proceed.

Options

- GitHub collaborator named "Claude":
  - Create a GitHub repo or tell me the existing repo. Provide the GitHub username or email for Claude and I will supply the command/steps to invite with write access.

- Anthropic "Claude" (cloud AI):
  - Anthropic's models don't get direct repo access. Common patterns:
    - Upload project files to a secure file share and give the model a wrapper that can edit and return patches.
    - Use an integration (e.g., GitHub + Anthropic workflow) that creates PRs from model suggestions.
  - If you want this route, tell me which Anthropic product and whether you can supply API keys.

- Local VS Code agent or plugin named "Claude":
  - Use a VS Code extension that grants the assistant file permissions (e.g., Copilot-like or third-party).
  - I can add a `.vscode` recommendation or devcontainer to make running an assistant easier — tell me which extension.

Security note
- Grant the minimum permissions necessary and prefer invite-based GitHub access or manual file uploads rather than sharing secrets publicly.
