
import serial
from serial.serialutil import SerialException

class UARTCommands:
    def __init__(self, ser=None):
        self.ser = ser

    def TurnONOFF(self, ON=None, OFF=None):
        ON = ON if ON is not None else 0
        OFF = OFF if OFF is not None else 0

        ON_bits = [int(b) for b in format(ON, '01b')[::-1]]
        OFF_bits = [int(b) for b in format(OFF, '01b')[::-1]]

        regValues = bytearray()
        regValues.append(0xAA)  # Header
        regValues.append((OFF_bits[0] << 5) + (ON_bits[0] << 4) + (0xA << 0))
        checksum = 0

        for values in regValues:
            checksum = checksum ^ values
        regValues.append(checksum)
        regValues.append(0x55)  # Default Footer

        print(f'Sending TurnONOFF command')
        # print the binary of regvalues
        for values in regValues:
            print(bin(values)[2:])

        try:
            if self.ser:
                self.ser.write(regValues)
                print("TurnONOFF command sent successfully.")
                print()
        except SerialException as e:
            print(f"Error writing to serial port: {e}")

    def Loom(self, Start_Loom=None):
        Start_Loom = Start_Loom if Start_Loom is not None else 0

        Start_Loom_bits = [int(b) for b in format(Start_Loom, '01b')[::-1]]

        regValues = bytearray()
        regValues.append(0xAA)  # Header
        regValues.append((Start_Loom_bits[0] << 4) + (0xB << 0))
        checksum = 0

        for values in regValues:
            checksum = checksum ^ values
        regValues.append(checksum)
        regValues.append(0x55)  # Default Footer

        print(f'Sending Loom command')
        # print the binary of regvalues
        for values in regValues:
            print(bin(values)[2:])

        try:
            if self.ser:
                self.ser.write(regValues)
                print("Loom command sent successfully.")
                print()
        except SerialException as e:
            print(f"Error writing to serial port: {e}")

    def LED(self, Start_LED=None):
        Start_LED = Start_LED if Start_LED is not None else 0

        Start_LED_bits = [int(b) for b in format(Start_LED, '01b')[::-1]]

        regValues = bytearray()
        regValues.append(0xAA)  # Header
        regValues.append((Start_LED_bits[0] << 4) + (0xC << 0))
        checksum = 0

        for values in regValues:
            checksum = checksum ^ values
        regValues.append(checksum)
        regValues.append(0x55)  # Default Footer

        print(f'Sending LED command')
        # print the binary of regvalues
        for values in regValues:
            print(bin(values)[2:])

        try:
            if self.ser:
                self.ser.write(regValues)
                print("LED command sent successfully.")
                print()
        except SerialException as e:
            print(f"Error writing to serial port: {e}")

    def Tarang(self, Tarang_BAND=None, Tarang_MODE=None, Tarang_PORT=None, Pulse_width=None, PRI=None):
        Tarang_BAND = Tarang_BAND if Tarang_BAND is not None else 0
        Tarang_MODE = Tarang_MODE if Tarang_MODE is not None else 0
        Tarang_PORT = Tarang_PORT if Tarang_PORT is not None else 0
        Pulse_width = Pulse_width if Pulse_width is not None else 0
        PRI = PRI if PRI is not None else 0

        Tarang_BAND_bits = [int(b) for b in format(Tarang_BAND, '02b')[::-1]]
        Tarang_MODE_bits = [int(b) for b in format(Tarang_MODE, '01b')[::-1]]
        Tarang_PORT_bits = [int(b) for b in format(Tarang_PORT, '01b')[::-1]]
        Pulse_width_bits = [int(b) for b in format(Pulse_width, '016b')[::-1]]
        PRI_bits = [int(b) for b in format(PRI, '016b')[::-1]]

        regValues = bytearray()
        regValues.append(0xAA)  # Header
        regValues.append((Tarang_PORT_bits[0] << 7) + (Tarang_MODE_bits[0] << 6) + (Tarang_BAND_bits[1] << 5) + (Tarang_BAND_bits[0] << 4) + (0xD << 0))
        regValues.append((Pulse_width_bits[7] << 7) + (Pulse_width_bits[6] << 6) + (Pulse_width_bits[5] << 5) + (Pulse_width_bits[4] << 4) + (Pulse_width_bits[3] << 3) + (Pulse_width_bits[2] << 2) + (Pulse_width_bits[1] << 1) + (Pulse_width_bits[0] << 0))
        regValues.append((Pulse_width_bits[15] << 7) + (Pulse_width_bits[14] << 6) + (Pulse_width_bits[13] << 5) + (Pulse_width_bits[12] << 4) + (Pulse_width_bits[11] << 3) + (Pulse_width_bits[10] << 2) + (Pulse_width_bits[9] << 1) + (Pulse_width_bits[8] << 0))
        regValues.append((PRI_bits[7] << 7) + (PRI_bits[6] << 6) + (PRI_bits[5] << 5) + (PRI_bits[4] << 4) + (PRI_bits[3] << 3) + (PRI_bits[2] << 2) + (PRI_bits[1] << 1) + (PRI_bits[0] << 0))
        regValues.append((PRI_bits[15] << 7) + (PRI_bits[14] << 6) + (PRI_bits[13] << 5) + (PRI_bits[12] << 4) + (PRI_bits[11] << 3) + (PRI_bits[10] << 2) + (PRI_bits[9] << 1) + (PRI_bits[8] << 0))
        checksum = 0

        for values in regValues:
            checksum = checksum ^ values
        regValues.append(checksum)
        regValues.append(0x55)  # Default Footer

        print(f'Sending Tarang command')
        # print the binary of regvalues
        for values in regValues:
            print(bin(values)[2:])

        try:
            if self.ser:
                self.ser.write(regValues)
                print("Tarang command sent successfully.")
                print()
        except SerialException as e:
            print(f"Error writing to serial port: {e}")

    def R118(self, R118_BAND=None, R118_MODE=None):
        R118_BAND = R118_BAND if R118_BAND is not None else 0
        R118_MODE = R118_MODE if R118_MODE is not None else 0

        R118_BAND_bits = [int(b) for b in format(R118_BAND, '03b')[::-1]]
        R118_MODE_bits = [int(b) for b in format(R118_MODE, '02b')[::-1]]

        regValues = bytearray()
        regValues.append(0xAA)  # Header
        regValues.append((R118_BAND_bits[2] << 6) + (R118_BAND_bits[1] << 5) + (R118_BAND_bits[0] << 4) + (0xE << 0))
        regValues.append((R118_MODE_bits[1] << 1) + (R118_MODE_bits[0] << 0))
        checksum = 0

        for values in regValues:
            checksum = checksum ^ values
        regValues.append(checksum)
        regValues.append(0x55)  # Default Footer

        print(f'Sending R118 command')
        # print the binary of regvalues
        for values in regValues:
            print(bin(values)[2:])

        try:
            if self.ser:
                self.ser.write(regValues)
                print("R118 command sent successfully.")
                print()
        except SerialException as e:
            print(f"Error writing to serial port: {e}")

    def Switch_matrix(self, RF_IN=None, RF_OUT=None, BITE_IN=None):
        RF_IN = RF_IN if RF_IN is not None else 0
        RF_OUT = RF_OUT if RF_OUT is not None else 0
        BITE_IN = BITE_IN if BITE_IN is not None else 0

        RF_IN_bits = [int(b) for b in format(RF_IN, '01b')[::-1]]
        RF_OUT_bits = [int(b) for b in format(RF_OUT, '02b')[::-1]]
        BITE_IN_bits = [int(b) for b in format(BITE_IN, '02b')[::-1]]

        regValues = bytearray()
        regValues.append(0xAA)  # Header
        regValues.append((RF_OUT_bits[1] << 6) + (RF_OUT_bits[0] << 5) + (RF_IN_bits[0] << 4) + (0x2 << 0))
        regValues.append((BITE_IN_bits[1] << 1) + (BITE_IN_bits[0] << 0))
        checksum = 0

        for values in regValues:
            checksum = checksum ^ values
        regValues.append(checksum)
        regValues.append(0x55)  # Default Footer

        print(f'Sending Switch_matrix command')
        # print the binary of regvalues
        for values in regValues:
            print(bin(values)[2:])

        try:
            if self.ser:
                self.ser.write(regValues)
                print("Switch_matrix command sent successfully.")
                print()
        except SerialException as e:
            print(f"Error writing to serial port: {e}")
