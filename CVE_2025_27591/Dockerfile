# Builder stage: Rust toolchain
FROM rust:1.76-slim AS builder

# Install system dependencies for building below (libbpf, LLVM, etc.)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential git pkg-config libssl-dev ca-certificates \
      libelf-dev zlib1g-dev clang llvm && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/below

# Clone and select version
RUN git clone https://github.com/facebookincubator/below.git /opt/below
RUN cd /opt/below && git checkout v0.8.1

# Install LLVM/Clang 15 for eBPF builds
RUN apt-get update && \
    apt-get install -y clang-15 llvm-15 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-15 100 && \
    update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-15 100

RUN rustup component add rustfmt

# Build Rust binary in release mode
RUN cd /opt/below && cargo build --release



# Runtime stage
FROM debian:bookworm
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime tools + Apache + CGI
RUN apt-get update && \
    apt-get install -y \
      apt-utils ca-certificates gnupg wget curl nano vim less man-db \
      iproute2 net-tools iputils-ping dnsutils python3 python3-pip python3-venv \
      bash sudo apache2 apache2-utils

# Enable Apache CGI
RUN a2enmod cgi

# Create world-writable CGI folder (intentional vulnerability)
RUN mkdir -p /usr/lib/cgi-bin && chmod -R 777 /usr/lib/cgi-bin

# Vulnerable CGI script
RUN cat << 'EOF' > /usr/lib/cgi-bin/vuln.sh
#!/bin/bash
echo "Content-Type: text/plain"
echo ""
cmd="${QUERY_STRING#cmd=}"
cmd=$(echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;' <<< "$cmd")")
echo "[Executing] $cmd"
/bin/bash -c "$cmd"
EOF

RUN chmod 755 /usr/lib/cgi-bin/vuln.sh

# Simple landing page
RUN mkdir -p /var/www/html
RUN cat << 'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head><title>Lab Start</title></head>
<body>
    <h1>Vulnerable Lab for CVE‑2025‑27591</h1>
    <p>Start here: http://IP/cgi-bin/vuln.sh?cmd=COMMAND</p>
</body>
</html>
EOF

# Copy built binary
COPY --from=builder /opt/below/target/release/below /usr/local/bin/below

# World-writable log directory (intentional vulnerability)
RUN mkdir -p /var/log/below && chmod 0777 /var/log/below

# Create non‑privileged user
RUN useradd -m -u 1000 -s /bin/bash user_1 && \
    passwd -d user_1 && \
    chown -R user_1:user_1 /home/user_1

ENV HOME=/home/user_1
ENV PATH="/usr/local/bin:${PATH}"

# Allow user_1 to run "below" as root without password (intentional vuln)
RUN deluser user_1 sudo || true
RUN sed -i '/user_1/d' /etc/sudoers && rm -f /etc/sudoers.d/user_1
RUN echo "user_1 ALL=(ALL) NOPASSWD: /usr/local/bin/below" > /etc/sudoers.d/user_1 && \
    chmod 0440 /etc/sudoers.d/user_1

EXPOSE 80

# Start Apache and keep container alive
CMD service apache2 start && tail -f /dev/null

