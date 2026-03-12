(require :asdf)
(asdf:load-system :hunchentoot)
(asdf:load-system :cl-json)
(asdf:load-system :frugal-uuid)
(asdf:load-system :bordeaux-threads)
(asdf:load-system :dexador)
(asdf:load-system :cl-base64)



;; Настройки Hunchentoot для поддержки больших файлов

(defpackage :hello
  (:use :cl :hunchentoot :fuuid)
  (:export #:start-server #:main #:plus #:test-plus  #:tests))
(in-package :hello)
;;; Функция суммирования
(defun plus (a b) (+ a b))

(defun test-plus ()
  (format t "Running tests for PLUS...~%")
  (assert (= (plus 2 1) 5))
  (assert (= (plus -1 1) 0))
  (assert (= (plus 0 0) 0))
  (format t "All tests passed.~%")
  t)
                                         ;;______   ______              ______        ______
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;|||    |  ||    ||  ||\\  || ||       ||   ||   __ ::::::::::::::::
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;|||       ||    ||  || \\ || ||_____  ||   ||    ||::::::::::::::::
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;|||____|  ||____||  ||  \\|| ||       ||   ||____||::::::::::::::::


(defparameter *acceptor* 
  (make-instance 'hunchentoot:easy-acceptor 
                 :port 11111
                 :read-timeout 300   ; таймаут на чтение в секундах
                 :write-timeout 300))


(defparameter *default-config*
  '((:bitrix-url . "https://b24-e8jgcd.bitrix24.ru/rest/1/aa6nqwskgkhq06qd/tasks.task.add")
    (:glpi-base . "http://192.168.1.98/apirest.php")
    (:glpi-app-token . "mol6EowqT6ktBj8NLmTAvHXs6IJpDm0Pn5D9qL7c")
    (:glpi-user-token . "K4YWmdgTWl5IBVwwHK5Cq2CQ7VXwkTE1OaC71dZf")
    (:bitrix-enabled . nil)
    (:glpi-enabled . nil)
    (:processing-enabled . nil)
    ;; Общее значение для аудиторов (может быть списком или числом)
    (:bitrix-auditors . (26))
    ;; Ответственные по категориям
    (:bitrix-responsible
     . (("orgtech" . 1)
        ("software" . 1)
        ("computers" . 1)
        ("network" . 1)
        ("meters" . 1)
        ("providers" . 1)
        ("cameras" . 1)
        ("mobile" . 1)))
    ;; GLPI requester по категориям
    (:glpi-requester
     . (("orgtech" . 2)
        ("software" . 2)
        ("computers" . 2)
        ("network" . 2)
        ("meters" . 2)
        ("providers" . 2)
        ("cameras" . 2)
        ("mobile" . 2)))))


(defparameter *config* (make-hash-table :test 'equal)
  "Глобальная хеш-таблица с текущей конфигурацией.")


(defun save-config (&optional (filename "config.lisp"))
  "Сохраняет текущую конфигурацию в FILENAME, форматируя каждую пару на отдельной строке."
  (with-open-file (out filename
                       :direction :output
                       :if-exists :supersede
                       :external-format :utf-8)
    (with-standard-io-syntax
      (let ((*print-readably* t)
            (*print-pretty* t)
            (*print-right-margin* 120))
        (let ((alist (loop for key being the hash-keys of *config*
                           collect (cons key (gethash key *config*)))))
          (pprint alist out)
          (terpri out))))))  ; все закрывающие скобки на месте

(defun load-config (&optional (filename "config.lisp"))
  "Загружает конфигурацию из FILENAME, если файл существует.
   Если файла нет, используется *DEFAULT-CONFIG* и создаётся новый файл."
  ;; Сначала заполняем таблицу значениями по умолчанию
  (clrhash *config*)
  (dolist (pair *default-config*)
    (setf (gethash (car pair) *config*) (cdr pair)))
  
  ;; Если файл существует, читаем его и обновляем таблицу
  (when (probe-file filename)
    (with-open-file (in filename
                        :direction :input
                        :external-format :utf-8)
      (with-standard-io-syntax
        (let ((alist (read in)))
          (dolist (pair alist)
            (setf (gethash (car pair) *config*) (cdr pair))))))
    (format t "Конфигурация загружена из ~A~%" filename))
  
  ;; Сохраняем текущую таблицу в файл (если его не было, он создастся)
  (save-config filename)
  *config*)



(defun reload-config ()
  "Перезагружает конфигурацию из файла (сбрасывая изменения)."
  (load-config))
          
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:::::::::::::::::::::::::::::::::::::::::::::::::::
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:::::::::::::::::::::::::::::::::::::::::::::::::::
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:::::::::::::::::::::::::::::::::::::::::::::::::::


;;; Работа с файлом lnk
(defparameter *link-file* "lnk")

(defun read-links ()
  (if (probe-file *link-file*)
      (with-open-file (f *link-file* :direction :input)
        (loop for line = (read-line f nil nil) while line collect line))
      '()))

(defun write-links (content)
  (with-open-file (f *link-file* :direction :output :if-exists :supersede)
    (write-string content f)))

;;; HTML-страницы
(defun index-html ()
  "<!DOCTYPE html>
<html>
<head>
    <title>Моё приложение</title>
    <script src=\"//api.bitrix24.com/api/v1/\"></script>
</head>
<body>
    <h1>Приложение загружено!</h1>
    <script>
        BX24.init(function() {
            console.log('BX24 инициализирована');
            BX24.installFinish();
        });
    </script>
</body>
</html>")

(defun up-form-html ()
  "<!DOCTYPE html>
<html>
<head><title>Update Link</title></head>
<body>
    <h2>Update Link</h2>
    <form method=\"POST\" action=\"/updatelnk\">
        <label for=\"content\">New content:</label>
        <input type=\"text\" name=\"content\" value=\"\" size=\"50\">
        <br/>
        <input type=\"submit\" value=\"Update\">
    </form>
</body>
</html>")

(defun tuid-html ()
  (let ((my-uuid (fuuid:make-v1)))
    ;; Возвращаем строку с UUID
    ;; (format nil "!!!!!!!!!!!!!!!!!!~a" (fuuid:to-string my-uuid))))
     (fuuid:to-string my-uuid)))

;;        (format nil "~a" (fuuid:to-string my-uuid))))


; (hunchentoot:define-easy-handler (index :uri "/tuid") ()
;   (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
;   (tuid-html))



(defun chat-html ()
  (let ((path "static/chat.html"))
    (if (probe-file path)
        (with-open-file (f path :direction :input)
          (let ((content (make-string (file-length f))))
            (read-sequence content f)
            content))
        "<h1>ERROR: chat.html not found</h1>")))

;;; Хендлеры
(hunchentoot:define-easy-handler (index :uri "/") ()
  (setf (hunchentoot:content-type*) "text/html")
  (index-html))

; (hunchentoot:define-easy-handler (index :uri "/tuid") ()
;   (setf (hunchentoot:content-type*) "text/html")
;   (tuid-html))  

(hunchentoot:define-easy-handler (index :uri "/tuid") ()
  (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
  (tuid-html))

(hunchentoot:define-easy-handler (reload :uri "/r") ()
  (setf (hunchentoot:content-type*) "text/plain")
  (load "hello.lisp")  ; Перезагружает этот же файл
  "Reloaded")

  (hunchentoot:define-easy-handler (reload-config-handler :uri "/rc") ()
  (setf (hunchentoot:content-type*) "text/plain")
  (handler-case
      (progn
        (reload-config)
        "Config reloaded")
    (error (e)
      (setf (hunchentoot:return-code*) 500)
      (format nil "Error: ~A" e))))


(hunchentoot:define-easy-handler (up :uri "/up") ()
  (setf (hunchentoot:content-type*) "text/html")
  (up-form-html))

(hunchentoot:define-easy-handler (lnk :uri "/lnk") ()
  (setf (hunchentoot:content-type*) "text/html")
  (let ((links (read-links)))
    (if links
        (format nil "<h3>HI there!</h3><br>~{~a~}"
                (loop for l in links collect (format nil "<a href='~a'>~a</a><br>" l l)))
        "<h3>HI there!</h3><br>No links")))

(hunchentoot:define-easy-handler (updatelnk :uri "/updatelnk" :default-request-type :post) (content)
  (if content
      (progn (write-links content) "Link updated successfully.")
      (progn (setf (hunchentoot:return-code*) 400) "Missing content parameter")))

(hunchentoot:define-easy-handler (chat :uri "/chat") ()
  (setf (hunchentoot:content-type*) "text/html")
  (chat-html))


(defun static-handler ()
  (let* ((uri (hunchentoot:request-uri*))
         (path (subseq uri 8))) 
    (handler-case
        (let ((full-path (make-pathname :name path :directory '(:relative "static"))))
          (if (and (probe-file full-path)
                   (not (uiop:directory-pathname-p full-path)))
              (progn
                (setf (hunchentoot:content-type*)
                      (or (hunchentoot:mime-type full-path) "application/octet-stream"))
                (with-open-file (stream full-path :element-type '(unsigned-byte 8))
                  (let ((data (make-array (file-length stream) :element-type '(unsigned-byte 8))))
                    (read-sequence data stream)
                    data)))
              (progn
                (setf (hunchentoot:return-code*) 404)
                "File not found")))
      (error ()
        (setf (hunchentoot:return-code*) 500)
        "Internal server error"))))

(push (hunchentoot:create-prefix-dispatcher "/static/" 'static-handler)
      hunchentoot:*dispatch-table*)



(hunchentoot:define-easy-handler (edit-handler :uri "/edit") (content)
  (case (hunchentoot:request-method*)
    ;; GET: показать форму с текущим содержимым
    (:get
     (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
     (let ((file-content
             (with-open-file (f "hello.lisp" :direction :input)
               (let ((str (make-string (file-length f))))
                 (read-sequence str f)
                 str))))
       (format nil "
<html>
<head><title>Edit hello.lisp</title>
<style>
body { font-family: sans-serif; margin: 20px; }
textarea { width: 100%; font-family: monospace; }
</style>
</head>
<body>
  <h1>Редактирование hello.lisp</h1>
  <form method='post' action='/edit'>
    <textarea name='content' rows='30'>~A</textarea><br>
    <input type='submit' value='Сохранить и перезагрузить'>
  </form>
  <p><a href='/r'>Перезагрузить без сохранения</a></p>
</body>
</html>"
               (hunchentoot:escape-for-html file-content))))
    ;; POST: сохранить и перезагрузить
    (:post
     (if content
         (progn
           (with-open-file (f "hello.lisp" :direction :output :if-exists :supersede)
             (write-string content f))
           (load "hello.lisp")
           (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
           "Сохранено и перезагружено. <a href='/edit'>Вернуться</a>")
         (progn
           (setf (hunchentoot:return-code*) 400)
           "Ошибка: нет данных")))))





(defun log-request (data)
  (with-open-file (log-stream "requests.log"
                               :direction :output
                               :if-exists :append
                               :if-does-not-exist :create)
    (multiple-value-bind (second minute hour day month year)
      (get-decoded-time)
      (format log-stream "[~4,'0d-~2,'0d-~2,'0d ~2,'0d:~2,'0d:~2,'0d] ~a~%"
              year month day hour minute second data))))

; (defun send-to-bitrix (data)
;   (let ((url (gethash :bitrix-url *config*))
;         (responsible-alist (gethash :bitrix-responsible *config*))
;         (category (cdr (assoc :category data)))
;         (title (or (cdr (assoc :title data)) "Без темы"))
;         (description (or (cdr (assoc :description data)) "")))
;     (unless url
;       (error "Bitrix URL не настроен в конфигурации"))
;     ;; Определяем ответственного по категории, если не найдено — используем 1
;     (let* ((responsible-id
;              (if responsible-alist
;                  (or (cdr (assoc category responsible-alist :test #'string=)) 1)
;                  1))
;            (payload `(("fields" .
;                        (("TITLE" . ,title)
;                         ("DESCRIPTION" . ,description)
;                         ("RESPONSIBLE_ID" . ,responsible-id)
;                         ("CREATED_BY" . 1)
;                         ("ACCOMPLICES" . (14))
;                         ("AUDITORS" . (26))
;                         ("DEADLINE" . "2025-03-10T18:00:00+03:00")
;                         ("PRIORITY" . 2)   ; можно позже заменить на priority из data
;                         ("GROUP_ID" . 10)))))
;           (json-payload (cl-json:encode-json-to-string payload)))
;       (handler-case
;           (let* ((response (dex:post url
;                                       :content-type "application/json"
;                                       :content json-payload
;                                       :want-string t))
;                  (body (car response))
;                  (status (cdr response)))
;             (format t "~%Bitrix ответ (статус ~A): ~A~%" status body)
;             (when (>= status 400)
;               (error "Bitrix request failed with status ~A" status)))
;         (dex:http-request-failed (e)
;           (format t "~%Ошибка HTTP при отправке в Bitrix: ~A~%" e)
;           (error e))))))    
;                              ______     _________ ________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| __|__|  || ______   | ______| ||   \\  //
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;||______  ||   ||     ||\ \     ||    \\//
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;|____|_|  ||   ||     || \ \    ||   // \\

;;; Функция для извлечения ID из ответа Bitrix после загрузки файла
(defun extract-number-from-json-string (json-string key)
  "Ищет в JSON-строке поле \"key\": и возвращает число после него.
   Например, для ключа \"id\" ищет подстроку \"id\": и извлекает следующее число."
  (let* ((key-str (format nil "\"~A\":" key))
         (start (search key-str json-string)))
    (unless start
      (error "Поле ~S не найдено в JSON" key-str))
    ;; позиция после двоеточия
    (let ((pos (+ start (length key-str))))
      ;; пропускаем пробелы
      (loop while (and (< pos (length json-string))
                       (member (aref json-string pos) '(#\Space #\Tab)))
            do (incf pos))
      ;; собираем цифры
      (let ((num-start pos))
        (loop while (and (< pos (length json-string))
                         (digit-char-p (aref json-string pos)))
              do (incf pos))
        (if (= num-start pos)
            (error "После поля ~S не найдено число" key-str)
            (parse-integer (subseq json-string num-start pos)))))))



(defun parse-bitrix-task-id (response-body)
  "Извлекает ID задачи из ответа Bitrix после создания.
   Ищет поле \"id\": в строке."
  (extract-number-from-json-string response-body "id"))
  
(defun extract-id-from-bitrix-response (response-body)
  "Извлекает ID из ответа Bitrix (поле ID)."
  (extract-number-from-json-string response-body "ID"))

;;; Тесты для extract-id-from-bitrix-response
(defun tests ()
  (format t "Running tests for JSON number extraction...~%")
  ;; Тест 1: извлечение ID из ответа загрузки файла (ключ "ID")
  (let ((response "{\"result\":{\"ID\":126,\"NAME\":\"file.txt\"}}"))
    (let ((id (extract-number-from-json-string response "ID")))
      (assert (= id 126))
      (format t "Test 1 passed: extracted ~A~%" id)))
  ;; Тест 2: извлечение ID задачи из ответа создания (ключ "id")
  (let ((response "{\"result\":{\"task\":{\"id\":84,\"title\":\"Test\"}}}"))
    (let ((id (extract-number-from-json-string response "id")))
      (assert (= id 84))
      (format t "Test 2 passed: extracted ~A~%" id)))
  ;; Тест 3: отсутствие ключа
  (let ((response "{\"result\":{\"name\":\"file.txt\"}}"))
    (handler-case
        (progn
          (extract-number-from-json-string response "ID")
          (error "Test 3 failed: expected error"))
      (error (e)
        (format t "Test 3 passed: caught expected error ~A~%" e))))
  ;; Тест 4: ключ "id" не должен путаться с частью другого слова
  (let ((response "{\"result\":{\"guid\":\"some-id-84\",\"id\":99}}"))
    (let ((id (extract-number-from-json-string response "id")))
      (assert (= id 99))
      (format t "Test 4 passed: extracted ~A from string with substring~%" id)))
  (format t "All tests passed.~%")
  t)


(defun parse-bitrix-task-id (response-body)
  (let ((json (cl-json:decode-json-from-string response-body)))
    (cdr (assoc :id (cdr (assoc :task (cdr (assoc :result json))))))))

(defun upload-file-to-bitrix-task-helper (upload-url file-path)
  "Загружает файл, добавляя timestamp к имени для уникальности. Возвращает ID диска."
  (let* ((orig-name (file-namestring file-path))
         (timestamp (format nil "~D" (get-universal-time)))
         (unique-name (concatenate 'string timestamp "_" orig-name))
         (file-content 
           (with-open-file (stream file-path :element-type '(unsigned-byte 8))
             (let ((bytes (make-array (file-length stream) :element-type '(unsigned-byte 8))))
               (read-sequence bytes stream)
               (cl-base64:usb8-array-to-base64-string bytes))))
         (payload `(("id" . 1)
                    ("data" . (("NAME" . ,unique-name)))
                    ("fileContent" . (,unique-name ,file-content))))
         (json-payload (cl-json:encode-json-to-string payload)))
    (format t "~%>>> UPLOAD REQUEST to ~A~%" upload-url)
    (format t ">>> payload: ~S~%" payload)
    (format t ">>> JSON: ~A~%" json-payload)
    (multiple-value-bind (body status)
        (dex:post upload-url
                  :headers '(("Content-Type" . "application/json"))
                  :content json-payload)
      (format t "<<< UPLOAD RESPONSE status: ~A, body: ~A~%" status body)
      (if (= status 200)
          (let* ((json (cl-json:decode-json-from-string body)))
            (extract-id-from-bitrix-response json))
          (error "Failed to upload file, status ~A: ~A" status body)))))

(defun attach-file-to-bitrix-task (attach-url task-id file-id-with-prefix)
  "Прикрепляет файл с FILE-ID-WITH-PREFIX (уже с префиксом 'n') к задаче TASK-ID."
  (let ((payload `(("taskId" . ,task-id)
                   ("fields" . (("UF_TASK_WEBDAV_FILES" . (,file-id-with-prefix)))))))
    (multiple-value-bind (body status)
        (dex:post attach-url
                  :headers '(("Content-Type" . "application/json"))
                  :content (cl-json:encode-json-to-string payload))
      (if (= status 200)
          body
          (error "Failed to attach file, status ~A: ~A" status body)))))

(defun format-bitrix-deadline (universal-time)
  (multiple-value-bind (second minute hour day month year)
      (decode-universal-time universal-time 3)
    (format nil "~4,'0d-~2,'0d-~2,'0dT~2,'0d:~2,'0d:~2,'0d+03:00"
            year month day hour minute second)))

(defun compute-deadline (priority)
  (let ((now (get-universal-time)))
    (cond ((member priority '("very_high" "high") :test #'string=)
           (format-bitrix-deadline (+ now (* 6 3600))))
          (t
           (format-bitrix-deadline (+ now (* 24 3600)))))))

(defun compute-bitrix-priority (priority)
  (if (member priority '("very_high" "high") :test #'string=)
      2
      1))

(defun find-uploaded-file (request-dir)
  "Возвращает путь к первому файлу в папке, кроме data.json и data.lisp, или NIL."
  (when (probe-file request-dir)
    (let* ((search-path (make-pathname :name :wild :type :wild :defaults request-dir))
           (all-files (directory search-path)))
      (find-if (lambda (f)
                 (let ((name (file-namestring f)))
                   (and (not (equal name "data.json"))
                        (not (equal name "data.lisp")))))
               all-files))))

;;; Основная функция отправки заявки в Bitrix
(defun send-to-bitrix (data request-dir)
  (let ((base-url (gethash :bitrix-url *config*))
        (responsible-alist (gethash :bitrix-responsible *config*))
        (auditors-val (gethash :bitrix-auditors *config*))
        (category (cdr (assoc :category data)))
        (title (or (cdr (assoc :title data)) "Без темы"))
        (description (or (cdr (assoc :description data)) ""))
        (priority (cdr (assoc :priority data)))
        (user-id-str (cdr (assoc :user_id data))))
    (format t "~%=== SEND-TO-BITRIX START ===~%")
    (format t "base-url: ~A~%" base-url)
    (format t "category: ~A, title: ~A, priority: ~A, user-id: ~A~%" category title priority user-id-str)
    (unless base-url
      (error "Bitrix URL не настроен в конфигурации"))

    ;; Ищем файл в папке заявки
    (let* ((file-path (find-uploaded-file request-dir))
           (file-id (when file-path
                      (let ((upload-url (concatenate 'string base-url "disk.folder.uploadfile")))
                        (upload-file-to-bitrix-task-helper upload-url file-path))))
           (user-id (and user-id-str
                         (not (equal user-id-str ""))
                         (not (equal user-id-str "undefined"))
                         (parse-integer user-id-str :junk-allowed t)))
           (base-auditors (if (listp auditors-val) auditors-val (list auditors-val)))
           (auditors-list (if user-id (adjoin user-id base-auditors) base-auditors))
           (responsible-id
             (if responsible-alist
                 (or (cdr (assoc category responsible-alist :test #'string=)) 1)
                 1))
           (deadline (compute-deadline priority))
           (bitrix-priority (compute-bitrix-priority priority))
           (payload `(("fields" .
                       (("TITLE" . ,title)
                        ("DESCRIPTION" . ,description)
                        ("RESPONSIBLE_ID" . ,responsible-id)
                        ("CREATED_BY" . 1)
                        ("AUDITORS" . ,auditors-list)
                        ("DEADLINE" . ,deadline)
                        ("PRIORITY" . ,bitrix-priority)
                        ("GROUP_ID" . 10)))))
           (json-payload (cl-json:encode-json-to-string payload))
           (create-url (concatenate 'string base-url "tasks.task.add")))
      (format t "    file-path: ~S, file-id: ~S~%" file-path file-id)
      (format t "~%>>> CREATE TASK REQUEST~%")
      (format t "payload: ~S~%" payload)
      (format t "JSON: ~A~%" json-payload)

      ;; Создаём задачу
      (multiple-value-bind (create-body create-status)
          (dex:post create-url
                    :headers '(("Content-Type" . "application/json"))
                    :content json-payload)
        (format t "<<< CREATE TASK RESPONSE status: ~A, body: ~A~%" create-status create-body)
        (if (>= create-status 400)
            (error "Bitrix task creation failed: ~A" create-body)
            (let ((task-id (parse-bitrix-task-id create-body)))
              (format t "task-id: ~A~%" task-id)
              ;; Прикрепляем файл, если он был загружен
              (when file-id
                (let ((attach-url (concatenate 'string base-url "tasks.task.update")))
                  (attach-file-to-bitrix-task attach-url task-id (format nil "n~A" file-id))
                  (format t "Файл прикреплён к задаче ~A~%" task-id)))
              (format t "=== SEND-TO-BITRIX END ===~%")
              task-id))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(defun send-to-glpi (data)
  (let ((base (gethash :glpi-base *config*))
        (app-token (gethash :glpi-app-token *config*))
        (user-token (gethash :glpi-user-token *config*))
        (requester-alist (gethash :glpi-requester *config*))
        (category (cdr (assoc :category data)))
        (title (or (cdr (assoc :title data)) "Без темы"))
        (description (or (cdr (assoc :description data)) "")))
    (unless (and base app-token user-token)
      (error "GLPI параметры не настроены в конфигурации"))
    (let* ((requester-id
             (if requester-alist
                 (or (cdr (assoc category requester-alist :test #'string=)) 2)
                 2))
           (session-token (get-glpi-session-token base app-token user-token))
           (url (concatenate 'string base "/Ticket"))
           (payload `(("input" .
                       (("name" . ,title)
                        ("content" . ,description)
                        ("_users_id_requester" . ,requester-id)))))
           (json-payload (cl-json:encode-json-to-string payload)))
      (handler-case
          (multiple-value-bind (body status)
              (dex:post url
                        :content json-payload
                        :headers `(("App-Token" . ,app-token)
                                   ("Session-Token" . ,session-token)
                                   ("Content-Type" . "application/json")))
            (format t "~%GLPI ответ (статус ~A): ~A~%" status body)
            (when (>= status 400)
              (error "GLPI request failed with status ~A" status)))
        (dex:http-request-failed (e)
          (format t "~%Ошибка HTTP при создании тикета GLPI: ~A~%" e)
          (error e))))))



;;;;;;;;;;;;;;PROCESS  REQUESTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun process-requestzzzzz (request-dir)
  (unless (typep request-dir 'pathname)
    (format t "~%process-request получил не pathname: ~S~%" request-dir)
    (return-from process-requestzzzzz))
  (let ((lisp-file (merge-pathnames "data.lisp" request-dir)))
    (when (probe-file lisp-file)
      (handler-case
          (let ((data
                  (with-open-file (f lisp-file
                                     :direction :input
                                     :external-format :utf-8)
                    (with-standard-io-syntax
                      (read f)))))
            (format t "~%Обработка заявки из ~A:~%" request-dir)
            (format t "  Данные: ~S~%" data)
            ;; Отправка в Bitrix, если включено
            (when (gethash :bitrix-enabled *config*)
              (send-to-bitrix data request-dir))
            ;; Отправка в GLPI, если включено
            (when (gethash :glpi-enabled *config*)
              (send-to-glpi data))
            ;; Если дошли до сюда без ошибок — удаляем папку
            (uiop:delete-directory-tree request-dir :validate t)
            (format t "  Папка ~A удалена.~%" request-dir))
        (error (e)
          (format t "~%Ошибка при обработке ~A: ~A~%" request-dir e)
          (format t "Папка НЕ удалена (остаётся для повторной обработки).~%"))))))

(defun scan-requests ()
  (let ((base-dir (make-pathname :directory '(:relative "requests"))))
    (format t "~%scan-requests: base-dir = ~S~%" base-dir)
    (format t "~%type of base-dir = ~S~%" (type-of base-dir))
    (when (probe-file base-dir)
      (let ((subdirs (uiop:subdirectories base-dir)))
        (format t "~%subdirs = ~S~%" subdirs)
        (dolist (item subdirs)
          (format t "~%item type = ~S~%" (type-of item))
          (if (typep item 'pathname)
              (process-requestzzzzz item)
              (format t "~%Пропущен элемент не pathname: ~S~%" item)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;; Вспомогательная функция для получения сессии GLPI (теперь принимает параметры)
(defun get-glpi-session-token (base app-token user-token)
  (let ((url (concatenate 'string base "/initSession")))
    (handler-case
        (multiple-value-bind (body status)
            (dex:get url
                     :headers `(("App-Token" . ,app-token)
                                ("Authorization" . ,(format nil "user_token ~A" user-token))))
          (if (= status 200)
              (cdr (assoc :session_token (cl-json:decode-json-from-string body)))
              (error "GLPI initSession failed, status ~A: ~A" status body)))
      (dex:http-request-failed (e)
        (format t "~%Ошибка HTTP при получении токена GLPI: ~A~%" e)
        (error e)))))



(hunchentoot:define-easy-handler (upload-file :uri "/upload-file" :default-request-type :post) ()
  (setf (hunchentoot:content-type*) "application/json; charset=utf-8")
  (handler-case
      (let* ((uuid (hunchentoot:post-parameter "uuid"))
             (uploaded-file (hunchentoot:post-parameter "file"))
             (base-dir (make-pathname :directory '(:relative "requests")))
             (request-dir (merge-pathnames (make-pathname :directory `(:relative ,uuid)) base-dir)))
        ;; Проверка UUID
        (unless (and uuid (string/= uuid ""))
          (error "Missing or empty uuid"))
        ;; Создаём директорию, если её нет
        (ensure-directories-exist request-dir)
        ;; Если файл есть, сохраняем
        (when uploaded-file
          (format t "~%>>> UPLOAD-FILE: ~S~%" uploaded-file)
          (cond
            ((and (consp uploaded-file) (>= (length uploaded-file) 2))
             (let ((temp-path (first uploaded-file))
                   (orig-name (second uploaded-file)))
               (format t "    temp-path: ~S, orig-name: ~S~%" temp-path orig-name)
               (if (and (pathnamep temp-path) (stringp orig-name))
                   (let ((dest-path (merge-pathnames (make-pathname :name orig-name) request-dir)))
                     (format t "    dest-path: ~S~%" dest-path)
                     (uiop:copy-file temp-path dest-path)
                     (format t "<<< File saved~%"))
                   (error "Invalid uploaded-file structure"))))
            (t
             (error "Unexpected uploaded-file format"))))
        ;; Возвращаем успех
        (cl-json:encode-json-to-string `((:status . "ok") (:message . "File uploaded"))))
    (error (e)
      (setf (hunchentoot:return-code*) 400)
      (cl-json:encode-json-to-string `((:status . "error") (:message . ,(princ-to-string e)))))))





(hunchentoot:define-easy-handler (create-task :uri "/create-task" :default-request-type :post) ()
  (setf (hunchentoot:content-type*) "application/json; charset=utf-8")
  (handler-case
      (let* ((uuid (hunchentoot:post-parameter "uuid"))
             (category (hunchentoot:post-parameter "category"))
             (title (hunchentoot:post-parameter "title"))
             (description (hunchentoot:post-parameter "description"))
             (user_id (hunchentoot:post-parameter "user_id"))
             (priority (hunchentoot:post-parameter "priority"))
             (user_email (hunchentoot:post-parameter "user_email"))
             (user_phone (hunchentoot:post-parameter "user_phone"))
             (uploaded-file (hunchentoot:post-parameter "file"))
             (base-dir (make-pathname :directory '(:relative "requests")))
             (request-dir (merge-pathnames (make-pathname :directory `(:relative ,uuid)) base-dir)))
        ;; Проверка наличия UUID
        (unless (and uuid (string/= uuid ""))
          (error "Missing or empty uuid"))
        ;; Создаём директорию запроса
        (ensure-directories-exist request-dir)
        ;; Данные для сохранения
        (let ((json-data `((:uuid . ,uuid)
                           (:category . ,category)
                           (:title . ,title)
                           (:priority . ,priority)
                           (:description . ,description)
                           (:user_id . ,user_id)
                           (:user_email . ,user_email)
                           (:user_phone . ,user_phone))))
          ;; Сохраняем JSON
          (with-open-file (f (merge-pathnames "data.json" request-dir)
                             :direction :output
                             :if-exists :supersede
                             :external-format :utf-8)
            (cl-json:encode-json json-data f))
          ;; Сохраняем Lisp-представление
          (with-open-file (f (merge-pathnames "data.lisp" request-dir)
                             :direction :output
                             :if-exists :supersede
                             :external-format :utf-8)
            (with-standard-io-syntax
              (let ((*print-readably* t))
                (print json-data f))))
          ;; Если есть файл, сохраняем его простейшим способом
                  )
        ;; Возвращаем успех
        (cl-json:encode-json-to-string `((:status . "ok") (:message . "Request saved"))))
    (error (e)
      (setf (hunchentoot:return-code*) 400)
      (cl-json:encode-json-to-string `((:status . "error") (:message . ,(princ-to-string e)))))))


(defun start-server (&key (port 11111))
  (let ((acceptor (make-instance 'hunchentoot:easy-acceptor 
                                 :port port
                                 :read-timeout 300
                                 :write-timeout 300)))
    (hunchentoot:start acceptor)
    (format t "Server running at http://localhost:~d/~%" port)
    (format t "Static files served from /static/~%")
    (format t "Endpoints: /, /up, /lnk, /updatelnk, /chat~%")
    acceptor))    



(defun main ()
  ;; Загружаем конфигурацию (если файла нет, создаётся с настройками по умолчанию)
  (load-config)
  
  ;; Запускаем фоновый поток для обработки заявок
  (bt:make-thread
    (lambda ()
      (loop
        (sleep 10)   ; интервал сканирования
        (when (gethash :processing-enabled *config*)
          (scan-requests))))
    :name "request-processor")
  
  ;; Запуск сервера
  (start-server)
  (loop (sleep 3600)))
;;; Запуск теста
;;; (test-plus)
  ;;sbcl --load hello.lisp      --eval '(sb-ext:save-lisp-and-die "hello-server" :toplevel #'\''hello::main :executable t)'

;;  sbcl --load hello.lisp      --eval '(hello:main)'


;; sbcl --load hello.lisp      --eval '(hello:main)'
;;  +/r   for hot reload


;; sbcl --load hello.lisp      --eval '(hello:tests)'
