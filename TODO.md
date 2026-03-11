curl -X POST \
-H "Content-Type: application/json" \
-d '{
	"fields": {
		"title": "New Deal",
		"typeId": "SALE",
		"stageId": "NEW"
	}
}' \
https://your-domain.bitrix24.com/rest/1/8g9l071eismy9q2l/crm.deal.add.json





curl -X POST \
-H "Content-Type: application/json" \
-d '{
	"fields": {
		"title": "New Deal",
		"typeId": "SALE",
		"stageId": "NEW"
	},
	"auth": "807ca26600631fce00007a4b00000001f0f107255033363e91ab16442bd901b2571ed9"
}' \
https://your-domain.bitrix24.com/rest/crm.deal.add.json




https://relits.bitrix24.ru/company/personal/user/336/tasks/?F_STATE=sV180

https://relits.bitrix24.ru/rest/336/onon0ac545fuacxm/

https://relits.bitrix24.ru/rest/336/onon0ac545fuacxm/profile.json


curl -X POST \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{}' \
https://relits.bitrix24.ru/rest/336/onon0ac545fuacxm/profile 


curl -X POST \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{}' \
https://relits.bitrix24.ru/rest/296/9tc2vltvblgd5oqp/profile 



9tc2vltvblgd5oqp
19.01.2026::


curl -X POST \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{"fields":{"TITLE":"Название задачи","DEADLINE":"2025-12-31T23:59:59","CREATED_BY":456,"RESPONSIBLE_ID":123,"UF_CRM_TASK":["L_4","C_7","CO_5","D_10"],"UF_TASK_WEBDAV_FILES":["n12345","n67890"]}}' \
https://relits.bitrix24.ru/rest/296/9tc2vltvblgd5oqp/tasks.task.add





TODO:: уточнить данные по сотрудникам, загрузить им фотки


Пигалева Юлия -> отчество?    225   Вячеславовна
Наталья Максимова -> фото?
Бочаров Денис -> номер ?
Бочарова Елена -> 885120484484
Оганесян -> номер ?
Нарядчикова  -> inaryadchikova@panorama-dom.ru   ?
Сиденко Наталья -> фото, отчество?      233   Викторовна
Пчелинцева Анна -> отчество?            235   Юрьевна
Мокрая Светлана -< отчество?            241   Алексеевна
Шафеев Руслан -> отчество?              247   Ахмеднадырович
Шевченко Алексей  -> Отчество?          255   Владимирович
Сидагалиев Нурлан  -> Отчество?         259   Мураткалиевич
Набиулина Саида -> Отчество   snabiulina@ressk.ru   ?       267    Магарамовна
Позднякова Анастасия -> отчество, мобильный?    283     Сергеевна
Мамонтов Алексей -> отчество, должность?        285     Петрович
Людмила Фомина -> Отчество, дата рождения   должность   292
Наталья Григорьева -> фото?

curl -X POST \
  'https://<ваш_портал>.bitrix24.ru/rest/user.update.json' \
  -d 'auth=<ваш_токен>' \
  -d 'ID=5319816' \
  -d 'FIELDS[ACTIVE]=false'


  curl -X POST \
  "https://ваш-домен.bitrix24.ru/rest/user.get" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "auth=ваш_токен_доступа" \
  -d "filter[NAME]=Ива%" \
  -d "filter[LAST_NAME]=Пет%" \
  -o response.json


  https://relits.bitrix24.ru/rest/336/l5rt3vw1retrxulv/

   curl -X POST \
  "https://relits.bitrix24.ru/rest/user.get" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "auth=l5rt3vw1retrxulv" \
  -d "filter[NAME]=Ива%" \
  -d "filter[LAST_NAME]=Пет%" \
  -o response.json


https://relits.bitrix24.ru/rest/336/l5rt3vw1retrxulv/

curl -X POST \
  "https://relits.bitrix24.ru/rest/336/stp81y0u2xk9lzdz/user.get" \
  -H "Content-Type: application/json" \
  -d '{
    "filter": {
      "NAME": "Иван",
      "LAST_NAME": "Петров"
    }
  }'

  https://relits.bitrix24.ru/rest/336/stp81y0u2xk9lzdz/

      curl -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{"filter":{"!%LAST_NAME":"Фомина"}}' \
    https://relits.bitrix24.ru/rest/336/stp81y0u2xk9lzdz/user.get

	 curl -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{"filter":{"@PERSONAL_CITY":["Москва","Санкт-Петербург"]}}' \
	https://relits.bitrix24.ru/rest/336/stp81y0u2xk9lzdz/user.get


curl -X POST \
https://relits.bitrix24.ru/rest/336/stp81y0u2xk9lzdz/user.get \
-H "Content-Type: application/json" \
-d '{
    "filter": {
     "NAME": "Роман",
     "LAST_NAME": "Пастушков"
    },
    "select": ["ID", "NAME", "LAST_NAME", "EMAIL"]
}'


