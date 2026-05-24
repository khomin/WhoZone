class Packet {
  Packet({required this.address, required this.tcp, required this.udp});
  final String address;
  final bool tcp;
  final bool udp;
}
