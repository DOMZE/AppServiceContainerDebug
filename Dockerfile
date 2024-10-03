FROM nginx:latest

# install openssh, mssql-tools and tooling
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends openssh-server jq bzip2 \
    && apt-get clean -y

RUN git_artifact_uri=$(curl -s 'https://api.github.com/repos/microsoft/go-sqlcmd/releases/latest' | jq -r '.assets[] | select(.name == "sqlcmd-linux-amd64.tar.bz2") | .browser_download_url') \
    && echo "Downloading $git_artifact_uri" \
    && curl -s -L -o /tmp/sqlcmd-linux-amd64.tar.bz2 $git_artifact_uri
RUN mkdir -p /opt/mssql-tools/bin \
    && tar -xvf /tmp/sqlcmd-linux-amd64.tar.bz2 -C /opt/mssql-tools/bin \
    && chmod +x /opt/mssql-tools/bin/sqlcmd \
    && ln -s /opt/mssql-tools/bin/sqlcmd /usr/bin/sqlcmd \
    && rm /tmp/sqlcmd-linux-amd64.tar.bz2

COPY index.html /usr/share/nginx/html/
COPY entrypoint.sh /
COPY helper.sh /home

RUN echo "root:Docker!" | chpasswd \
    && chmod u+x /entrypoint.sh
COPY sshd_config /etc/ssh

EXPOSE 80 2222

ENTRYPOINT ["/entrypoint.sh"]