curl -X POST \
https://relits.bitrix24.ru/rest/336/stp81y0u2xk9lzdz/user.get \
-H "Content-Type: application/json" \
-d '{
    "filter": {
     "NAME": "Роман",
     "LAST_NAME": "Пастушков"
    },
    "select": ["ID", "NAME", "LAST_NAME", "EMAIL"],
    "limit": 0
}'


http://localhost:11111/custom

https://relits.bitrix24.ru/rest/336/azn550dfzrbeqiil/

curl -X POST \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{
    "ID": 292,
    "SECOND_NAME": "xxxxxxxx"
}' \
https://relits.bitrix24.ru/rest/336/phw0peq7tp03a91u/user.update


x-www-form-urlencoded  ID, SECOND name
 curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{
    "ID": 292,
    "SECOND_NAME": "xxxxxxxx222222"
}' https://relits.bitrix24.ru/rest/336/phw0peq7tp03a91u/user.update


https://relits.bitrix24.ru/rest/336/ldo7yqium9v19hng/


338 to delete

curl -X POST \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{}' \
https://relits.bitrix24.ru/rest/338/7kzrsa06v4vppzgb/user.current


curl -X POST \
https://relits.bitrix24.ru/rest/338/7kzrsa06v4vppzgb/user.delete \
-H "Content-Type: application/json" \
-d '{
    "id": 12345
}'




   curl -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{
        "UF_DEPARTMENT": 1,
        "SORT": "ID",
        "ORDER": "asc",
        "start": 10
    }' \
    https://relits.bitrix24.ru/rest/336/5kex81viff9ijsb8/user.search


https://relits.bitrix24.ru/rest/336/5kex81viff9ijsb8/




curl -X POST "https://relits.bitrix24.ru/rest/336/5kex81viff9ijsb8/user.get" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "ID=1"


  https://relits.bitrix24.ru/rest/336/5kex81viff9ijsb8/

# Или с использованием query string (GET запрос)
curl "https://ваш-домен.bitrix24.ru/rest/1/ваш-вебхук/user.get?ID=1"

# Получение нескольких пользователей
curl -X POST "https://ваш-домен.bitrix24.ru/rest/1/ваш-вебхук/user.get" \
  -d "ID[0]=1&ID[1]=2&ID[2]=3"

# Получение пользователя с определенными полями
curl -X POST "https://ваш-домен.bitrix24.ru/rest/1/ваш-вебхук/user.get" \
  -d "ID=1&SELECT[]=ID&SELECT[]=NAME&SELECT[]=LAST_NAME&SELECT[]=EMAIL"



  curl -X POST "https://relits.bitrix24.ru/rest/336/5kex81viff9ijsb8/user.get" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "ID=1"


294


curl -X POST \
https://relits.bitrix24.ru/rest/336/5kex81viff9ijsb8/user.update \
-H "Content-Type: application/json" \
-d '{
    "id": 344,
    "fields": {
     "REPORTS_TO_ID": 294
    }
}'


curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
        "ID": 123,  // ID подразделения
        "UF_HEAD": 456 // ID нового руководителя подразделения (пользователя)
      }' \
  "https://ВАШ_ДОМЕН.bitrix24.ru/rest/1/XXXXXX/department.update.json?auth=XXXXXXXXXXXX"



  curl -X POST "https://relits.bitrix24.ru/rest/336/5kex81viff9ijsb8/department.get" \
-H "Content-Type: application/json" \
-d '{
    "ID": 23
}'

79   сикорский
294 юдкина
  curl -X POST "https://relits.bitrix24.ru/rest/336/r403wy0csnxmptxx/department.get" \
-H "Content-Type: application/json" \
-d '{
    "ID": 23
}'


curl -X POST "https://ваш_домен.bitrix24.ru/rest/department.get" \
-H "Content-Type: application/json" \
-d '{
    "ID": 23  
}'


https://relits.bitrix24.ru/rest/336/i9iqyw31yy0pvw1i/

curl -X POST "https://relits.bitrix24.ru/rest/336/i9iqyw31yy0pvw1i/user.get" \
-H "Content-Type: application/json" \
-d '{
    "FILTER": {
        "UF_DEPARTMENT": 23
    },
    "SELECT": ["ID", "NAME", "LAST_NAME", "UF_HEAD"]
}'


curl -X POST "https://relits.bitrix24.ru/rest/336/i9iqyw31yy0pvw1i/department.update" \
-H "Content-Type: application/json" \
-d '{
    "ID": 23,
    "FIELDS": {
        "UF_HEAD": 79  
    }
}'

curl -X POST "https://relits.bitrix24.ru/rest/336/i9iqyw31yy0pvw1i/user.get" \
-H "Content-Type: application/json" \
-d '{
    "FILTER": {
        "UF_DEPARTMENT": 23
    },
    "SELECT": ["ID", "NAME", "LAST_NAME", "UF_HEAD"]
}'


curl -X POST \
https://relits.bitrix24.ru/rest/336/i9iqyw31yy0pvw1i/user.login.get \
-H "Content-Type: application/json" \
-d '{
    "filter": {
     "USER_ID": 1
    },
    "select": ["ID", "USER_ID", "LOGIN_DATE", "IP_ADDRESS", "USER_AGENT"]
}'


