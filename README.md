# PocketPlan

PocketPlan is a small, offline study planner built with Flutter for the CareerSwami Flutter/Android internship project.

## Features

- Starts with four sample study tasks: Algebra, Read brief, Python exercises, and Revise notes.
- Add and edit a task (title, subject, and planned day).
- Delete a task after a confirmation prompt.
- Mark a task complete or incomplete.
- Filter tasks by subject (All, Maths, Design, or Code).
- Save task data locally on the device with `shared_preferences`.
- Show a task completion progress indicator.

The app uses planned-day labels (for example, Day 2), not calendar dates. It does not require an account or a backend service.

## Requirements

- Flutter SDK (project archive generated with Flutter 3.44.0).
- Dart SDK compatible with the constraint in `pubspec.yaml` (`^3.12.0`).
- Android Studio or VS Code with the Flutter and Dart extensions.
- An Android emulator or an Android device with USB debugging enabled.

## Run the project

Open a terminal in the `pocketplan` project folder and run:

```bash
flutter --version
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter run
```

To create a release APK:

```bash
flutter build apk --release
```

The APK is generated at `build/app/outputs/flutter-apk/app-release.apk`.

## Project structure

```text
lib/
  main.dart                    # App entry point and Material 3 theme
  models/
    task_model.dart            # StudyTask model and starter tasks
  screens/
    home_screen.dart           # Main task list and task interactions
  services/
    storage_service.dart        # Local JSON persistence using shared_preferences
test/
  widget_test.dart              # First-launch starter-task widget test
```

## Navigation

The app currently has one main screen: `HomeScreen`.

- Launching the app opens `HomeScreen`.
- The Add Task floating action button opens the add-task dialog; Cancel closes it and Add saves the new task.
- The task overflow menu opens Edit or Delete actions.
- Edit opens the edit-task dialog; Cancel closes it and Update saves changes.
- Delete opens a confirmation dialog; Cancel keeps the task and Delete removes it.
- Android system Back follows the standard dialog dismissal behavior; there are no separate app routes at this stage.

## UI and reusable styling notes

- The app uses Material 3 with a seed color of `#5267D9`.
- The main screen uses a light `#F8F9FC` background.
- Main content uses 16 logical pixels of outer padding; task cards use compact internal padding and 12 logical pixels of bottom spacing.
- The task title uses 16sp semibold text; section headings use 18–20sp bold text.
- Task cards are built by `buildTaskCard` in `lib/screens/home_screen.dart`.
- The current implementation keeps the task-card layout and subject colors in `HomeScreen`; it does not yet extract a separate reusable widget or centralized spacing/text-style file.

## Data storage

`StorageService` stores the task list as JSON in `SharedPreferences` under the key `pocketplan_tasks`.

- If the key does not exist on first launch, the four starter tasks are saved and returned.
- If the key exists with an empty list, the app keeps the list empty (it does not reseed tasks).
- Task changes are saved after add, edit, delete, and completion-state updates.

This is local device storage; clearing app data or uninstalling the app may remove the saved tasks.

## Validation and evidence checklist

Run the commands in the Run section and keep the actual terminal output for your submission. Also capture genuine screenshots from your own device/emulator for:

1. The task list after marking **Python exercises** complete and adding **Past papers · Maths · Day 5**.
2. The same task list after force-stopping the app and reopening it, showing that all five tasks and the completion state remain.
3. The app with a subject filter selected and the behavior when adding a task from a different subject.
4. The delete confirmation dialog.
5. A large-text / screen-reader check, if completed on your device.

Do not mark a check as passed or include a screenshot unless you personally ran that check and captured the evidence. TalkBack and large-text behavior must be checked on a real Android device or emulator with the relevant accessibility settings enabled.

## Submission contents

Keep the final submission together in a clearly named folder, for example:

```text
CS_mobile-app-dev-flutter-android_YourName_v1/
  pocketplan/        # Flutter source project
  evidence/          # Genuine screenshots and test output
  README.md          # Submission overview and links to deliverables
```

Replace `YourName` with your own name before submitting. Add the requested screenshots and any required setup/navigation notes to the final package. Share the submission link with view access enabled as required by the internship instructions.

## AI assistance disclosure

AI assistance was used to review the project and help prepare documentation and a widget test. The developer should run the listed checks, review the generated changes, and report only the results they personally verified.
