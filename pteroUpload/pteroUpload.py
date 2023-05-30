import sys
import os
import os.path
import requests
import configparser

config = configparser.ConfigParser()
config.read('/home/neil/Documents/Code/ShellScripts/pteroUpload/config.ini')

if len( sys.argv ) < 2:
    print("A file path must be provided.")

if not os.path.isfile(sys.argv[1]):
        print(f"{sys.argv[1]} is nota valid file.")
        sys.exit(0)

url = config['KPG']['url']
headers = {
    "Authorization": f"Bearer {config['KPG']['key']}",
    "Accept": "application/json",
    "Content-Type": "application/json"
}
payload = '{"command": "rnr"}'

servers = open ('/home/neil/Documents/Code/ShellScripts/pteroUpload/kingsServers.txt', 'r')
Lines = servers.readlines()
file = open(sys.argv[1], 'rb')

for line in Lines:
    noRestart = False
    response = requests.get(f"{url}/{line.strip()}/files/upload", headers=headers)
    if (not response.ok):
        print(f"An error has occurred: {response.status_code} {response.text}")
        sys.exit(0)

    signedURL = response.json()["attributes"]["url"]
    response2 = requests.post(f"{signedURL}&directory=.config/EXILED/Plugins", files={'files': file})
    if (not response2.ok):
        print(f"An error has occurred: {response2.status_code} {response2.text}")
        sys.exit(0)
    
    response3 = requests.post(f"{url}/{line.strip()}/command", data=payload, headers=headers)
    if (response3.status_code == 502):
        noRestart = True
    elif (not response3.ok):
        print(f"{response3}")
        sys.exit(0)
    
    if (noRestart):
        print(f"{line.strip()} done. --no-restat")
    else:
        print(f"{line.strip()} done.")
