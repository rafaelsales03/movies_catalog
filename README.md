# 🎬 Movies Catalog - Catálogo de Filmes em Ruby on Rails

[![Ruby Version](https://img.shields.io/badge/Ruby-3.4.6-red.svg)](.ruby-version)
[![Rails Version](https://img.shields.io/badge/Rails-8.0.3-blue.svg)](Gemfile.lock)

O projeto implementa as seguintes funcionalidades, divididas entre áreas públicas e autenticadas:

**🌐 Área Pública (Sem Login):**

* **Listagem de Filmes:** Exibição de todos os filmes cadastrados, ordenados do mais novo para o mais antigo.
* **Paginação:** Listagem paginada com 6 filmes por página para melhor navegação.
* **Detalhes do Filme:** Visualização completa dos detalhes de um filme: pôster (se houver), título, sinopse, ano de lançamento, duração e diretor.
* **Comentários Anônimos:** Qualquer visitante pode adicionar comentários em um filme, informando apenas nome e conteúdo.
* **Exibição de Comentários:** Comentários são exibidos na página do filme, ordenados do mais recente para o mais antigo.
* **Cadastro e Recuperação de Senha:** Funcionalidades completas de registro de novos usuários e recuperação de senha via e-mail, utilizando Devise.

**🔒 Área Autenticada (Com Login):**

* **Autenticação:** Login e Logout de usuários.
* **Gerenciamento de Filmes:** Usuário autenticado pode cadastrar, editar e apagar **apenas os filmes que ele mesmo criou**.
* **Comentários Autenticados:** Usuário autenticado pode comentar e seu nome é automaticamente vinculado ao comentário.
* **Edição de Perfil:** Possibilidade de editar o nome e alterar a senha na área de perfil.

**🌟 Funcionalidades Adicionais Implementadas:**

* **Categorias de Filmes:** Sistema para criar, listar, editar e excluir categorias. É possível associar um ou mais categorias aos filmes no momento do cadastro/edição.
* **Busca e Filtros:** Implementação de busca por título, diretor e/ou ano. Filtros avançados por múltiplas categorias, intervalo de anos e múltiplos diretores.
* **Tags:** Sistema de tags (palavras-chave) associadas aos filmes, com interface interativa no formulário.
* **Upload de Imagem (Poster):** Utilização do Active Storage para upload, exibição e remoção de pôsteres dos filmes, com validações de formato e tamanho, e preview no formulário.
* **Internacionalização (I18n):** Suporte completo a múltiplos idiomas (Português Brasileiro e Inglês).
* **Testes Automatizados Básicos:** Configuração e implementação de testes unitários (Models) e de requisição (Requests) utilizando RSpec e FactoryBot.

**🚧 Funcionalidades Não Implementadas**

* Importação em massa via CSV com Sidekiq.
* Busca e preenchimento de dados via IA.

## 🛠️ Tecnologias Utilizadas

* **Backend:** Ruby `3.4.6`, Ruby on Rails `8.0.3`
* **Banco de Dados:** PostgreSQL
* **Frontend:** HTML, CSS, JavaScript (via Importmap), Bootstrap 5, StimulusJS
* **Autenticação:** Devise
* **Paginação:** Kaminari
* **Upload de Arquivos:** Active Storage (Rails nativo) configurado com AWS S3 para produção
* **Testes:** RSpec Rails, FactoryBot, Database Cleaner
* **Servidor de Aplicação:** Puma
* **Deployment:** Configurado para Render (via `render.yaml`)

## ⚙️ Configuração do Ambiente Local

**Pré-requisitos:**

* Ruby `3.4.6`
* Bundler (`gem install bundler`)
* PostgreSQL (servidor rodando)

**Passos para Instalação:**

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/seu-usuario/movies_catalog.git](https://github.com/seu-usuario/movies_catalog.git)
    cd movies_catalog
    ```

2.  **Instale as dependências Ruby:**
    ```bash
    bundle install
    ```

3.  **Configure o Banco de Dados:**
    * Certifique-se que seu servidor PostgreSQL está rodando.
    * Configure o arquivo `config/database.yml` se necessário (por padrão, ele tentará usar o usuário do seu sistema operacional para conectar). Pode ser necessário criar um usuário no Postgres: `CREATE USER seu_usuario WITH PASSWORD 'sua_senha' CREATEDB;`
    * Crie os bancos de dados de desenvolvimento e teste e rode as migrations e seeds:
        ```bash
        bin/rails db:prepare
        bin/rails db:seed
        ```

4.  **Variáveis de Ambiente**
    * Crie um arquivo `.env` na raiz do projeto (este arquivo está no `.gitignore`).
    * Adicione a `RAILS_MASTER_KEY`. Se não tiver uma, gere com `bin/rails credentials:edit` e copie o conteúdo de `config/master.key` ou a chave exibida no editor para a variável no `.env`:
        ```dotenv
        RAILS_MASTER_KEY=sua_master_key_aqui
        ```
    * Se quiser testar o envio de emails de recuperação de senha em desenvolvimento, configure as credenciais do SendGrid (ou outro provedor) no `.env`:
        ```dotenv
        SENDGRID_USERNAME=apikey
        SENDGRID_PASSWORD=sua_chave_sendgrid
        DEVISE_MAILER_SENDER=seu_email_remetente@exemplo.com
        ```

5.  **Inicie o Servidor Rails:**
    ```bash
    bin/dev
    ```
   
    A aplicação estará acessível em `http://localhost:3000`.

## ✅ Executando os Testes

Para rodar a suíte de testes RSpec:

1.  **Prepare o banco de dados de teste:**
    ```bash
    RAILS_ENV=test bin/rails db:prepare
    ```

2.  **Execute os testes:**
    ```bash
    bundle exec rspec
    ```

## 🚀 Deployment

A aplicação está configurada para deploy na plataforma **Render** através do arquivo `render.yaml`.

**Importante:** Devido ao sistema de arquivos efêmero do Render, o Active Storage **deve** ser configurado para usar um serviço de armazenamento externo em produção (como AWS S3, Google Cloud Storage, etc.) para que os uploads de arquivos persistam entre deploys. A configuração padrão neste projeto usa AWS S3.

**Variáveis de Ambiente Essenciais no Render:**

* `DATABASE_URL`: Fornecida automaticamente pelo serviço de banco de dados do Render.
* `RAILS_MASTER_KEY`: Conteúdo do arquivo `config/master.key` (adicionar como Secret).
* `AWS_ACCESS_KEY_ID`: Chave de acesso da AWS (adicionar via `credentials.yml.enc` ou como Secret).
* `AWS_SECRET_ACCESS_KEY`: Chave secreta da AWS (adicionar na `credentials.yml.enc` ou como Secret).
* `AWS_REGION`: A região do seu bucket S3 (ex: `sa-east-1`).
* `AWS_BUCKET`: O nome do seu bucket S3 (ex: `movies-catalog`).
* `SENDGRID_USERNAME`: `apikey` (adicionar como Secret).
* `SENDGRID_PASSWORD`: Sua chave de API do SendGrid (adicionar como Secret).
* `APP_DOMAIN`: O domínio principal da sua aplicação no Render (ex: `movies-catalog.onrender.com`).
* `DEVISE_MAILER_SENDER`: O e-mail remetente para Devise (ex: `noreply@movies-catalog.onrender.com`).

O Render automaticamente executará `bundle install`, `assets:precompile` e `db:migrate` com base no `render.yaml`.

## 🗂️ Organização do Projeto e Documentação

* **Gerenciamento de Tarefas:** As funcionalidades e tarefas foram organizadas utilizando a aba **Projects** do GitHub, proporcionando uma visão clara do progresso durante o desenvolvimento do desafio. Veja o quadro do projeto [AQUI](https://github.com/users/rafaelsales03/projects/2/views/1).
* **Comentários no Código:** Os arquivos CSS (`app/assets/stylesheets/`) e JavaScript (`app/javascript/`) contêm comentários explicando as principais seções e lógicas implementadas, visando facilitar a compreensão e manutenção.

## 🎨 Filosofia e Boas Práticas

Durante o desenvolvimento, buscou-se seguir boas práticas como:

* **Código Limpo e Legível:** Esforço para manter o código organizado, bem formatado e fácil de entender.
* **Testes Automatizados:** Implementação de testes básicos para garantir a robustez das funcionalidades core.
* **Versionamento Semântico (Commits):** Commits claros e descritivos no Git.
