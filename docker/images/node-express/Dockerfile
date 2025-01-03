FROM node:22-bookworm-slim AS base

# Deps
FROM base AS deps

RUN corepack disable && corepack enable
RUN corepack enable pnpm

WORKDIR /home/node/app

COPY apps/backend /home/node/app/apps/backend
COPY packages/shared /home/node/app/packages/shared
COPY package.json /home/node/app/
COPY pnpm-lock.yaml /home/node/app/
COPY pnpm-workspace.yaml /home/node/app/
COPY tsconfig.json /home/node/app/

# Test
FROM mcr.microsoft.com/playwright:v1.49.0-noble AS test

WORKDIR /home/node/app

COPY --from=deps /home/node/app /home/node/app

RUN corepack disable && corepack enable
RUN corepack enable pnpm
RUN corepack use pnpm@latest

RUN pnpm install --frozen-lockfile --prefer-frozen-lockfile && pnpm store prune

# Build
FROM deps AS build

WORKDIR /home/node/app

RUN pnpm install --frozen-lockfile --prefer-frozen-lockfile && pnpm store prune

RUN pnpm backend:build

# Deploy
FROM build AS deploy

RUN pnpm backend:deploy

# Production
FROM base AS production

ARG PORT

ENV TINI_VERSION=v0.19.0
ENV PATH=/home/node/app/node_modules/.bin:$PATH

ADD --chmod=755 https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini

EXPOSE ${PORT}

USER node

WORKDIR /home/node/app

COPY --from=deploy /home/node/app/output /home/node/app/

ENTRYPOINT ["/usr/local/bin/tini", "--"]

CMD ["node", "/home/node/app/dist/index.js"]
