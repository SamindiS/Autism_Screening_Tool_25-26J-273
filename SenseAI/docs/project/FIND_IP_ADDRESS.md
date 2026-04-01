# How to Find Your Computer's IP Address

## For Windows (Your System):

### Method 1: Using Command Prompt
1. Press `Win + R` to open Run dialog
2. Type `cmd` and press Enter
3. In the Command Prompt, type:
   ```
   ipconfig
   ```
4. Look for **"IPv4 Address"** under your active network adapter (usually "Wireless LAN adapter Wi-Fi" or "Ethernet adapter")
5. It will look like: `192.168.1.100` or `192.168.0.50`

### Method 2: Using PowerShell
1. Press `Win + X` and select "Windows PowerShell"
2. Type:
   ```
   ipconfig | findstr IPv4
   ```
3. You'll see your IP address

## Important Notes:
- Make sure your **tablet and computer are on the same Wi-Fi network**
- The IP address should start with `192.168.` or `10.0.`
- Use the IP address that's NOT `127.0.0.1` (that's localhost)

## Example:
If your IP address is `192.168.1.100`, your backend URL should be:
```
http://192.168.1.100:3000
```


