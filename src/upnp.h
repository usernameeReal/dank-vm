#ifndef COLLABVM_UPNP_H
#define COLLABVM_UPNP_H

#ifdef __cplusplus
extern "C" {
#endif

void init_upnp (void);
void upnp_add_redir (const char * addr, unsigned int port);
void upnp_rem_redir (unsigned int port);

#ifdef __cplusplus
}
#endif
#endif