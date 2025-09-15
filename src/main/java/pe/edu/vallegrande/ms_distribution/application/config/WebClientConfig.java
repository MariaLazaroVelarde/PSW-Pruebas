package pe.edu.vallegrande.ms_distribution.application.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.netty.channel.ChannelOption;
import io.netty.handler.timeout.ReadTimeoutHandler;
import io.netty.handler.timeout.WriteTimeoutHandler;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.netty.http.client.HttpClient;

import java.time.Duration;
import java.util.concurrent.TimeUnit;

/**
 * Configuración para WebClient usado para consumir APIs internas
 */
@Configuration
public class WebClientConfig {

    @Value("${external.apis.ms-users.base-url:https://lab.vallegrande.edu.pe/jass/ms-users}")
    private String msUsersBaseUrl;

    @Value("${external.apis.ms-users.timeout.connection:5000}")
    private int connectionTimeout;

    @Value("${external.apis.ms-users.timeout.read:10000}")
    private int readTimeout;

    @Bean(name = "msUsersWebClient")
    public WebClient msUsersWebClient() {
        HttpClient httpClient = HttpClient.create()
                .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, connectionTimeout)
                .responseTimeout(Duration.ofMillis(readTimeout))
                .doOnConnected(conn -> 
                    conn.addHandlerLast(new ReadTimeoutHandler(readTimeout, TimeUnit.MILLISECONDS))
                        .addHandlerLast(new WriteTimeoutHandler(readTimeout, TimeUnit.MILLISECONDS)));

        return WebClient.builder()
                .baseUrl(msUsersBaseUrl)
                .clientConnector(new ReactorClientHttpConnector(httpClient))
                .defaultHeader("Content-Type", "application/json")
                .defaultHeader("Accept", "application/json")
                .build();
    }

    @Bean(name = "defaultWebClient")
    public WebClient defaultWebClient() {
        return WebClient.builder().build();
    }
}