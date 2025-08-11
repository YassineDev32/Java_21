# Étape 1 : build de l'application avec Maven
FROM maven:3.9.3-eclipse-temurin-21 AS build

# Copier les fichiers sources dans le conteneur
WORKDIR /app
COPY pom.xml .
COPY src ./src

# Compiler et packager l'application (skip tests pour plus rapide, tu peux enlever -DskipTests)
RUN mvn clean package -DskipTests

# Étape 2 : créer l'image finale avec Java runtime (JRE)
FROM eclipse-temurin:21-jre

# Dossier de travail dans le conteneur final
WORKDIR /app

# Copier le jar construit depuis l'étape de build
COPY --from=build /app/target/*.jar app.jar

# Exposer le port (exemple 8080)
EXPOSE 8080

# Commande pour lancer l'application
ENTRYPOINT ["java", "-jar", "app.jar"]
