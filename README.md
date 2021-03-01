# Rust Cross-compile

Docker container for cross compiling rust gtk apps to Windows from Linux.

By default will package all required DLLs into a `package.zip` and use the included Windows10 theme.

Typical usage:

1. Create a container with the source mounted the image (which starts the build):

    ```
    docker create -v $(pwd):/home/rust/src --name PROJECTNAME-build rust-crosscompile:latest
    ```

2. Each time you want to build the project, start the Docker container.

    ```
    docker start -ai PROJECTNAME-build
    ```

If there are dependencies you need that are not included in the official image:

1. Modify the Dockerfile to add all your native dependencies
2. Building the image:

    ```
    docker build . -t PROJECTNAME-build-image
    ```

3. Create a container with the source mounted the image (which kicks off the build):

    ```
    docker create -v $(pwd):/home/rust/src --name PROJECTNAME-build PROJECTNAME-build-image
    ```

4. Each time you want to build the project, start the Docker container.

    ```
    docker start -ai PROJECTNAME-build
    ```
