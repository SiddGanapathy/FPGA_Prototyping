import serial
import time

# -------- CONFIG --------
COM_PORT = "COM14"        # CHANGE THIS
BAUD_RATE = 115200       # Must match FPGA
DELAY = 0.05             # Delay between bytes (seconds)

# HEX DATA TO SEND (example: 0x12 0x34)
hex_data = [
    0x05,
    0x01,
    0x18,
    0x02,
    0x08,
    0x07,
    0x08,
    0x01
]

# ------------------------

ser = serial.Serial(
    port=COM_PORT,
    baudrate=BAUD_RATE,
    bytesize=serial.EIGHTBITS,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    timeout=1
)

time.sleep(2)  # Allow UART to stabilize

print("Sending HEX data...")
for byte in hex_data:
    ser.write(bytes([byte]))
    print(f"Sent: 0x{byte:02X}")
    time.sleep(DELAY)

ser.close()
print("Done.")
