#!/usr/bin/env python

import os.path
import sys
import uuid

from os_win import utilsfactory
from os_win import constants
from os_win.utils.network.networkutils import NetworkUtils
from os_win.utils.storage.virtdisk.vhdutils import VHDUtils
from os_win.utils.compute.vmutils import VMUtils


abspath = lambda x: os.path.abspath(x).replace("/", "\\")
# patch _set_vm_memory to only set VirtualQuantity
def _set_vm_memory(self, vmsetting, memory_mb, memory_per_numa_node,
                    dynamic_memory_ratio):
    mem_settings = self._get_vm_memory(vmsetting)
    mem_settings.VirtualQuantity = int(memory_mb)
    self._jobutils.modify_virt_resource(mem_settings)

vhdutils: VHDUtils = utilsfactory.get_vhdutils()
vmutils: VMUtils = utilsfactory.get_vmutils()
netutils: NetworkUtils = utilsfactory.get_networkutils()
vmutils._set_vm_memory = _set_vm_memory.__get__(vmutils)

vhdutils.create_differencing_vhd(sys.argv[2]+".vhdx", sys.argv[1])
vmutils.create_vm(sys.argv[2], False, constants.VM_GEN_2, None)
vmutils.update_vm(sys.argv[2], 8*1024, None, 2, None, False, 2, snapshot_type=constants.VM_SNAPSHOT_TYPE_DISABLED)
vmutils.enable_secure_boot(sys.argv[2], False)
vmutils.create_scsi_controller(sys.argv[2])
vmutils.attach_scsi_drive(sys.argv[2], abspath(sys.argv[2]+".vhdx"))
vmutils.attach_scsi_drive(sys.argv[2], abspath(os.path.expandvars("${USERPROFILE}/winautoconfig/msys2-runner-setup/setup.iso"), constants.DVD)

# I don't really want to have to deal with unique NIC names...
#vmutils.create_nic(sys.argv[2], "Nicky")
new_nic_data = vmutils._get_new_setting_data(
    vmutils._SYNTHETIC_ETHERNET_PORT_SETTING_DATA_CLASS)
new_nic_data.ElementName = "Network Adapter"
new_nic_data.VirtualSystemIdentifiers = ['{' + str(uuid.uuid4()) + '}']
vmsd = vmutils._lookup_vm_check(sys.argv[2])
newresources = vmutils._jobutils.add_virt_resource(new_nic_data, vmsd)

#netutils.connect_vnic_to_vswitch("Default Switch", "Nicky")
port = netutils._get_default_setting_data(netutils._PORT_ALLOC_SET_DATA)
vswitch = netutils._get_vswitch("Default Switch")
port.HostResource = [vswitch.path_()]
port.Parent = newresources[0]
vmutils._jobutils.add_virt_resource(port, vmsd)
