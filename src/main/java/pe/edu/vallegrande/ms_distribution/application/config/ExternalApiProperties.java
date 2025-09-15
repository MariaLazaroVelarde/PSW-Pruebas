package pe.edu.vallegrande.ms_distribution.application.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * Propiedades de configuración para APIs externas
 */
@Data
@Configuration
@ConfigurationProperties(prefix = "external.apis")
public class ExternalApiProperties {

    private MsUsers msUsers = new MsUsers();

    @Data
    public static class MsUsers {
        private String baseUrl = "https://lab.vallegrande.edu.pe/jass/ms-users";
        private Endpoints endpoints = new Endpoints();
        private Auth auth = new Auth();
        private Timeout timeout = new Timeout();

        @Data
        public static class Endpoints {
            private String admins = "/internal/organizations/{organizationId}/admins";
            private String users = "/internal/organizations/{organizationId}/users";
            private String clients = "/internal/organizations/{organizationId}/clients";
            private String userById = "/internal/users/{userId}";
        }

        @Data
        public static class Auth {
            private String type = "bearer";
            private String token = "";
            private String apiKey = "";
            private String username = "";
            private String password = "";
        }

        @Data
        public static class Timeout {
            private int connection = 10000;
            private int read = 15000;
        }
    }
}