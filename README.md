# Open Tibia Server - Avatar the last Airbender

<div align="center">
  <img src="https://www.tibiawiki.com.br/images/e/e4/Outfit_Citizen_Male.gif" alt="Citizen Male">
  <img src="https://www.tibiawiki.com.br/images/6/62/Outfit_Hunter_Male_Addon_1.gif" alt="Hunter male">
</div>

## 🔥 Revivendo a Nostalgia

Este projeto recria os famosos servidores **Korelin** e **Taelin** em uma versão moderna do Tibia. Nosso objetivo é trazer de volta a nostalgia e a experiência única destes servidores clássicos que marcaram época, agora com melhorias técnicas e visuais.

## 📋 Requisitos

- Sistema Operacional: Windows, Linux ou macOS
- Compilador C++ compatível com C++20
- CMake 3.16 ou superior
- MySQL/MariaDB
- Bibliotecas: vcpkg para gerenciar dependências

## 🛠️ Instalação

### Preparando o ambiente

1. Clone o repositório:
```bash
git clone git@github.com:matheusjimenez/ot-avatar.git
cd ot-avatar
```

2. Instale o vcpkg se ainda não tiver:
```bash
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
./bootstrap-vcpkg.sh  # No Linux/macOS
.\bootstrap-vcpkg.bat  # No Windows
```

3. Instale as dependências usando vcpkg:
```bash
vcpkg install
```

### Configurando o banco de dados

1. Crie um banco de dados MySQL:
```bash
mysql -u root -p
CREATE DATABASE tibia;
exit;
```

2. Importe o esquema e dados iniciais:
```bash
mysql -u root -p tibia < schema.sql
mysql -u root -p tibia < otserv.sql
```

### Compilando

1. Configure o projeto usando CMake:
```bash
mkdir build
cd build
cmake ..
```

2. Compile o projeto:
```bash
cmake --build . --config Release
```

## ▶️ Executando o servidor

1. Configure o arquivo `config.lua` de acordo com suas necessidades:
   - Defina o IP e portas desejadas
   - Configure o nome do servidor
   - Ajuste as configurações de gameplay

2. Execute o servidor:
```bash
# No Linux/macOS
./start.sh

# No Windows
canary.exe
```

3. O servidor estará disponível na porta definida (padrão: 7171 para login, 7172 para jogo)

## 🎮 Conectando ao servidor

1. Use um cliente Tibia compatível (versão definida em config.lua)
2. Configure o cliente para apontar para o IP e porta do seu servidor
3. Crie uma conta e comece a jogar!

## 🌟 Características

- Reviver a essencia dos classicos Korelin, Taelin e Avaot
- Sem item shop, somente premium acc (sou contra pay 2 win)
- Divines em drops de bosses
- Sistema de combate balanceado
- Sistema de quests nostálgicas
- Eventos PvP e PvE
- Sistema de forja e aprimoramento de itens

## 🤝 Contribuindo

Contribuições são bem-vindas! Se você deseja ajudar a melhorar este projeto:

1. Faça um fork do repositório
2. Crie uma branch para sua funcionalidade: `git checkout -b minha-funcionalidade`
3. Commit suas mudanças: `git commit -m 'Adiciona nova funcionalidade'`
4. Push para a branch: `git push origin minha-funcionalidade`
5. Abra um Pull Request

## 🙏 Agradecimentos

- À comunidade do Tibia
- Aos criadores originais dos servidores Korelin, Taelin e Avaot por inspirarem este projeto
- A todos os jogadores que mantêm viva a nostalgia deste clássico MMORPG 

## 🪄 Magias Disponíveis

### 💧 Magias de Água (Water)
- [x] Water Wave
- [x] Water Dragon 
- [x] Water Rain 
- [x] Water Cannon 
- [x] Water Blood

### 🌱 Magias de Terra (Earth)
- [x] Earth Crush
- [x] Earth Barrier (wip)
- [x] Earth Track (wip)

### 💨 Magias de Ar (Air)
- [x] Air Ball

### 🔥 Magias de Fogo (Fire)
- [x] Fire Wave
