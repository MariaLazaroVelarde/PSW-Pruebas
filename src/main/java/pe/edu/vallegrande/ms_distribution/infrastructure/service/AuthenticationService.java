package pe.edu.vallegrande.ms_distribution.infrastructure.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

/**
 * Servicio para manejar autenticación con APIs externas
 */
@Slf4j
@Service
public class AuthenticationService {

    @Value("${external.apis.ms-users.auth.type:bearer}")
    private String authType;

    @Value("${external.apis.ms-users.auth.token:}")
    private String authToken;

    @Value("${external.apis.ms-users.auth.api-key:}")
    private String apiKey;

    @Value("${external.apis.ms-users.auth.username:}")
    private String username;

    @Value("${external.apis.ms-users.auth.password:}")
    private String password;

    /**
     * Obtiene un token de autenticación válido
     * En una implementación real, esto podría hacer una llamada de login
     */
    public Mono<String> getValidToken() {
        if (!authToken.isEmpty()) {
            return Mono.just(authToken);
        }
        
        // Aquí se podría implementar lógica para obtener un token
        // Por ejemplo, llamando a un endpoint de login
        log.warn("No se ha configurado un token de autenticación válido");
        return Mono.empty();
    }

    /**
     * Verifica si la autenticación está configurada
     */
    public boolean isAuthenticationConfigured() {
        return switch (authType.toLowerCase()) {
            case "bearer" -> !authToken.isEmpty();
            case "apikey" -> !apiKey.isEmpty();
            case "basic" -> !username.isEmpty();
            default -> false;
        };
    }

    /**
     * Obtiene el tipo de autenticación configurado
     */
    public String getAuthType() {
        return authType;
    }

    /**
     * Agrega headers de autenticación a una request WebClient
     */
    public WebClient.RequestHeadersSpec<?> addAuthHeaders(WebClient.RequestHeadersSpec<?> spec) {
        return switch (authType.toLowerCase()) {
            case "bearer" -> !authToken.isEmpty() ? 
                spec.header("Authorization", "Bearer " + authToken) : spec;
            case "apikey" -> !apiKey.isEmpty() ? 
                spec.header("X-API-Key", apiKey) : spec;
            case "basic" -> !username.isEmpty() ? 
                spec.header("Authorization", "Basic " + 
                    java.util.Base64.getEncoder().encodeToString(
                        (username + ":" + password).getBytes())) : spec;
            default -> spec;
        };
    }
}