curl -X POST "https://relits.bitrix24.ru/rest/336/i9iqyw31yy0pvw1i/user.access" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "ID=1"

  curl -X POST "https://relits.bitrix24.ru/rest/336/i9iqyw31yy0pvw1i/event.get" \
  -d "FILTER[ENTITY_TYPE]=USER" \
  -d "FILTER[ENTITY_ID]=1" \
  -d "FILTER[EVENT_TYPE]=LOGIN" \
  -d "ORDER[ID]=DESC"


  curl -X POST "https://relits.bitrix24.ru/rest/336/i9iqyw31yy0pvw1i/user.get" \
  -d "ID=1" \
  -d "SELECT[]=ID" \
  -d "SELECT[]=NAME" \
  -d "SELECT[]=LAST_NAME" \
  -d "SELECT[]=LAST_LOGIN" \
  -d "SELECT[]=LAST_ACTIVITY_DATE"



  curl -v -X POST "https://relits.bitrix24.ru/rest/336/i9iqyw31yy0pvw1i/user.access" \
  -d "ID=1" \
  -o response.json


  curl -i -X POST "https://relits.bitrix24.ru/rest/336/i9iqyw31yy0pvw1i/user.access" \
  -d "ID=1" \
  -o full_response.txt




  curl -X POST "https://relits.bitrix24.ru/rest/336/i9iqyw31yy0pvw1i/user.access" \
  -d "ID=1" \
  -d "ORDER[DATE_INSERT]=DESC" \
  -d "limit=10"

# Получить информацию о пользователе
curl -X POST "https://relits.bitrix24.ru/rest/336/i9iqyw31yy0pvw1i/user.get" \
  -d "ID=1" \
  -d "SELECT[]=LAST_LOGIN" \
  -d "SELECT[]=LAST_ACTIVITY_DATE"

# Получить события
curl -X POST "https://relits.bitrix24.ru/rest/336/dzzw89mh9yyphwjc/event.get" \
  -d "FILTER[ENTITY_TYPE]=USER" \
  -d "FILTER[ENTITY_ID]=1" \
  -d "FILTER[EVENT_TYPE]=LOGIN" \
  -d "ORDER[DATE_INSERT]=DESC"

# Проверить рабочее время
curl -X POST "https://ваш-домен.bitrix24.ru/rest/1/вебхук/timeman.status" \
  -d "USER_ID=123" \
  -d "DATE_START=2024-01-01"


curl -X POST \
  "https://relits.bitrix24.ru/rest/336/9xuqnmbu879m3zg3/im.message.add" \
  -H "Content-Type: application/json" \
  -d '{
    "DIALOG_ID": "296",
    "MESSAGE": "Привет! Это тестовое сообщение"
  }'


curl    -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{
        "sort": "NAME",
        "order": "DESC"
    }' \
    https://relits.bitrix24.ru/rest/336/z05f05knpby7y985/department.get


curl -X POST \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{DIALOG_ID: "chat5",MESSAGE: "Сообщение [B]с вложением[/B] цвета primary и поддержкой [I]bb-кодов[/I]",ATTACH: [{MESSAGE: "API будет доступно в обновлении [B]im 24.0.0[/B]"}]}' \
https://relits.bitrix24.ru/rest/336/9xuqnmbu879m3zg3//im.message.add


СГМБ4 , Гранд4 газовые счетчики


curl -X POST \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{}' \
https://relits.bitrix24.ru/rest/336/eablzesyagwz5bbx/task.item.list


curl -X POST \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{"order":{"DEADLINE":"asc","PRIORITY":"desc"},"select":["ID","TITLE","DESCRIPTION","STATUS","subStatus","DEADLINE","CREATED_DATE","RESPONSIBLE_ID","ACCOMPLICES","AUDITORS","TAGS","COUNTERS","PRIORITY","MARK"],"params":{"WITH_TIMER_INFO":true,"WITH_RESULT_INFO":true,"WITH_PARSED_DESCRIPTION":true}}' \
https://relits.bitrix24.ru/rest/336/eablzesyagwz5bbx/tasks.task.list



curl -X POST \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{"order":{"DEADLINE":"asc","PRIORITY":"desc"},"select":["ID","TITLE","DESCRIPTION","STATUS","subStatus","DEADLINE","CREATED_DATE","RESPONSIBLE_ID","ACCOMPLICES","AUDITORS","TAGS","COUNTERS","PRIORITY","MARK"],"params":{"WITH_TIMER_INFO":true,"WITH_RESULT_INFO":true,"WITH_PARSED_DESCRIPTION":true}}' \
https://relits.bitrix24.ru/rest/336/eablzesyagwz5bbx/tasks.task.list


Базовый скрипт для выгрузки всех задач
bash
#!/bin/bash

# Настройки
WEBHOOK_URL="https://ваш-портал.bitrix24.ru/rest/1/ваш-токен/"
USER_ID="123" # Ваш ID пользователя в Bitrix24
OUTPUT_FILE="bitrix_tasks_$(date +%Y%m%d_%H%M%S).json"

