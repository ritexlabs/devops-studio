# Node.js Sample Apps

This folder contains Node.js sample applications used for learning and Docker practice.

## Layout

```text
samples-nodejs/
├── nodejs-web/
│   ├── chat-app/
│   ├── taskmanager-app/
│   └── weather-app/
└── nodejs-static/
    ├── notes-app/
    └── test-manager-app/
```

## How To Use

1. Open the app folder you want to explore.
2. Read the app README for setup and environment variables.
3. Create a local `.env` file for any required secrets or runtime values.
4. Build or run the app using the provided Dockerfile when available.
5. Keep test output and temporary artifacts out of Git.

## Docker Coverage

Apps with a `Dockerfile` are intended to be built by the repository workflow.

## Notes

- Keep file names, functions, and methods lowercase unless the app already uses another convention.
- Use clear names and short steps so each sample stays easy to scan and maintain.