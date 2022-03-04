#include <stdio.h>
#include <string.h>
#include <stdlib.h> // free()

#include "upnp.h"

#include <miniupnpc/miniwget.h>
#include <miniupnpc/miniupnpc.h>
#include <miniupnpc/upnpcommands.h>

static struct UPNPUrls urls;
static struct IGDdatas data;

void init_upnp (void)
{
	struct UPNPDev * devlist;
	struct UPNPDev * dev;
	char * descXML;
	int descXMLsize = 0;
	int upnperror = 0;
	memset(&urls, 0, sizeof(struct UPNPUrls));
	memset(&data, 0, sizeof(struct IGDdatas));
	devlist = upnpDiscover(2000, NULL/*multicast interface*/, NULL/*minissdpd socket path*/, 0/*sameport*/, 0/*ipv6*/, 2/*ttl*/, &upnperror);
	if (devlist)
	{
		dev = devlist;
		while (dev)
		{
			if (strstr (dev->st, "InternetGatewayDevice"))
				break;
			dev = dev->pNext;
		}
		if (!dev)
			dev = devlist; /* defaulting to first device */
		descXML = miniwget(dev->descURL, &descXMLsize, 0, &upnperror);
		if (descXML)
		{
			parserootdesc (descXML, descXMLsize, &data);
			free (descXML); descXML = 0;
			GetUPNPUrls (&urls, &data, dev->descURL, 0);
		}
		freeUPNPDevlist(devlist);
	}
	else
	{
		/* error ! */
	}
}

void upnp_add_redir (const char * addr, unsigned int port)
{
	char port_str[8];
	int r;
	if (urls.controlURL == NULL)
	{
		fprintf(stderr, "[UPnP] Error: No UPnP-compatible gateway detected.\nCollabVM Server will not be automatically forwarded.\n");
		return;
	}
	if(urls.controlURL[0] == '\0')
	{
		return;
	}
	sprintf(port_str, "%d", port);
	r = UPNP_AddPortMapping(urls.controlURL, data.first.servicetype, port_str, port_str, addr, "collabvm", "TCP", NULL, NULL);
	if(r==0)
		return;
}

void upnp_rem_redir (unsigned int port)
{
	char port_str[8];
	int t;
	if (urls.controlURL == NULL)
	{
		return;
	}
	if(urls.controlURL[0] == '\0')
	{
		return;
	}
	sprintf(port_str, "%d", port);
	UPNP_DeletePortMapping(urls.controlURL, data.first.servicetype, port_str, "TCP", NULL);
}