# Функция для выполнения запросов
bitrix_request() {
    local method=$1
    local data=$2
    
    curl -s -X POST "${WEBHOOK_URL}${method}" \
        -H "Content-Type: application/json" \
        -d "$data"
}

echo "Начинаем выгрузку задач..."

# 1. Получаем задачи где вы исполнитель
echo "Получаем задачи где вы исполнитель..."
RESPONSIBLE_TASKS=$(bitrix_request "tasks.task.list" '{
    "filter": {
        "RESPONSIBLE_ID": '$USER_ID'
    },
    "select": ["*", "UF_*", "TAGS"],
    "order": {"ID": "DESC"}
}')

# 2. Получаем задачи где вы соисполнитель
echo "Получаем задачи где вы соисполнитель..."
ACCOMPLICE_TASKS=$(bitrix_request "tasks.task.list" '{
    "filter": {
        "ACCOMPLICE": '$USER_ID'
    },
    "select": ["*", "UF_*", "TAGS"],
    "order": {"ID": "DESC"}
}')

# Парсим результаты
RESPONSIBLE_TASKS_IDS=$(echo $RESPONSIBLE_TASKS | jq -r '.result.tasks[]?.id' | tr '\n' ',')
ACCOMPLICE_TASKS_IDS=$(echo $ACCOMPLICE_TASKS | jq -r '.result.tasks[]?.id' | tr '\n' ',')

echo "Найдено задач как исполнитель: $(echo $RESPONSIBLE_TASKS_IDS | tr ',' '\n' | grep -c .)"
echo "Найдено задач как соисполнитель: $(echo $ACCOMPLICE_TASKS_IDS | tr ',' '\n' | grep -c .)"

# Объединяем ID задач
ALL_TASK_IDS=$(echo "$RESPONSIBLE_TASKS_IDS,$ACCOMPLICE_TASKS_IDS" | tr ',' '\n' | sort -u | grep -v '^$' | tr '\n' ',' | sed 's/,$//')

echo "Всего уникальных задач: $(echo $ALL_TASK_IDS | tr ',' '\n' | wc -l)"
2. Полная выгрузка с комментариями
bash
#!/bin/bash

# Настройки
WEBHOOK="https://ваш-портал.bitrix24.ru/rest/1/ваш-токен/"
USER_ID="123"
OUTPUT_FILE="bitrix_tasks_full_$(date +%Y%m%d_%H%M%S).json"
TEMP_DIR="/tmp/bitrix_export_$(date +%s)"

# Создаем временную директорию
mkdir -p "$TEMP_DIR"

echo "=== Выгрузка задач из Bitrix24 ==="
echo "Вебхук: $(echo $WEBHOOK | cut -d'/' -f3)"
echo "User ID: $USER_ID"
echo "Время начала: $(date)"
echo ""

# 1. Получаем список всех задач (пакетный запрос)
echo "1. Получаем список задач..."
BATCH_DATA='{
    "halt": 0,
    "cmd": {
        "responsible": "tasks.task.list?filter[RESPONSIBLE_ID]='$USER_ID'&select[]=*&select[]=UF_*&select[]=TAGS",
        "accomplice": "tasks.task.list?filter[ACCOMPLICE]='$USER_ID'&select[]=*&select[]=UF_*&select[]=TAGS"
    }
}'

curl -s -X POST "${WEBHOOK}batch" \
    -H "Content-Type: application/json" \
    -d "$BATCH_DATA" > "$TEMP_DIR/tasks_batch.json"

echo "Пакетный запрос выполнен"

# 2. Извлекаем ID всех задач
RESPONSIBLE_TASKS=$(jq -r '.result.result.responsible.tasks[]?.id' "$TEMP_DIR/tasks_batch.json" 2>/dev/null || echo "")
ACCOMPLICE_TASKS=$(jq -r '.result.result.accomplice.tasks[]?.id' "$TEMP_DIR/tasks_batch.json" 2>/dev/null || echo "")

# Объединяем и убираем дубликаты
ALL_TASK_IDS=$(echo -e "$RESPONSIBLE_TASKS\n$ACCOMPLICE_TASKS" | sort -u | grep -v '^$')

TASK_COUNT=$(echo "$ALL_TASK_IDS" | wc -l)
echo "2. Найдено задач: $TASK_COUNT"

if [ $TASK_COUNT -eq 0 ]; then
    echo "Нет задач для выгрузки"
    exit 0
fi

# 3. Получаем полную информацию по каждой задаче
echo "3. Получаем детальную информацию по задачам..."
TASK_DETAILS="[]"
counter=0

