#!/bin/sh

# Define variables
ResourceGroup="YOUR_RESOURCE_GROUP_NAME"
NsgName="YOUR_NSG_NAME"
RuleName="block-"
Description="\"block\""
Type="Deny" # Allow/Deny
Protocol="*" #Tcp/Udp/*
Direction="Inbound" #Inbound/Outbound
Priority=""
SourceAddressPrefix="*"
SourcePortRange="*"
DestinationAddressPrefix="*"
DestinationPortRange="*"

PriorityNumText="./priority.txt"
DefaultPriorityNum="2000"

# Processing variables
RuleName=$RuleName`date +"%Y-%m-%d-%I-%M"`

if [ -e $PriorityNumText ]; then
	Priority=`cat $PriorityNumText`
else
	echo $DefaultPriorityNum > $PriorityNumText
	Priority=`cat $PriorityNumText`
fi

#Priority=`cat $PriorityNumText`

cat ./cidr.txt | while read line; do
	i=1
	RuleName=$RuleName--$i
	az network nsg rule create \
	--resource-group "$ResourceGroup" \
	--nsg-name "$NsgName" \
	--name "$RuleName" \
	--description "${Description}" \
	--access "$Type" \
	--protocol "${Protocol}" \
	--direction "$Direction" \
	--priority "$Priority" \
	--source-address-prefix "${line}" \
	--source-port-range "${SourcePortRange}" \
	--destination-address-prefix "${DestinationAddressPrefix}" \
	--destination-port-range "${SourcePortRange}"

	i=$(( i +1 ))
	Priority=$(( Priority + 1 ))
	echo $Priority > $PriorityNumText
done

