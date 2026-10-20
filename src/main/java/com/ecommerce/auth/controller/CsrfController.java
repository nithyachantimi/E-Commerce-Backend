package com.ecommerce.auth.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Initializes the readable CSRF cookie used by the browser before unsafe API requests. */
@RestController
@RequestMapping("/api")
public class CsrfController {

    @GetMapping("/csrf")
    public ResponseEntity<Void> csrf(CsrfToken csrfToken) {
        // Resolving the token causes CookieCsrfTokenRepository to write its cookie.
        csrfToken.getToken();
        return ResponseEntity.noContent().build();
    }
}
