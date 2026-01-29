# --- 第一阶段：构建 ---
    FROM node:lts-alpine AS build-stage

    # 1. 安装 pnpm
    # 使用 Corepack 是 Node.js 官方推荐的安装 pnpm 方式，速度最快
    RUN corepack enable && corepack prepare pnpm@latest --activate
    
    WORKDIR /build
    
    # 2. 设置 pnpm 镜像源
    ENV PNPM_HOME="/pnpm"
    ENV PATH="$PNPM_HOME:$PATH"
    RUN pnpm config set registry https://registry.npmmirror.com
    
    # 3. 拷贝依赖描述文件
    # 重点：pnpm 使用 pnpm-lock.yaml 而不是 package-lock.json
    COPY package.json pnpm-lock.yaml ./
    
    # 4. 安装依赖
    # --frozen-lockfile 确保在 CI 环境中不更新 lock 文件，速度更快更安全
    RUN pnpm install --frozen-lockfile
    
    # 5. 拷贝源代码并构建
    COPY ./ .
    
    # [针对免费套餐优化] 限制 Node 构建时的内存使用，防止在 Docker 内部崩溃
    ENV NODE_OPTIONS="--max-old-space-size=768"
    RUN pnpm run build
    
    # --- 第二阶段：运行 ---
    FROM nginx:stable-alpine
    # 确保目录一致
    RUN mkdir -p /app
    COPY --from=build-stage /build/dist /app
    # 确保项目根目录下有 nginx.conf
    COPY --from=build-stage /build/nginx.conf /etc/nginx/nginx.conf
    
    EXPOSE 80
    CMD ["nginx", "-g", "daemon off;"]