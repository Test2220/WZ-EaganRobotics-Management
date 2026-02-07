Adding General notes here adding a Pode Intergration for API access to Unifi
will need to add API code and findings to this readme for network configuraiton of FMS VLANs of 10,20,30,40,50,60,70,80,90,100
fundmentaly this will update the network stack to get it off of VERY old cisco gear.

as a remidner the FMS network on secure mode will use L3 networking so a L3 switch from Unifi will be needed plus ACL lists.  we will also need to test intervlan routing for internal team routing from team VLANs to FMS VLAN (10.0.100.0/24)

should also map out VH-113 api calls and beable to configure the AP from there.