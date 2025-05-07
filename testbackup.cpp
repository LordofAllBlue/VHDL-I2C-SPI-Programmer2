#include <windows.h>
#include <winbase.h>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <sstream>
#include <vector>

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

int main() {
    HANDLE hSerial;
    hSerial = CreateFile("COM5",
                         GENERIC_READ | GENERIC_WRITE,
                         0,
                         0,
                         OPEN_EXISTING,
                         FILE_ATTRIBUTE_NORMAL,
                         0);
    if (hSerial == INVALID_HANDLE_VALUE) {
        if (GetLastError() == ERROR_FILE_NOT_FOUND) {
            // Serial port does not exist. Inform user.
            printf("1");
        }
        // Some other error occurred. Inform user.
        printf("2");
    }

    DCB dcbSerialParams = {0};
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    if (!GetCommState(hSerial, &dcbSerialParams)) {
        // Error getting state
        printf("3");
    }
    dcbSerialParams.BaudRate = 576000;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT;
    dcbSerialParams.Parity = NOPARITY;
    if (!SetCommState(hSerial, &dcbSerialParams)) {
        // Error setting serial port state
        printf("4");
    }

    COMMTIMEOUTS timeouts = {0};
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;
    if (!SetCommTimeouts(hSerial, &timeouts)) {
        // Error occurred. Inform user
        printf("5");
    }

    char szBuff[1000000] = {0};
    char szBuff1[1000000] = {0}; // Initialize with nulls

    while (1) {
        cout << "Enter hex data (type 'exit' to quit): ";
        cin.getline(szBuff, sizeof(szBuff)); // Use getline to capture input

        if (strlen(szBuff) == 0) {
            continue; // Skip empty input
        }

        if (strcmp(szBuff, "exit") == 0) {
            break; // Exit the loop if 'exit' is entered
        }

        // Convert hex string to byte array
        string hexInput(szBuff);
        vector<unsigned char> byteArray = hexStringToBytes(hexInput);

        DWORD dwBytes = 0;
        if (!WriteFile(hSerial, byteArray.data(), byteArray.size(), &dwBytes, NULL)) {
            printf("Error writing to serial port\n");
        } else {
            printf("Bytes written: %lu\n", dwBytes);
        }

        // Wait for loopback
        Sleep(500);

        COMSTAT comStat;
        DWORD errors;
        if (ClearCommError(hSerial, &errors, &comStat)) {
            printf("Bytes in queue: %lu\n", comStat.cbInQue);
        }

        DWORD dwBytesRead = 0;
        if (!ReadFile(hSerial, szBuff1, comStat.cbInQue, &dwBytesRead, NULL)) {
            printf("Error reading from serial port\n");
        } else {
            szBuff1[dwBytesRead] = '\0'; // Null-terminate the string
            printf("Received: ");
            for (DWORD i = 0; i < dwBytesRead; i++) {
                printf("%02X ", (unsigned char)szBuff1[i]); // Print received data as hex
            }
            printf("\n");
        }
    }

    CloseHandle(hSerial);
    return 0;
}