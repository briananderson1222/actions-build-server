FROM myoung34/github-runner:latest

LABEL maintainer="your-email@example.com"
LABEL description="Custom GitHub Actions Runner with additional tools"

# Install additional tools as needed
# Examples:
# RUN apt-get update && apt-get install -y \
#     build-essential \
#     python3 \
#     nodejs \
#     npm \
#     && rm -rf /var/lib/apt/lists/*

# Copy custom entrypoint if needed
COPY runner-entrypoint.sh /opt/runner/entrypoint.sh
RUN chmod +x /opt/runner/entrypoint.sh

ENTRYPOINT ["/opt/runner/entrypoint.sh"]
