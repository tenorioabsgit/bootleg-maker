# Defina o diretório da pasta
pasta <- "C:/Users/Pira/Downloads/Sergio Britto"

# Listar os arquivos na pasta
arquivos <- list.files(pasta, full.names = TRUE)

# Verificar se há arquivos na pasta
if (length(arquivos) == 0) {
  stop("Nenhum arquivo encontrado na pasta especificada.")
}

# Criar uma sequência randomizada dos arquivos
set.seed(123)  # Configurar seed para reprodutibilidade (opcional)
arquivos_randomizados <- sample(arquivos)

# Adicionar números à frente do nome do arquivo
for (i in seq_along(arquivos_randomizados)) {
  arquivo_atual <- arquivos_randomizados[i]
  nome_antigo <- basename(arquivo_atual)
  nome_novo <- sprintf("%02d - %s", i, nome_antigo)
  caminho_novo <- file.path(pasta, nome_novo)
  
  # Renomear o arquivo
  file.rename(arquivo_atual, caminho_novo)
}

cat("Renomeação concluída com sucesso!\n")
