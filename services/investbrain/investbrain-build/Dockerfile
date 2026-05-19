FROM investbrainapp/investbrain:latest

# Install dependencies
RUN apk add patch diffutils

# Copy patches
COPY ./patch/app.php.patch /var/app/app.php.patch
COPY ./patch/AppServiceProvider.php.patch /var/app/AppServiceProvider.php.patch

# Apply patches and remove them
RUN patch /var/app/bootstrap/app.php < /var/app/app.php.patch && \
    patch /var/app/app/Providers/AppServiceProvider.php < /var/app/AppServiceProvider.php.patch && \
    rm /var/app/app.php.patch /var/app/AppServiceProvider.php.patch

# Delegate back to main entrypoint script
ENTRYPOINT ["/bin/sh", "./docker/entrypoint.sh"]
