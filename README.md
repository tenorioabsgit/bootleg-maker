# 🎵 Download e Processamento de Áudios do YouTube e Vimeo

Este projeto utiliza **yt-dlp** e **ffmpeg** para baixar áudios de **YouTube** e **Vimeo**, separá-los em faixas, renomear, combinar arquivos e organizar playlists.

## 📌 Funcionalidades

✅ **Download de áudio de vídeos e playlists do YouTube e Vimeo**  
✅ **Divisão do áudio em faixas com base em timestamps**  
✅ **Renomeação automática e remoção de números das faixas**  
✅ **Combinação de arquivos de áudio respeitando limite de tamanho**  
✅ **Organização de faixas baixadas e processamento de playlists**  

---

## 🛠 Tecnologias Utilizadas

- **Linguagem:** R  
- **Ferramentas externas:** `yt-dlp`, `ffmpeg`  
- **Pacotes R:** `processx`, `glue`, `tidyverse`, `fs`, `magrittr`, `stringr`  

---

## 📂 Estrutura do Código

```
📁 /  (Diretório Raiz)
├── V1 - Versao_final.R           # Download e separação de faixas
├── V2 - Versao_final.R           # Versão aprimorada do script de download
├── v3_corrige_erro_de_track.R    # Correções no script de divisão de faixas
├── v7_youtube_vimeo.R            # Suporte para vídeos do YouTube e Vimeo
├── V8_playlist_youtube.R         # Processamento de playlists
├── combina_audios.R              # Combinação de arquivos MP3 até 150MB
├── download_mp3_file.R           # Download de um único MP3
├── download_split_musics_by_time.R # Download e separação automática por tempo
├── remove_nemeros_faixas.R       # Remove números dos nomes dos arquivos
├── renomeia_random.R             # Renomeia faixas aleatoriamente
```

---

## 🚀 Como Executar

### 1️⃣ **Instalar Dependências**

Certifique-se de que `yt-dlp` e `ffmpeg` estão instalados e acessíveis no sistema:

- **Windows:** Baixe e extraia [yt-dlp](https://github.com/yt-dlp/yt-dlp/releases) e adicione ao PATH.
- **Linux:** Instale com:

```sh
sudo apt install yt-dlp ffmpeg
```

No R, instale os pacotes necessários:

```r
install.packages(c("processx", "glue", "tidyverse", "fs", "stringr"))
```

### 2️⃣ **Executar o Download de Áudio**

Para baixar e processar um vídeo do YouTube:

```r
source("V1 - Versao_final.R")
```

Para playlists:

```r
source("V8_playlist_youtube.R")
```

### 3️⃣ **Separar o Áudio em Faixas**

Se houver timestamps, rode:

```r
source("download_split_musics_by_time.R")
```

Se precisar corrigir os cortes:

```r
source("v3_corrige_erro_de_track.R")
```

### 4️⃣ **Organizar e Renomear Arquivos**

Para remover números das faixas:

```r
source("remove_nemeros_faixas.R")
```

Para renomear aleatoriamente:

```r
source("renomeia_random.R")
```

Para combinar arquivos respeitando limite de 150MB:

```r
source("combina_audios.R")
```

---

## 🛑 Possíveis Problemas e Soluções

### ⚠️ **Erro ao baixar vídeos do YouTube**  
Se o download falhar, verifique se o **yt-dlp** está atualizado:

```sh
yt-dlp -U
```

### ⏳ **Áudio está sendo cortado incorretamente**  
Se houver erro na separação das faixas, tente ajustar os timestamps no script antes de rodar novamente.

---


🚀 **Agora você pode baixar, organizar e processar áudios de forma automatizada!** Qualquer dúvida, me avise! 😊
