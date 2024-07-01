# wp_chessboard_interface
This is a Dart package that provides a unified interface for interacting with various chessboards. Its used in WhitePawn and PawnTown applications.
To have a reference how to integration works, this package includes the
implementation for the SquareOff chessboard.

The aim of this project is to bridge the gap between various chessboard manufacturers, creating a standardized API that allows WhitePawn to easily connect, interact, and manipulate chessboard functionalities.

## Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✅    | ✅  |  ✅   | ✅  |  ✅   |   ✅    |

## Chessboards Support
| Name | Driver | Chessboard |
| :----- | :----- | :----- |
SquareOff Pro | [squareoffdriver.dart](lib/src/drivers/squareoff/squareoffdriver.dart) | [squareoff_chessboard.dart](lib/src/chessboards/squareoff_chessboard.dart)

# Folder Structure

```
.
├── chessboards
│   └── (adapters for normalizing chessboard drivers)
├── drivers
│   └── (drivers for different chessboards)
├── interfaces
│   ├── illuminable.dart
│   └── loggable.dart
├── models
│   └── (shared models)
├── chessboard_connection_factory.dart
└── chessboard.dart
```

The repository is organized into several key components to ensure ease of navigation and maintainability:

- **`chessboards` folder**: Includes adapters that normalize the various chessboard drivers to a standard interface, enabling a consistent connection method across different brands.

- **`drivers` folder**: Contains the specific drivers for the different supported chessboards.

- **`interfaces` folder**: Encapsulates common functionalities that can be implemented by the adapters inside the `chessboards` folder, including:
  - `illuminable.dart`
  - `loggable.dart`

- **`models` folder**: Includes shared models that are utilized across different parts of the project.

- **`chessboard_connection_factory.dart`**: Responsible for initializing connections with different chessboards.

- **`chessboard.dart`**: Acts as the foundation for the chessboard adapters.

By understanding this structure, you can more effectively navigate the project and contribute to its continued growth and success.
