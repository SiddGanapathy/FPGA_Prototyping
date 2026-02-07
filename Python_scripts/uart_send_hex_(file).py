import serial
import time
import os

# === Configuration ===
PORT = 'COM14'           # Your Sender Port
BAUD_RATE = 115200        # Match the Receiver
FILE_PATH = 'firmware.hex'  # The file you want to send
CHUNK_SIZE = 64         # Bytes to send at a time (don't overwhelm the buffer)

def sender():
    if not os.path.exists(FILE_PATH):
        print(f"Error: File '{FILE_PATH}' not found.")
        return

    file_size = os.path.getsize(FILE_PATH)
    
    try:
        with serial.Serial(PORT, BAUD_RATE, timeout=1) as ser:
            print(f"\nConnected to {PORT}. Prepare for launch.")
            print(f"📄 Sending '{FILE_PATH}' ({file_size} bytes)...")
            time.sleep(2) # Give the receiver a moment to wake up

            bytes_sent = 0
            
            with open(FILE_PATH, 'rb') as f: # 'rb' = Read Binary
                while True:
                    chunk = f.read(CHUNK_SIZE)
                    if not chunk:
                        break  # End of file
                    
                    ser.write(chunk)
                    bytes_sent += len(chunk)
                    
                    # Visual progress bar logic
                    progress = int((bytes_sent / file_size) * 100)
                    print(f"\rProgress: {progress}% ({bytes_sent}/{file_size} bytes)", end='', flush=True)
                    
                    time.sleep(0.05) # tiny pause to prevent buffer overflow

            print(f"\n\n✅ Done. Sent {bytes_sent} bytes.")

    except serial.SerialException as e:
        print(f"Serial Error: {e}")

if __name__ == "__main__":
    sender()