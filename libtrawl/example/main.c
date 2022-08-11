#include <client_api.h>
#include <stdio.h>
#include <string.h>

void print_all_resources(conf_client proxy) {
    GError *err = NULL;
    char *query = "", *query_result = ""; // Get all resources
    if (!conf_client_query(proxy, query, &query_result, &err)) {
        fprintf(stderr, "[ERROR] failed to get query %s - %s\n", query, err->message);
    }
    if (!query_result) {
        fprintf(stderr, "[ERROR] no resources found %s - %s\n", query, err->message);
    }
    else {
        printf("\n\nAll Resources:\n%s\n", query_result);
    }
}

int main()
{
    int ret = 0;
    conf_client proxy = NULL;
    GError *err = NULL;
    if(!conf_client_init(&proxy, &err)) {
        fprintf(stderr, "[ERROR] failed to connect - %s\n", err->message);
    }

    print_all_resources(proxy);

    // Insert resource with key="hello" and value = "world"
    if (!conf_client_add_resource(proxy, "hello", "world", &err)) {
        fprintf(stderr, "[ERROR] failed to add resource %s - %s\n", "hello", err->message);
    }

    print_all_resources(proxy);

    // Remove all resources
    conf_client_remove_all(proxy, &err);

    print_all_resources(proxy);
    return ret;
}

