20230709 net-tools NIC, WNIC, modem [abstraction/virtual, gates and nodes]
Fact is that network interfaces evolved covering a wide range of devices in both spectrum of radio frequency (RF), either (a) RF-wired or (b) RF-wireless. Kernel Network Interfaces (KNI) is not a title but the definition of limitations in operating systems (OS/s) which are expected to provide configuration capabilities for almost any device available on a computer-machine that such OS is booting on.
[simple way to understand nodes] if linux/unix is to survive transformation, is as simple as watching kids playing with two computers connected via a network-cable and setting both network interfaces to exchange pockets – example via IPv4 where there are no standards/limitations on what numbers to choose. Theoretically, interface1 IP 0.0.0.1 will talk to interface2 IP 0.0.0.2 as long as both share the same system gate IP 0.0.0.3; One can observe that the gate is a virtual number only representative to a communication established (in this case explained as two interfaces sharing a common-gate forming a virtual-system of communication).
[a swinging gate is dangerous as long as a designated mask or app_check is not provided. neither covered here 127.0.0.0 – almost as I wrote reserved_names () {echo “”;}]
The Open Systems Interconnection model OSI covers a little more detail and standardization in abstract layers eg Physical, Data Link, Network, Transport, Session etc. in that software is the backbone of communication. Basically, the old network-script is a big-deal software undertaking and it is as bad as not knowing how to make a cross in a religious faction or bow gracefully in front of the emperor – a gate in abstract layer is a node making. Protocol, Protocol, Protocol.
However, “net-tools” is a pseudonym of KNI who served well in the past but never received proper funding to keep up with the pace of new devices. The new kid in town is called iproute2 
Q. do we have the iproute2?  How long it will function or stay financed? 
Seems that installing net-tools in Ubuntu 22.04 was the wrong decision and the clutter of internet in US only helps to make such wrong decisions.
Have to restart from zero and backup from github all code that I promised should work on a fresh install.
Some references:
[net-tools] https://yum-info.contradodigital.com/view-package/installed/net-tools/
"Most of them are obsolete. For replacement check iproute package."
per https://hackage.haskell.org/package/iproute

*** Concluding that net-tools may not be used in the future should one desire to look forward. I do not chat GPT yet.


San Anton 20230709 [aka iface physical challenge]
PS: “we bridge in infinity as long as we can convert to standards” “the ant man”
…
