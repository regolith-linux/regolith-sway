#ifndef REGOLITH_CONFIG_MANAGER_CLIENT_API_HEADER
#define REGOLITH_CONFIG_MANAGER_CLIENT_API_HEADER
#include "config_manager.h"
#include <stdbool.h>

typedef OrgRegolithTrawl1 *conf_client;

conf_client *proxy_new();
bool conf_client_init(conf_client *proxy, GError **err);

bool conf_client_load(conf_client proxy, char *file, bool nocpp, GError **err);
bool conf_client_load_cpp(conf_client proxy, char *file, char *cpp,
                          char *cpp_args, GError **err);

bool conf_client_merge(conf_client proxy, char *file, bool nocpp, GError **err);
bool conf_client_merge_cpp(conf_client proxy, char *file, char *cpp,
                           char *cpp_args, GError **err);

bool conf_client_query(conf_client proxy, char *query, char **result,
                       GError **err);
bool conf_client_get(conf_client proxy, char *key, char **result, GError **err);

bool conf_client_add_resource(conf_client proxy, char *key, char *value,
                              GError **err);
bool conf_client_set_resource(conf_client proxy, char *key, char *value,
                              GError **err);

bool conf_client_remove_all(conf_client proxy, GError **err);
bool conf_client_remove_one(conf_client proxy, char *key, GError **err);

#endif // REGOLITH_CONFIG_MANAGER_CLIENT_API_HEADER
