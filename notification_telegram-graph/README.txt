1º Copiar notification_zabbix-graph.sh para /usr/lib/zabbix/alertscripts

2º Alterar variaveis do programa para infomações proprias
ZABBIX_URL=
ZABBIX_USER=
ZABBIX_PASSWORD=
TELEGRAM_TOKEN=

3º Criar novo Media Types no Zabbix (OBS: Em Subject o terceiro campo é o eixo X do gráfico, quarto campo é o eixo Y do gráfico e o quinto campo é o tempo do gráfico em horas. )
#Media type
Name= Telegram Graph
Type= Script
Script name= notification_telegram.sh
Script parameters=
{ALERT.SENDTO}
{ALERT.SUBJECT}
{ALERT.MESSAGE}

#Message templates
Message type= Problem
Subject= {TRIGGER.ID}#{EVENT.ID}#0120#0300#0001
Message= ❌Problem: {HOST.NAME} • {TRIGGER.NAME}
Host: {HOST.NAME} 
Problem started at {EVENT.TIME} on {EVENT.DATE} 
Trigger name: {TRIGGER.NAME} 
Trigger status: {TRIGGER.STATUS} 
Trigger severity: {TRIGGER.SEVERITY} 
Original problem ID: {EVENT.ID}

Message type= Problem recovery
Subject= {TRIGGER.ID}#{EVENT.ID}#0120#0300#0001
Message= ✅Resolved: {HOST.NAME} • {TRIGGER.NAME}
Host: {HOST.NAME} 
Problem has been resolved at {EVENT.RECOVERY.TIME} on {EVENT.RECOVERY.DATE} 
Trigger name: {TRIGGER.NAME} 
Trigger status: {TRIGGER.STATUS} 
Trigger severity: {TRIGGER.SEVERITY} 
Original problem ID: {EVENT.ID} 
Last Value: {ITEM.LASTVALUE}
{TRIGGER.URL}

Message type= Problem update
Subject= {TRIGGER.ID}#{EVENT.ID}#0120#0300#0001
Message= ⚠️Updated problem: {HOST.NAME} • {TRIGGER.NAME}
{USER.FULLNAME} {EVENT.UPDATE.ACTION} problem at {EVENT.UPDATE.DATE} - {EVENT.UPDATE.TIME} 
Message: {EVENT.UPDATE.MESSAGE} 
Current problem status is {EVENT.STATUS}, acknowledged: {EVENT.ACK.STATUS} 
Original problem ID: {EVENT.ID}

4º Criar User Group Report Telegram no Zabbix
#User Group
Group name= Report Telegram
Users= ...

5º Criar Actions no Zabbix
#Action
Name= Report problem Telegram Graph
Type of Calculation= And
Conditions= 
A => Value of tag report_telegram-graph - yes
B => Problem is not supressed

#Operations
Operations
-Operation type= Send message
-Send to user groups= Report Telegram
-Send only to= Telegram Graph

Recovery operations
-Operation type= Send message
-Send to user groups= Report Telegram
-Send only to= Telegram Graph


Update operations
-Operation type= Send message
-Send to user groups= Report Telegram
-Send to users=
-Send only to= Telegram Graph

6º Configurar tag nas triggers desejadas