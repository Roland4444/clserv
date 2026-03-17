(require :asdf)
(asdf:load-system :dexador)
(asdf:load-system :cl-json)

(defun create-bitrix-task ()
  "Создаёт задачу в Bitrix24. Возвращает JSON-ответ."
  (let* ((url "https://b24-e8jgcd.bitrix24.ru/rest/1/aa6nqwskgkhq06qd/tasks.task.add")
         (json-body
           (cl-json:encode-json-to-string
            '(("fields" .
               (("TITLE" . "ЖОПА")
                ("DESCRIPTION" . "Отремонтировать хренов принтер")
                ("RESPONSIBLE_ID" . 1)
                ("CREATED_BY" . 1)
                ("ACCOMPLICES" . (14))
                ("AUDITORS" . (1))
                ("DEADLINE" . "2025-03-10T18:00:00+03:00")
                ("PRIORITY" . 2)
                ("GROUP_ID" . 10)))))))
    (format t "~&Sending JSON:~%~a~%" json-body)
    (dex:post url
              :headers '(("Content-Type" . "application/json"))
              :content json-body
              :verbose t)))

(create-bitrix-task)