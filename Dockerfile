FROM node:25-bookworm-slim AS install
USER node
WORKDIR /app
COPY server/package.json server/package-lock.json ./
RUN --mount=type=cache,target=/home/node/.npm,uid=1000,gid=1000 \
    npm ci --omit=dev --no-audit --no-fund
FROM install AS build_node
RUN --mount=type=cache,target=/home/node/.npm,uid=1000,gid=1000 \
    npm ci --no-audit --no-fund
COPY server/types/ types/
COPY server/tsconfig.json ./
COPY server/src/ src/
RUN npx tsc
FROM install AS server_node
COPY --from=build_node /app/build /app/build
EXPOSE 4416
ENTRYPOINT ["/usr/local/bin/node", "build/main.js"]