package pe.edu.vallegrande.ms_distribution.domain.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.math.BigDecimal;
import java.time.Instant;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder 
@Document(collection = "fare")
public class Fare {

    @Id
    private String id;

    private String organizationId;

    private String fareCode;
    private String fareName;
    private String fareType;

    private BigDecimal fareAmount;
    private String status;
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Instant createdAt;
}