for TASK_ID in $ALL_TASK_IDS; do
    counter=$((counter + 1))
    echo "  [$counter/$TASK_COUNT] Обрабатываю задачу #$TASK_ID"
    
    # Получаем детали задачи
    TASK_DETAIL=$(curl -s -X POST "${WEBHOOK}tasks.task.get" \
        -H "Content-Type: application/json" \
        -d '{"taskId": '$TASK_ID', "select": ["*", "UF_*", "TAGS"]}')
    
    # Получаем комментарии
    COMMENTS=$(curl -s -X POST "${WEBHOOK}task.commentitem.getlist" \
        -H "Content-Type: application/json" \
        -d '{"taskId": '$TASK_ID', "select": ["*", "USER", "FILES"]}')
    
    # Получаем информацию об участниках
    TASK_DATA=$(echo $TASK_DETAIL | jq -r '.result.task')
    if [ -n "$TASK_DATA" ] && [ "$TASK_DATA" != "null" ]; then
        # Извлекаем ID участников
        PARTICIPANTS_IDS=""
        if echo $TASK_DATA | jq -e '.responsibleId' >/dev/null 2>&1; then
            PARTICIPANTS_IDS="$PARTICIPANTS_IDS $(echo $TASK_DATA | jq -r '.responsibleId')"
        fi
        
        if echo $TASK_DATA | jq -e '.createdBy' >/dev/null 2>&1; then
            PARTICIPANTS_IDS="$PARTICIPANTS_IDS $(echo $TASK_DATA | jq -r '.createdBy')"
        fi
        
        if echo $TASK_DATA | jq -e '.accomplices[]?' >/dev/null 2>&1; then
            PARTICIPANTS_IDS="$PARTICIPANTS_IDS $(echo $TASK_DATA | jq -r '.accomplices[]?')"
        fi
        
        if echo $TASK_DATA | jq -e '.auditors[]?' >/dev/null 2>&1; then
            PARTICIPANTS_IDS="$PARTICIPANTS_IDS $(echo $TASK_DATA | jq -r '.auditors[]?')"
        fi
        
        # Получаем информацию об участниках
        PARTICIPANTS_INFO="[]"
        UNIQUE_IDS=$(echo $PARTICIPANTS_IDS | tr ' ' '\n' | sort -u | grep -v '^$')
        
        for USER_ID in $UNIQUE_IDS; do
            USER_INFO=$(curl -s -X POST "${WEBHOOK}user.get" \
                -H "Content-Type: application/json" \
                -d '{"ID": "'$USER_ID'"}')
            
            if echo $USER_INFO | jq -e '.result[0]' >/dev/null 2>&1; then
                USER_DATA=$(echo $USER_INFO | jq '.result[0] | {id: .ID, name: .NAME, lastName: .LAST_NAME, email: .EMAIL, work_position: .WORK_POSITION}')
                PARTICIPANTS_INFO=$(echo $PARTICIPANTS_INFO | jq --argjson user "$USER_DATA" '. + [$user]')
            fi
        done
        
        # Формируем итоговый объект задачи
        TASK_OBJECT=$(echo $TASK_DATA | jq --argjson comments "$(echo $COMMENTS | jq '.result // []')" \
            --argjson participants "$PARTICIPANTS_INFO" \
            '. + {comments: $comments, participants: $participants, comment_count: ($comments | length)}')
        
        TASK_DETAILS=$(echo $TASK_DETAILS | jq --argjson task "$TASK_OBJECT" '. + [$task]')
    fi
    
    # Пауза чтобы не превысить лимиты API
    sleep 0.5
done

# 4. Сохраняем результат
echo "$TASK_DETAILS" | jq '.' > "$OUTPUT_FILE"

echo ""
echo "=== Выгрузка завершена ==="
echo "Сохранено в: $OUTPUT_FILE"
echo "Количество задач: $(jq '. | length' "$OUTPUT_FILE")"
echo "Общий размер: $(du -h "$OUTPUT_FILE" | cut -f1)"
echo "Время окончания: $(date)"
3. Выгрузка в CSV формат
bash
#!/bin/bash

WEBHOOK="https://ваш-портал.bitrix24.ru/rest/1/ваш-токен/"
USER_ID="123"
JSON_FILE="bitrix_tasks_$(date +%Y%m%d).json"
CSV_FILE="bitrix_tasks_$(date +%Y%m%d).csv"

# Получаем данные в JSON
echo "Получаем данные задач..."
curl -s -X POST "${WEBHOOK}batch" \
    -H "Content-Type: application/json" \
    -d '{
        "halt": 0,
        "cmd": {
            "tasks_responsible": "tasks.task.list?filter[RESPONSIBLE_ID]='$USER_ID'&select[]=*",
            "tasks_accomplice": "tasks.task.list?filter[ACCOMPLICE]='$USER_ID'&select[]=*"
        }
    }' > "$JSON_FILE"

echo "Данные сохранены в $JSON_FILE"

# Конвертируем в CSV (требуется jq)
echo "ID,Название,Статус,Создана,Крайний срок,Ответственный,Комментариев" > "$CSV_FILE"

