#include <client_api.h>
#include <stdbool.h>
#include <stdlib.h>

bool conf_client_init(conf_client *proxy, GError **err) {
  bool success = true;
  *proxy = org_regolith_trawl1_proxy_new_for_bus_sync(
      G_BUS_TYPE_SESSION, G_DBUS_PROXY_FLAGS_NONE, "org.regolith.Trawl",
      "/org/regolith/Trawl", NULL, err);
  if (*err) {
    success = false;
  }
  return success;
}

bool conf_client_load(conf_client proxy, char *file, bool nocpp, GError **err) {
  return org_regolith_trawl1_call_load_sync(proxy, file, nocpp, NULL, err);
}

bool conf_client_load_cpp(conf_client proxy, char *file, char *cpp,
                          char *cpp_args, GError **err) {
  return org_regolith_trawl1_call_load_cpp_sync(proxy, file, cpp, cpp_args,
                                                NULL, err);
}

bool conf_client_merge(conf_client proxy, char *file, bool nocpp,
                       GError **err) {
  return org_regolith_trawl1_call_merge_sync(proxy, file, nocpp, NULL, err);
}

bool conf_client_merge_cpp(conf_client proxy, char *file, char *cpp,
                           char *cpp_args, GError **err) {
  return org_regolith_trawl1_call_merge_cpp_sync(proxy, file, cpp, cpp_args,
                                                 NULL, err);
}

bool conf_client_query(conf_client proxy, char *query, char **result,
                       GError **err) {
  return org_regolith_trawl1_call_query_sync(proxy, query, result, NULL, err);
}

bool conf_client_get(conf_client proxy, char *key, char **result,
                     GError **err) {
  return org_regolith_trawl1_call_get_resource_sync(proxy, key, result, NULL,
                                                    err);
}

bool conf_client_add_resource(conf_client proxy, char *key, char *value,
                              GError **err) {
  return org_regolith_trawl1_call_add_resource_sync(proxy, key, value, NULL,
                                                    err);
}

bool conf_client_set_resource(conf_client proxy, char *key, char *value,
                              GError **err) {
  return org_regolith_trawl1_call_set_resource_sync(proxy, key, value, NULL,
                                                    err);
}

bool conf_client_remove_all(conf_client proxy, GError **err) {
  return org_regolith_trawl1_call_remove_all_sync(proxy, NULL, err);
}

bool conf_client_remove_one(conf_client proxy, char *key, GError **err) {

  return org_regolith_trawl1_call_remove_one_sync(proxy, key, NULL, err);
}
