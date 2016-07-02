.set BaseOfLoader,    0x9000    
.set OffsetOfLoader,  0x0100    

.set BaseOfLoaderPhyAddr, 0x90000


.set BaseOfKernelFile,    0x8000
.set OffsetOfKernelFile,  0x0

.set BaseOfKernelFilePhyAddr, 0x80000
.set E_PHNUM_PhyAddr,         BaseOfKernelFilePhyAddr + 0x2c 
.set E_PHOFF_PhyAddr,         BaseOfKernelFilePhyAddr + 0x1c

.set KernelEntryPointPhyAddr, 0x30400

.set PageDirBase, 0x200000   
.set PageTblBase, 0x201000   
