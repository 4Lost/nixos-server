# { ... }:
#
# {
#   perSystem =
#     { ... }:
#
#     {
#       _module.args.inventory = {
#         proxmox = {
#           nodes = {
#             pve01 = {
#               hostname = "pve01";
#               address = "192.168.1.10";
#               role = "hypervisor";
#             };
#
#             pve02 = {
#               hostname = "pve02";
#               address = "192.168.1.11";
#               role = "hypervisor";
#             };
#           };
#         };
#
#         networks = {
#           management = {
#             vlan = 10;
#             subnet = "192.168.10.0/24";
#           };
#
#           servers = {
#             vlan = 20;
#             subnet = "192.168.20.0/24";
#           };
#         };
#       };
#     };
# }
