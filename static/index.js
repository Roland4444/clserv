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
                formData.uuid = uuid;
                if (callback) callback(uuid);
            }
        };
        xhr.send();
    }

    fetchUUID(function(uuid) { console.log('UUID получен:', uuid); });

    // Определяем мобильное устройство или приложение Bitrix24
    const ua = navigator.userAgent.toLowerCase();
    const isMobile = /iphone|ipad|ipod|android|wv|bitrix24/i.test(ua);
    const isBitrixApp = typeof BX24 !== 'undefined';
    const useThree = !isMobile && !isBitrixApp; // Отключаем Three.js на мобильных и в приложении

    // Переменные для Three.js (только если useThree === true)
    let scene, camera, renderer, labelRenderer, cube, animate;
    let htmlContainer = null;

    if (!useThree) {
        // Создаём простой контейнер для обычного HTML
        htmlContainer = document.createElement('div');
        htmlContainer.id = 'html-container';
        htmlContainer.style.position = 'absolute';
        htmlContainer.style.top = '0';
        htmlContainer.style.left = '0';
        htmlContainer.style.width = '100%';
        htmlContainer.style.height = '100%';
        htmlContainer.style.display = 'flex';
        htmlContainer.style.justifyContent = 'center';
        htmlContainer.style.alignItems = 'center';
        htmlContainer.style.pointerEvents = 'none';
        document.body.appendChild(htmlContainer);
    } else {
        // Проверяем загрузку CSS2DRenderer
        if (typeof THREE.CSS2DRenderer === 'undefined') {
            console.error('CSS2DRenderer не загрузился. Проверьте подключение скриптов.');
            document.body.innerHTML += '<div style="color:red;position:absolute;top:50px;">Ошибка: CSS2DRenderer не загружен</div>';
            return;
        }

        // --- Three.js сцена и камера ---
        scene = new THREE.Scene();
        camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
        camera.position.set(0, 0, 8);
        camera.lookAt(0, 0, 0);

        renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
        renderer.setSize(window.innerWidth, window.innerHeight);
        renderer.setClearColor(0x000000, 0);
        document.body.appendChild(renderer.domElement);

        labelRenderer = new THREE.CSS2DRenderer();
        labelRenderer.setSize(window.innerWidth, window.innerHeight);
        labelRenderer.domElement.style.position = 'absolute';
        labelRenderer.domElement.style.top = '0px';
        labelRenderer.domElement.style.left = '0px';
        labelRenderer.domElement.style.pointerEvents = 'none';
        document.body.appendChild(labelRenderer.domElement);

        // --- Куб с текстурой (опционально) ---
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
        cube = new THREE.Mesh(geometry, material);
        scene.add(cube);
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
                    console.log('data::', JSON.stringify(user, null, 2));

                    var email = user.EMAIL;
                    var id__ = user.ID;
                    var phone = user.PERSONAL_MOBILE;
                    formData.user_email = email;
                    formData.user_phone = phone;
                    formData.user_id = id__;

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

    // --- Состояние приложения ---
    let state = 0;
    let selectedCategory = null;

    const categories = [
        { value: 'orgtech', label: '🖨️ Оргтехника', desc: '• подключение рабочего места\n• проблемы с печатью\n• замена картриджей\n• прочие проблемы' },
        { value: 'software', label: '💻 ПО', desc: '• установка ПО, плагинов\n• настройка работы с сервисами (Госуслуги)\n• проблемы с эксплуатацией ПО\n• ошибки при работе, подключении к сервисам' },
        { value: 'computers', label: '🖥️ Компьютеры', desc: '• не включается/выключается/перезагружается\n• ошибки\n• модернизация/замена\n• тестирование\n• подключение периферии (наушники, микрофоны, разветвители)' },
        { value: 'network', label: '🌐 Сетевые работы', desc: '• замена патчкордов\n• тестирование и выявление проблем (тестером)\n• замена сетевого оборудования' },
        { value: 'meters', label: '📊 Счётчики', desc: '• полная неработоспособность счетчиков\n• не работает телеметрия\n• проверка правильности показаний\n• поиск серийников\n• выгрузки показаний' },
        { value: 'providers', label: '📡 Провайдеры', desc: '• новое подключение\n• неработоспособность существующего канала\n• замена юрлица в договоре' },
        { value: 'cameras', label: '📹 Камеры', desc: '• добавление камер\n• просмотр записей\n• неработоспособность камер\n• заявки на очистку' },
        { value: 'mobile', label: '📱 Сотовая связь/покрытие', desc: '• получение сим-карт\n• добавление личных данных\n• проверка покрытия на объекте\n• заявки на операторов для улучшения покрытия' }
    ];

    let currentPanel = null; // для Three.js или ссылка на HTML-элемент

    function createPanel() {
        // Удаляем предыдущую панель
        if (useThree) {
            if (currentPanel) scene.remove(currentPanel);
        } else {
            if (htmlContainer) htmlContainer.innerHTML = '';
        }

        const div = document.createElement('div');
        div.className = 'ui-panel';
        div.style.pointerEvents = 'auto';

        // Генерация HTML в зависимости от состояния
        switch (state) {
            case 0:
                let tilesHtml = '<h2>Выберите категорию заявки</h2><div class="category-grid">';
                categories.forEach(cat => {
                    tilesHtml += `<div class="category-tile" data-value="${cat.value}">${cat.label}</div>`;
                });
                tilesHtml += '</div>';
                div.innerHTML = tilesHtml;
                break;
            case 5:
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
                break;
            case 6:
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
            case 1:
                div.innerHTML = `
                    <h2>Введите тему заявки</h2>
                    <input type="text" id="titleInput" placeholder="Тема" value="${formData.title}">
                    <div>
                        <button id="backBtn">Назад</button>
                        <button id="nextBtn">Далее</button>
                    </div>
                `;
                break;
            case 2:
                div.innerHTML = `
                    <h2>Опишите проблему подробно</h2>
                    <textarea id="descInput" rows="4" placeholder="Описание">${formData.description}</textarea>
                    <div>
                        <button id="backBtn">Назад</button>
                        <button id="nextBtn">Далее</button>
                    </div>
                `;
                break;
            case 3:
                div.innerHTML = `
                    <h2>Загрузите файл (необязательно)</h2>
                    <input type="file" id="fileInput" accept="image/*,video/*">
                    <div class="file-info" id="fileInfo">${formData.file ? formData.file.name : 'Файл не выбран'}</div>
                    <div>
                        <button id="backBtn">Назад</button>
                        <button id="nextBtn">Пропустить</button>
                        <button id="submitBtn">Отправить</button>
                    </div>
                `;
                break;
            case 4:
                div.innerHTML = `
                    <h2>✅ Заявка создана!</h2>
                    <p>Спасибо, ваша заявка отправлена в IT-отдел.</p>
                    <button id="restartBtn">Новая заявка</button>
                `;
                break;
        }

        // --- Обработчики событий (делегирование на всей панели) ---
        div.addEventListener('click', (e) => {
            const target = e.target;

            if (target.id === 'backBtn') {
                if (state === 1) state = 6;
                else if (state === 2) state = 1;
                else if (state === 3) state = 2;
                else if (state === 5) state = 0;
                else if (state === 6) state = 5;
                createPanel();
                return;
            }

            if (target.id === 'nextBtn') {
                if (state === 1) {
                    if (formData.title.trim()) state = 2;
                    else { alert('Введите тему'); return; }
                } else if (state === 2) {
                    if (formData.description.trim()) state = 3;
                    else { alert('Введите описание'); return; }
                } else if (state === 3) {
                    submitForm(); // пропуск файла
                    return;
                } else if (state === 6) {
                    const select = div.querySelector('#prioritySelect');
                    if (select) formData.priority = select.value;
                    state = 1;
                }
                createPanel();
                return;
            }

            if (target.id === 'selectBtn') {
                formData.category = selectedCategory.value;
                state = 6;
                createPanel();
                return;
            }

            if (target.id === 'submitBtn') {
                submitForm();
                return;
            }

            if (target.id === 'restartBtn') {
                formData = { category: '', title: '', description: '', file: null, uuid: formData.uuid, user_id: formData.user_id, user_email: formData.user_email, user_phone: formData.user_phone, priority: 'medium' };
                selectedCategory = null;
                state = 0;
                createPanel();
                return;
            }

            // Обработка плиток категорий
            if (target.classList.contains('category-tile')) {
                const value = target.dataset.value;
                selectedCategory = categories.find(c => c.value === value);
                if (selectedCategory) {
                    state = 5;
                    createPanel();
                }
            }
        });

        // Отдельные обработчики для input и select (можно добавлять сразу)
        if (state === 1) {
            const input = div.querySelector('#titleInput');
            if (input) {
                input.value = formData.title;
                input.addEventListener('input', (e) => formData.title = e.target.value);
            }
        }
        if (state === 2) {
            const textarea = div.querySelector('#descInput');
            if (textarea) {
                textarea.value = formData.description;
                textarea.addEventListener('input', (e) => formData.description = e.target.value);
            }
        }
        if (state === 3) {
            const fileInput = div.querySelector('#fileInput');
            const fileInfo = div.querySelector('#fileInfo');
            if (fileInput) {
                fileInput.addEventListener('change', (e) => {
                    formData.file = e.target.files[0] || null;
                    if (fileInfo) fileInfo.textContent = formData.file ? formData.file.name : 'Файл не выбран';
                });
            }
        }
        if (state === 6) {
            const select = div.querySelector('#prioritySelect');
            if (select) {
                select.value = formData.priority;
                select.addEventListener('change', (e) => formData.priority = e.target.value);
            }
        }

        // Вставляем панель в сцену или контейнер
        if (useThree) {
            const panelObj = new THREE.CSS2DObject(div);
            panelObj.position.set(0, 0, 1);
            scene.add(panelObj);
            currentPanel = panelObj;
        } else {
            if (htmlContainer) {
                htmlContainer.innerHTML = '';
                htmlContainer.appendChild(div);
                currentPanel = div;
            }
        }
    }

    function submitForm() {
        if (!formData.uuid) {
            alert('UUID ещё не получен, попробуйте через секунду');
            return;
        }

        const textData = new FormData();
        textData.append('uuid', formData.uuid);
        textData.append('category', formData.category);
        textData.append('title', formData.title);
        textData.append('description', formData.description);
        textData.append('user_id', formData.user_id);
        textData.append('user_email', formData.user_email);
        textData.append('user_phone', formData.user_phone);
        textData.append('priority', formData.priority);

        fetch('/create-task', { method: 'POST', body: textData })
            .then(response => response.json())
            .then(result => {
                if (result.status === 'ok') {
                    if (formData.file) {
                        const fileData = new FormData();
                        fileData.append('uuid', formData.uuid);
                        fileData.append('file', formData.file);
                        return fetch('/upload-file', { method: 'POST', body: fileData })
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
                        state = 4;
                        createPanel();
                    }
                } else {
                    alert('Ошибка: ' + result.message);
                }
            })
            .catch(err => alert('Ошибка сети: ' + err));
    }

    createPanel();

    if (useThree) {
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

        window.addEventListener('resize', () => {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
            labelRenderer.setSize(window.innerWidth, window.innerHeight);
        });
    }

})();