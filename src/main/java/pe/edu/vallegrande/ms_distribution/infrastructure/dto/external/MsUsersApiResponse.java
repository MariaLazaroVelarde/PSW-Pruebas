package pe.edu.vallegrande.ms_distribution.infrastructure.dto.external;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * DTO para respuesta estándar de la API externa MS-USERS
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MsUsersApiResponse<T> {
    private Boolean success;
    private String message;
    private List<T> data;
}