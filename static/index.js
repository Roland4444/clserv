  (function() {

            let formData = {
                category: '',
                title: '',
                description: '',
                file: null,
                uuid: '',
                user_id: '',
                user_email: '',
                user_phone: '',
                priority: 'medium'
            };


			function fetchUUID(callback) {
    		var xhr = new XMLHttpRequest();
    		xhr.open('GET', '/tuid', true);
    		xhr.onreadystatechange = function() {
        		if (xhr.readyState === 4 && xhr.status === 200) {
            		var uuid = xhr.responseText.trim();
            		formData.uuid = uuid;  // сохраняем в formData
            		if (callback) callback(uuid);
        			}
    			};
    		xhr.send();
			}

			
			fetchUUID(function(uuid) {console.log('UUID получен:', uuid);});
            
            if (typeof THREE.CSS2DRenderer === 'undefined') {
                console.error('CSS2DRenderer не загрузился. Проверьте подключение скриптов.');
                document.body.innerHTML += '<div style="color:red;position:absolute;top:50px;">Ошибка: CSS2DRenderer не загружен</div>';
                return;
            }

            // --- Получение данных пользователя из Bitrix24 ---
            let currentUser = null;
            const userInfoDiv = document.getElementById('user-info');

            if (typeof BX24 !== 'undefined' && BX24) {
                BX24.init(function() {
                    BX24.installFinish();
                    BX24.callMethod('user.current', {}, function(result) {
                        if (result.error()) {
                            console.error('Ошибка API:', result.error());
                            userInfoDiv.textContent = 'Не удалось загрузить данные';
                        } else {
                            const user = result.data();
                            var info__ = 'data::'+ JSON.stringify(user, null, 2)
                            console.log(info__)
                            alert(info__)

                            var email =  user.EMAIL
                            var id__  =  user.ID
                            var phone =  user.PERSONAL_MOBILE
                            formData.user_email = email
                            formData.user_phone = phone

                            formData.user_id    = id__  
                            const userName = user.NAME || '';
                            const userLastName = user.LAST_NAME || '';
                            const fullName = (userName + ' ' + userLastName).trim() || 'Без имени';
                            userInfoDiv.textContent = `Привет, ${fullName}!`;
                            currentUser = user;
                        }
                    });
                });
            } else {
                console.warn('BX24 не загружена, работа в автономном режиме');
                userInfoDiv.textContent = 'Автономный режим';
            }

            // --- Three.js сцена и камера ---
            const scene = new THREE.Scene();
            const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
            camera.position.set(0, 0, 8);
            camera.lookAt(0, 0, 0);

            // --- Рендереры: WebGL и CSS2D ---
            const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.setClearColor(0x000000, 0); // прозрачный фон
            document.body.appendChild(renderer.domElement);

            const labelRenderer = new THREE.CSS2DRenderer();
            labelRenderer.setSize(window.innerWidth, window.innerHeight);
            labelRenderer.domElement.style.position = 'absolute';
            labelRenderer.domElement.style.top = '0px';
            labelRenderer.domElement.style.left = '0px';
            labelRenderer.domElement.style.pointerEvents = 'none';
            document.body.appendChild(labelRenderer.domElement);

            // --- Куб с текстурой ---
            const canvas = document.createElement('canvas');
            canvas.width = 1024;
            canvas.height = 1024;
            const ctx = canvas.getContext('2d');
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.font = 'bold 400px "Segoe UI", Tahoma, Geneva, Verdana, sans-serif';
            ctx.fillStyle = '#ffffff';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText('λ', canvas.width/2, canvas.height/2 - 120);
            ctx.font = 'bold 200px "Segoe UI", Tahoma, Geneva, Verdana, sans-serif';
            ctx.fillText('LISP', canvas.width/2, canvas.height/2 + 200);
            const texture = new THREE.CanvasTexture(canvas);
            const material = new THREE.MeshBasicMaterial({ map: texture, transparent: true, side: THREE.DoubleSide });
            const geometry = new THREE.BoxGeometry(2, 2, 2);
            const cube = new THREE.Mesh(geometry, material);
            scene.add(cube);

            // --- Состояние приложения ---
            let state = 0; // 0: выбор категории, 1: тема, 2: описание, 3: файл, 4: завершение, 5: подтверждение категории

            let selectedCategory = null; // временная выбранная категория для подтверждения

            // --- Массив категорий с подробными описаниями ---
            const categories = [
                { value: 'orgtech', label: '🖨️ Оргтехника', 
                  desc: '• подключение рабочего места\n• проблемы с печатью\n• замена картриджей\n• прочие проблемы' },
                { value: 'software', label: '💻 ПО',
                  desc: '• установка ПО, плагинов\n• настройка работы с сервисами (Госуслуги)\n• проблемы с эксплуатацией ПО\n• ошибки при работе, подключении к сервисам' },
                { value: 'computers', label: '🖥️ Компьютеры',
                  desc: '• не включается/выключается/перезагружается\n• ошибки\n• модернизация/замена\n• тестирование\n• подключение периферии (наушники, микрофоны, разветвители)' },
                { value: 'network', label: '🌐 Сетевые работы',
                  desc: '• замена патчкордов\n• тестирование и выявление проблем (тестером)\n• замена сетевого оборудования' },
                { value: 'meters', label: '📊 Счётчики',
                  desc: '• полная неработоспособность счетчиков\n• не работает телеметрия\n• проверка правильности показаний\n• поиск серийников\n• выгрузки показаний' },
                { value: 'providers', label: '📡 Провайдеры',
                  desc: '• новое подключение\n• неработоспособность существующего канала\n• замена юрлица в договоре' },
                { value: 'cameras', label: '📹 Камеры',
                  desc: '• добавление камер\n• просмотр записей\n• неработоспособность камер\n• заявки на очистку' },
                { value: 'mobile', label: '📱 Сотовая связь/покрытие',
                  desc: '• получение сим-карт\n• добавление личных данных\n• проверка покрытия на объекте\n• заявки на операторов для улучшения покрытия' }
            ];

            // --- Создание CSS2D-объекта для интерфейса ---
            let currentPanel = null;

            function createPanel() {
                if (currentPanel) scene.remove(currentPanel);

                const div = document.createElement('div');
                div.className = 'ui-panel';
                div.style.pointerEvents = 'auto';

                switch (state) {
                    case 0: // Выбор категории (плитки)
                        let tilesHtml = '<h2>Выберите категорию заявки</h2><div class="category-grid">';
                        categories.forEach(cat => {
                            tilesHtml += `<div class="category-tile" data-value="${cat.value}">${cat.label}</div>`;
                        });
                        tilesHtml += '</div>';
                        div.innerHTML = tilesHtml;
                        // Добавляем обработчики после вставки в DOM
                        setTimeout(() => {
                            const tiles = div.querySelectorAll('.category-tile');
                            tiles.forEach(tile => {
                                tile.addEventListener('click', (e) => {
                                    const value = tile.dataset.value;
                                    selectedCategory = categories.find(c => c.value === value);
                                    if (selectedCategory) {
                                        // Переходим к экрану подтверждения категории
                                        state = 5;
                                        createPanel();
                                    }
                                });
                            });
                        }, 0);
                        break;
                    case 5: // Экран подтверждения категории с описанием
                        if (!selectedCategory) {
                            state = 0;
                            createPanel();
                            return;
                        }
                        div.innerHTML = `
                            <h2>${selectedCategory.label}</h2>
                            <div class="category-desc">${selectedCategory.desc.replace(/\n/g, '<br>')}</div>
                            <div>
                                <button id="backBtn">Назад к списку</button>
                                <button id="selectBtn">Выбрать</button>
                            </div>
                        `;
                        setTimeout(() => {
                            document.getElementById('backBtn')?.addEventListener('click', () => {
                                state = 0;
                                createPanel();
                            });
                            document.getElementById('selectBtn')?.addEventListener('click', () => {
                                formData.category = selectedCategory.value;
                                state = 6;  // раньше было state = 1
                                createPanel();
                            });
                        }, 0);
                        break;
                    case 6: // Выбор срочности
                    // div.innerHTML = `
                    //     <h2>Укажите срочность</h2>
                    //     <div style="display: flex; flex-direction: column; gap: 10px; margin-bottom: 15px;">
                    //     <label style="display: flex; align-items: center; gap: 10px;">
                    //         <input type="radio" name="priority" value="very_high" ${formData.priority === 'very_high' ? 'checked' : ''}> Очень высокая
                    //     </label>
                    //     <label style="display: flex; align-items: center; gap: 10px;">
                    //         <input type="radio" name="priority" value="high" ${formData.priority === 'high' ? 'checked' : ''}> Высокая
                    //     </label>
                    //     <label style="display: flex; align-items: center; gap: 10px;">
                    //         <input type="radio" name="priority" value="medium" ${formData.priority === 'medium' ? 'checked' : ''}> Средняя
                    //     </label>
                    //     <label style="display: flex; align-items: center; gap: 10px;">
                    //         <input type="radio" name="priority" value="low" ${formData.priority === 'low' ? 'checked' : ''}> Низкая
                    //     </label>
                    //     <label style="display: flex; align-items: center; gap: 10px;">
                    //         <input type="radio" name="priority" value="very_low" ${formData.priority === 'very_low' ? 'checked' : ''}> Очень низкая
                    //     </label>
                    //     </div>
                    //     <div>
                    //         <button id="backBtn">Назад</button>
                    //         <button id="nextBtn">Далее</button>
                    //     </div>
                    //     `;
                      div.innerHTML = `
        <h2>Укажите срочность</h2>
        <select id="prioritySelect" style="width: 100%; padding: 10px; margin-bottom: 15px; background: #311b92; color: white; border: 1px solid #795548; border-radius: 8px;">
            <option value="very_high" ${formData.priority === 'very_high' ? 'selected' : ''}>Очень высокая</option>
            <option value="high" ${formData.priority === 'high' ? 'selected' : ''}>Высокая</option>
            <option value="medium" ${formData.priority === 'medium' ? 'selected' : ''}>Средняя</option>
            <option value="low" ${formData.priority === 'low' ? 'selected' : ''}>Низкая</option>
            <option value="very_low" ${formData.priority === 'very_low' ? 'selected' : ''}>Очень низкая</option>
        </select>
        <div>
            <button id="backBtn">Назад</button>
            <button id="nextBtn">Далее</button>
        </div>
    `;
               

                    break;    
                    case 1: // Ввод темы
                        div.innerHTML = `
                            <h2>Введите тему заявки</h2>
                            <input type="text" id="titleInput" placeholder="Тема" value="${formData.title}">
                            <div>
                                <button id="backBtn">Назад</button>
                                <button id="nextBtn")>Далее</button>
                            </div>
                        `;
                        break;
                    case 2: // Ввод описания
                        div.innerHTML = `
                            <h2>Опишите проблему подробно</h2>
                            <textarea id="descInput" rows="4" placeholder="Описание">${formData.description}</textarea>
                            <div>
                                <button id="backBtn">Назад</button>
                                <button id="nextBtn">Далее</button>
                            </div>
                        `;
                        break;
                    case 3: // Загрузка файла (опционально)
                        div.innerHTML = `
                            <h2>Загрузите файл (необязательно)888888888888888888888</h2>
                            <input type="file" id="fileInput" accept="image/*,video/*">
                            <div class="file-info" id="fileInfo">${formData.file ? formData.file.name : 'Файл не выбран'}</div>
                            <div>
                                <button id="backBtn">Назад</button>
                                <button id="nextBtn">Пропустить</button>
                                <button id="submitBtn">Отправить</button>
                            </div>
                        `;
                        break;
                    case 4: // Завершение
                        div.innerHTML = `
                            <h2>✅ Заявка создана!</h2>
                            <p>Спасибо, ваша заявка отправлена в IT-отдел.</p>
                            <button id="restartBtn">Новая заявка</button>
                        `;
                        break;
                }

                // Добавляем остальные обработчики (для состояний 1-4)
                setTimeout(() => {
                    if (state === 1) {
                        const input = document.getElementById('titleInput');
                        if (input) {
                            input.value = formData.title;
                            input.addEventListener('input', (e) => formData.title = e.target.value);
                        }
                        document.getElementById('backBtn')?.addEventListener('click', () => { state = 6; createPanel(); });   // раньше было state = 0
                        document.getElementById('nextBtn')?.addEventListener('click', () => {
                            if (formData.title.trim()) state = 2;
                            else alert('Введите тему');
                            createPanel();
                        });
                    } else if (state === 2) {
                        const textarea = document.getElementById('descInput');
                        if (textarea) {
                            textarea.value = formData.description;
                            textarea.addEventListener('input', (e) => formData.description = e.target.value);
                        }
                        document.getElementById('backBtn')?.addEventListener('click', () => { state = 1; createPanel(); });
                        document.getElementById('nextBtn')?.addEventListener('click', () => {
                            if (formData.description.trim()) state = 3;
                            else alert('Введите описание');
                            createPanel();
                        });
                    } else if (state === 3) {
                        const fileInput = document.getElementById('fileInput');
                        const fileInfo = document.getElementById('fileInfo');
                        if (fileInput) {
                            fileInput.addEventListener('change', (e) => {
                                formData.file = e.target.files[0] || null;
                                if (fileInfo) fileInfo.textContent = formData.file ? formData.file.name : 'Файл не выбран';
                            });
                        }
                        document.getElementById('backBtn')?.addEventListener('click', () => { state = 2; createPanel(); });
                        document.getElementById('nextBtn')?.addEventListener('click', () => { submitForm(); }); // пропуск файла
                        document.getElementById('submitBtn')?.addEventListener('click', () => { submitForm(); });
                    } else if (state === 4) {
                        document.getElementById('restartBtn')?.addEventListener('click', () => {
                            formData = { category: '', title: '', description: '', file: null };
                            selectedCategory = null;
                            state = 0;
                            createPanel();
                        });
                    }


                    else if (state === 6) {
                    //     const radios = div.querySelectorAll('input[name="priority"]');
                    //     radios.forEach(radio => {
                    //     radio.addEventListener('change', (e) => {
                    //             formData.priority = e.target.value;
                    //         });
                    //     });
                    // document.getElementById('backBtn')?.addEventListener('click', () => {
                    //     state = 5; // возврат к подтверждению категории
                    //     createPanel();
                    // });
                    // document.getElementById('nextBtn')?.addEventListener('click', () => {
                    //     if (!formData.priority) formData.priority = 'medium'; // значение по умолчанию, если ничего не выбрано
                    //     state = 1; // переход к вводу темы
                    //     createPanel();
                    // });
                        const select = div.querySelector('#prioritySelect');
                        if (select) {
                            select.value = formData.priority;
                            select.addEventListener('change', (e) => {
                            formData.priority = e.target.value;
                        });
                        }
                        document.getElementById('backBtn')?.addEventListener('click', () => {
                        state = 5; // возврат к подтверждению категории
                        createPanel();
                        });
                        document.getElementById('nextBtn')?.addEventListener('click', () => {
                        if (select)             formData.priority = select.value; // фиксируем выбор
                        state = 1; // переход к вводу темы
                        createPanel();
                        });


                }
                }, 0);

                // Создаём CSS2DObject
                const panelObj = new THREE.CSS2DObject(div);
                panelObj.position.set(0, 0, 1); // перед камерой
                scene.add(panelObj);
                currentPanel = panelObj;
            }

            // --- Отправка данных на сервер (заглушка) ---
function submitForm() {
    if (!formData.uuid) {
        alert('UUID ещё не получен, попробуйте через секунду');
        return;
    }

    // Сначала отправляем текстовые данные (без файла)
    const textData = new FormData();
    textData.append('uuid', formData.uuid);
    textData.append('category', formData.category);
    textData.append('title', formData.title);
    textData.append('description', formData.description);
    textData.append('user_id', formData.user_id);
    textData.append('user_email', formData.user_email);
    textData.append('user_phone', formData.user_phone);
    textData.append('priority', formData.priority);

    fetch('/create-task', {
        method: 'POST',
        body: textData
    })
    .then(response => response.json())
    .then(result => {
        if (result.status === 'ok') {
            // Если есть файл, загружаем его отдельно
            if (formData.file) {
                const fileData = new FormData();
                fileData.append('uuid', formData.uuid);
                fileData.append('file', formData.file);

                return fetch('/upload-file', {
                    method: 'POST',
                    body: fileData
                })
                .then(response => response.json())
                .then(fileResult => {
                    if (fileResult.status === 'ok') {
                        state = 4;
                        createPanel();
                    } else {
                        alert('Ошибка загрузки файла: ' + fileResult.message);
                    }
                });
            } else {
                // Файла нет – сразу переходим к завершению
                state = 4;
                createPanel();
            }
        } else {
            alert('Ошибка: ' + result.message);
        }
    })
    .catch(err => {
        alert('Ошибка сети: ' + err);
    });
}

            // --- Запуск ---
            createPanel();

            // --- Анимация ---
            let time = 0;
            function animate() {
                requestAnimationFrame(animate);
                time += 0.01;
                cube.material.color.setHSL(time % 1, 1, 0.7);
                cube.rotation.x += 0.005;
                cube.rotation.y += 0.01;

                renderer.render(scene, camera);
                labelRenderer.render(scene, camera);
            }
            animate();

            // --- Обработка ресайза ---
            window.addEventListener('resize', () => {
                camera.aspect = window.innerWidth / window.innerHeight;
                camera.updateProjectionMatrix();
                renderer.setSize(window.innerWidth, window.innerHeight);
                labelRenderer.setSize(window.innerWidth, window.innerHeight);
            });
        })();