jq -r '
.result.result |
(.tasks_responsible.tasks // []), (.tasks_accomplice.tasks // []) |
.[] |
[
    .id,
    .title,
    .status,
    .createdDate,
    .deadline // "",
    .responsibleId,
    (.comments // [] | length)
] | @csv' "$JSON_FILE" >> "$CSV_FILE"

echo "CSV файл создан: $CSV_FILE"
echo "Количество строк: $(wc -l < "$CSV_FILE")"
4. Скрипт с пагинацией для большого количества задач
bash
#!/bin/bash

WEBHOOK="https://ваш-портал.bitrix24.ru/rest/1/ваш-токен/"
USER_ID="123"
LIMIT=50 # Количество задач за один запрос
ALL_TASKS_FILE="all_tasks.json"
COMMENTS_FILE="tasks_with_comments.json"

# Функция получения задач с пагинацией
get_tasks_with_pagination() {
    local filter_type=$1
    local filter_value=$2
    local all_tasks="[]"
    local start=0
    
    echo "Получаем задачи (фильтр: $filter_type = $filter_value)"
    
    while true; do
        echo "  Загрузка с позиции $start..."
        
        RESPONSE=$(curl -s -X POST "${WEBHOOK}tasks.task.list" \
            -H "Content-Type: application/json" \
            -d '{
                "filter": {"'$filter_type'": '$filter_value'},
                "select": ["*"],
                "order": {"ID": "DESC"},
                "start": '$start'
            }')
        
        TASKS=$(echo $RESPONSE | jq -r '.result.tasks // []')
        TASKS_COUNT=$(echo $TASKS | jq 'length')
        
        if [ "$TASKS_COUNT" -eq 0 ]; then
            break
        fi
        
        all_tasks=$(echo $all_tasks | jq --argjson new "$TASKS" '. + $new')
        start=$((start + TASKS_COUNT))
        
        if [ "$TASKS_COUNT" -lt "$LIMIT" ]; then
            break
        fi
        
        sleep 1
    done
    
    echo $all_tasks
}

# Основной скрипт
echo "=== Начало выгрузки ==="

# Получаем задачи как исполнитель
RESPONSIBLE_TASKS=$(get_tasks_with_pagination "RESPONSIBLE_ID" "$USER_ID")
RESP_COUNT=$(echo $RESPONSIBLE_TASKS | jq 'length')
echo "Задач как исполнитель: $RESP_COUNT"

# Получаем задачи как соисполнитель
ACCOMPLICE_TASKS=$(get_tasks_with_pagination "ACCOMPLICE" "$USER_ID")
ACC_COUNT=$(echo $ACCOMPLICE_TASKS | jq 'length')
echo "Задач как соисполнитель: $ACC_COUNT"

# Объединяем и удаляем дубликаты
echo "Объединяем задачи..."
ALL_TASKS_JSON=$(echo "[$RESPONSIBLE_TASKS,$ACCOMPLICE_TASKS]" | jq 'add | unique_by(.id)')
TOTAL_COUNT=$(echo $ALL_TASKS_JSON | jq 'length')
echo "Всего уникальных задач: $TOTAL_COUNT"

# Сохраняем список задач
echo $ALL_TASKS_JSON | jq '.' > "$ALL_TASKS_FILE"
echo "Список задач сохранен в $ALL_TASKS_FILE"

# Получаем комментарии для каждой задачи
echo "Получаем комментарии..."
FINAL_RESULT="[]"
COUNTER=0

echo $ALL_TASKS_JSON | jq -c '.[]' | while read TASK; do
    COUNTER=$((COUNTER + 1))
    TASK_ID=$(echo $TASK | jq -r '.id')
    echo "[$COUNTER/$TOTAL_COUNT] Задача #$TASK_ID"
    
    # Получаем комментарии
    COMMENTS_RESPONSE=$(curl -s -X POST "${WEBHOOK}task.commentitem.getlist" \
        -H "Content-Type: application/json" \
        -d '{"taskId": '$TASK_ID'}')
    
    COMMENTS=$(echo $COMMENTS_RESPONSE | jq '.result // []')
    
    # Обновляем задачу с комментариями
    UPDATED_TASK=$(echo $TASK | jq --argjson comments "$COMMENTS" \
        '. + {comments: $comments, comment_count: ($comments | length)}')
    
    # Добавляем в финальный результат
    FINAL_RESULT=$(echo $FINAL_RESULT | jq --argjson task "$UPDATED_TASK" '. + [$task]')
    
    # Сохраняем промежуточный результат каждые 10 задач
    if [ $((COUNTER % 10)) -eq 0 ]; then
        echo $FINAL_RESULT | jq '.' > "$COMMENTS_FILE.tmp"
        echo "  Промежуточное сохранение..."
    fi
    
    sleep 0.3
done

# Сохраняем финальный результат
echo $FINAL_RESULT | jq '.' > "$COMMENTS_FILE"

echo ""
echo "=== Выгрузка завершена ==="
echo "Результаты сохранены в:"
echo "  - $ALL_TASKS_FILE (список задач)"
echo "  - $COMMENTS_FILE (задачи с комментариями)"
echo "Общее количество задач с комментариями: $(jq 'length' "$COMMENTS_FILE")"
5. Быстрая выгрузка через batch запросы
bash
#!/bin/bash

WEBHOOK="https://ваш-портал.bitrix24.ru/rest/1/ваш-токен/"
USER_ID="123"
OUTPUT="tasks_export_$(date +%s).json"

# Создаем batch запрос для получения всех данных
echo "Создаем batch запрос..."

# Сначала получаем ID всех задач
BATCH_GET_TASKS='{
    "halt": 0,
    "cmd": {
        "tasks_1": "tasks.task.list?filter[RESPONSIBLE_ID]='$USER_ID'&select[]=ID",
        "tasks_2": "tasks.task.list?filter[ACCOMPLICE]='$USER_ID'&select[]=ID"
    }
}'

echo "Выполняем запрос списка задач..."
curl -s -X POST "${WEBHOOK}batch" \
    -H "Content-Type: application/json" \
    -d "$BATCH_GET_TASKS" > temp_tasks.json

# Извлекаем ID
TASK_IDS=$(jq -r '.result.result.tasks_1.tasks[].id, .result.result.tasks_2.tasks[].id' temp_tasks.json | sort -u)

echo "Найдено задач: $(echo "$TASK_IDS" | wc -l)"

# Создаем batch для получения деталей и комментариев
BATCH_CMD="{}"
counter=0

for ID in $TASK_IDS; do
    if [ -n "$ID" ]; then
        counter=$((counter + 1))
        BATCH_CMD=$(echo "$BATCH_CMD" | jq --arg cmd "tasks.task.get?taskId=$ID" \
            --arg idx "task_$counter" '. + {($idx): $cmd}')
        
        if [ $counter -lt 50 ]; then # Ограничение batch
            BATCH_CMD=$(echo "$BATCH_CMD" | jq --arg cmd "task.commentitem.getlist?taskId=$ID" \
                --arg idx "comments_$counter" '. + {($idx): $cmd}')
        fi
    fi
done

# Выполняем batch запрос
echo "Выполняем batch запрос для $counter задач..."
BATCH_DATA='{"halt": 0, "cmd": '"$BATCH_CMD"'}'

curl -s -X POST "${WEBHOOK}batch" \
    -H "Content-Type: application/json" \
    -d "$BATCH_DATA" | jq '.' > "$OUTPUT"

echo "Готово! Результат в $OUTPUT"

# Очистка
rm -f temp_tasks.json
6. Получение своего User ID через API
bash
#!/bin/bash

WEBHOOK="https://ваш-портал.bitrix24.ru/rest/1/ваш-токен/"

# Способ 1: Текущий пользователь
echo "Получение ID текущего пользователя..."
curl -s -X POST "${WEBHOOK}user.current" \
    -H "Content-Type: application/json" \
    -d '{}' | jq '.result.ID'

# Способ 2: По email
EMAIL="ваш-email@example.com"
echo "Поиск ID по email $EMAIL..."
curl -s -X POST "${WEBHOOK}user.search" \
    -H "Content-Type: application/json" \
    -d '{
        "filter": {
            "EMAIL": "'$EMAIL'"
        },
        "select": ["ID", "NAME", "LAST_NAME", "EMAIL"]
    }' | jq '.result[0].ID'

