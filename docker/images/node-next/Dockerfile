FROM node:22-bookworm-slim AS base

# Deps
FROM base AS deps

RUN apt-get update && apt-get install -y ca-certificates
RUN corepack disable && corepack enable
RUN corepack enable pnpm

WORKDIR /home/node/app

COPY apps/backend /home/node/app/apps/backend
COPY apps/frontend /home/node/app/apps/frontend
COPY packages/shared /home/node/app/packages/shared
COPY package.json /home/node/app/
COPY pnpm-lock.yaml /home/node/app/
COPY pnpm-workspace.yaml /home/node/app/
COPY tsconfig.json /home/node/app/

RUN pnpm install --frozen-lockfile --prefer-frozen-lockfile && pnpm store prune

# Test
FROM mcr.microsoft.com/playwright:v1.49.0-noble AS test

WORKDIR /home/node/app

COPY --from=deps /home/node/app /home/node/app

RUN corepack disable && corepack enable
RUN corepack enable pnpm
RUN corepack use pnpm@latest

# Build
FROM deps AS build

ARG NODE_ENV
ARG NEXT_PUBLIC_FRONTEND_URL
ARG NEXT_PUBLIC_BACKEND_URL
ARG NEXT_PUBLIC_COOKIE_DOMAIN
ARG NEXT_PUBLIC_AWS_CLOUDFRONT_DISTRIBUTION_URL
ARG NEXT_PUBLIC_LOG_LEVEL
ARG NEXT_PUBLIC_SITE_NAME

WORKDIR /home/node/app

RUN echo "NODE_ENV=${NODE_ENV}" > /home/node/app/apps/frontend/.env \
    && echo "NEXT_PUBLIC_FRONTEND_URL=${NEXT_PUBLIC_FRONTEND_URL}" >> /home/node/app/apps/frontend/.env \
    && echo "NEXT_PUBLIC_BACKEND_URL=${NEXT_PUBLIC_BACKEND_URL}" >> /home/node/app/apps/frontend/.env \
    && echo "NEXT_PUBLIC_COOKIE_DOMAIN=${NEXT_PUBLIC_COOKIE_DOMAIN}" >> /home/node/app/apps/frontend/.env \
    && echo "NEXT_PUBLIC_AWS_CLOUDFRONT_DISTRIBUTION_URL=${NEXT_PUBLIC_AWS_CLOUDFRONT_DISTRIBUTION_URL}" >> /home/node/app/apps/frontend/.env \
    && echo "NEXT_PUBLIC_LOG_LEVEL=${NEXT_PUBLIC_LOG_LEVEL}" >> /home/node/app/apps/frontend/.env \
    && echo "NEXT_PUBLIC_SITE_NAME=${NEXT_PUBLIC_SITE_NAME}" >> /home/node/app/apps/frontend/.env

RUN pnpm frontend:build

# Production
FROM base AS production

ARG PORT

ENV TINI_VERSION=v0.19.0
ENV NEXT_TELEMETRY_DISABLED=1
ENV HOSTNAME="0.0.0.0"
ENV PORT=${PORT}
ENV PATH=/home/node/app/node_modules/.bin:$PATH

ADD --chmod=755 https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini

EXPOSE ${PORT}

USER node

WORKDIR /home/node/app

RUN mkdir .next && chown node:node .next

COPY --chown=node:node --from=build /home/node/app/apps/frontend/.next/standalone ./

ENTRYPOINT ["/usr/local/bin/tini", "--"]
CMD ["node", "/home/node/app/apps/frontend/server.js"]
