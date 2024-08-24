# Router_1x3_RTL_Design
Router_1x3_RTL_Design
Router is a device that forwards data packets between computer networks. It is an OSI layer 3 (TCP/IP Protocol) routing device. It drives an incoming packet to an output channel based on the address field contained in the packet header. Router 1x3 design follows packet based protocol and it receives the network packet from a source LAN uning data on a byte by byte basis on active poedge of the clock.

Router top block level architecture consist 4 sub-blocks
FSM Controller
Synchronizer
Register
FIFOs
Functionality of each sub-blocks
Registers : This blocks acts like a loadabe register which uses the control signal comming from FSM controller and load the packets in the order as header,payload followed by parity using dout[7:0].
FSM Controller : This is the main hub of router architecture. FSM acts like a controller that generates multiple control signal which is used to control reset of the sub-blocks.
Synchronizer : This blocks capture the address of the packet and based on that generate write_enb[2:0] signal which is further used for connecting the write_enb[0],write_enb[1],write_enb[2] pins of the each FIFOs. Apart from that this block also generates the timer logic of the router.
FIFO : Since there are 3 destination LAN, we have 3 FIFOs. The primary job of the FIFO is to store a packet based on relevant address driven by the source LAN. This FIFO operates both resd and write operations simultaneously.
