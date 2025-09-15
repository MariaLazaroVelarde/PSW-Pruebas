package pe.edu.vallegrande.ms_distribution.application.config;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.fasterxml.jackson.databind.SerializerProvider;

import java.io.IOException;
import java.time.Instant;
import java.time.format.DateTimeFormatter;

/**
 * Serializer personalizado para convertir Instant a string ISO
 */
public class InstantSerializer extends JsonSerializer<Instant> {
    
    @Override
    public void serialize(Instant instant, JsonGenerator jsonGenerator, SerializerProvider serializerProvider) throws IOException {
        if (instant != null) {
            jsonGenerator.writeString(DateTimeFormatter.ISO_INSTANT.format(instant));
        } else {
            jsonGenerator.writeNull();
        }
    }
}