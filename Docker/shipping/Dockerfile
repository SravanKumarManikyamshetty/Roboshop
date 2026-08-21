FROM maven:3.5
WORKDIR /app
RUN mvn clean package 
COPY pom.xml .
COPY src/ ./src
RUN mv target/shipping-1.0.jar shipping.jar 
EXPOSE 8080
CMD ["java", "-jar", "shipping.jar"]