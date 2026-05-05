;;; -*- mode: lisp; coding: utf-8 -*-
;;; synteka.lisp – работа с API Закупки

(asdf:load-system :cl-json)
(asdf:load-system :dexador)
(asdf:load-system :cl-ppcre)

;; synteka.lisp – минимальная рабочая версия


(defpackage :synteka
  (:use :cl :cl-json)
  (:export :test-parse-item-line))

(in-package :synteka)

(defun list= (list1 list2)
  (if (and (listp list1) (listp list2))
      (and (= (length list1) (length list2)) (every #'list= list1 list2))
      (equal list1 list2)))

(defun unit-to-code (unit-str)
  (let ((normalized (string-trim "." unit-str)))
    (cond
      ((member normalized '("шт" "штук" "штуки") :test #'string-equal) 1)
      ((member normalized '("м" "метр" "метра") :test #'string-equal) 2)
      ((member normalized '("м.п" "п.м" "пог.м" "мп") :test #'string-equal) 3)
      ((member normalized '("л" "литр" "литра") :test #'string-equal) 4)
      ((member normalized '("кг" "килограмм" "килограмма") :test #'string-equal) 5)
      ((member normalized '("м2" "кв.м" "квадратный метр") :test #'string-equal) 6)
      ((member normalized '("м3" "куб.м" "кубический метр") :test #'string-equal) 7)
      (t (error "Неизвестная единица: ~A" unit-str)))))

; (defun extract-items-from-string (text)
;   (let ((items (list ())))
;     (with-input-from-string (stream text)
;       (loop for line = (read-line stream nil)
;             while line
;             when (and (> (length line) 0) (digit-char-p (char line 0)))
;               do (let* ((paren-pos (position #\) line)))
;                    (when paren-pos
;                      (let* ((name-start (1+ paren-pos))
;                             (dash-pos (search " - " line :start2 name-start)))
;                        (when dash-pos
;                          (let ((name (string-trim " " (subseq line name-start dash-pos)))
;                                (rest (subseq line (+ dash-pos 3)))
;                                (space-pos (position #\space rest :from-end t)))
;                            (when space-pos
;                              (let* ((quantity-str (subseq rest 0 space-pos))
;                                     (unit-str (subseq rest (1+ space-pos)))
;                                     (quantity (read-from-string (substitute #\. #\, quantity-str))))
;                                (push (list name quantity (unit-to-code unit-str)) items)))))))))
;     (nreverse items)))

; (defun test-extract-items ()
;   (let* ((initial-string "Прошу согласовать для производства работ по монтажу стилобата по объекту Рыбацкая:\n1) Доска 25х100 - 20 шт.\n2) Саморезы 3,5x51 - 1000 шт.\n3) Гвозди 100 мм. - 10 кг.\n\nКонт.тел. 8917-091-14-10 Дмитрий")
;          (etalon-list (list (list "Доска 25х100" 20 1)
;                             (list "Саморезы 3,5x51" 1000 1)
;                             (list "Гвозди 100 мм." 10 5)))
;          (result (extract-items-from-string initial-string)))
;     (assert (list= result etalon-list))
;     (format t "Тест пройден!~%")
;     result))
(defun parse-item-line (line)
  "Разбирает строку вида '1) Доска 25х100 - 20 шт.' в список (НАЗВАНИЕ КОЛИЧЕСТВО КОД_ЕДИНИЦЫ)."
  (let* ((paren-pos (position #\) line))
         (name-start (1+ paren-pos)))
    (unless paren-pos
      (error "Неверный формат: отсутствует ')'. Строка: ~S" line))
    (let ((dash-pos (search " - " line :start2 name-start)))
      (unless dash-pos
        (error "Неверный формат: отсутствует разделитель ' - '. Строка: ~S" line))
      (let ((name (string-trim " " (subseq line name-start dash-pos)))
            (rest (subseq line (+ dash-pos 3))))
        (let ((space-pos (position #\space rest :from-end t)))
          (unless space-pos
            (error "Неверный формат: нет пробела перед единицей измерения. Строка: ~S" line))
          (let* ((quantity-str (subseq rest 0 space-pos))
                 (unit-str (subseq rest (1+ space-pos)))
                 (quantity (read-from-string (substitute #\. #\, quantity-str)))
                 (code (unit-to-code unit-str)))
            (list name quantity code))))))
;;; Тест для проверки
(defun test-parse-item-line ()              ;;      
  (let ((line "1) Доска 25х100 - 20 шт.")
        (expected '("Доска 25х100" 20 1)))
    (assert (equal (parse-item-line line) expected)
            nil
            "Test failed: ~S returned ~S, expected ~S"
            line (parse-item-line line) expected)
    (format t "Test passed~%")))