# Способ 3: Список всех пользователей
echo "Список пользователей (первые 10):"
curl -s -X POST "${WEBHOOK}user.get" \
    -H "Content-Type: application/json" \
    -d '{
        "filter": {"ACTIVE": true},
        "select": ["ID", "NAME", "LAST_NAME", "EMAIL"],
        "limit": 10
    }' | jq '.result[] | "\(.ID): \(.NAME) \(.LAST_NAME) (\(.EMAIL))"'
Установка зависимостей (если нужно)
bash
# Для работы скриптов нужен jq
sudo apt-get install jq  # Ubuntu/Debian
# или
brew install jq         # macOS
# или
yum install jq          # CentOS/RHEL
Запуск скриптов
bash
# Сделать скрипт исполняемым
chmod +x bitrix_export.sh

# Запустить
./bitrix_export.sh

# Или сразу одной командой
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ваш-репозиторий/bitrix_export.sh)"
Эти скрипты покрывают все основные сценарии выгрузки задач с комментариями через cURL. Выберите подходящий вариант в зависимости от ваших потребностей и количества задач.







https://relits.bitrix24.ru/rest/336/w1gzyqwhiipe1jph/

curl -X POST \
  'https://relits.bitrix24.ru/rest/336/w1gzyqwhiipe1jph/sonet_group.get.json' \
  -H 'Content-Type: application/json' \
  -d '{
    "filter": {
      "PROJECT": "Y"
    },
    "order": {
      "NAME": "ASC"
    },
    "select": ["ID", "NAME", "DESCRIPTION", "DATE_CREATE", "IMAGE_ID"]
  }'




получить список проектов. рекурсивно их удалить. )RUST)
Взять спсиок пользвоателей. Рекурсивно проверить их в бинаном дампе  (RUST)


Замена Java csv parser (Haskell)



Использовать в смарт-процессе свои воронки и туннели продаж


Использовать в смарт-процессе свои стадии и канбан



Использовать в смарт-процессе роботы и триггеры




Использовать в смарт-процессе дизайнер бизнес-процессов


Делать новые воронки доступными для всех





 Перезагрузка / Сброс
