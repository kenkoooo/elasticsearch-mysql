FROM ubuntu

RUN apt-get update
RUN apt-get install wget -y
RUN wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
RUN apt-get update
RUN apt-get install elasticsearch -y
RUN update-rc.d elasticsearch defaults 95 10

RUN apt-get install openjdk-8-jdk -y
RUN /usr/share/elasticsearch/bin/plugin install analysis-kuromoji
RUN apt-get install curl -y
RUN apt-get install apt-utils -y
RUN apt-get install python3-pip -y
RUN pip3 install --upgrade pip

RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections && \
    apt-get -y install mysql-server

RUN sed -i -e "s/^bind-address\s*=\s*\(.*\)/#bind-address = \1/" /etc/mysql/my.cnf
RUN sed -i -e "s/\(\[mysqld\]\)/\1\ncharacter-set-server = utf8/g" /etc/mysql/my.cnf
RUN sed -i -e "s/\(\[client\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf
RUN sed -i -e "s/\(\[mysqldump\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf
RUN sed -i -e "s/\(\[mysql\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf

RUN service mysql start & \
    sleep 10 && \
    echo "grant all on *.* to root@'localhost' identified by 'root' with grant option" | mysql -uroot -proot
