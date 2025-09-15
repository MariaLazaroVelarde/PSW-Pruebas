package pe.edu.vallegrande.ms_distribution.infrastructure.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import pe.edu.vallegrande.ms_distribution.infrastructure.dto.external.AdminUserResponse;
import pe.edu.vallegrande.ms_distribution.infrastructure.dto.external.MsUsersApiResponse;
import pe.edu.vallegrande.ms_distribution.infrastructure.exception.CustomException;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.retry.Retry;

import java.time.Duration;
import java.util.List;
import java.util.Map;

/**
 * Servicio para consultar información de organizaciones y usuarios
 * desde el microservicio MS-USERS
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OrganizationService {

    @Qualifier("msUsersWebClient")
    private final WebClient msUsersWebClient;
    
    private final ObjectMapper objectMapper;

    @Value("${external.apis.ms-users.endpoints.admins}")
    private String adminsEndpoint;

    @Value("${external.apis.ms-users.endpoints.users}")
    private String usersEndpoint;

    @Value("${external.apis.ms-users.endpoints.clients}")
    private String clientsEndpoint;

    @Value("${external.apis.ms-users.endpoints.user-by-id}")
    private String userByIdEndpoint;

    /**
     * Obtiene la lista de administradores autorizados por organización
     * 
     * @param organizationId ID de la organización
     * @return Flux de usuarios administradores
     */
    public Flux<AdminUserResponse> getAuthorizedAdminsByOrganization(String organizationId) {
        log.debug("Obteniendo administradores autorizados para organización: {}", organizationId);
        
        var request = msUsersWebClient
                .get()
                .uri(adminsEndpoint, organizationId);
                
        return request
                .retrieve()
                .onStatus(HttpStatus.NOT_FOUND::equals, response -> {
                    log.warn("Organización no encontrada: {}", organizationId);
                    return Mono.error(new CustomException(404, "ORGANIZATION_NOT_FOUND", 
                            "No se encontró la organización: " + organizationId));
                })
                .bodyToMono(MsUsersApiResponse.class)
                .flatMapMany(response -> {
                    if (response.getSuccess() && response.getData() != null) {
                        return Flux.fromIterable(response.getData())
                                .cast(Map.class)
                                .map(map -> mapToAdminUserResponse((Map<String, Object>) map));
                    } else {
                        log.warn("Respuesta de API sin éxito: {}", response.getMessage());
                        return Flux.empty();
                    }
                })
                .retryWhen(Retry.backoff(3, Duration.ofSeconds(1))
                        .filter(throwable -> throwable instanceof WebClientResponseException.InternalServerError))
                .doOnNext(admin -> log.debug("Admin encontrado: {}", admin.toString()))
                .doOnError(error -> log.error("Error al obtener administradores: {}", error instanceof Throwable ? ((Throwable)error).getMessage() : error.toString()));
    }

    /**
     * Verifica si un usuario es administrador autorizado de una organización
     * 
     * @param organizationId ID de la organización
     * @param userId ID del usuario a verificar
     * @return Mono<Boolean> indicando si es administrador autorizado
     */
    public Mono<Boolean> isAuthorizedAdmin(String organizationId, String userId) {
        log.debug("Verificando si usuario {} es admin autorizado de organización {}", userId, organizationId);
        
        return getAuthorizedAdminsByOrganization(organizationId)
                .any(admin -> userId.equals(admin.getId()))
                .doOnNext(isAuthorized -> log.debug("Usuario {} {} autorizado para organización {}", 
                        userId, isAuthorized ? "es" : "no es", organizationId))
                .onErrorReturn(false);
    }

    /**
     * Obtiene un administrador específico por su ID y organización
     * 
     * @param organizationId ID de la organización
     * @param adminId ID del administrador
     * @return Mono del administrador encontrado
     */
    public Mono<AdminUserResponse> getAdminById(String organizationId, String adminId) {
        log.debug("Buscando administrador {} en organización {}", adminId, organizationId);
        
        return getAuthorizedAdminsByOrganization(organizationId)
                .filter(admin -> adminId.equals(admin.getId()))
                .next()
                .switchIfEmpty(Mono.error(new CustomException(404, "ADMIN_NOT_FOUND", 
                        "Administrador no encontrado o no autorizado")));
    }

    /**
     * Verifica si una organización existe y tiene administradores
     * 
     * @param organizationId ID de la organización
     * @return Mono<Boolean> indicando si la organización existe
     */
    public Mono<Boolean> organizationExists(String organizationId) {
        log.debug("Verificando existencia de organización: {}", organizationId);
        
        return getAuthorizedAdminsByOrganization(organizationId)
                .hasElements()
                .doOnNext(exists -> log.debug("Organización {} {}", organizationId, 
                        exists ? "existe" : "no existe"))
                .onErrorReturn(false);
    }

    /**
     * Obtiene usuarios de una organización desde /internal/organizations/{organizationId}/users
     */
    public Flux<Object> getOrganizationUsers(String organizationId) {
        log.debug("Obteniendo usuarios de organización: {}", organizationId);
        
        var request = msUsersWebClient
                .get()
                .uri(usersEndpoint, organizationId);
                
        return request
                .retrieve()
                .bodyToMono(MsUsersApiResponse.class)
                .flatMapMany(response -> {
                    if (response.getSuccess() && response.getData() != null) {
                        return Flux.fromIterable(response.getData());
                    } else {
                        log.warn("Respuesta de API sin éxito: {}", response.getMessage());
                        return Flux.empty();
                    }
                })
                .doOnError(error -> log.error("Error al obtener usuarios: {}", error instanceof Throwable ? ((Throwable)error).getMessage() : error.toString()));
    }

    /**
     * Obtiene clientes de una organización desde /internal/organizations/{organizationId}/clients
     */
    public Flux<Object> getOrganizationClients(String organizationId) {
        log.debug("Obteniendo clientes de organización: {}", organizationId);
        
        var request = msUsersWebClient
                .get()
                .uri(clientsEndpoint, organizationId);
                
        return request
                .retrieve()
                .bodyToMono(MsUsersApiResponse.class)
                .flatMapMany(response -> {
                    if (response.getSuccess() && response.getData() != null) {
                        return Flux.fromIterable(response.getData());
                    } else {
                        log.warn("Respuesta de API sin éxito: {}", response.getMessage());
                        return Flux.empty();
                    }
                })
                .doOnError(error -> log.error("Error al obtener clientes: {}", error instanceof Throwable ? ((Throwable)error).getMessage() : error.toString()));
    }

    /**
     * Obtiene un usuario por su ID desde /internal/users/{userId}
     */
    public Mono<Object> getUserById(String userId) {
        log.debug("Obteniendo usuario por ID: {}", userId);
        
        var request = msUsersWebClient
                .get()
                .uri(userByIdEndpoint, userId);
                
        return request
                .retrieve()
                .bodyToMono(Object.class)
                .doOnError(error -> log.error("Error al obtener usuario por ID: {}", error instanceof Throwable ? ((Throwable)error).getMessage() : error.toString()));
    }
    
    /**
     * Mapea un Map (LinkedHashMap) a AdminUserResponse
     */
    private AdminUserResponse mapToAdminUserResponse(Map<String, Object> map) {
        try {
            return objectMapper.convertValue(map, AdminUserResponse.class);
        } catch (Exception e) {
            log.error("Error al mapear AdminUserResponse: {}", e.getMessage());
            throw new CustomException(500, "MAPPING_ERROR", 
                    "Error al mapear datos de administrador: " + e.getMessage());
        }
    }
}
