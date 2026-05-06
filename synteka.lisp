(require :asdf)
(asdf:load-system :cl-json)
(asdf:load-system :dexador)
(asdf:load-system :cl-ppcre)

(defpackage :synteka
  (:use :cl :cl-json )   ; :cl-json и :dexador нужны для HTTP
  (:export
   :get-offers
   :create-order
   :create-order2
   :extract-items-from-string
   :test-extract-items
   :*config*))

(in-package :synteka)

(defun get-offers (&key (count 10) (state "DELETED"))
  "Выполняет GET-запрос к /api/v1/offers, читает токен из *config*."
  (let* ((token (gethash :zakupay-token *config*))
         (url (format nil "https://restetris.cynteka.ru/api/v1/offers?count=~A&state=~A" count state))
         (headers `(("accept" . "application/json")
                    ("ZakupayToken" . ,token))))
    (unless token
      (error "Token :zakupay-token not found in config"))
    (multiple-value-bind (body status)
        (dex:get url :headers headers)
      (if (= status 200)
          (cl-json:decode-json-from-string body)
          (error "HTTP request failed with status ~A" status)))))


(defun create-order2 ()
  (let* ((token (gethash :zakupay-token *config*))
         (url "https://restetris.cynteka.ru/api/v1/orders?format=json&isoDate=true")
         (headers `(("accept" . "application/json")
                    ("ZakupayToken" . ,token)
                    ("Content-Type" . "application/json")))
         (payload `((name . "Тестовый заказ")
                    (project ((id . 12)))
                    (state . "DRAFT")
                    (finishDate . "2026-06-10")
                    (sourceAccount ((id . 34)))
                    (consignee ((id . 2)))
                    (region ((id . 23)))
                    (responsible ((id . 45)))
                    (delay . 30)
                    (externalId . 1744320000)
                    (orderItems (((goodName . "Тестовый товар")
                                  (count . 1)
                                  (unit ((id . 76)))
                                  (budgetItem ((id . 10)))
                                  (costItem ((id . 93)))
                                  (analogAllow . :false)
                                  (innerComment . "Тест")
                                  (goodPosition ((externalId . "000000004100008693")))))))))
    (multiple-value-bind (body status)
        (dex:post url :headers headers :content (cl-json:encode-json-to-string payload))
      (if (= status 200)
          (cl-json:decode-json-from-string body)
          (error "HTTP request failed with status ~A" status)))))   


(defun create-order-okland(items-lst))          
(defun list= (list1 list2)
  "Сравнивает два списка на равенство, включая вложенные списки."
  (if (and (listp list1) (listp list2))
      (and (= (length list1) (length list2))
           (every #'list= list1 list2))
      (equal list1 list2)))

(defun unit-to-code (unit-str)
  "Преобразует строку единицы измерения (например \"шт\" или \"кг\") в числовой код согласно таблице."
  (let ((normalized (string-trim "." unit-str))) ; убираем точку в конце
    (cond
      ((member normalized '("шт" "штук" "штуки") :test #'string-equal) 1)
      ((member normalized '("м" "метр" "метра") :test #'string-equal) 2)
      ((member normalized '("м.п" "п.м" "пог.м" "мп") :test #'string-equal) 3)
      ((member normalized '("л" "литр" "литра") :test #'string-equal) 4)
      ((member normalized '("кг" "килограмм" "килограмма") :test #'string-equal) 5)
      ((member normalized '("м2" "кв.м" "квадратный метр") :test #'string-equal) 6)
      ((member normalized '("м3" "куб.м" "кубический метр") :test #'string-equal) 7)
      (t (error "Неизвестная единица измерения: ~A" unit-str)))))

;; Реализация без CL-PPCRE (чистый Common Lisp)
(defun extract-items-no-ppcre (text)
())

;; Основная функция (используем реализацию без ppcre)
(defun extract-items-from-string (text)
  (extract-items-no-ppcre text))

(defun test-extract-items ()    ;;   sbcl --load hello.lisp      --eval '(hello:test-extract-items)'
  (let* ((initial-string "Прошу согласовать для производства работ по монтажу стилобата по объекту Рыбацкая:\n1) Доска 25х100 - 20 шт.\n2) Саморезы 3,5x51 - 1000 шт.\n3) Гвозди 100 мм. - 10 кг.\n\nКонт.тел. 8917-091-14-10 Дмитрий")
         (etalon-list (list
                       (list "Доска 25х100" 20 1)
                       (list "Саморезы 3,5x51" 1000 1)
                       (list "Гвозди 100 мм." 10 5)))
         (result (extract-items-from-string initial-string)))
    (assert (list= result etalon-list))
    (format t "Тест пройден!~%")
    result))


(defun create-order ()
  (let* ((token (gethash :zakupay-token *config*))
         (url "https://restetris.cynteka.ru/api/v1/orders?format=json&isoDate=true")
         (headers `(("accept" . "application/json")
                    ("ZakupayToken" . ,token)
                    ("Content-Type" . "application/json")))
         (payload (list (cons "name" "Тестовый заказ")
                        (cons "project" (list (cons "id" 6)))   ;;  (cons "project" (list (cons "id" 12)))   ПРОЕКТ  :: Ответственные кто имее  право создавать заявки
                        (cons "state" "DRAFT")
                        (cons "finishDate" "2026-06-10")
             
                        (cons "sourceAccount" (list (cons "id" 34)))
                        (cons "consignee" (list (cons "id" 2)))     ; ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "СПЕЦИАЛИЗИРОВАННЫЙ ЗАСТРОЙЩИК "РЭС-ТЕТРИС" #2           Грузополучатель
                        (cons "region" (list (cons "id" 30)))
                        (cons "responsible" (list (cons "id" 222)))   ; исполнитель
                        (cons "delay" 35)   ;; ООО "ЮЖНЫЙ КАБЕЛЬНЫЙ ЦЕНТР"   - 30;   
                        (cons "externalId" 1744320000)
                        (cons "orderItems"
                              (list (list (cons "goodName" "Тестовый товар")
                                          (cons "count" 1)
                                          (cons "unit" (list (cons "id" 6)))   ;; 1 - шт, 2 - м,  3 - м .п. 4 - литр, 5 =- кг, 6 квадратный метр,  7 - кубический метр, 
                                          ; (cons "budgetItem" (list (cons "id" 10)))
                                          ; (cons "costItem" (list (cons "id" 93)))
                                          (cons "analogAllow" nil)
                                          (cons "innerComment" "Тест")
                                          (cons "goodPosition" (list (cons "externalId" "000000004100008693"))))
                                    (list (cons "goodName" "Crude Oil")
                                          (cons "count" 1)
                                          (cons "unit" (list (cons "id" 1)))
                                          (cons "analogAllow" nil)
                                          (cons "innerComment" "")
                                          (cons "goodPosition" (list (cons "externalId" "000000004100008693")))))))))
    (multiple-value-bind (body status)
        (dex:post url :headers headers :content (cl-json:encode-json-to-string payload))
      (if (= status 200)
          (cl-json:decode-json-from-string body)
          (error "HTTP request failed with status ~A, body: ~A" status body)))))