  (function() {

                var session_uuid = "";
                function load_uuid(){
                       // alert('test ajax')
                        function getXmlHttp()
                        {
                            var xmlhttp;
                            try {
                            xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
                            } catch (e) {
                            try {
                                xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
                            } catch (E) {
                                xmlhttp = false;
                            }
                            }
                            if (!xmlhttp && typeof XMLHttpRequest!='undefined')  xmlhttp = new XMLHttpRequest();
                           return xmlhttp;
                        }
                            var xhr = getXmlHttp()
                           // var params= document.getElementById("params").value ;
                            var request = "/tuid";///?params="//+params;
                            xhr.open("GET", request, true);
                            xhr.onreadystatechange=function(){
                            //    alert(xhr.responseText);
                                if (xhr.readyState != 4) return
                                clearTimeout(xhrTimeout)
                                if (xhr.status == 200) {
                                  //  var json = JSON.parse(xhr.responseText);
                             //       alert(xhr.responseText);
                                    session_uuid =  xhr.responseText;
                                } else {}
                            }
                           xhr.send("a=5&b=4");// xhr.send("a=5&b=4");
                            var xhrTimeout = setTimeout( function(){ xhr.abort(); handleError("Timeout") }, 10000);
                            function handleError(message) {
                                alert("Ошибка: "+message)
                            }
                } 
            load_uuid();

            alert('ession uuid='+session_uuid )
            // Проверка загрузки CSS2DRenderer
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
                            var info__ = 'data::'+data
                            console.log(info__)
                            alert(info__)
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
            let formData = {
                category: '',
                title: '',
                description: '',
                file: null
            };
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
                                state = 1;
                                createPanel();
                            });
                        }, 0);
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
                        alert('session uuid='+session_uuid )

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
                        document.getElementById('backBtn')?.addEventListener('click', () => { state = 0; createPanel(); });
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
                }, 0);

                // Создаём CSS2DObject
                const panelObj = new THREE.CSS2DObject(div);
                panelObj.position.set(0, 0, 1); // перед камерой
                scene.add(panelObj);
                currentPanel = panelObj;
            }

            // --- Отправка данных на сервер (заглушка) ---
            function submitForm() {
                alert('Запрос одобрен')
                console.log('Отправка данных:', formData);
                // Здесь реальный fetch на /create-task
                state = 4;
                createPanel();
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