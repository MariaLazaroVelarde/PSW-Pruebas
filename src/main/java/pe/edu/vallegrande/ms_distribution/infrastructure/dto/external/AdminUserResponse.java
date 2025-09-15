package pe.edu.vallegrande.ms_distribution.infrastructure.dto.external;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * DTO para respuesta de usuarios administradores del MS-USERS
 * Basado en la estructura real de la API
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class AdminUserResponse {
    private String id;
    private String userCode;
    private String firstName;
    private String lastName;
    private String documentType;
    private String documentNumber;
    private String email;
    private String phone;
    private String address;
    private List<String> roles;
    private String status;
    private String createdAt;
    private String updatedAt;
    
    // Objetos anidados opcionales de la respuesta completa
    private OrganizationInfo organization;
    private ZoneInfo zone;
    private StreetInfo street;
    
    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class OrganizationInfo {
        private String organizationId;
        private String organizationCode;
        private String organizationName;
        private String legalRepresentative;
        private String phone;
        private String address;
        private String status;
    }
    
    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class ZoneInfo {
        private String zoneId;
        private String zoneCode;
        private String description;
        private String zoneName;
        private String status;
    }
    
    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class StreetInfo {
        private String streetId;
        private String streetCode;
        private String streetName;
        private String streetType;
        private String status;
    }
}