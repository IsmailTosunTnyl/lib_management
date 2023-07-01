# Library Management and Desk Reservation Tool

This repository contains a Flutter project for a library management and desk reservation tool. The tool allows users to borrow and return books, check the availability of books, add books to a wishlist, and receive notifications when a desired book becomes available. It also provides a search functionality using the ChatGPT API, enabling users to describe a book and find it in the inventory for borrowing or adding to their wishlist.

Additionally, the tool facilitates desk reservations, providing information on desk availability, allowing users to make desk reservations, and offering features such as reservation details and personal study and reading statistics with charts. The tool includes a desk prototype with an RFID reader that utilizes a Raspberry Pi to communicate with Firebase. This setup enables real-time detection of whether a user is currently using a desk and automatically cancels reservations if a user fails to utilize their reservation within a specified timeframe, resulting in a karma penalty.

## Prerequisites

Before running the project, ensure that you have the following installed:

- Flutter SDK
- Dart SDK
- Android Studio / Xcode (for running on a physical device)
- Emulator / Simulator (for running on a virtual device)

## Getting Started

To run the project, follow these steps:

1. Clone the repository:

   ```shell
   git clone https://github.com/your-username/library-management-tool.git
   ```

2. Navigate to the project directory:

   ```shell
   cd library-management-tool
   ```

3. Install the dependencies:

   ```shell
   flutter pub get
   ```

4. Set up the necessary configurations for the ChatGPT API, Firebase, and the RFID reader with Raspberry Pi. Refer to the provided documentation for detailed instructions.

5. Run the project:

   - On a physical device, connect your device and run:

     ```shell
     flutter run
     ```

   - On a virtual device, start the emulator/simulator and run:

     ```shell
     flutter run
     ```

## Contributing

Contributions are welcome! If you would like to contribute to this project, please fork the repository and create a pull request with your proposed changes. Remember to follow the existing coding style and add appropriate tests for new functionality.

## License

This project is licensed under the [MIT License](LICENSE). Feel free to use and modify the code as per the license terms.

Please refer to the individual files in the repository for more details and specific licensing information.

## Acknowledgments

Special thanks to the creators and maintainers of the ChatGPT API, Firebase, and the RFID reader integration with Raspberry Pi. Their contributions have made this library management and desk reservation tool possible.

If you have any questions or suggestions, please feel free to contact us at [ismailtosuntnly@gmail.com](mailto:ismailtosuntnly@gmail.com). We appreciate your feedback!
