# Carregar pacotes necessários
if (!require("stringr")) install.packages("stringr", dependencies = TRUE)
library(stringr)

# Caminho para a pasta base
pasta_base <- "C:\\Users\\Pira\\Downloads"

# Obter todos os arquivos em subpastas
arquivos <- list.files(path = pasta_base, recursive = TRUE, full.names = TRUE)

# Filtrar apenas os arquivos que começam com o padrão "XX - "
arquivos_para_renomear <- arquivos[str_detect(basename(arquivos), "^\\d{1,2} - ")]

# Renomear os arquivos
for (arquivo in arquivos_para_renomear) {
  # Obter o diretório e o novo nome do arquivo
  diretorio <- dirname(arquivo)
  novo_nome <- str_remove(basename(arquivo), "^\\d{1,2} - ")
  
  # Caminho completo para o novo nome do arquivo
  novo_caminho <- file.path(diretorio, novo_nome)
  
  # Renomear o arquivo
  file.rename(arquivo, novo_caminho)
  
  # Informar o progresso
  cat("Renomeado:", arquivo, "para", novo_caminho, "\n")
}

cat("Processo de renomeação concluído!")
