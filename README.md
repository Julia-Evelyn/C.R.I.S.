🎲 C.R.I.S. - Ficha de Agente (Ordem Paranormal RPG)
Um aplicativo mobile feito em Flutter para gerenciar fichas de personagens do RPG Ordem Paranormal. O objetivo do projeto é automatizar os cálculos e regras do sistema, oferecendo uma interface imersiva, responsiva e inteligente para os jogadores durante as sessões.

✨ Funcionalidades
Arquivo Confidencial: Uma tela exclusiva e responsiva que simula um arquivo oficial da Ordem para documentar o background do agente (Idade, Nacionalidade, Histórico, Aparência e Objetivos).

Gestos Intuitivos (Swipe): Na tela inicial, deslize o card do seu agente para revelar ações rápidas, como duplicar a ficha para testes ou acessar o Dossiê instantaneamente.

Poderes Paranormais Inteligentes: O sistema calcula pré-requisitos, bloqueia escolhas inválidas e aplica efeitos passivos automaticamente na ficha. Poderes como Arma de Sangue geram itens dinâmicos no inventário, e Sangue Fervente altera atributos em tempo real quando o agente está machucado.

Inventário e Arsenal Amaldiçoado: Catálogo embutido com busca e filtros para Armas, Munições, Proteções e Itens Amaldiçoados (categorizados pelas tags visuais de Sangue, Morte, Energia e Conhecimento).

Criação Customizada: Crie seus próprios poderes paranormais, itens e armas diretamente pelo app, com integração total à mecânica de Afinidade.

Interface Temática: O design e as animações do app (cores, bordas e efeitos visuais) mudam automaticamente de acordo com o Elemento de Afinidade do personagem.

Automação de Regras: Cálculo automático de espaços, limites por Patente, limite de PE por turno, defesa passiva e aplicação de Modificações nas rolagens de ataque.

Rolador de Dados e Status: Clique direto nos atributos ou armas para rolar dados na tela. Barras de PV, PE e Sanidade são totalmente interativas por toque e deslize.

Salvamento Local: Fichas persistidas de forma segura no dispositivo do usuário.

🛠️ Tecnologias
Flutter / Dart

Pacotes Utilizados: * shared_preferences (salvamento de dados locais)

image_picker e image_cropper (captura e recorte de fotos de perfil)

flutter_slidable (animações e gestos de deslize na lista de agentes)

Arquitetura Modular: Separação clara entre Lógica de Dados (Modelos), Interface (UI) e Catálogos do Sistema.

🚀 Como Executar
Certifique-se de ter o SDK do Flutter instalado em sua máquina e rode os seguintes comandos no terminal:

Bash
# Clone o repositório
git clone https://github.com/Julia-Evelyn/C.R.I.S..git

# Entre na pasta
cd C.R.I.S.

# Baixe as dependências
flutter pub get

# Execute o app no emulador ou dispositivo físico
flutter run
