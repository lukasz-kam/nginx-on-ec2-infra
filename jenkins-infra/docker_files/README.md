# Provisioning instructions

1. Check the docker group id on the host

    ```getent group docker```
2. Set the id in the Dockerfile

    ```RUN groupadd -g GROUP_ID docker || true && usermod -aG docker jenkins```

3. Build the agent image and set the image name in the compose.yml

    ```docker build -t jenkins-ag1 .```

4. Start the Jenkins master container and add new agent - update the following values in compose.yml

    ```docker compose up -d jenkins-master```

    ```
        - JENKINS_AGENT_NAME=agent-1
        - JENKINS_SECRET=XXXXXX
    ```

5. Start the jenkins agent

    ```docker compose up -d```


