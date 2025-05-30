# 🎮 VABGames

## 📱 Sobre o Projeto
VABGames é uma aplicação iOS desenvolvida em Swift utilizando SwiftUI, focada em jogos e publicadores. A aplicação oferece uma experiência moderna e interativa para utilizadores explorarem jogos, com funcionalidades como seleção aleatória de jogos, lista de publicadores e sistema de lista negra. O projeto demonstra competências em desenvolvimento iOS moderno, incluindo gestão de estado, persistência de dados, localização e testes unitários.

## 🛠️ Tecnologias Utilizadas
- Swift 5.0+
- SwiftUI
- Core Data
- Framework XCTest
- Arquitetura MVVM
- Localização (i18n)
- Gestos e Animações
- Navegação por Tabs
- NavigationView

## 📁 Estrutura do Projeto
```
VABGames/
├── Views/
│   ├── MainTabView.swift         # Navegação principal da app
│   ├── PublishersListView.swift  # Lista de publicadores
│   ├── PublisherDetailView.swift # Detalhes do publicador
│   ├── GameDetailView.swift      # Detalhes do jogo
│   ├── ShakeForGameView.swift    # Seleção aleatória de jogos
│   ├── SettingsView.swift        # Definições da app
│   ├── BlacklistView.swift       # Gestão da lista negra
│   ├── StudioOfTheDayView.swift  # Destaque do dia
│   └── CompactGameView.swift     # Visualização compacta de jogos
├── ViewModels/
│   ├── PublishersViewModel.swift
│   └── PublisherDetailViewModel.swift
├── Models/          # Modelos de dados
├── Services/        # Serviços e APIs
├── Extensions/      # Extensões Swift
├── Strings/         # Localização
└── VABGames.xcdatamodeld/  # Modelo de dados Core Data
```

## 🚀 Funcionalidades Principais
- **Navegação por Tabs**: Interface moderna com três separadores principais
  - Início: Lista de publicadores
  - Aleatório: Seleção aleatória de jogos
  - Definições: Configurações da aplicação

- **Sistema de Publicadores**
  - Lista completa de publicadores
  - Visualização detalhada de cada publicador
  - Jogos associados a cada publicador

- **Recursos Interativos**
  - Agitar para seleção aleatória de jogos
  - Estúdio do dia em destaque
  - Sistema de lista negra para filtragem de conteúdo

- **Definições Avançadas**
  - Suporte a múltiplos idiomas
  - Personalização de preferências
  - Gestão da lista negra

## 🎯 Competências Demonstradas
- Desenvolvimento iOS moderno com SwiftUI
- Implementação de MVVM para separação de responsabilidades
- Gestão de estado com @StateObject e @State
- Navegação complexa com TabView e NavigationView
- Persistência de dados com Core Data
- Internacionalização (i18n) com sistema de localização
- Implementação de gestos e interações
- Testes automatizados
- Boas práticas de desenvolvimento e organização de código

## 💻 Requisitos
- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+

## 🔧 Instalação
1. Clone o repositório
```bash
git clone https://github.com/seu-usuario/VABGames.git
```
2. Abra o projeto no Xcode
3. Execute o projeto (⌘R)

## 🧪 Testes
O projeto inclui testes unitários e de UI. Para executar os testes:
1. Abra o projeto no Xcode
2. Prima ⌘U para executar todos os testes

## 📱 Capturas de Ecrã
[Adicione capturas de ecrã da sua aplicação aqui]

## 🔄 Fluxo de Desenvolvimento
1. Clone o repositório
2. Crie uma branch para a sua funcionalidade (`git checkout -b feature/FuncionalidadeIncrivel`)
3. Faça commit das suas alterações (`git commit -m 'Adiciona uma Funcionalidade Incrível'`)
4. Faça push para a branch (`git push origin feature/FuncionalidadeIncrivel`)
5. Abra um Pull Request



## 👨‍💻 Autor
Vinicius Jardim - vpbjardim@gmail.com

---
⭐️ Desenvolvido com ❤️ para demonstrar competências em desenvolvimento iOS 