Обновление конфигурации	
Переназначение прав / Доступ
Очистка кэша / Временных данных	
Замена компонента / Оборудования
Предоставлена инструкция
Тестовое решение (требует проверки)
Временное решение (workaround)	
Не требует действий (ложная тревога)




https://restetris.cynteka.ru/core



curl
    -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{
        "sort": "NAME",
        "order": "DESC"
   }' \
    https://relits.bitrix24.ru/rest/336/w1gzyqwhiipe1jph/department.get


    2a00:f940:2:2:1:1:0:291 195.133.146.173

https://b24-e8jgcd.bitrix24.ru/rest/1/aa6nqwskgkhq06qd/

curl -X POST \
  'https://b24-e8jgcd.bitrix24.ru/rest/1/aa6nqwskgkhq06qd/tasks.task.add' \
  -H 'Content-Type: application/json' \
  -d '{
  "fields": {
    "TITLE": "zzzzzzzzzzzzzzzzzzzzzz",
    "DESCRIPTION": "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz",
    "RESPONSIBLE_ID": "1",
    "CREATED_BY": "1",
    "ACCOMPLICES": ["14"],
    "AUDITORS": ["1"],
    "DEADLINE": "2025-03-10T18:00:00+03:00",
    "PRIORITY": "2",
    "GROUP_ID": "10"
  }
}'    

curl -X POST \
  'https://b24-e8jgcd.bitrix24.ru/rest/1/aa6nqwskgkhq06qd/tasks.task.add' \
  -H 'Content-Type: application/json' \
  -d '{
  "fields": {
    "TITLE": "Подготовить коммерческое предложение",
    "RESPONSIBLE_ID": "1"
  }
}'    

 curl -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{"fields":{"TITLE":"zzzzzzzzzzzzzzzzzz","DEADLINE":"2025-12-31T23:59:59","CREATED_BY":1,"RESPONSIBLE_ID":1}}' \
    https://b24-e8jgcd.bitrix24.ru/rest/1/aa6nqwskgkhq06qd/tasks.task.add


SIMPLE::
 curl -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{"fields":{"TITLE":"zzzzzzzzzzzzzzzzzz","DEADLINE":"2025-12-31T23:59:59","CREATED_BY":1,"RESPONSIBLE_ID":1}}' \
    https://b24-e8jgcd.bitrix24.ru/rest/1/aa6nqwskgkhq06qd/tasks.task.add


PRORITY::
 curl -X POST \
  'https://b24-e8jgcd.bitrix24.ru/rest/1/aa6nqwskgkhq06qd/tasks.task.add' \
  -H 'Content-Type: application/json' \
  -d '{
  "fields": {
    "TITLE": "zzzzzzzzzzzzzzzzzzzzzz",
    "DESCRIPTION": "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz",
    "RESPONSIBLE_ID": "1",
    "CREATED_BY": "1",
    "ACCOMPLICES": ["14"],
    "AUDITORS": ["1"],
    "DEADLINE": "2025-03-10T18:00:00+03:00",
    "PRIORITY": "2",
    "GROUP_ID": "10"
  }
}'


 curl -X POST   'https://b24-e8jgcd.bitrix24.ru/rest/1/aa6nqwskgkhq06qd/tasks.task.add'   -H 'Content-Type: application/json'   -d '{
  "fields": {
    "TITLE": "XXXXXX",   
    "DESCRIPTION": "ZZZZZZZZZZZZ",
    "RESPONSIBLE_ID": "1",
    "CREATED_BY": "1",
    "ACCOMPLICES": ["14"],
    "AUDITORS": ["26"],
    "DEADLINE": "2025-03-10T18:00:00+03:00",
    "PRIORITY": "2",
    "GROUP_ID": "10"
  }
}'

TITLE  название
DESCRIPTION   описание
RESPONSIBLE_ID   исполнитель
CREATED_BY  создан
ACCOMPLICES   соисполнитель
AUDITORS     наблюдатель


api token: 854SKBJtC2Q0VX64pwsqu2MEz7aEjBUyn9yHOeRW


user_token::  K4YWmdgTWl5IBVwwHK5Cq2CQ7VXwkTE1OaC71dZf
app_token::   mol6EowqT6ktBj8NLmTAvHXs6IJpDm0Pn5D9qL7c

curl -X GET \
  -H "Content-Type: application/json" \
  -H "App-Token: ВАШ_APP_TOKEN" \
  -H "Authorization: user_token ВАШ_USER_TOKEN" \
  "http://192.168.1.98/glpi/apirest.php/initSession"


  user_token::  K4YWmdgTWl5IBVwwHK5Cq2CQ7VXwkTE1OaC71dZf
app_token::   mol6EowqT6ktBj8NLmTAvHXs6IJpDm0Pn5D9qL7c

curl -X GET \
  -H "Content-Type: application/json" \
  -H "App-Token: mol6EowqT6ktBj8NLmTAvHXs6IJpDm0Pn5D9qL7c" \
  -H "Authorization: user_token K4YWmdgTWl5IBVwwHK5Cq2CQ7VXwkTE1OaC71dZf" \
  "http://192.168.1.98/glpi/apirest.php/initSession"


  http://192.168.1.98/apirest.php/




