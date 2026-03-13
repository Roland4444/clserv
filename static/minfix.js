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

    // ---------- ОПРЕДЕЛЕНИЕ СРЕДЫ ДЛЯ ФИКСА ----------
    const ua = navigator.userAgent.toLowerCase();
    const isAndroidWebView = /android.*wv|android.*; wv/.test(ua) || typeof BX24 !== 'undefined';

    // ---------- ФИКС ДЛЯ SELECT (работает только на Android) ----------
    function fixAndroidSelects() {
        if (!isAndroidWebView) return;
        console.log('Android WebView: применяем фикс select');

        function replaceSelect(select) {
            if (select.dataset.replaced) return;

            const id = select.id || '';
            const name = select.name || '';
            const options = Array.from(select.options).map(opt => ({
                value: opt.value,
                text: opt.text,
                selected: opt.selected
            }));

            const wrapper = document.createElement('div');
            wrapper.className = 'custom-select-wrapper';
            wrapper.style.position = 'relative';
            wrapper.style.display = 'inline-block';
            wrapper.style.width = '100%';

            const button = document.createElement('div');
            button.className = 'custom-select-button';
            button.setAttribute('data-id', id);
            button.setAttribute('data-name', name);
            button.style.cssText = `
                width: 100%;
                padding: 10px;
                background: #311b92;
                color: white;
                border: 1px solid #795548;
                border-radius: 8px;
                cursor: pointer;
                user-select: none;
                box-sizing: border-box;
            `;
            button.textContent = options.find(opt => opt.selected)?.text || 'Выберите...';

            const dropdown = document.createElement('div');
            dropdown.className = 'custom-select-dropdown';
            dropdown.style.cssText = `
                display: none;
                position: absolute;
                top: 100%;
                left: 0;
                right: 0;
                z-index: 1000;
                background: #311b92;
                border: 1px solid #795548;
                border-radius: 8px;
                margin-top: 2px;
                max-height: 200px;
                overflow-y: auto;
            `;

            options.forEach((opt, index) => {
                const item = document.createElement('div');
                item.className = 'custom-select-item';
                item.dataset.value = opt.value;
                item.dataset.index = index;
                item.textContent = opt.text;
                item.style.cssText = `
                    padding: 10px;
                    cursor: pointer;
                    color: white;
                    border-bottom: 1px solid #795548;
                `;
                if (opt.selected) {
                    item.style.backgroundColor = '#b71c1c';
                }
                item.addEventListener('mouseenter', () => {
                    item.style.backgroundColor = '#4a148c';
                });
                item.addEventListener('mouseleave', () => {
                    if (opt.selected) {
                        item.style.backgroundColor = '#b71c1c';
                    } else {
                        item.style.backgroundColor = '';
                    }
                });
                dropdown.appendChild(item);
            });

            button.addEventListener('click', (e) => {
                e.stopPropagation();
                const isVisible = dropdown.style.display === 'block';
                document.querySelectorAll('.custom-select-dropdown').forEach(d => d.style.display = 'none');
                dropdown.style.display = isVisible ? 'none' : 'block';
            });

            dropdown.addEventListener('click', (e) => {
                const target = e.target.closest('.custom-select-item');
                if (!target) return;

                const value = target.dataset.value;
                const text = target.textContent;

                button.textContent = text;
                dropdown.style.display = 'none';

                let hiddenInput = wrapper.querySelector('input[type="hidden"]');
                if (!hiddenInput) {
                    hiddenInput = document.createElement('input');
                    hiddenInput.type = 'hidden';
                    hiddenInput.name = name;
                    wrapper.appendChild(hiddenInput);
                }
                hiddenInput.value = value;

                dropdown.querySelectorAll('.custom-select-item').forEach((item, idx) => {
                    if (item.dataset.value === value) {
                        item.style.backgroundColor = '#b71c1c';
                    } else {
                        item.style.backgroundColor = '';
                    }
                });

                const changeEvent = new Event('change', { bubbles: true });
                hiddenInput.dispatchEvent(changeEvent);

                // Синхронизация с formData
                if (name === 'priority' || id === 'prioritySelect') {
                    formData.priority = value;
                }
            });

            document.addEventListener('click', (e) => {
                if (!wrapper.contains(e.target)) {
                    dropdown.style.display = 'none';
                }
            });

            wrapper.appendChild(button);
            wrapper.appendChild(dropdown);
            select.parentNode.replaceChild(wrapper, select);
            wrapper.dataset.replaced = 'true';
        }

        function init() {
            document.querySelectorAll('select').forEach(replaceSelect);
        }

        const observer = new MutationObserver((mutations) => {
            mutations.forEach((mutation) => {
                mutation.addedNodes.forEach((node) => {
                    if (node.nodeType === 1) {
                        if (node.tagName === 'SELECT') {
                            replaceSelect(node);
                        } else {
                            node.querySelectorAll && node.querySelectorAll('select').forEach(replaceSelect);
                        }
                    }
                });
            });
        });
        observer.observe(document.body, { childList: true, subtree: true });

        init();
    }

    // Вызываем фикс после загрузки DOM
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', fixAndroidSelects);
    } else {
        fixAndroidSelects();
    }

    // ---------- ДАННЫЕ ПОЛЬЗОВАТЕЛЯ ----------
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
                    formData.user_email = user.EMAIL;
                    formData.user_phone = user.PERSONAL_MOBILE;
                    formData.user_id = user.ID;
                    const fullName = (user.NAME + ' ' + user.LAST_NAME).trim() || 'Без имени';
                    userInfoDiv.textContent = `Привет, ${fullName}!`;
                    currentUser = user;
                }
            });
        });
    } else {
        console.warn('BX24 не загружена, автономный режим');
        userInfoDiv.textContent = 'Автономный режим';
    }

    // ---------- КОНТЕЙНЕР ДЛЯ ИНТЕРФЕЙСА ----------
    let htmlContainer = document.createElement('div');
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

    // ---------- СОСТОЯНИЕ ПРИЛОЖЕНИЯ ----------
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

    let currentPanel = null;

    function createPanel() {
        if (htmlContainer) htmlContainer.innerHTML = '';

        const div = document.createElement('div');
        div.className = 'ui-panel';
        div.style.pointerEvents = 'auto';

        // Генерация HTML в зависимости от state
        switch (state) {
            case 0:
                let tilesHtml = '<h2>Выберите категорию заявки</h2><div class="category-grid">';
                categories.forEach(cat => {
                    tilesHtml += `<div class="category-tile" data-value="${cat.value}">${cat.label}</div>`;
                });
                tilesHtml += '</div>';
                div.innerHTML = tilesHtml;
                div.querySelectorAll('.category-tile').forEach(tile => {
                    tile.addEventListener('click', (e) => {
                        const value = tile.dataset.value;
                        selectedCategory = categories.find(c => c.value === value);
                        if (selectedCategory) {
                            state = 5;
                            createPanel();
                        }
                    });
                });
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
                div.querySelector('#backBtn')?.addEventListener('click', () => {
                    state = 0;
                    createPanel();
                });
                div.querySelector('#selectBtn')?.addEventListener('click', () => {
                    formData.category = selectedCategory.value;
                    state = 6;
                    createPanel();
                });
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
                // Обработчики (фикс select сам обновит formData.priority)
                div.querySelector('#backBtn')?.addEventListener('click', () => {
                    state = 5;
                    createPanel();
                });
                div.querySelector('#nextBtn')?.addEventListener('click', () => {
                    // Можно дополнительно считать значение из скрытого поля, но фикс уже синхронизировал
                    state = 1;
                    createPanel();
                });
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
                div.querySelector('#titleInput')?.addEventListener('input', (e) => {
                    formData.title = e.target.value;
                });
                div.querySelector('#backBtn')?.addEventListener('click', () => {
                    state = 6;
                    createPanel();
                });
                div.querySelector('#nextBtn')?.addEventListener('click', () => {
                    if (formData.title.trim()) {
                        state = 2;
                        createPanel();
                    } else {
                        alert('Введите тему');
                    }
                });
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
                div.querySelector('#descInput')?.addEventListener('input', (e) => {
                    formData.description = e.target.value;
                });
                div.querySelector('#backBtn')?.addEventListener('click', () => {
                    state = 1;
                    createPanel();
                });
                div.querySelector('#nextBtn')?.addEventListener('click', () => {
                    if (formData.description.trim()) {
                        state = 3;
                        createPanel();
                    } else {
                        alert('Введите описание');
                    }
                });
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
                div.querySelector('#fileInput')?.addEventListener('change', (e) => {
                    formData.file = e.target.files[0] || null;
                    const fileInfo = div.querySelector('#fileInfo');
                    if (fileInfo) fileInfo.textContent = formData.file ? formData.file.name : 'Файл не выбран';
                });
                div.querySelector('#backBtn')?.addEventListener('click', () => {
                    state = 2;
                    createPanel();
                });
                div.querySelector('#nextBtn')?.addEventListener('click', () => {
                    submitForm(); // пропуск файла
                });
                div.querySelector('#submitBtn')?.addEventListener('click', () => {
                    submitForm();
                });
                break;
            case 4:
                div.innerHTML = `
                    <h2>✅ Заявка создана!</h2>
                    <p>Спасибо, ваша заявка отправлена в IT-отдел.</p>
                    <button id="restartBtn">Новая заявка</button>
                `;
                div.querySelector('#restartBtn')?.addEventListener('click', () => {
                    formData = {
                        category: '', title: '', description: '', file: null,
                        uuid: formData.uuid, user_id: formData.user_id,
                        user_email: formData.user_email, user_phone: formData.user_phone,
                        priority: 'medium'
                    };
                    selectedCategory = null;
                    state = 0;
                    createPanel();
                });
                break;
        }

        htmlContainer.appendChild(div);
        currentPanel = div;
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
})();