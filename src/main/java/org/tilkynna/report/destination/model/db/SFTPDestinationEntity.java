/**
 * *************************************************
 * Copyright (c) 2019, Grindrod Bank Limited
 * License MIT: https://opensource.org/licenses/MIT
 * **************************************************
 */
package org.tilkynna.report.destination.model.db;

import java.util.Arrays;
import java.util.Objects;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;

import org.hibernate.annotations.ColumnTransformer;
import org.hibernate.annotations.Type;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "sftp")
public class SFTPDestinationEntity extends DestinationEntity {

    public SFTPDestinationEntity() {
        super();
        this.setType(DestinationTypes.Values.SFTP);
    }

    @Column(name = "host", nullable = false)
    @Type(type = "org.hibernate.type.TextType")
    private String host;

    @Column(name = "port", nullable = false)
    private Short port;

    @Column(name = "username", nullable = false)
    @Type(type = "org.hibernate.type.TextType")
    private String username;

    @Column(name = "password", nullable = false)
    @ColumnTransformer(read = "pgp_sym_decrypt_bytea(password, current_setting('secret.key'))", write = "pgp_sym_encrypt_bytea(?, current_setting('secret.key'))")
    @Type(type = "org.hibernate.type.BinaryType")
    private byte[] password;

    @Column(name = "password_hash", nullable = false)
    private String hash = "passwordHash"; // TODO: sort out this is in ERD pgmodel but we decided to descope that functionality for now

    @Column(name = "working_directory", nullable = false)
    @Type(type = "org.hibernate.type.TextType")
    private String workingDirectory;

    @Override
    public void setDefaultDestinationParameters() {
        DestinationParameterEntity destinationParameter = new DestinationParameterEntity();
        destinationParameter.setDataType("String");
        destinationParameter.setDescription("path on SFTP server under root folder");
        destinationParameter.setDestination(this);
        destinationParameter.setName("path");
        destinationParameter.setRequired(false);
        destinationParameter.setValidation("TODO:: validation RM#923");

        addDestinationParameter(destinationParameter);
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + Arrays.hashCode(password);
        result = prime * result + Objects.hash(hash, host, port, username, workingDirectory);
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
        if (!(obj instanceof SFTPDestinationEntity)) {
            return false;
        }
        SFTPDestinationEntity other = (SFTPDestinationEntity) obj;
        return Objects.equals(hash, other.hash) && Objects.equals(host, other.host) && Arrays.equals(password, other.password) && Objects.equals(port, other.port) && Objects.equals(username, other.username)
                && Objects.equals(workingDirectory, other.workingDirectory);
    }

}
