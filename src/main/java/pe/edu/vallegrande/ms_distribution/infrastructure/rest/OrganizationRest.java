package pe.edu.vallegrande.ms_distribution.infrastructure.rest;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.vallegrande.ms_distribution.infrastructure.dto.external.AdminUserResponse;
import pe.edu.vallegrande.ms_distribution.infrastructure.service.OrganizationService;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * Controlador para gestión de organizaciones y validaciones
 */
@Tag(name = "Organization", description = "API para gestión de organizaciones")
@RestController
@RequestMapping("/api/organizations")
@RequiredArgsConstructor
public class OrganizationRest {

    private final OrganizationService organizationService;

    @Operation(summary = "Obtener administradores autorizados", 
               description = "Obtiene la lista de administradores autorizados para una organización")
    @GetMapping("/{organizationId}/admins")
    public Flux<AdminUserResponse> getAuthorizedAdmins(
            @Parameter(description = "ID de la organización") 
            @PathVariable String organizationId) {
        return organizationService.getAuthorizedAdminsByOrganization(organizationId);
    }

    @Operation(summary = "Verificar administrador autorizado", 
               description = "Verifica si un usuario es administrador autorizado de una organización")
    @GetMapping("/{organizationId}/admins/{userId}/authorized")
    public Mono<ResponseEntity<Boolean>> isAuthorizedAdmin(
            @Parameter(description = "ID de la organización") 
            @PathVariable String organizationId,
            @Parameter(description = "ID del usuario") 
            @PathVariable String userId) {
        return organizationService.isAuthorizedAdmin(organizationId, userId)
                .map(ResponseEntity::ok);
    }

    @Operation(summary = "Obtener administrador específico", 
               description = "Obtiene un administrador específico por su ID y organización")
    @GetMapping("/{organizationId}/admins/{adminId}")
    public Mono<AdminUserResponse> getAdminById(
            @Parameter(description = "ID de la organización") 
            @PathVariable String organizationId,
            @Parameter(description = "ID del administrador") 
            @PathVariable String adminId) {
        return organizationService.getAdminById(organizationId, adminId);
    }

    @Operation(summary = "Verificar existencia de organización", 
               description = "Verifica si una organización existe y tiene administradores")
    @GetMapping("/{organizationId}/exists")
    public Mono<ResponseEntity<Boolean>> organizationExists(
            @Parameter(description = "ID de la organización") 
            @PathVariable String organizationId) {
        return organizationService.organizationExists(organizationId)
                .map(ResponseEntity::ok);
    }

    @Operation(summary = "Obtener usuarios de organización", 
               description = "Obtiene todos los usuarios de una organización")
    @GetMapping("/{organizationId}/users")
    public Flux<Object> getOrganizationUsers(
            @Parameter(description = "ID de la organización") 
            @PathVariable String organizationId) {
        return organizationService.getOrganizationUsers(organizationId);
    }

    @Operation(summary = "Obtener clientes de organización", 
               description = "Obtiene todos los clientes de una organización")
    @GetMapping("/{organizationId}/clients")
    public Flux<Object> getOrganizationClients(
            @Parameter(description = "ID de la organización") 
            @PathVariable String organizationId) {
        return organizationService.getOrganizationClients(organizationId);
    }

    @Operation(summary = "Obtener usuario por ID", 
               description = "Obtiene un usuario específico por su ID")
    @GetMapping("/users/{userId}")
    public Mono<Object> getUserById(
            @Parameter(description = "ID del usuario") 
            @PathVariable String userId) {
        return organizationService.getUserById(userId);
    }

    @Operation(summary = "Endpoint de prueba", 
               description = "Endpoint simple para probar que la API funciona")
    @GetMapping("/test")
    public Mono<ResponseEntity<String>> testEndpoint() {
        return Mono.just(ResponseEntity.ok("API funcionando correctamente - sin autenticación requerida"));
    }
}