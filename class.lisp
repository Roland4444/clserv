; (require :asdf)
; (asdf:load-system :cl-store)   ; загружаем библиотеку бинарной сериализации

; (defpackage :my-class
;   (:use :cl :cl-store)
;   (:export #:make-my-data
;            #:my-data-int1
;            #:my-data-int2
;            #:my-data-string-list
;            #:save-to-file
;            #:load-from-file))

; (in-package :my-class)

; ;; Определение класса
; (defclass my-data ()
;   ((int1       :initarg :int1       :accessor my-data-int1)
;    (int2       :initarg :int2       :accessor my-data-int2)
;    (string-list :initarg :string-list :accessor my-data-string-list)))

; ;; Удобный конструктор
; (defun make-my-data (int1 int2 string-list)
;   (make-instance 'my-data :int1 int1 :int2 int2 :string-list string-list))

; ;; Сохранение в бинарный файл
; (defun save-to-file (obj filename)
;   (with-open-file (out filename
;                        :direction :output
;                        :element-type '(unsigned-byte 8)
;                        :if-exists :supersede)
;     (cl-store:store obj out))
;   (format t "Object saved to ~a~%" filename))

; ;; Загрузка из бинарного файла
; (defun load-from-file (filename)
;   (with-open-file (in filename
;                       :direction :input
;                       :element-type '(unsigned-byte 8))
;     (cl-store:restore in)))



; (defvar *obj* (make-my-data 42 100 '("hello" "world" "clisp")))

; (save-to-file *obj* "mydata.bin")

; (defvar *loaded* (load-from-file "mydata.bin"))

; (print (my-data-int1 *loaded*))        
; (print (my-data-string-list *loaded*)) 



(require :asdf)
(asdf:load-system :cl-json)

(defpackage :my-class
  (:use :cl :cl-json)
  (:export #:make-my-data
           #:my-data-int1
           #:my-data-int2
           #:my-data-string-list
           #:save-to-file
           #:load-from-file))

(in-package :my-class)

(defclass my-data ()
  ((int1       :initarg :int1       :accessor my-data-int1)
   (int2       :initarg :int2       :accessor my-data-int2)
   (string-list :initarg :string-list :accessor my-data-string-list)))

(defun make-my-data (int1 int2 string-list)
  (make-instance 'my-data :int1 int1 :int2 int2 :string-list string-list))

;; Сохраняем с ключами-символами
(defun object-to-alist (obj)
  `((int-1 . ,(my-data-int1 obj))
    (int-2 . ,(my-data-int2 obj))
    (string-list . ,(my-data-string-list obj))))

;; Загружаем, ищем ключи по имени (без учёта регистра)
(defun alist-to-object (alist)
  (flet ((find-value (name)
           (cdr (find name alist
                      :key (lambda (pair) (symbol-name (car pair)))
                      :test #'string-equal))))
    (make-my-data (find-value "INT-1")
                  (find-value "INT-2")
                  (find-value "STRING-LIST"))))

(defun save-to-file (obj filename)
  (with-open-file (out filename :direction :output :if-exists :supersede)
    (cl-json:encode-json (object-to-alist obj) out))
  (format t "Object saved to ~a~%" filename))

(defun load-from-file (filename)
  (with-open-file (in filename)
    (alist-to-object (cl-json:decode-json in))))

;; Пример
(defvar *obj* (make-my-data 42 100 '("hello" "world" "clisp")))
(save-to-file *obj* "mydata.json")
(defvar *loaded* (load-from-file "mydata.json"))
(format t "int1: ~a~%" (my-data-int1 *loaded*))
(format t "string-list: ~a~%" (my-data-string-list *loaded*))