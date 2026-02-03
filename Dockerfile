# --- 生产运行阶段 ---
    FROM nginx:stable-alpine

    # 创建应用目录
    RUN mkdir -p /app
    
    # [核心修改] 直接从宿主机的 dist 目录拷贝
    # 注意：这要求你在 docker build 之前先在外面运行 pnpm build
    COPY dist/ /app/
    
    # 拷贝 nginx 配置
    COPY nginx.conf /etc/nginx/nginx.conf
    
    EXPOSE 80
    CMD ["nginx", "-g", "daemon off;"]