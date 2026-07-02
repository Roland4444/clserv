
(require :asdf)
(asdf:load-system :uiop) 

(defpackage :ocr-app
  (:use :cl :uiop)
  (:export :recognize-from-bytes
           :recognize-from-file
           :main))
(in-package :ocr-app)

(defun read-file-bytes (pathname)
  (with-open-file (stream pathname :element-type '(unsigned-byte 8))
    (let ((length (file-length stream)))
      (let ((bytes (make-array length :element-type '(unsigned-byte 8))))
        (read-sequence bytes stream)
        bytes))))

(defun recognize-from-file (image-path &key (language "rus"))
  "Распознаёт текст из файла с помощью внешнего Tesseract."
  (uiop:with-temporary-file (:pathname out-temp :suffix "txt" :keep t)
    (let* ((base (namestring (pathname-name out-temp)))
           (result-file (format nil "~a.txt" base)))
      (uiop:run-program (list "tesseract" image-path base "-l" language) :output t)
      (uiop:read-file-string result-file))))

(defun recognize-from-bytes (image-bytes &key (language "rus"))
  "Принимает вектор байт, сохраняет во временный файл и распознаёт."
  (uiop:with-temporary-file (:pathname temp-image-path :suffix "jpg" :keep t)
    ;; Открываем поток для записи байтов
    (with-open-file (stream temp-image-path
                            :direction :output
                            :element-type '(unsigned-byte 8)
                            :if-exists :supersede)
      (write-sequence image-bytes stream))
    ;; Распознаём из созданного файла
    (recognize-from-file (namestring temp-image-path) :language language)))

(defun main (&optional (image-path "test.jpg"))
  (format t "~&Читаем файл: ~a~%" image-path)
  (let ((bytes (read-file-bytes image-path)))
    (format t "~&Файл прочитан, размер: ~d байт~%" (length bytes))
    (let ((text (recognize-from-bytes bytes :language "rus")))
      (format t "~&=== РАСПОЗНАННЫЙ ТЕКСТ ===~%~a~%" text))))