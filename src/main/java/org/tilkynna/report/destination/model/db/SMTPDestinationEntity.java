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
@Table(name = "smtp")
public class SMTPDestinationEntity extends DestinationEntity {

    public SMTPDestinationEntity() {
        super();
        this.setType(DestinationTypes.Values.SMTP);
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

    @Column(name = "from_address", nullable = false)
    @Type(type = "org.hibernate.type.TextType")
    private String fromAddress;

    @Override
    public void setDefaultDestinationParameters() {
        String destParameterType = "String";
        String validationRegExStr = "TODO:: validation RM#923";
        addDestinationParameter(createDestinationParameter(destParameterType, "to email address", "to", true, validationRegExStr));
        addDestinationParameter(createDestinationParameter(destParameterType, "cc email address", "cc", false, validationRegExStr));
        addDestinationParameter(createDestinationParameter(destParameterType, "bcc email address", "bcc", false, validationRegExStr));
        addDestinationParameter(createDestinationParameter(destParameterType, "subject email address", "subject", true, validationRegExStr));
        addDestinationParameter(createDestinationParameter(destParameterType, "body email address", "body", false, validationRegExStr));
    }

    private DestinationParameterEntity createDestinationParameter(String dataType, String desc, String name, boolean required, String validation) {
        DestinationParameterEntity toDestinationParameter = new DestinationParameterEntity();
        toDestinationParameter.setDataType(dataType);
        toDestinationParameter.setDescription(desc);
        toDestinationParameter.setDestination(this);
        toDestinationParameter.setName(name);
        toDestinationParameter.setRequired(required);
        toDestinationParameter.setValidation(validation);
        return toDestinationParameter;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + Arrays.hashCode(password);
        result = prime * result + Objects.hash(fromAddress, hash, host, port, username);
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
        if (!(obj instanceof SMTPDestinationEntity)) {
            return false;
        }
        SMTPDestinationEntity other = (SMTPDestinationEntity) obj;
        return Objects.equals(fromAddress, other.fromAddress) && Objects.equals(hash, other.hash) && Objects.equals(host, other.host) && Arrays.equals(password, other.password) && Objects.equals(port, other.port)
                && Objects.equals(username, other.username);
    }

}
