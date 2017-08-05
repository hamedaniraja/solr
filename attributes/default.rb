default['solr']['MOUNTED_STORAGE'] = '/ecx_solr_data'


default['solr']['SOLR_JAVA_HOME'] = '/usr/java/jdk1.8.0_77'
default['solr']['SOLR_HOST'] = 'SOLR.HOST.NAME'
default['solr']['SOLR_PORT'] = '8983'
default['solr']['ZK_HOST'] = 'ZOOKEEPER.HOST.NAME'
default['solr']['SOLR_LOGS_DIR'] = '/var/solr/logs/'
default['solr']['LOG4J_PROPS'] = '/var/solr/log4j.properties'
default['solr']['SOLR_PID_DIR'] = '/var/solr/'

lastOctet=node['ipaddress'].split('.')[3]
default['solr']['SOLR_HOME'] = "/var/solr/data/Node#{lastOctet}"

xmx = (node['memory']['total'].to_i*0.75/(1024*1024)).round
xms = (node['memory']['total'].to_i*0.50/(1024*1024)).round
default['solr']['SOLR_JAVA_MEM'] = "-Xms#{xms}g -Xmx#{xmx}g"

default['solr']['USER'] = 'solr'
default['solr']['GROUP'] = 'solr'
default['solr']['SERVICE'] = 'solr'
default['solr']['USER_UID'] = 1001
default['solr']['USER_GID'] = 1001
default['solr']['USER_HOME'] = '/home/solr'
default['solr']['USER_SHELL'] = '/bin/bash'

default['solr']['INSTALL_PACKAGE'] = 'solr-6.5.1.tgz'
default['solr']['SERVICE_INSTALL_SH'] = 'solr-6.5.1/bin/install_solr_service.sh'
default['solr']['INSTALL_PATH'] = '/usr/local'

default['solr']['SHORT_HOST_NAME'] = node['solr']['SOLR_HOST'].split('.')[0]

default['solr']['COMPANY_DIR'] = '/usr/local/solr/contrib/Company'

default['solr']['APP_DIR'] = '/usr/local/solr/server/solr/configsets/app'
