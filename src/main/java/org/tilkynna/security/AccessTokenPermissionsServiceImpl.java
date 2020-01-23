/**
 * *************************************************
 * Copyright (c) 2019, Grindrod Bank Limited
 * License MIT: https://opensource.org/licenses/MIT
 * **************************************************
 */
package org.tilkynna.security;


import java.util.List;

import org.springframework.stereotype.Service;

@Service
public class AccessTokenPermissionsServiceImpl implements AccessTokenPermissionsService {

    public Boolean hasPermission(String permission) {
        if (permission == null) {
            return false;
        }
        
        List<String> permissions = SecurityContextUtility.getPermissionsFromJwt();

        if (permissions == null) {
            return false;
        }

        return permissions.contains(permission);
    }
}
