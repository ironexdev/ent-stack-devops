FROM node:22-bookworm-slim

RUN corepack disable && corepack enable
RUN corepack enable pnpm

RUN npm install -g typescript

WORKDIR /home/node/app

COPY --chown=node:node apps/backend/drizzle /home/node/app/drizzle
COPY --chown=node:node apps/backend/drizzle.config.ts /home/node/app/drizzle.config.ts
COPY --chown=node:node package.json /home/node/app/
COPY --chown=node:node pnpm-lock.yaml /home/node/app/
COPY --chown=node:node pnpm-workspace.yaml /home/node/app/

RUN pnpm add -w drizzle-kit drizzle-orm

ENV PATH=/home/node/app/node_modules/.bin:$PATH