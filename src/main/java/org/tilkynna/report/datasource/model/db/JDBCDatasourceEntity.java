/**
 * *************************************************
 * Copyright (c) 2019, Grindrod Bank Limited
 * License MIT: https://opensource.org/licenses/MIT
 * **************************************************
 */
package org.tilkynna.report.datasource.model.db;

import java.util.Arrays;
import java.util.Objects;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;

import org.hibernate.annotations.ColumnTransformer;
import org.hibernate.annotations.Type;

import lombok.Getter;
import lombok.Setter;

// http://docs.jboss.org/hibernate/orm/5.3/userguide/html_single/Hibernate_User_Guide.html#mapping-column-read-and-write-example
@Getter
@Setter
@Entity
@Table(name = "jdbc")
public class JDBCDatasourceEntity extends DatasourceEntity {

    public JDBCDatasourceEntity() {
        this.setType(DataSourceTypes.Values.JDBC);
    }

    @Column(name = "username", nullable = false)
    @Type(type = "org.hibernate.type.TextType")
    private String username;

    @Column(name = "password", nullable = false)
    @ColumnTransformer(read = "pgp_sym_decrypt_bytea(password, current_setting('secret.key'))", write = "pgp_sym_encrypt_bytea(?, current_setting('secret.key'))")
    @Type(type = "org.hibernate.type.BinaryType")
    private byte[] password;

    @Column(name = "password_hash", nullable = false)
    private String hash = "passwordHash"; // TODO: sort out this is in ERD pgmodel but we decided to descope that functionality for now

    @Column(name = "driver_class", nullable = false)
    @Type(type = "org.hibernate.type.TextType")
    private String driverClass;

    @Column(name = "db_url", nullable = false)
    @Type(type = "org.hibernate.type.TextType")
    private String dbUrl;

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + Arrays.hashCode(password);
        result = prime * result + Objects.hash(dbUrl, driverClass, hash, username);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!super.equals(obj)) {
            return false;
        }
        if (!(obj instanceof JDBCDatasourceEntity)) {
            return false;
        }
        JDBCDatasourceEntity other = (JDBCDatasourceEntity) obj;
        return Objects.equals(dbUrl, other.dbUrl) && Objects.equals(driverClass, other.driverClass) && Objects.equals(hash, other.hash) && Arrays.equals(password, other.password) && Objects.equals(username, other.username);
    }

}
