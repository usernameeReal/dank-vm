#include <stdio.h>
#include <string.h>

#include "upnp.h"

#include <miniupnpc/miniupnpc.h>
#include <miniupnpc/upnpcommands.h>

static struct UPNPUrls urls;
static struct IGDdatas data;
static char localip[16]; // increase to 40 if we're doing ipv6
static char externalip[16]; // then again we need to rewrite this to support ipv6

void init_upnp (void)
{
	struct UPNPDev * devlist;
	char * descXML;
	int descXMLsize = 0;
	int upnperror = 0;
	memset(&urls, 0, sizeof(struct UPNPUrls));
	memset(&data, 0, sizeof(struct IGDdatas));
	devlist = upnpDiscover(2000, NULL/*multicast interface*/, NULL/*minissdpd socket path*/, 0/*sameport*/, 0/*ipv6*/, 2/*ttl*/, &upnperror);
	if (devlist)
	{
		UPNP_GetValidIGD(devlist,&urls,&data,localip,16); // same here, 16->40
	}
	else
	{
		/* error ! */
		fprintf(stderr, "[UPnP] An internal error occured.\n");
		return;
	}
}

void upnp_add_redir (unsigned int port)
{
	char port_str[6];
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
	UPNP_GetExternalIPAddress(urls.controlURL, data.first.servicetype, externalip);
	sprintf(port_str, "%d", port);
#ifdef DEBUG
	printf("[UPnP] Local IP reporting as %s.\n",localip);
#endif
	printf("[UPnP] Redirecting %s:%s to %s:%s...\n",localip,port_str,externalip,port_str);
	r = UPNP_AddPortMapping(urls.controlURL, data.first.servicetype, port_str, port_str, localip, "collabvm", "TCP", NULL, NULL);
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
	printf("[UPnP] Removing redirect from %s:%s...\n",externalip,port_str);
	UPNP_DeletePortMapping(urls.controlURL, data.first.servicetype, port_str, "TCP", NULL);
}