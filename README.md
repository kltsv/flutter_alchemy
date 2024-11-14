# Flutter Alchemy

An AI powered cross-platform Alchemy Game written in Flutter.

[Web Demo](https://kltsv.github.io/flutter_alchemy/) —
requires your personal Google AIStudio API key (instruction is down below).

## Getting Started

### Prepare you AIStudio API key

1. Go to https://aistudio.google.com
2. Sign In with your Google Account
3. Press "Get API key" or go to https://aistudio.google.com/apikey
4. Press "Create API key" and wait for it to be generated

### Pass API key to the app

1. Use additional run arg: `--dart-define=GEMINI_API_KEY=[your_api_key_here]`

### Deploy Web

1. Fork this repository
2. Run `dart deploy_web.dart`
2. In your GitHub repository go to Settings -> Pages
3. In Branch menu select the branch `web`
4. Wait for corresponding GitHub Action to be completed