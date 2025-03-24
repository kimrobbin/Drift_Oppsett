# documentation

<br>

```
The main servers name is MainServer.

The ip is 192.168.35.10 and the gateway is 192.168.35.1.

The DHCP scope is 192.168.35.100-200 and the subnetmask is 255.255.255.0.

Hyper-v has a virtual network with a vlan at 335.

OPNsense is needed for DNS to work. It is not installed with the script.


All variables are defined at the top of the script. If you need to make simple changes you should only need to change those.

Two OU gets made: Lerere and Elever 

To change the path of the csv you need to change this code: $csvPath = ""
    You will find it at line 9 in import_users.ps1

If you are going to use a csv to import users this is the format:
 First Name, Last Name, Password, Role  

The scrip will make a folder in your C drive where it will log what the scrip does. So if it fails you can see everything.

The part that downloads programs are on line 35 in windowserver1.ps1
```



