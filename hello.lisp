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
  (:export #:start-server #:main #:plus #:test-plus  #:tests   #:test-id
  #:test-bitrix-update-json   #:test-find-uploaded-file
  #:test-compute-deadline #:testExtractToken))
(in-package :hello)
(declaim (ftype (function (string string) integer) send-to-glpi))

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
;; Функция извлечения числа из JSON-строки по ключу (исправленная версия)
(defun extract-number-from-json-string (json-string key)
  "Извлекает число из JSON-строки по ключу. Число может быть в кавычках или без."
  (let* ((key-str (format nil "\"~A\"" key))
         (key-start (search key-str json-string)))
    (unless key-start
      (error "Поле ~S не найдено в JSON" key-str))
    ;; позиция после ключа
    (let ((pos (+ key-start (length key-str))))
      ;; ищем двоеточие
      (setf pos (position #\: json-string :start pos))
      (unless pos
        (error "После ключа ~S не найдено двоеточие" key-str))
      ;; переходим к символу после двоеточия
      (incf pos)
      ;; пропускаем пробелы и табуляции
      (loop while (and (< pos (length json-string))
                       (member (aref json-string pos) '(#\Space #\Tab)))
            do (incf pos))
      ;; если после пробелов идёт кавычка, пропускаем её
      (when (and (< pos (length json-string))
                 (char= (aref json-string pos) #\"))
        (incf pos))
      ;; собираем цифры
      (let ((num-start pos))
        (loop while (and (< pos (length json-string))
                         (digit-char-p (aref json-string pos)))
              do (incf pos))
        (if (= num-start pos)
            (error "После поля ~S не найдено число" key-str)
            (parse-integer (subseq json-string num-start pos)))))))

(defun test-id ()
  (let ((json "{\"result\":{\"ID\":592,\"NAME\":\"3982318137_1.txt\",\"CODE\":null,\"STORAGE_ID\":\"1\",\"TYPE\":\"file\",\"PARENT_ID\":\"1\",\"DELETED_TYPE\":0,\"GLOBAL_CONTENT_VERSION\":1,\"FILE_ID\":674,\"SIZE\":\"4\",\"CREATE_TIME\":\"2026-03-12T18:28:57+03:00\",\"UPDATE_TIME\":\"2026-03-12T18:28:57+03:00\",\"DELETE_TIME\":null,\"CREATED_BY\":\"1\",\"UPDATED_BY\":\"1\",\"DELETED_BY\":null,\"DOWNLOAD_URL\":\"https://b24-e8jgcd.bitrix24.ru/rest/1/j76xi3h3vyvmqlro/download/?token=disk%7CaWQ9NTkyJl89YWh5cU9LazI0WTEzZ1BaQXA2Z3RmUDQ4bE0ybld2UlA%3D%7CImRvd25sb2FkfGRpc2t8YVdROU5Ua3lKbDg5WVdoNWNVOUxhekkwV1RFeloxQmFRWEEyWjNSbVVEUTRiRTB5YmxkMlVsQT18MXxqNzZ4aTNoM3Z5dm1xbHJvIg%3D%3D.Lc1oPtPAnkpfX9jKEtKm%2FH8w0EdG2QSGwXOjhQiZE2w%3D\",\"DETAIL_URL\":\"https://b24-e8jgcd.bitrix24.ru/company/personal/user/1/disk/file/3982318137_1.txt\"},\"time\":{\"start\":1773329337,\"finish\":1773329337.204803,\"duration\":0.2048029899597168,\"processing\":0,\"date_start\":\"2026-03-12T18:28:57+03:00\",\"date_finish\":\"2026-03-12T18:28:57+03:00\",\"operating_reset_at\":1773329937,\"operating\":6.6042845249176025}}"))
    (let ((id (extract-number-from-json-string json "ID")))
      (assert (= id 592))
      (format t "Test passed: extracted ~A~%" id))))

;; Запуск: (test-extract-id)

;; Запуск теста
;; (test-extract-id)




;;; Тесты для extract-id-from-bitrix-response
;; Тест для extract-number-from-json-string на реальном JSON из лога


;; Запуск: (test-extract-id)


(defun test-find-uploaded-file ()
  (let* ((test-dir (make-pathname :directory '(:relative "test-upload")))
         (test-dir-pathname (ensure-directories-exist test-dir)))
    (unwind-protect
         (progn
           ;; Создаём тестовые файлы
           (with-open-file (f (merge-pathnames "data.json" test-dir-pathname)
                              :direction :output :if-exists :supersede)
             (write-line "{}" f))
           (with-open-file (f (merge-pathnames "data.lisp" test-dir-pathname)
                              :direction :output :if-exists :supersede)
             (write-line "()" f))
           (with-open-file (f (merge-pathnames "test.txt" test-dir-pathname)
                              :direction :output :if-exists :supersede)
             (write-line "hello" f))

           ;; Тест 1: должен найти test.txt
           (let ((result (find-uploaded-file test-dir-pathname)))
             (unless (and result
                          (equal (file-namestring result) "test.txt"))
               (error "Test 1 failed: expected test.txt, got ~S" result))
             (format t "Test 1 passed~%"))

           ;; Тест 2: если удалить test.txt, должен вернуть NIL
           (delete-file (merge-pathnames "test.txt" test-dir-pathname))
           (let ((result (find-uploaded-file test-dir-pathname)))
             (unless (null result)
               (error "Test 2 failed: expected NIL, got ~S" result))
             (format t "Test 2 passed~%"))

           ;; Тест 3: если добавить ещё один файл, должен вернуть первый
           (with-open-file (f (merge-pathnames "other.png" test-dir-pathname)
                              :direction :output :if-exists :supersede)
             (write-line "fake" f))
           (let ((result (find-uploaded-file test-dir-pathname)))
             (unless (and result
                          (member (file-namestring result) '("other.png") :test #'string=))
               (error "Test 3 failed: expected other.png, got ~S" result))
             (format t "Test 3 passed~%"))

           (format t "All tests passed~%"))
      ;; очистка: удаляем временную директорию
      (uiop:delete-directory-tree test-dir-pathname :validate t))))

;; Запуск: (test-find-uploaded-file)

(defun tests ()
  (format t "Testing extract-number-from-json-string...~%")
  ;; Тест 1: ID без кавычек (как в ответе загрузки файла)
  (let ((json "{\"result\":{\"ID\":592,\"NAME\":\"file.txt\"}}"))
    (assert (= (extract-number-from-json-string json "ID") 592))
    (format t "Test 1 passed: extracted 592~%"))
  ;; Тест 2: id в кавычках (как в ответе создания задачи)
  (let ((json "{\"result\":{\"task\":{\"id\":\"88\",\"title\":\"Test\"}}}"))
    (assert (= (extract-number-from-json-string json "id") 88))
    (format t "Test 2 passed: extracted 88~%"))
  ;; Тест 3: ключ не найден
  (let ((json "{\"result\":{\"name\":\"file.txt\"}}"))
    (handler-case
        (progn
          (extract-number-from-json-string json "ID")
          (error "Test 3 failed: expected error"))
      (error (e)
        (format t "Test 3 passed: caught expected error ~A~%" e))))
  (format t "All tests passed.~%")
  t)

;;;            sbcl --load hello.lisp      --eval '(hello:test-compute-deadline)'
(defun test-compute-deadline ()
  (let ((now (get-universal-time)))
    (format t "~%Current time (UTC+3): ~A~%" (format-bitrix-deadline now))
    (flet ((test-one (priority expected-delta)
             (let* ((expected-time (+ now expected-delta))
                    (expected-str (format-bitrix-deadline expected-time))
                    (actual-str (compute-deadline priority now)))
               (format t "~%Priority: ~A" priority)
               (format t "~%  Expected (+~A sec): ~A" expected-delta expected-str)
               (format t "~%  Actual:              ~A" actual-str)
               (assert (string= actual-str expected-str)
                       nil
                       "FAIL: ~A" priority)
               (format t "  -> OK~%"))))
      (test-one "very_high" (* 6 3600))
      (test-one "high"      (* 6 3600))
      (test-one "medium"    (* 24 3600))
      (test-one "low"       (* 24 3600))
      (test-one "very_low"  (* 24 3600))
      (format t "~%All tests passed.~%")
      t)))


; Обновлённая функция compute-deadline с необязательным параметром now
(defun compute-deadline (priority &optional (now (get-universal-time)))
  (let ((now-utc now))
    (multiple-value-bind (sec min hour day month year) (decode-universal-time now-utc 0)
      (format t "DEBUG compute-deadline: now-utc=~A (UTC), decoded UTC: ~4,'0d-~2,'0d-~2,'0d ~2,'0d:~2,'0d:~2,'0d~%" 
              now-utc year month day hour min sec))
    (multiple-value-bind (sec min hour day month year) (decode-universal-time now-utc 3)
      (format t "DEBUG compute-deadline: local time (UTC+3): ~4,'0d-~2,'0d-~2,'0d ~2,'0d:~2,'0d:~2,'0d~%" 
              year month day hour min sec))
    (format t "DEBUG compute-deadline: priority=~S~%" priority)
    (cond ((member priority '("very_high" "high") :test #'string=)
           (let ((future (+ now-utc (* 6 3600))))
             (multiple-value-bind (sec min hour day month year) (decode-universal-time future 3)
               (format t "DEBUG future (+6h local): ~4,'0d-~2,'0d-~2,'0d ~2,'0d:~2,'0d:~2,'0d~%" 
                       year month day hour min sec))
             (format-bitrix-deadline future)))
          (t
           (let ((future (+ now-utc (* 24 3600))))
             (multiple-value-bind (sec min hour day month year) (decode-universal-time future 3)
               (format t "DEBUG future (+24h local): ~4,'0d-~2,'0d-~2,'0d ~2,'0d:~2,'0d:~2,'0d~%" 
                       year month day hour min sec))
             (format-bitrix-deadline future))))))


(defun make-bitrix-task-add-payload (title description responsible-id auditors deadline priority group-id)
  "Создаёт payload для создания задачи (tasks.task.add)."
  `(("fields" .
     (("TITLE" . ,title)
      ("DESCRIPTION" . ,description)
      ("RESPONSIBLE_ID" . ,responsible-id)
      ("CREATED_BY" . 1)
      ("AUDITORS" . ,auditors)
      ("DEADLINE" . ,deadline)
      ("PRIORITY" . ,priority)
      ("GROUP_ID" . ,group-id)))))

(defun make-bitrix-file-upload-payload (file-name file-content)
  "Создаёт payload для загрузки файла (disk.folder.uploadfile)."
  `(("id" . 1)
    ("data" . (("NAME" . ,file-name)))
    ("fileContent" . (,file-name ,file-content))))


;; Функция формирования payload для прикрепления файла (исправленная)
(defun make-bitrix-update-json (task-id file-id-with-prefix)
  (format nil "{\"taskId\":~A,\"fields\":{\"UF_TASK_WEBDAV_FILES\":[\"~A\"]}}" task-id file-id-with-prefix))

;; Тест (можно выполнить прямо в REPL)
(defun test-bitrix-update-json ()
  (let ((json (make-bitrix-update-json 232 "n1288")))
    (assert (string= json "{\"taskId\":232,\"fields\":{\"UF_TASK_WEBDAV_FILES\":[\"n1288\"]}}"))
    (format t "Test passed: ~A~%" json)
    t))

;; Тест, который проверяет правильность генерации JSON


;; Запуск теста (можно скопировать в REPL)



(defun upload-file-to-bitrix-task-helper (upload-url file-path)
  (let* ((orig-name (file-namestring file-path))
         (timestamp (format nil "~D" (get-universal-time)))
         (unique-name (concatenate 'string timestamp "_" orig-name))
         (file-content 
           (with-open-file (stream file-path :element-type '(unsigned-byte 8))
             (let ((bytes (make-array (file-length stream) :element-type '(unsigned-byte 8))))
               (read-sequence bytes stream)
               (cl-base64:usb8-array-to-base64-string bytes))))
         (payload (make-bitrix-file-upload-payload unique-name file-content))
         (json-payload (cl-json:encode-json-to-string payload)))
    (format t "~%>>> UPLOAD REQUEST to ~A~%" upload-url)
    (format t ">>> JSON: ~A~%" json-payload)
    (multiple-value-bind (body status)
        (dex:post upload-url :headers '(("Content-Type" . "application/json")) :content json-payload)
      (format t "<<< UPLOAD RESPONSE status: ~A, body: ~A~%" status body)
      (if (= status 200)
          (extract-number-from-json-string body "ID")
          (error "Failed to upload file, status ~A: ~A" status body)))))

;; Полная замена attach-file-to-bitrix-task на простую версию
(defun attach-file-to-bitrix-task (attach-url task-id file-id-with-prefix)
  (let ((json-payload (make-bitrix-update-json task-id file-id-with-prefix)))
    (format t "~%>>> ATTACH REQUEST to ~A~%" attach-url)
    (format t ">>> JSON: ~A~%" json-payload)
    (multiple-value-bind (body status)
        (dex:post attach-url
                  :headers '(("Content-Type" . "application/json"))
                  :content json-payload)
      (format t "<<< ATTACH RESPONSE status: ~A, body: ~A~%" status body)
      (unless (= status 200)
        (error "Failed to attach file, status ~A: ~A" status body))
      body)))
;
(defun format-bitrix-deadline (universal-time)
  (multiple-value-bind (second minute hour day month year)
      (decode-universal-time universal-time -3)  ; UTC+3
    (format nil "~4,'0d-~2,'0d-~2,'0dT~2,'0d:~2,'0d:~2,'0d+03:00"
            year month day hour minute second)))



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
;; Вспомогательные функции для подготовки данных
(defun prepare-bitrix-auditors (auditors-val user-id)
  "Формирует список аудиторов, добавляя user-id, если он есть."
  (let ((base-auditors (if (listp auditors-val) auditors-val (list auditors-val))))
    (if user-id
        (adjoin user-id base-auditors)
        base-auditors)))

(defun prepare-bitrix-task-data (category title description priority user-id-str
                                 responsible-alist auditors-val)
  "Собирает все данные, необходимые для создания задачи."
  (let* ((user-id (and user-id-str
                        (not (equal user-id-str ""))
                        (not (equal user-id-str "undefined"))
                        (parse-integer user-id-str :junk-allowed t)))
         (responsible-id (if responsible-alist
                             (or (cdr (assoc category responsible-alist :test #'string=)) 1)
                             1))
         (auditors-list (prepare-bitrix-auditors auditors-val user-id))
         (deadline (progn
                     (format t "DEBUG calling compute-deadline with priority=~S~%" priority)
                     (compute-deadline priority)))
         (priority-val (compute-bitrix-priority priority)))
    (format t "DEBUG prepare-bitrix-task-data: category=~S, title=~S, priority=~S, user-id-str=~S~%" category title priority user-id-str)
    (format t "  user-id (parsed)=~S~%" user-id)
    (format t "  responsible-id=~S~%" responsible-id)
    (format t "  auditors-list=~S~%" auditors-list)
    (format t "  deadline (computed)=~S~%" deadline)
    (format t "  priority-val=~S~%" priority-val)
    (values title description responsible-id auditors-list deadline priority-val)))

(defun create-bitrix-task (base-url title description responsible-id auditors deadline priority)
  "Создаёт задачу в Bitrix и возвращает её ID."
  (let* ((payload (make-bitrix-task-add-payload
                   title description responsible-id auditors deadline priority 10))
         (json-payload (cl-json:encode-json-to-string payload))
         (create-url (concatenate 'string base-url "tasks.task.add")))
    (multiple-value-bind (body status)
        (dex:post create-url :headers '(("Content-Type" . "application/json")) :content json-payload)
      (if (>= status 400)
          (error "Bitrix task creation failed: ~A" body)
          (extract-number-from-json-string body "id")))))

;; Основная функция – теперь короткая и ясная
(defun send-to-bitrix (data request-dir)
  (let ((base-url (gethash :bitrix-url *config*))
        (responsible-alist (gethash :bitrix-responsible *config*))
        (auditors-val (gethash :bitrix-auditors *config*)))
    (format t "~%=== SEND-TO-BITRIX START === base-url: ~A~%" base-url)
    (unless base-url (error "Bitrix URL не настроен"))

    ;; 1. Загружаем файл, если есть
    (let* ((file-path (find-uploaded-file request-dir))
           (file-id (when file-path
                      (let ((upload-url (concatenate 'string base-url "disk.folder.uploadfile")))
                        (upload-file-to-bitrix-task-helper upload-url file-path)))))

      ;; 2. Готовим данные для задачи
      (multiple-value-bind (title description responsible-id auditors deadline priority)
          (prepare-bitrix-task-data
           (cdr (assoc :category data))
           (or (cdr (assoc :title data)) "Без темы")
           (or (cdr (assoc :description data)) "")
           (cdr (assoc :priority data))
           (cdr (assoc :user_id data))
           responsible-alist
           auditors-val)
        (format t "DEBUG: deadline from prepare = ~S~%" deadline)
        (format t "DEBUG: priority from data = ~S~%" (cdr (assoc :priority data))) ; отладка

        ;; 3. Создаём задачу
        (let ((task-id (create-bitrix-task base-url title description responsible-id
                                           auditors deadline priority)))
          (format t "task-id: ~A~%" task-id)

          ;; 4. Прикрепляем файл, если он был загружен
          (when file-id
            (let ((attach-url (concatenate 'string base-url "tasks.task.update")))
              (attach-file-to-bitrix-task attach-url task-id (format nil "n~A" file-id))
              (format t "Файл прикреплён к задаче ~A~%" task-id)))
          (format t "=== SEND-TO-BITRIX END ===~%")
          task-id)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                      ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   ||||||||||||  ||||           ||||||||||||||  ||||  ;;;;;;;;;;;;;;;;;;;;;;;;;;;                           
;   ||||          ||||           ||||      ||||  ||||  ;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;   ||||  ||||||  ||||           ||||||||||||||  ||||  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   ||||     |||  |||||||||||||  ||||            ||||  ;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;   ||||||||||||  |||||||||||||  ||||            ||||  ;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;                                                      ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun extract-string-from-json-string (json-string key)
  "Извлекает строковое значение из JSON-строки по ключу (например, key=\"session_token\")."
  (let* ((key-str (format nil "\"~A\":" key))
         (start (search key-str json-string)))
    (unless start
      (error "Поле ~S не найдено в JSON" key-str))
    (let ((pos (+ start (length key-str))))
      (loop while (and (< pos (length json-string))
                       (member (aref json-string pos) '(#\Space #\Tab)))
            do (incf pos))
      (when (and (< pos (length json-string))
                 (char= (aref json-string pos) #\"))
        (incf pos))
      (let ((start-pos pos))
        (loop while (and (< pos (length json-string))
                         (char/= (aref json-string pos) #\"))
              do (incf pos))
        (if (= start-pos pos)
            (error "После поля ~S не найдена строка" key-str)
            (subseq json-string start-pos pos))))))



;; Тест для extract-string-from-json-string
(defun testExtractToken ()
  (format t "Testing extract-string-from-json-string...~%")
  (let ((json "{\"session_token\":\"abc123\"}"))
    (assert (string= (extract-string-from-json-string json "session_token") "abc123")))
  (let ((json "{\"session_token\": \"abc123\"}"))
    (assert (string= (extract-string-from-json-string json "session_token") "abc123")))
  (let ((json "{\"other\":\"value\"}"))
    (handler-case
        (extract-string-from-json-string json "session_token")
      (error (e)
        (format t "Test passed: caught expected error ~A~%" e))))
  (format t "All tests passed for extract-string-from-json-string.~%")
  t)

(defun upload-file-to-glpi (base-url file-path session-token app-token)
  "Загружает файл в GLPI как документ. Возвращает ID документа."
  (let* ((url (concatenate 'string base-url "/Document"))
         (file-name (file-namestring file-path))
         ;; Читаем файл как байты для отправки
         (file-content 
           (with-open-file (stream file-path :element-type '(unsigned-byte 8))
             (let ((bytes (make-array (file-length stream) :element-type '(unsigned-byte 8))))
               (read-sequence bytes stream)
               bytes)))
         ;; Формируем multipart тело
         (boundary "----GLPIBoundary")
         (manifest (format nil "{\"input\": {\"name\": \"~A\", \"_filename\": [\"~A\"]}}" 
                          file-name file-name))
         ;; Собираем тело запроса
         (body-parts (list
                      (format nil "--~A~%Content-Disposition: form-data; name=\"uploadManifest\"~%~%~A~%" 
                              boundary manifest)
                      (format nil "--~A~%Content-Disposition: form-data; name=\"filename[0]\"; filename=\"~A\"~%Content-Type: application/octet-stream~%~%" 
                              boundary file-name)))
         ;; Добавляем бинарные данные
         (body (with-output-to-string (out)
                 (dolist (part body-parts) (write-string part out))
                 (write-sequence file-content out)
                 (format nil "~%--~A--~%" boundary))))
    (format t "~%>>> UPLOADING FILE TO GLPI: ~A~%" file-name)
    (multiple-value-bind (response-body status)
        (dex:post url
                  :headers `(("Session-Token" . ,session-token)
                             ("App-Token" . ,app-token)
                             ("Content-Type" . ,(format nil "multipart/form-data; boundary=~A" boundary)))
                  :content body)
      (format t "<<< GLPI UPLOAD RESPONSE status: ~A, body: ~A~%" status response-body)
      (if (= status 201)  ; 201 Created
          (extract-number-from-json-string response-body "id")
          (error "GLPI file upload failed, status ~A: ~A" status response-body)))))


  (defun attach-document-to-glpi-ticket (base-url document-id ticket-id session-token app-token)
  "Привязывает документ с DOCUMENT-ID к тикету TICKET-ID в GLPI."
  (let* ((url (concatenate 'string base-url "/Document/" (write-to-string document-id) "/Document_Item/"))
         (payload `(("input" .
                     (("documents_id" . ,document-id)
                      ("items_id" . ,ticket-id)
                      ("itemtype" . "Ticket")))))
         (json-payload (cl-json:encode-json-to-string payload)))
    (format t "~%>>> ATTACHING DOCUMENT ~A TO TICKET ~A~%" document-id ticket-id)
    (format t ">>> JSON: ~A~%" json-payload)
    (multiple-value-bind (response-body status)
        (dex:post url
                  :headers `(("Session-Token" . ,session-token)
                             ("App-Token" . ,app-token)
                             ("Content-Type" . "application/json"))
                  :content json-payload)
      (format t "<<< GLPI ATTACH RESPONSE status: ~A, body: ~A~%" status response-body)
      (unless (= status 201)  ; 201 Created
        (error "Failed to attach document to ticket, status ~A: ~A" status response-body))
      response-body)))        



(defun send-to-glpi (data request-dir)
  (let ((base (gethash :glpi-base *config*))
        (app-token (gethash :glpi-app-token *config*))
        (user-token (gethash :glpi-user-token *config*))
        (requester-alist (gethash :glpi-requester *config*))
        (category (cdr (assoc :category data)))
        (title (or (cdr (assoc :title data)) "Без темы"))
        (description (or (cdr (assoc :description data)) "")))
    (unless (and base app-token user-token)
      (error "GLPI параметры не настроены в конфигурации"))
    
    ;; 1. Получаем сессионный токен
    (let* ((session-token (get-glpi-session-token base app-token user-token))
           ;; 2. Определяем requester_id
           (requester-id (if requester-alist
                             (or (cdr (assoc category requester-alist :test #'string=)) 2)
                             2))
           ;; 3. Создаём тикет
           (ticket-id (create-glpi-ticket base title description requester-id 
                                          session-token app-token))
           ;; 4. Ищем файл в папке заявки (как в Bitrix)
           (file-path (find-uploaded-file request-dir)))
      
      ;; 5. Если есть файл — загружаем и прикрепляем
      (when file-path
        (handler-case
            (let ((doc-id (upload-file-to-glpi base file-path session-token app-token)))
              (attach-document-to-glpi-ticket base doc-id ticket-id session-token app-token)
              (format t "    Файл ~A прикреплён к тикету ~A~%" 
                      (file-namestring file-path) ticket-id))
          (error (e)
            (format t "    Ошибка при загрузке/прикреплении файла в GLPI: ~A~%" e))))
      
      (format t "GLPI тикет создан, ID: ~A~%" ticket-id)
      ticket-id)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;PROCESS  REQUESTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (defun process-requestzzzzz (request-dir)
;   (unless (typep request-dir 'pathname)
;     (format t "~%process-request получил не pathname: ~S~%" request-dir)
;     (return-from process-requestzzzzz))
;   (let ((lisp-file (merge-pathnames "data.lisp" request-dir)))
;     (when (probe-file lisp-file)
;       (handler-case
;           (let ((data
;                   (with-open-file (f lisp-file
;                                      :direction :input
;                                      :external-format :utf-8)
;                     (with-standard-io-syntax
;                       (read f)))))
;             (format t "~%Обработка заявки из ~A:~%" request-dir)
;             (format t "  Данные: ~S~%" data)
;             ;; Отправка в Bitrix, если включено
;             (when (gethash :bitrix-enabled *config*)
;               (send-to-bitrix data request-dir))
;             ;; Отправка в GLPI, если включено
;             (when (gethash :glpi-enabled *config*)
;               (send-to-glpi data))
;             ;; Если дошли до сюда без ошибок — удаляем папку
;             (uiop:delete-directory-tree request-dir :validate t)
;             (format t "  Папка ~A удалена.~%" request-dir))
;         (error (e)
;           (format t "~%Ошибка при обработке ~A: ~A~%" request-dir e)
;           (format t "Папка НЕ удалена (остаётся для повторной обработки).~%"))))))

(defun process-requestzzzzz (request-dir)
  (unless (typep request-dir 'pathname)
    (format t "~%process-request получил не pathname: ~S~%" request-dir)
    (return-from process-requestzzzzz))
  (let ((lisp-file (merge-pathnames "data.lisp" request-dir)))
    (when (probe-file lisp-file)
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
          (send-to-glpi data request-dir))
        ;; Если дошли до сюда без ошибок — удаляем папку
        (uiop:delete-directory-tree request-dir :validate t)
        (format t "  Папка ~A удалена.~%" request-dir)))))

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
    (format t "~%>>> GET GLPI SESSION TOKEN from ~A~%" url)
    (handler-case
        (multiple-value-bind (body status)
            (dex:get url
                     :headers `(("App-Token" . ,app-token)
                                ("Authorization" . ,(format nil "user_token ~A" user-token))))
          (format t "<<< GLPI initSession response status: ~A, body: ~A~%" status body)
          (if (= status 200)
              (let ((token (extract-string-from-json-string body "session_token")))
                (format t "    extracted session token: ~A~%" token)
                token)
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

(defun test-upload-form ()
  "<!DOCTYPE html>
<html>
<head><title>Test File Upload</title></head>
<body>
  <h2>Test File Upload</h2>
  <form method=\"POST\" action=\"/test-upload\" enctype=\"multipart/form-data\">
    <input type=\"file\" name=\"file\">
    <input type=\"submit\" value=\"Upload\">
  </form>
</body>
</html>")

;; Хендлер для тестирования загрузки файла (GET — форма, POST — обработка)
(hunchentoot:define-easy-handler (test-upload :uri "/test-upload") ()
  (case (hunchentoot:request-method*)
    (:get
     (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
     (test-upload-form))
    (:post
     (setf (hunchentoot:content-type*) "text/plain; charset=utf-8")
     (let* ((uploaded-file (hunchentoot:post-parameter "file"))
            (temp-path (when (and (consp uploaded-file) (>= (length uploaded-file) 2))
                         (first uploaded-file)))
            (orig-name (when (and (consp uploaded-file) (>= (length uploaded-file) 2))
                         (second uploaded-file)))
            (save-dir #P"./test-uploads/")
            (dest-path (when (and temp-path orig-name)
                         (ensure-directories-exist save-dir)
                         (merge-pathnames (make-pathname :name orig-name) save-dir))))
       ;; Сохраняем файл, если получилось
       (when dest-path
         (uiop:copy-file temp-path dest-path))
       ;; Возвращаем подробную информацию
       (format nil "Uploaded file structure:~%~S~%~%Temp path: ~A~%Original name: ~A~%Saved to: ~A"
               uploaded-file temp-path orig-name dest-path)))))









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

;; sbcl --load hello.lisp      --eval '(hello:test-id)'


