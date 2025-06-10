# demo1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Application Setup and Running Instructions
Before running the application, ensure that the environment is set up and all dependencies are installed. The application requires running the translation or Computer Vision services separately via the terminal. Follow the steps below based on the service you want to run.
Running the Translation Service
To start the translation service, open a terminal and execute the following commands:

Navigate to the lib directory:cd lib


Enter the translate directory:cd translate


Move to the backend directory:cd backend


Run the backend server using Uvicorn:uvicorn main:app --reload



Running the Computer Vision Service
To start the Computer Vision service, open a terminal and execute the following commands:

Navigate to the lib directory:cd lib


Enter the ComputerVision directory:cd ComputerVision


Move to the backend directory:cd backend


Run the backend script:python backend.py



Notes

Ensure that all required dependencies (e.g., Python, Uvicorn, and any Computer Vision libraries) are installed before running the commands.
For the translation service, the --reload flag with Uvicorn enables auto-reload for development purposes.
If you encounter issues, verify that the paths are correct and that the backend services are properly configured.

