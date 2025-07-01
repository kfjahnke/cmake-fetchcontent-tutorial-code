#include <SFML/Graphics/RenderWindow.hpp>
#include <SFML/System/Clock.hpp>
#include <SFML/Window/Event.hpp>
#include <iostream>

#include <imgui-SFML.h>
#include <imgui.h>

int main() {
    sf::RenderWindow window(sf::VideoMode(sf::Vector2u(1280, 720)), "Dear ImGUI + SFML 3");
    window.setFramerateLimit(60);

    // Handle nodiscard warning: store the return value
    bool imguiInitialized = ImGui::SFML::Init(window);
    if (!imguiInitialized) {
        std::cerr << "Failed to initialize ImGui-SFML!" << std::endl;
        return 1; // Exit if initialization fails
    }

    sf::Clock deltaClock;
    while (window.isOpen()) {
        // SFML 3.x event polling loop:
        // 'pollEvent()' returns an std::optional<sf::Event>.
        // The loop continues as long as 'window.pollEvent()' returns an optional with a value.
        while (std::optional<sf::Event> event = window.pollEvent()) {
            // Pass *both* the window and the dereferenced event to ImGui-SFML::ProcessEvent
            ImGui::SFML::ProcessEvent(window, *event);

            // SFML 3.x: Use is<T>() to check event type
            if (event->is<sf::Event::Closed>()) {
                window.close();
            }
        }

        ImGui::SFML::Update(window, deltaClock.restart());

        ImGui::ShowDemoWindow();

        window.clear();
        ImGui::SFML::Render(window);
        window.display();
    }

    ImGui::SFML::Shutdown();

    return 0;
}
