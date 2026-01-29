# --- 第一阶段：构建 ---
    FROM node:lts-alpine AS build-stage
    WORKDIR /build
    RUN npm config set registry https://registry.npmmirror.com
    COPY package.json ./
    # 使用 npm ci 或增加内存限制防止构建崩溃
    RUN npm install
    COPY ./ .
    RUN npm run build
    
    # --- 第二阶段：运行 ---
    FROM nginx:stable-alpine
    # 确保目录一致，nginx 默认路径通常是 /usr/share/nginx/html
    RUN mkdir -p /app
    COPY --from=build-stage /build/dist /app
    # [重要] 确保你的 nginx.conf 里的 root 指向 /app
    COPY --from=build-stage /build/nginx.conf /etc/nginx/nginx.conf
    
    EXPOSE 80
    CMD ["nginx", "-g", "daemon off;"]    