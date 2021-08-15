FROM centos:centos7

# 必要なソフトウェアのインストール
RUN yum -y update; yum clean all
RUN yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm; yum clean all
RUN yum -y install sudo epel-release yum-utils; yum clean all
RUN yum -y install postgresql12-server postgresql12 postgresql12-contrib supervisor pwgen; yum clean all

# 環境変数の設定
ENV PATH $PATH:/usr/pgsql-12/bin
ENV PGDATA /var/lib/pgsql/12/data

# ファイルの追加(PGDATA以外のディレクトリに追加するものが対象)
ADD ./conf/supervisord.conf /etc/supervisord.conf
ADD ./setup/init_postgres.sh /init_postgres.sh
ADD ./setup/start_postgres.sh /start_postgres.sh

# shファイルの権限設定
RUN chmod 755 /start_postgres.sh
RUN chmod 755 /init_postgres.sh

# データベースクラスタを作成するshファイルを実行する
RUN ["/bin/bash", "-c", "/init_postgres.sh"]

# postgresql.confファイルの追加
ADD ./conf/postgresql.conf /var/lib/pgsql/12/data/postgresql.conf
RUN chown -v postgres:postgres /var/lib/pgsql/12/data/postgresql.conf

# pg_hba.confファイルの追加
ADD ./conf/pg_hba.conf /var/lib/pgsql/12/data/pg_hba.conf
RUN chown -v postgres:postgres /var/lib/pgsql/12/data/pg_hba.conf

# ポートの開放
EXPOSE 5432

# postgresqlの開始
CMD ["/bin/bash", "/start_postgres.sh"]