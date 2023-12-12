# Copyright 2018-2023 the Kubeapps contributors.
# SPDX-License-Identifier: Apache-2.0

FROM bitnami/node:18.18.0 AS build
WORKDIR /app

ARG VERSION=2.9.0
RUN wget -O- https://github.com/vmware-tanzu/kubeapps/archive/refs/tags/v${VERSION}.tar.gz | tar xzf - --strip-components=2 kubeapps-${VERSION}/dashboard

RUN sed -i 's/"Kubeapps",/"Cozystack",/' lang/en.json
RUN sed -i 's/Kubeapps/Cozystack/g' public/site.webmanifest
RUN sed -i 's/Welcome To Kubeapps/Welcome To Cozystack/g' ./src/components/LoginForm/LoginForm.tsx ./src/components/AppList/AppListGrid.tsx ./src/components/AppList/AppList.test.tsx
RUN sed -i '/by VMware/,/ \.$/d' src/components/Header/Menu.tsx
RUN sed -i 's/#304250/#202124/g' src/components/HeadManager/HeadManager.tsx

RUN yarn install --frozen-lockfile

RUN yarn run prettier-check && yarn run ts-compile-check
RUN yarn run build

RUN sed -i 's/hsl(206, 25%, 25%)/hsl(225, 6%, 13%)/g' $(grep -rl 'hsl(206, 25\%, 25\%)')
RUN sed -i 's/#304250/#202124/g' $(grep -rl "#304250")

FROM bitnami/nginx:1.25.2
COPY --from=build /app/build /app
