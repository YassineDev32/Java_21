package com.example.demosgabs.service;
import org.springframework.stereotype.Service;

@Service
public class WelcomeServiceImpl implements WelcomeService {
    @Override
    public String getWelcomeMessage() {
        return "Bienvenue sur l'API DemoSgabs !";
    }
}

