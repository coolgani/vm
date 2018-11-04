 ## Global
Add-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId "e91e576d-238d-47fb-9d8b-3d05f6da4c61"
 
 $ResourceGroupName = "ResourceGroup11"
 $Location = "WestEurope"

 ## Storage
 $StorageName = "coolganistore3"
 $StorageType = "Standard_GRS"

 ## Network
 $InterfaceName1 = "ServerInterface06"
 $InterfaceName2 = "ServerInterface07"
 $InterfaceName3 = "ServerInterface08"
 $Subnet1Name = "Subnet1"
 $VNetName = "VNet09"
 $VNetAddressPrefix = "10.0.0.0/16"
 $VNetSubnetAddressPrefix = "10.0.0.0/24"

 ## Compute
 $VMName = "VirtualMachine12"
 $ComputerName = "Server22"
 $VMName3 = "VirtualMachine14"
 $ComputerName3 = "Server24"
 $VMSize = "Standard_DS2_v2"
 $VMSize2 = "Standard_DS1_v2"
 $OSDiskName = $VMName + "OSDisk"
 $OSDiskName3 = $VMName3 + "OSDisk"

 # Resource Group
 New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location

 # Storage
 $StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageName -Type $StorageType -Location $Location

 # Network
 $PIp1 = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic
 $PIp2 = New-AzureRmPublicIpAddress -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic
 $SubnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $Subnet1Name -AddressPrefix $VNetSubnetAddressPrefix
 $VNet = New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VNetAddressPrefix -Subnet $SubnetConfig
 $Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[0].Id -PublicIpAddressId $PIp1.Id
 $Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[0].Id -PublicIpAddressId $PIp2.Id

 # Compute

 ## Setup local VM object
 $Credential = Get-Credential
 $VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
 $VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
 $VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
 $VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id-Primary 
 $VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface2.Id
 $OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
 $VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption FromImage

 ## Create the VM in Azure
 New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine

 
