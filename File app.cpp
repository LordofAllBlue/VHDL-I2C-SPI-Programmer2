#include <windows.h>
#include <winbase.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <regex>
#include <iomanip>

using namespace std;

// Function to convert a hex string to a byte array
vector<unsigned char> hexStringToBytes(const string &hex) {
    vector<unsigned char> bytes;
    for (size_t i = 0; i < hex.length(); i += 2) {
        string byteString = hex.substr(i, 2);
        unsigned char byte = (unsigned char)strtol(byteString.c_str(), nullptr, 16);
        bytes.push_back(byte);
    }
    return bytes;
}

// Function to parse wait commands
int parseWaitCommand(const string &line) {
    regex waitRegex(R"(wait\((\d+)ms\))");
    smatch match;
    if (regex_match(line, match, waitRegex)) {
        return stoi(match[1]); // Extract the number of milliseconds
    }
    return -1; // Not a wait command
}

void processFile(HANDLE hSerial, const string &fileName) {
    // Open log file in truncation mode to clear its contents
    ofstream logFile("log.txt", ios::trunc);
    if (!logFile.is_open()) {
        cerr << "Error: Could not open log.txt for writing" << endl;
        return;
    }

    ifstream inputFile(fileName); // Open the file
    if (!inputFile.is_open()) {
        cerr << "Error: Could not open file " << fileName << endl;
        return;
    }

    string line;
    while (getline(inputFile, line)) {
        // Trim whitespace
        line.erase(remove(line.begin(), line.end(), ' '), line.end());

        if (line.empty()) {
            continue; // Skip empty lines
        }

        if (line == "exit") {
            break; // Exit the loop if 'exit' is encountered
        }

        int waitTime = parseWaitCommand(line);
        if (waitTime != -1) {
            // Handle wait command
            printf("Waiting for %d ms\n", waitTime);
            logFile << "Waiting for " << waitTime << " ms\n";
            Sleep(waitTime);
            continue;
        }

        // Convert hex string to byte array
        vector<unsigned char> byteArray = hexStringToBytes(line);

        // Send data to the COM port
        DWORD dwBytes = 0;
        if (!WriteFile(hSerial, byteArray.data(), byteArray.size(), &dwBytes, NULL)) {
            printf("Error writing to serial port\n");
            logFile << "Error writing to serial port\n";
        } else {
            printf("Bytes written: %lu\n", dwBytes);
            logFile << "Bytes written: " << dec << dwBytes << "\n";
        }

        Sleep(20); // Wait for loopback

        // Check for bytes in the queue
        COMSTAT comStat;
        DWORD errors;
        if (ClearCommError(hSerial, &errors, &comStat)) {
            printf("Bytes in queue: %lu\n", comStat.cbInQue);
            logFile << "Bytes in queue: " << comStat.cbInQue << "\n";
        }

        DWORD dwBytesRead = 0;

        // Allocate a separate buffer for reading
        vector<unsigned char> readBuffer(comStat.cbInQue);
        
        if (!ReadFile(hSerial, readBuffer.data(), comStat.cbInQue, &dwBytesRead, NULL)) {
            printf("Error reading from serial port\n");
            logFile << "Error reading from serial port\n";
        } else {
            printf("Received: ");
            logFile << "Received: ";
            logFile << hex << uppercase << setfill('0'); // Apply manipulators once
            for (DWORD i = 0; i < dwBytesRead; i++) {
                printf("%02X ", readBuffer[i]); // Print received data as hex
                logFile << setw(2) << (unsigned int)readBuffer[i] << " ";
            }
            printf("\n");
            logFile << "\n";
        }
    }
}

int main() {
    // Open the COM port once in the main loop
    HANDLE hSerial = CreateFile("COM5",
                                GENERIC_READ | GENERIC_WRITE,
                                0,
                                0,
                                OPEN_EXISTING,
                                FILE_ATTRIBUTE_NORMAL,
                                0);
    if (hSerial == INVALID_HANDLE_VALUE) {
        DWORD error = GetLastError();
        if (error == ERROR_FILE_NOT_FOUND) {
            cerr << "Error: COM5 does not exist or is unavailable." << endl;
        } else {
            cerr << "Error: Unable to open COM5. Error code: " << error << endl;
        }
        return 1;
    }

    // Extend the serial port buffer
    if (!SetupComm(hSerial, 1024, 1024)) { // Set  input and output buffers
        cerr << "Error: Failed to set up serial port buffers. Error code: " << GetLastError() << endl;
        CloseHandle(hSerial);
        return 1;
    }

    DCB dcbSerialParams = {0};
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    if (!GetCommState(hSerial, &dcbSerialParams)) {
        cerr << "Error: Failed to get serial port state. Error code: " << GetLastError() << endl;
        CloseHandle(hSerial);
        return 1;
    }
    dcbSerialParams.BaudRate = 576000;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT;
    dcbSerialParams.Parity = NOPARITY;
    if (!SetCommState(hSerial, &dcbSerialParams)) {
        cerr << "Error: Failed to set serial port state. Error code: " << GetLastError() << endl;
        CloseHandle(hSerial);
        return 1;
    }

    COMMTIMEOUTS timeouts = {0};
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;
    if (!SetCommTimeouts(hSerial, &timeouts)) {
        cerr << "Error: Failed to set serial port timeouts. Error code: " << GetLastError() << endl;
        CloseHandle(hSerial);
        return 1;
    }

    // Main loop to process files
    while (true) {
        string fileName;
        cout << "Enter the file name (or type 'exit' to quit): ";
        getline(cin, fileName);

        if (fileName == "exit") {
            break; // Exit the program
        }

        processFile(hSerial, fileName); // Process the specified file
    }

    // Close the COM port after the main loop
    CloseHandle(hSerial);
    return 0;
}