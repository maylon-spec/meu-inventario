# Meu Inventário — versão inicial (MVP)

Aplicativo Flutter multiplataforma para inventário residencial.

## O que já está preparado
- Cadastro de bens com nome, cômodo, categoria, código de barras, quantidade, valor unitário e observações.
- Totalização do patrimônio cadastrado.
- Banco local SQLite (os dados permanecem no aparelho).
- Campo de leitura compatível com leitores Bluetooth que funcionam como teclado (HID).
- Bip de confirmação após receber uma leitura.
- Estrutura inicial de serviço Firebase/Firestore para futura sincronização.

## Requisitos
- Flutter SDK estável
- Android Studio (Android) e/ou Xcode em macOS (iOS)

## Executar
1. Extraia o projeto.
2. No terminal, entre na pasta `meu_inventario`.
3. Execute:
   ```bash
   flutter pub get
   flutter run
   ```

## Testar o leitor Bluetooth
1. Emparelhe o leitor nas configurações Bluetooth do celular.
2. Configure o leitor para modo Bluetooth HID / Keyboard.
3. Abra o app e deixe o campo "Leia um código de barras aqui" em foco.
4. Faça uma leitura. O leitor deve digitar o código e enviar Enter/CR ao final.
5. O app toca o bip e procura o código no inventário. Se não existir, abre o cadastro com o código preenchido.

**Importante:** o leitor deve estar configurado para enviar Enter (sufixo CR/Enter) depois de cada leitura. Alguns modelos exigem configuração pelo manual ou leitura de código de configuração.

## Firebase e sincronização
A nuvem ainda não é ativada por padrão, para que o app rode sem credenciais. Para habilitar:
1. Crie um projeto no Firebase.
2. Instale a FlutterFire CLI e execute `flutterfire configure`.
3. Adicione `firebase_options.dart` em `lib/`.
4. Em `main.dart`, importe `firebase_options.dart`, descomente `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` e defina `cloudConfigured = true`.
5. Implemente autenticação (Firebase Auth) e regras Firestore por usuário antes de armazenar dados pessoais.

O serviço `SyncService` contém o ponto inicial para envio dos itens. A próxima etapa é implementar fila offline, resolução de conflitos, autenticação e sincronização bidirecional.

## Observações sobre iOS
Leitores Bluetooth HID emparelhados pelo sistema costumam enviar dados como teclado. O comportamento pode variar conforme o modelo do leitor e a versão do iOS. Teste o modelo físico antes de comprar em quantidade.

## Próximas etapas recomendadas
1. Autenticação e sincronização bidirecional Firebase.
2. Edição de itens, fotos e histórico de alterações.
3. Cadastro de etiquetas QR próprias para itens sem código de barras.
4. Relatórios por cômodo/categoria e exportação PDF/CSV.
5. Backup, restauração e controle de usuários/família.
