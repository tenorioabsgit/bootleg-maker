# 💰 Monitoramento de Cashback - Web Scraping e Telegram Bot

Este projeto realiza **web scraping** para monitoramento de cashback em lojas parceiras dos sites **Buscapé, Meliuz e Cuponomia**. Sempre que um **cashback acima de um valor configurado** for encontrado, o sistema envia um **alerta no Telegram**.

## 📌 Funcionalidades

✅ **Coleta de cashback de múltiplas plataformas**  
✅ **Filtragem por lojas de interesse**  
✅ **Comparação de valores de cashback**  
✅ **Envio de alertas no Telegram quando um cashback alto for encontrado**  

---

## 🛠 Tecnologias Utilizadas

- **Linguagem:** R  
- **Pacotes:** `RSelenium`, `rvest`, `tidyverse`, `telegram`  
- **Fontes de Dados:**  
  - [Buscapé](https://www.buscape.com.br/cupom-de-desconto/)  
  - [Meliuz](https://www.meliuz.com.br/desconto-lojas)  
  - [Cuponomia](https://www.cuponomia.com.br/desconto)  

---

## 📂 Estrutura do Código

```
📁 /  (Diretório Raiz)
└── web_scraping_cashbacks.R   # Script principal de monitoramento
```

---

## 🚀 Como Executar

### 1️⃣ **Instalar os pacotes necessários**

Se ainda não estiverem instalados, execute no R:

```r
install.packages(c("RSelenium", "rvest", "tidyverse", "telegram"))
```

### 2️⃣ **Configurar a Lista de Lojas de Interesse**

No script `web_scraping_cashbacks.R`, edite a variável `lojas_interesse` para incluir as lojas desejadas:

```r
lojas_interesse <- c("Amazon", "Americanas", "Submarino")
```

E defina o valor mínimo de cashback para alertas no Telegram:

```r
valor_cashback <- 6  # Somente cashback acima de 6% será notificado
```

### 3️⃣ **Configurar o Bot do Telegram**

- No script, insira o **Token do Bot do Telegram** na variável `Sys.setenv`:

```r
Sys.setenv(R_TELEGRAM_BOT_Algoritimus_bot='SEU_TOKEN_AQUI')
```

- Defina o **Chat ID** para onde os alertas devem ser enviados:

```r
bot$set_default_chat_id(SEU_CHAT_ID_AQUI)
```

### 4️⃣ **Executar o Script**

```r
source("web_scraping_cashbacks.R")
```

Se um **cashback alto** for encontrado, você receberá um alerta no **Telegram** com as melhores ofertas.

---

## 📊 Estrutura do Alerta no Telegram

Sempre que um cashback alto for encontrado, você receberá uma mensagem no seguinte formato:

```
Buscapé | Amazon | 8%
Meliuz | Submarino | 10%
Cuponomia | Americanas | 12%
```

---

## 🛑 Possíveis Problemas e Soluções

### ⚠️ **Erro ao iniciar o Selenium**
Se houver erro ao rodar o Selenium, verifique se o **Firefox e Geckodriver** estão instalados e compatíveis com a versão do seu navegador.

### 🔄 **Cashback não está aparecendo corretamente**
Pode ser necessário ajustar os seletores CSS usados no web scraping:

```r
cashback <- page %>% html_elements(".Text_MobileTagXs__SHXq9") %>% html_text2()
```

### ⏳ **Demora na execução**
Se o scraping estiver muito lento, experimente **reduzir o número de páginas analisadas**:

```r
pagination <- 1  # Reduza o número máximo de páginas para buscar
```

---

## 👨‍💻 Autor

👤 **José Tenório Abs Junior**  
📧 [Seu Email]  
🏛 **IBPAD - Instituto Brasileiro de Pesquisa e Análise de Dados**  

🚀 **Agora você pode monitorar cashback automaticamente e receber alertas no Telegram!** Qualquer dúvida, me avise! 😊
