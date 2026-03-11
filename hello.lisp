(require :asdf)
(asdf:load-system :hunchentoot)
(asdf:load-system :cl-json)
(asdf:load-system :frugal-uuid)
(defpackage :hello
  (:use :cl :hunchentoot :fuuid)
  ;; (:import-from :hunchentoot ... ) - полностью удалите эту строку!
  (:export #:start-server #:main #:plus #:test-plus))
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

(defun log-request (data)
  (with-open-file (log-stream "requests.log"
                               :direction :output
                               :if-exists :append
                               :if-does-not-exist :create)
    (multiple-value-bind (second minute hour day month year)
      (get-decoded-time)
      (format log-stream "[~4,'0d-~2,'0d-~2,'0d ~2,'0d:~2,'0d:~2,'0d] ~a~%"
              year month day hour minute second data))))

; (hunchentoot:define-easy-handler (create-task :uri "/create-task" :default-request-type :post) ()
;   (setf (hunchentoot:content-type*) "application/json")
;   (let* ((raw-data (hunchentoot:raw-post-data :force-text t)))
;     (log-request raw-data)
;     (cl-json:encode-json-to-string '((:status . "ok") (:message . "logged")))))      


(hunchentoot:define-easy-handler (create-task :uri "/create-task" :default-request-type :post) ()
  (setf (hunchentoot:content-type*) "application/json; charset=utf-8")
  (handler-case
      (let* ((uuid (hunchentoot:post-parameter "uuid"))
             (category (hunchentoot:post-parameter "category"))
             (title (hunchentoot:post-parameter "title"))
             (description (hunchentoot:post-parameter "description"))
             (user_id (hunchentoot:post-parameter "user_id"))
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
                           (:description . ,description)
                           (:user_id . ,user_id)
                           (:user_email . ,user_email)
                           (:user_phone . ,user_phone))))
          ;; Сохраняем JSON (с экранированием юникода — стандартное поведение cl-json)
          (with-open-file (f (merge-pathnames "data.json" request-dir)
                             :direction :output
                             :if-exists :supersede
                             :external-format :utf-8)
            (cl-json:encode-json json-data f))
          ;; Сохраняем Lisp-представление (читабельно в REPL)
          (with-open-file (f (merge-pathnames "data.lisp" request-dir)
                             :direction :output
                             :if-exists :supersede
                             :external-format :utf-8)
            (with-standard-io-syntax
              (let ((*print-readably* t))
                (print json-data f))))   ; печатаем в формате, читаемом Lisp
          ;; Если есть файл, сохраняем его
          (when uploaded-file
            (let* ((temp-path (first uploaded-file))
                   (orig-name (second uploaded-file))
                   (dest-path (merge-pathnames (make-pathname :name (or orig-name "uploaded-file")
                                                              :type nil)
                                               request-dir)))
              (uiop:copy-file temp-path dest-path))))
        ;; Возвращаем успех
        (cl-json:encode-json-to-string `((:status . "ok") (:message . "Request saved"))))
    (error (e)
      (setf (hunchentoot:return-code*) 400)
      (cl-json:encode-json-to-string `((:status . "error") (:message . ,(princ-to-string e)))))))
(defun start-server (&key (port 11111))
  (let ((acceptor (make-instance 'hunchentoot:easy-acceptor :port port)))
    (hunchentoot:start acceptor)
    (format t "Server running at http://localhost:~d/~%" port)
    (format t "Static files served from /static/~%")
    (format t "Endpoints: /, /up, /lnk, /updatelnk, /chat~%")
    acceptor))

(defun main ()
  (start-server)
  (loop (sleep 3600)))
;;; Запуск теста
;;; (test-plus)
  ;;sbcl --load hello.lisp      --eval '(sb-ext:save-lisp-and-die "hello-server" :toplevel #'\''hello::main :executable t)'

;;  sbcl --load hello.lisp      --eval '(hello:main)'


;; sbcl --load hello.lisp      --eval '(hello:main)'
;;  +/r   for hot reload