### Prerequisites
Before running the project, ensure the following prerequisites are met:
1. **Docker Installed**  
    Install Docker on your system. Follow the official installation guide [here](https://docs.docker.com/get-docker/).
2. **Python Installed (Optional)**  
    If you want to test the application locally without Docker, ensure Python 3.9 or higher is installed. Download it [here](https://www.python.org/downloads/).
3. **Basic Knowledge of Docker**  
    Familiarity with Docker commands and concepts is recommended. Refer to the Docker documentation [here](https://docs.docker.com/get-started/).
4. **Internet Connection**  
    Required to pull the base image and install dependencies during the Docker build process.
5. **Code Editor (Optional)**  
    Use a code editor like VS Code for modifying the project files. Download VS Code [here](https://code.visualstudio.com/).
6. **curl or Web Browser**  
    Use `curl` or a web browser to test the application endpoints.

### Files in `projects/docker` Directory.

1. **`app.py`**  
   A Python-based HTTP server that serves an HTML page and provides an endpoint to fetch the container's hostname.  
   - **Endpoints:**
     - `/` - Serves the `index.html` file.
     - `/hostname` - Returns the container's hostname.
   - **Port:** 8080

2. **`Dockerfile`**  
   A Dockerfile to containerize the Python application.  
   - **Base Image:** `python:3.9-slim`
   - **Exposed Port:** 8080
   - **Command:** Runs `app.py` using Python.

3. **`index.html`**  
   A simple HTML file that provides a user interface to interact with the containerized application.  
   - **Features:**
     - Displays the container's hostname.
     - Allows users to input their name and displays a welcome message.

4. **`requirements.txt`**  
   A list of Python dependencies required by the application.  
   - **Dependencies:**
     - `flask`
     - `requests`
     - `numpy`

### How to build and run it?

1. Build the Docker image:
   ```bash
   docker build -t myapp:v1 .
2. to 'run' use following command:
    ```bash
    docker run --rm -it -p 8080:8080 --name=myapp myapp:v1
3. How to test it?
    visit http://127.0.0.1:8080

    ### Suggested Improvements for the Dockerfile

    1. **Use a Specific Version for Base Image**  
        Instead of `python:3.9-slim`, use a specific patch version (e.g., `python:3.9.7-slim`) to ensure consistent builds.

    2. **Reduce Image Size**  
        Use a smaller base image like `python:3.9-alpine` if possible, to minimize the image size.

    3. **Multi-Stage Build**  
        Implement a multi-stage build to separate the build environment from the runtime environment, reducing the final image size.

    4. **Add a Non-Root User**  
        Create and use a non-root user to enhance security.

    5. **Optimize Layer Caching**  
        Reorder instructions to take advantage of Docker's layer caching. For example:
        - Install dependencies before copying application files to avoid rebuilding layers unnecessarily.

    6. **Pin Dependency Versions**  
        Specify exact versions in `requirements.txt` to ensure consistent builds.

    7. **Health Check**  
        Add a `HEALTHCHECK` instruction to monitor the container's health.

    8. **Environment Variables**  
        Use `ENV` instructions to define environment variables for configuration.

    9. **Clean Up Temporary Files**  
        Remove temporary files and caches after installing dependencies to reduce image size.

    10. **Expose Port Explicitly**  
         Use the `EXPOSE` instruction to document the port the application listens on.

    Example snippet for some of these improvements:
    ```dockerfile
    # Add a non-root user
    RUN addgroup -S appgroup && adduser -S appuser -G appgroup
    USER appuser

    # Add a health check
    HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
      CMD curl -f http://localhost:8080/ || exit 1
    ```

    ### References
    - **Dockerfile Reference**: The complete Dockerfile reference is available [here](https://docs.docker.com/engine/reference/builder/).
    - **Docker Health Check**: Learn more about the `HEALTHCHECK` instruction in Docker [here](https://docs.docker.com/engine/reference/builder/#healthcheck).
    - **Running as Non-Root User**: Best practices for running containers as a non-root user can be found [here](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user).
    - **Multi-Stage Builds**: Understand how to use multi-stage builds to optimize Docker images [here](https://docs.docker.com/develop/develop-images/multistage-build/).
    - **Layer Caching**: Learn about Docker's layer caching mechanism [here](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#leverage-build-cache).
    - **Pinning Dependency Versions**: Guidance on pinning dependency versions in Dockerfiles is available [here](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#version-pinning).
    - **Environment Variables**: Learn how to use `ENV` instructions in Dockerfiles [here](https://docs.docker.com/engine/reference/builder/#env).
    - **EXPOSE Instruction**: Documentation on the `EXPOSE` instruction can be found [here](https://docs.docker.com/engine/reference/builder/#expose).
    - **Reducing Image Size**: Tips for minimizing Docker image size are available [here](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#minimize-the-number-of-layers).
    - **Using Alpine Base Image**: Learn about using Alpine Linux as a base image [here](https://hub.docker.com/_/alpine).
    - **Temporary File Cleanup**: Best practices for cleaning up temporary files in Dockerfiles are outlined [here](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#clean-up-temporary-files).
    - **colima**: Learn more about colima [here](https://github.com/abiosoft/colima)

---
> For advanced usage or troubleshooting, review the comments in the scripts and consult the referenced documentation.
>
> v1.0.0 : release date: 2025-05-03