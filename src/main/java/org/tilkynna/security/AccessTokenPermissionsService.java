/****************************************************
* Copyright (c) 2019, Grindrod Bank Limited
* License MIT: https://opensource.org/licenses/MIT
****************************************************/
package org.tilkynna.security;

public interface AccessTokenPermissionsService {
    public Boolean hasPermission(String permission);
}
