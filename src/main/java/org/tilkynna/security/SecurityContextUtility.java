/**
 * *************************************************
 * Copyright (c) 2019, Grindrod Bank Limited
 * License MIT: https://opensource.org/licenses/MIT
 * **************************************************
 */
package org.tilkynna.security;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.jwt.Jwt;
import org.springframework.security.jwt.JwtHelper;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.databind.ObjectMapper;

@Component
public class SecurityContextUtility {

    private static final Logger LOGGER = LoggerFactory.getLogger(SecurityContextUtility.class);

    private static final String ANONYMOUS = "anonymous";

    // TODO need to replace securityEnabled/UUID.randomUUID().toString() to null after OCS UI support Auth
    private static boolean securityEnabled = true;

    @Value("${rest.security.enabled}")
    private void setSecurityEnabled(boolean securityEnabled) {
        SecurityContextUtility.securityEnabled = securityEnabled;
    }

    private SecurityContextUtility() {
    }

    public static String getUserName() {
        SecurityContext securityContext = SecurityContextHolder.getContext();
        Authentication authentication = securityContext.getAuthentication();
        String username = ANONYMOUS;

        if (null != authentication) {
            if (authentication.getPrincipal() instanceof UserDetails) {
                UserDetails springSecurityUser = (UserDetails) authentication.getPrincipal();
                username = springSecurityUser.getUsername();

            } else if (authentication.getPrincipal() instanceof String) {
                username = (String) authentication.getPrincipal();

            } else {
                LOGGER.debug("User details not found in Security Context");
            }
        } else {
            LOGGER.debug("Request not authenticated, hence no user name available");
        }

        return username;
    }

    public static Set<String> getUserRoles() {
        return getUserAuthorities();
    }

    public static Set<String> getUserAuthorities() {
        SecurityContext securityContext = SecurityContextHolder.getContext();
        Authentication authentication = securityContext.getAuthentication();
        Set<String> roles = new HashSet<>();

        if (null != authentication) {
            authentication.getAuthorities().forEach(e -> roles.add(e.getAuthority()));
        }
        return roles;
    }

    @SuppressWarnings("unchecked")
    public static Map<String, Object> getClaimsFromJwt() {
        SecurityContext securityContext = SecurityContextHolder.getContext();
        Authentication authentication = securityContext.getAuthentication();

        ObjectMapper objectMapper = new ObjectMapper();

        Map<String, Object> map = objectMapper.convertValue(authentication.getDetails(), Map.class);

        // create a token object to represent the token that is in use.
        Jwt jwt = JwtHelper.decode((String) map.get("tokenValue"));

        try {
            Map<String, Object> claims = objectMapper.readValue(jwt.getClaims(), Map.class);
            LOGGER.debug("Claims VAL {}", claims);

            return claims;
        } catch (IOException e) {
            LOGGER.error(e.getMessage());
        }
        return null;
    }

    // TODO need to replace securityEnabled/UUID.randomUUID().toString() to null after OCS UI support Auth
    public static String getUserIdFromJwt() {
        if (securityEnabled) {
            Map<String, Object> claims = getClaimsFromJwt();

            if (claims != null) {
                return (String) claims.get("sub");
            }
        } else {
            return UUID.randomUUID().toString();
        }

        return null;

    }

    public static UUID getUserUUIDFromJwt() {
        String user = getUserIdFromJwt();
        return (!StringUtils.isEmpty(user)) ? UUID.fromString(user) : null;
    }

    @SuppressWarnings("unchecked")
    public static List<String> getPermissionsFromJwt() {
        Map<String, Object> claims = getClaimsFromJwt();

        // The permissions can be a list, or possibly a single string if there is only one permission. Check for this!!
        if (claims != null) {
            try {
                return (List<String>) claims.get("permission");
            } catch (ClassCastException e) {
                // Could not cast the permission into a list, assuming a single string value. Attempting to create the list from this value.
                List<String> permissions = new ArrayList<>();

                try {
                    String permission = (String) claims.get("permission");

                    if (permission == null) {
                        return new ArrayList<>();
                    }

                    permissions.add(permission);

                    return permissions;
                } catch (Exception a) {
                    LOGGER.error("Exception extracting permission string from JWT token. Exception message: {}", e.getMessage());
                    return new ArrayList<>();
                }
            }

        }

        return new ArrayList<>();
    }
}
