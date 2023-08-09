# Build stage
FROM node:lts-alpine AS build

# Set the working directory for the build stage
WORKDIR /community-server

# Copy the dockerfile's context's community server files to the build stage
COPY . .

# Install dependencies and build the Solid community server
RUN npm ci --unsafe-perm && npm run build

# Runtime stage
FROM node:lts-alpine

# Add contact information for questions about the container
LABEL maintainer="Solid Community Server Docker Image Maintainer <thomas.dupont@ugent.be>"

# Create directories for configuration and data sharing
RUN mkdir /config /data

# Set the working directory for the runtime stage
WORKDIR /community-server

# Copy runtime files from the build stage
COPY --from=build /community-server/package.json .
COPY --from=build /community-server/bin ./bin
COPY --from=build /community-server/config ./config
COPY --from=build /community-server/dist ./dist
COPY --from=build /community-server/node_modules ./node_modules
COPY --from=build /community-server/templates ./templates

# Expose port 3000
EXPOSE 3000

# Set the command to run when the container starts
# Pass the --baseUrl option to the ENTRYPOINT command
ENTRYPOINT [ "node", "bin/server.js", "--baseUrl", "https://communitysolid-lawalsheriffnifemi.b4a.run/" ]

# Set environment variables (you can customize these as needed)
ENV CSS_CONFIG=/config/file.json
ENV CSS_ROOT_FILE_PATH=/data
