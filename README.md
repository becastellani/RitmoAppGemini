# RitmoApp – Produtividade Remota

O **RitmoApp** é um aplicativo Flutter que atua como um assistente de produtividade voltado para trabalhadores remotos. Ele utiliza **reconhecimento de voz**, **armazenamento local** e **inteligência artificial** para fornecer dicas de foco, organização, pausas e equilíbrio com base nos desafios ou rotinas dos usuários.

## ✨ Funcionalidades

- 🎤 **Reconhecimento de voz**: transforme fala em texto para facilitar a inserção de tarefas ou desafios.
- 🤖 **Assistente de IA**: integração com o modelo **Gemini 2.0** da Google para gerar dicas personalizadas.
- 💬 **Histórico de mensagens**: persistência de dados com SQLite para manter o chat entre sessões.
- 📝 **Suporte a Markdown**: as respostas são renderizadas com formatação amigável.
- 🧹 **Limpeza do chat**: opção para limpar todo o histórico de conversa.

## 🚀 Tecnologias Utilizadas

- **Flutter**: Framework principal para desenvolvimento mobile.
- **HTTP**: Para chamadas à API do modelo Gemini.
- **Speech to Text**: Para reconhecimento de fala.
- **Sqflite**: Banco de dados local para armazenamento das mensagens.
- **Path**: Para manipulação de caminhos locais.
- **Flutter Markdown**: Para renderizar conteúdo markdown nas respostas da IA.

## 📦 Dependências (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.3.0
  speech_to_text: ^7.0.0
  flutter_markdown: ^0.7.7
  sqflite: ^2.4.2
  path: ^1.7.0

## 🧠 Como funciona?

1. O usuário descreve uma tarefa ou desafio relacionado ao trabalho remoto (via texto ou voz).
2. A mensagem é armazenada localmente no banco SQLite.
3. A IA analisa o conteúdo e retorna uma sugestão personalizada, com emojis e dicas práticas.
4. Todo o histórico de mensagens é apresentado em uma interface limpa e responsiva.

## 📱 Interface

A UI consiste em:

- **AppBar** com logo e menu de ações.
- **Lista de mensagens** com separação clara entre usuário e assistente.
- **Campo de entrada** com suporte a múltiplas linhas e botão de microfone.
- **Botão de envio** com feedback visual durante o carregamento.

## 🛠️ Execução

Para executar o projeto:

1. Clone o repositório:
   ```bash
   git clone [https://github.com/seu-usuario/ritmoapp.git](https://github.com/becastellani/RitmoAppGemini.git](https://github.com/becastellani/RitmoAppGemini.git)
   cd ritmoapp
   ```
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Rode o app:
   ```bash
   flutter run
   ```

## 🧪 Testado em

- Flutter SDK: `>=3.0.0`
- Android 10+
- iOS 13+

## 🔐 Observações de Segurança

- ⚠️ A chave da API Gemini está embutida diretamente no código (`main.dart`). Para produção, **utilize variáveis de ambiente ou um arquivo `.env`** com o pacote `flutter_dotenv` para proteger suas credenciais.

## 📸 Screenshot

>![image](https://github.com/user-attachments/assets/efe07d78-7ef9-432c-ab4f-a52e531e64ee)


## 📄 Licença

Este projeto está licenciado sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
