# TV PLAYOUT 0.2 — compilação automática

Este pacote adiciona uma rotina de GitHub Actions para compilar os instaladores em servidores de compilação, sem instalar Qt/Xcode/Visual Studio no computador do usuário.

## O que será produzido

- macOS: `TV-PLAYOUT-0.2-macOS.dmg`
- Windows: `TV-PLAYOUT-0.2-Windows-Setup.exe`

## Importante sobre o Mac M1 com Big Sur 11.2

A rotina macOS deste primeiro pipeline usa Qt 6.5.3 `clang_64` (Intel x86_64), com deployment target 11.0. O aplicativo deverá rodar no M1 usando Rosetta 2, se o macOS tiver Rosetta instalada. Esta é uma primeira via de compatibilidade, não um binário Apple Silicon nativo. Uma build arm64 nativa será uma etapa posterior e precisará de um runner macOS ARM compatível.

O workflow ainda precisa ser executado e os instaladores precisam ser testados em máquinas reais. Criar este pacote não significa que os instaladores já foram compilados ou validados.

## Como gerar os instaladores

1. Crie uma conta em https://github.com/ se ainda não tiver.
2. Crie um repositório novo, por exemplo `tv-playout`.
3. Extraia este ZIP.
4. Envie **todo o conteúdo da pasta `TV-PLAYOUT`** para o repositório GitHub, mantendo a pasta `.github` (ela contém o workflow).
5. No GitHub, abra a aba **Actions**.
6. Selecione **Build TV PLAYOUT installers**.
7. Clique em **Run workflow** e confirme em **Run workflow**.
8. Aguarde os dois jobs terminarem com marca verde.
9. Abra a execução concluída. Na área **Artifacts**, baixe:
   - `TV-PLAYOUT-0.2-macOS`
   - `TV-PLAYOUT-0.2-Windows`

Cada Artifact será um ZIP contendo o instalador correspondente.

## Privacidade e publicação

O repositório pode ser privado. O código será enviado ao GitHub para a compilação. Não inclua senhas, chaves ou arquivos pessoais no repositório.

## Limitações do aplicativo 0.2

Este pipeline só empacota o protótipo atual. Ele não adiciona NDI, Blackmagic DeckLink, agendamento, histórico persistente, recuperação 24/7 ou recursos de broadcast ainda não implementados.
