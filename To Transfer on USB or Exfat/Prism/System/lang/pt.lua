-- Prism PS2 Launcher - lang/pt.lua
-- Português / Portuguese: every text of the interface. Fills the TEXT_* tables.
-- Split from the original language.lua (RETROLauncher, Spaghetticode / Boon Tobias).

function lang_pt(actual)
	-- Nota. ------------------------------------------------------------------------
	-- Evite usar palavras ou frases que excedam o limite de caracteres dos originais, para evitar que o texto ultrapasse os limites do quadro.
	-- ...? - É uma pergunta que pode variar, então termina em outra parte do código; nesses casos, omita o caractere "?" no final.
	-- \n - É uma quebra de linha, portanto não deve haver espaço entre elas e a palavra seguinte.
	-- \" - É utilizado para escapar um caractere especial usado pelo código que pode causar conflitos.

	-- Textos de uso geral. ---------------------------------------------------------
	TEXT_GEN = {
		"Sair"; -- 1
		"Não"; -- 2
		"Sim"; -- 3
		"Volte"; -- 4
		"Escolher"; -- 5
		"Cancelar"; -- 6
		"Sair"; -- 7
		"Mudar"; -- 8
		"Não"; -- 9
		"Sim"; -- 10
		"Reiniciar"; -- 11
		"Salvar"; -- 12
		"Ligado"; -- 13
		"Desligado"; -- 14
	};

	-- Menu de configurações para jogos de PS1. -------------------------------------
	TEXT_M_PS1 = {
		"Instalar arquivo \"CHEATS.TXT\""; -- 1
		"Procurando por arquivos \"CHEATS.TXT\""; -- 2
		"Descrição"; -- 3
		"Controle de código"; -- 4
		"Salvar códigos selecionados"; -- 5 ...?
		"Salvando os códigos"; -- 6
		"Instalando patches"; -- 7
		"Procurando patches"; -- 8
		"Carregando as configurações do jogo"; -- 9
		"Limpando as configurações do jogo"; -- 10
		"Patches de uso geral encontrados"; -- 11
		"Patches com o mesmo nome serão substituídos."; -- 12
		"Patches de jogo encontrados"; -- 13
		"Todos os patches anteriores serão removidos."; -- 14
		"Instalar patch"; -- 15
		"Nome do patch a ser instalado"; -- 16
		"Instalar"; -- 17
		"Instalar patches selecionados"; -- 18 ...?
		"Instalar patches para jogos específicos"; -- 19
		"Instalar patches gerais"; -- 20
		"Configurações extras"; -- 21
		"Limpar as configurações do jogo"; -- 22
		"Selecione o tipo de configuração"; -- 23
		"Somente patches"; -- 24
		"Somente códigos"; -- 25
		"Todas as configurações"; -- 26
		"Limpar configurações selecionadas"; -- 27 ...?
		"Limpar"; -- 28
		"\"CHEATS.TXT\" de jogos encontrados"; -- 29
		"O anterior \"CHEATS.TXT\" será excluído."; -- 30
		"Instalar \"CHEATS.TXT\" selecionado"; -- 31 ...?
		"\"CHEATS.TXT\" do jogo a ser instalado"; -- 32
		"Instalando \"CHEATS.TXT\""; -- 33
	};

	-- Descrições das opções do POPStarter. -----------------------------------------
	TEXT_POPS_DESCR = {
		-- Descrição dos códigos para POPStarter. -----------------------------------
		"Desativa o mecanismo de trapaça e só o\nativa após o POPS sair do PS1 OSD.\nDeve estar sempre ligado."; -- 1
		"Habilita o mapeamento de textura suave na\ninicialização."; -- 2
		"Configura o atraso USB do wrapper PFS.\nPara dispositivos USB que apresentam\nproblemas ao executar o \"POPStarter\"."; -- 3
		"Força a ativação do patcher PAL e aplica o\npatch do código de região para Euro. Útil\npara VCDs PAL que não possuem um texto de\nlicença válido em seu setor de inicialização."; -- 4
		"Desativa o patcher PAL do POPStarters.\nNão foi projetado para converter jogos NTSC\npara PAL."; -- 5
		"Centraliza a tela verticalmente. Não há\nvalor padrão, depende do jogo, você precisa\nexperimentar. Quanto maior o valor, mais a\ntela se move para baixo."; -- 6
		"Centraliza a tela horizontalmente. O valor\npadrão é 640; valores menores que 640 movem\na tela para a esquerda; valores maiores que\n640 movem a tela para a direita."; -- 7
		"Estende a tela horizontalmente. O valor\npadrão é 2559; aumente para esticar a tela\npara a direita e diminua para estreitá-la\npara a esquerda."; -- 8
		"Reduz/expande a largura da área de exibição.\nO valor máximo é 2560; diminua-o para cortar\na tela à direita."; -- 9
		"Habilita o gerador de scanlines. Os jogos\nsão exibidos com esse tipo de linhas que as\nantigas TVs e monitores de tubo tinham."; -- 10
		"O controle permanece no Modo Digital.\nHabilita o suporte a joystick para jogos\nque não o suportam nativamente."; -- 11
		"O controle permanece no Modo Analógico.\nHabilita o suporte a joysticks para jogos\nque não o suportam nativamente."; -- 12
		"Ajuda com TVs de alta definição que não\nsuportam resoluções entrelaçadas via\ncomponente. Não é compatível com algumas\nTVs de tubo (CRT)."; -- 13
		"Silencia sons/músicas baseados em\nVAB/VAG/VB+VH em jogos. Pode ser útil para\njogos antigos que emitem efeitos sonoros ou\nruídos distorcidos."; -- 14
		"Abre o menu IGR.\nCombinação:\nL1 + L2 + R1 + R2 + X + DOWN"; -- 15
		"Abre o menu IGR.\nCombinação:\nSELECT + START"; -- 16
		"Abre o menu IGR.\nCombinação:\nL1 + L2 + R1 + R2 + SELECT + START"; -- 17
		"A combinação \"IGR\" encerra o POPS\n(não há menu \"IGR\").\nCombinação:\nL1 + L2 + R1 + R2 + X + DOWN"; -- 18
		"A combinação \"IGR\" encerra o POPS\n(não há menu \"IGR\").\nCombinação:\nSELECT + START"; -- 19
		"A combinação \"IGR\" encerra o POPS\n(não há menu \"IGR\").\nCombinação:\nL1 + L2 + R1 + R2 + SELECT + START"; -- 20
		"Desativa o menu IGR."; -- 21
		"Carrega uma palavra mágica LibCrypt nula no\nregistrador cop0. Pode ser necessário em\nalguns discos que apresentam problemas na\nproteção LibCrypt."; -- 22
		"Habilita o hack de tela ampla POPS GTE e\nforça 16:9. Não lida com coisas como HUDs,\ntextos, menus, fundos 2D (este hack não\nestá concluído)."; -- 23
		"Semelhante ao WIDESCREEN, mas com um campo\nde visão mais amplo. Não lida com coisas\ncomo HUDs, textos, menus, fundos 2D (este\nhack não está concluído)."; -- 24
		"Igual ao WIDESCREEN, com proporção de\naspecto 3×16:9. Não lida com coisas como\nHUDs, textos, menus, fundos 2D (este hack\nnão está concluído)."; -- 25
		"Force 480p. Não compatível com XPOS, YPOS,\nDWSTRETCH ou DWCROP. Evite usá-lo, pois não\né confiável."; -- 26
		"Use somente \"Virtual Memory Card 1\"."; -- 27
		"Use somente \"Virtual Memory Card 0\"."; -- 28
		"Impede que o POPStarter ative correções de\njogo. Este comando pode não funcionar em\nalguns jogos."; -- 29
		"Ajuda a restaurar músicas/vozes em vários\njogos.\nDesabilite se estiver usando patches \".bin\"."; -- 30
		"Uma variante do modo 0×01, com um segundo\nhack para não quebrar o MDECoding dos FMVs\n(foi projetado para a série Colony Wars).\nDesabilite se estiver usando patches \".bin\"."; -- 31
		"Pode ser usado se o modo 0×01 não fornecer\nos resultados esperados.\nDesabilite se estiver usando patches \".bin\"."; -- 32
		"Corrige lentidão, oscilações e muitas outras\nfalhas.\nDesabilite se estiver usando patches \".bin\"."; -- 33
		"Feito para corrigir as cutscenes do\nResident Evil: Director’s Cut (PAL).\nDesabilite se estiver usando patches \".bin\"."; -- 34
		"Desativa o shell OSD do BIOS integrado do\nemulador, fazendo com que alguns jogos que\ntravam na inicialização sejam executados.\nDesabilite se estiver usando patches \".bin\"."; -- 35
		-- Descrição dos patches para o POPStarter. ---------------------------------
		"Possivelmente corrige jogos com problemas\n3D/2D.\nHack / +4 de brilho / DQA, DQB"; -- 36
		"Possivelmente corrige jogos com problemas\n3D/2D.\nHack / Brilho normal / DQA, DQB"; -- 37
		"Possivelmente corrige jogos com problemas\n3D/2D.\nHack / -4 de brilho / DQA, DQB"; -- 38
		"Possivelmente corrige jogos com problemas\n3D/2D.\nHack / -16 de brilho / DQA, DQB"; -- 39
		"Possivelmente corrige jogos com problemas\n3D/2D.\nHack / DQA, DQB"; -- 40
		"Possivelmente corrige jogos com problemas\n3D/2D.\nHack / IR0"; -- 41
		"Possivelmente corrige jogos com problemas\n3D/2D.\nA opção mais compatível e recomendada."; -- 42
		"Corrige falhas no nível do recompilador em\nraríssimos casos, apenas quando o problema é\numa atualização incorreta do código no cache\nde instruções do recompilador."; -- 43
		"Esses mods evitam falhas de áudio.\nRecomenda-se usar \"SPU_IRQ_ON_STABLE\",\npois é o mais estável; o áudio será pulado,\nentão você não o ouvirá."; -- 44
		"Isso aplica overclocks ao emulador,\nsuportando PAL e NTSC.\nAtenção: Valores acima de +40 podem causar\nproblemas de salvamento."; -- 45
		"Sem overclocking da GPU. Necessário para\nalgumas combinações de overclocking da CPU."; -- 46
		"Pode corrigir algumas partes do jogo, mas\nseu uso deve ser compensado por overclock.\nRecomenda-se que o clock da GPU seja 20%\nmenor que o clock da CPU."; -- 47
		"Desabilite o Dithering, este é um filtro\nespecial usado em jogos de PS1."; -- 48
		"Sem descrição."; -- 49
	};

	-- Menu de configurações para jogos de PS2. -------------------------------------
	TEXT_M_PS2 = {
		"Procurando configurações de jogo"; -- 1
		"Use o cartão de memória virtual"; -- 2
		"Sem cartão de memória virtual"; -- 3
		"Modos de compatibilidade"; -- 4
		"IOP: Fast Reads"; -- 5
		"Dummy"; -- 6
		"IOP: Sync Reads"; -- 7
		"EE : Unhook Syscalls"; -- 8
		"IOP: emulate DVD-DL"; -- 9
		"IOP: Fix game buffer overrun"; -- 10
		"Modo sintetizador gráfico"; -- 11
		"Forçar modo de vídeo"; -- 12
		"Modo de compatibilidade"; -- 13
		"Não utilizado"; -- 14
		"Salvar configurações do jogo"; -- 15
		"OPL"; -- 16
		"Neutrino"; -- 17
		"VMC não encontrado"; -- 18
		"Salvando as configurações do jogo"; -- 19
		"Accurate Reads"; -- 20
		"Synchronous Reads"; -- 21
		"Unhook Syscalls"; -- 22
		"Skip videos"; -- 23
		"Emulate DVD-DL"; -- 24
		"Disable IGR"; -- 25
		"Ajuste horizontal"; -- 26
		"Ajuste vertical"; -- 27
		"Salvar configurações?"; -- 28
		"AVISO:\nÉ recomendado que você configure seus jogos\ndentro do \"OPL\", pois pode haver conflitos entre\ndiferentes versões do \"OPL\" e seus arquivos de\nconfiguração."; -- 29
	};

	-- Menu do navegador. -----------------------------------------------------------
	TEXT_M_EXP = {
		"A pasta está vazia ou os arquivos não são compatíveis"; -- 1
		"Não há arquivos válidos"; -- 2
		"Itens"; -- 3
	};

	-- Menu de configurações para Prism. ------------------------------------
	TEXT_M_CON = {
		"Efeito RGB"; -- 1
		"Cor nos fundos"; -- 2
		"Definir uma cor de fundo"; -- 3
		"Vermelho"; -- 4
		"Verde"; -- 5
		"Azul"; -- 6
		"Estilo de lista"; -- 7
		"Fonte do texto"; -- 8
		"Papel de parede"; -- 9
		"GUI limpa"; -- 10
		"Coleta forçada de lixo"; -- 11
		"Saída personalizada"; -- 12
		"Diretório"; -- 13
		"Rotas completas no menu do APPS"; -- 14
		"Sons no menu"; -- 15
		"Volume de som"; -- 16
		"Capturas de tela como fundos"; -- 17
		"Modo de vídeo"; -- 18
		"Vibração no menu"; -- 19
		"Diretórios adicionais"; -- 20
		"Reiniciar todas as configurações"; -- 21
		"Créditos"; -- 22
		"Salvar configurações"; -- 23
		"Página 1"; -- 24
		"Página 2"; -- 25
		"Alterações não salvas. você quer sair?"; -- 26
		"Todas as alterações feitas serão perdidas."; -- 27
		"Selecione o dispositivo de pesquisa"; -- 28
		"Procurar"; -- 29
		"Ajustar largura"; -- 30
		"Ajustar altura"; -- 31
		"Ajuste os fundos de texto"; -- 32
		"Ajustar deslocamento de texto"; -- 33
		"Aumente ou diminua o deslocamento até que o número \"0\" fique visível ao lado da caixa colorida"; -- 34
		"Definir a fonte do texto"; -- 35
		"Ajustar texto em caixas escuras"; -- 36
		"Tente colocar o \"0\" na caixa de cores"; -- 37
		"Tente fazer a barra escura cobrir o texto"; -- 38
		"Exemplo de texto fixo"; -- 39
		"Restaurar"; -- 40
		"Estabelecer"; -- 41
		"Liberar o resto das listas?"; -- 42
		"Se ativado, o movimento será mais suave"; -- 43
		"mas haverá pausas ao alternar os sistemas."; -- 44
		"Desativar \"wLaunchELF\"?"; -- 45
		"Por favor aguarde"; -- 46
		"Música de fundo em loop?"; -- 47
		"Utilizar se o RetroArch tiver cortes de áudio ou"; -- 48
		"se você não tem os meios para alterar o formato"; -- 49
		"Restaurar"; -- 50 ...?
		"Apagar jogos salvos?"; -- 51
		"Alterar o modo de vídeo para"; -- 52 ...?
		"Reiniciar todas as configurações?"; -- 53
		"Padrão"; -- 54
		"(ativar cores de depuração)"; -- 55
		"Simple"; -- 56
		"Cover art"; -- 57
		"Full art"; -- 58
		"Big cover"; -- 59
		"Big art"; -- 60
		"Big list"; -- 61
		"Custom"; -- 62
		"Nível de zoom"; -- 63
		"Ativar sistemas"; -- 64
		"Transparência"; -- 65
		"Sem transparência"; -- 66
		"Selecione o aplicativo"; -- 67
		"Selecione a versão OPL"; -- 68
		"(configuração do usuário)"; -- 69
		"Apagar jogos salvos"; -- 70
		"Restaurando"; -- 71
		"Alterando as configurações de vídeo"; -- 72
		"Carregando listas de jogos e configurações"; -- 73
		"Reiniciando todas as configurações"; -- 74
		"W"; -- 75 Exemplo de configuração de fonte.
		"M"; -- 76 Exemplo de configuração de fonte.
		"Colunas"; -- 77
		"Linhas"; -- 78
		"Número de animações"; -- 79
		"Renomear imagem para configuração automática"; -- 80 ...?
		"Nome atual"; -- 81
		"Novo nome"; -- 82
		"Configuração do POPStarter"; -- 83
		"\"IGR\" sai para \"OSDSYS\""; -- 84
		"Desativar \"Dithering\" em jogos"; -- 85
		"Instalar tradução em \"IGR\""; -- 86
		"Configurar animação de camada"; -- 87
		"Tipo de animação"; -- 88
		"Velocidade da animação"; -- 89
		"Multiplicador de quadros"; -- 90
		"Tipo de transparência"; -- 91
		"Nível de transparência"; -- 92
		"Velocidade de transparência"; -- 93
		"Tipo de rotação"; -- 94
		"Velocidade de rotação"; -- 95
		"Camadas afetadas"; -- 96
		"Gire para a\ndireita"; -- 97
		"Gire para a\nesquerda"; -- 98
		"Mudando de\ndireção"; -- 99
		"Transparência\nfixa"; -- 100
		"Alternar\nmínimo/máximo"; -- 101
		"Alternar\nmitad/máximo"; -- 102
		"Alternar camadas\nmínimo/máximo"; -- 103
		"Alternar camadas\nmitad/máximo"; -- 104
		"Exibir índices de jogos?"; -- 105
		"Configuração de sprites"; -- 106
		"Ative os sprites no menu"; -- 107
		"Sprite correspondente ao"; -- 108
		"Tipo de animação"; -- 109
		"Velocidade da animação"; -- 110
		"Transparências na animação"; -- 111
		"Rotações na animação"; -- 112
		"Espelhar sprite"; -- 113
		"Branco"; -- 114
		"Tamanho do raio"; -- 115
		"Selecione o menu de configurações"; -- 116
		"Editor de estilo"; -- 117
		"Configuração do sprite"; -- 118
		"Transparência das capturas de tela"; -- 119
		"Exibir sempre o menu de execução alternativo."; -- 120
		"Cor das sombras atrás dos elementos"; -- 121
	};

	-- Nomes dos estilos de animação para os sprites. -------------------------------
	TEXT_SPR_T = {
		"Sprite\nfixo"; -- 1
		"Mova-se para\na direita\nno eixo\nhorizontal"; -- 2
		"Mova-se para\na esquerda\nno eixo\nhorizontal"; -- 3
		"Mova-se para\na direita\nno eixo\nhorizontal\n+zigzague\nno eixo\nvertical\n(curto)"; -- 4
		"Mova-se para\na esquerda\nno eixo\nhorizontal\n+zigzague\nno eixo\nvertical\n(curto)"; -- 5
		"Mova-se para\na direita\nno eixo\nhorizontal\n+zigzague\nno eixo\nvertical\n(longo)"; -- 6
		"Mova-se para\na esquerda\nno eixo\nhorizontal\n+zigzague\nno eixo\nvertical\n(longo)"; -- 7
		"Mova-se da\ndireita para\na esquerda\nno eixo\nhorizontal\n(curto)"; -- 8
		"Mova-se da\ndireita para\na esquerda\nno eixo\nhorizontal\n(metade)"; -- 9
		"Mova-se da\ndireita para\na esquerda\nno eixo\nhorizontal\n(longo)"; -- 10
		"Mova-se da\ndireita para\na esquerda\nno eixo\nhorizontal\n(curto)\n+zigzague\nno eixo\nvertical"; -- 11
		"Mova-se da\ndireita para\na esquerda\nno eixo\nhorizontal\n(metade)\n+zigzague\nno eixo\nvertical"; -- 12
		"Mova-se da\ndireita para\na esquerda\nno eixo\nhorizontal\n(longo)\n+zigzague\nno eixo\nvertical"; -- 13
		"Descer\nno eixo\nvertical"; -- 14
		"Subir\nno eixo\nvertical"; -- 15
		"Descer\nno eixo\nvertical\n+zigzague\nno eixo\nhorizontal\n(curto)"; -- 16
		"Subir\nno eixo\nvertical\n+zigzague\nno eixo\nhorizontal\n(curto)"; -- 17
		"Descer\nno eixo\nvertical\n+zigzague\nno eixo\nhorizontal\n(longo)"; -- 18
		"Subir\nno eixo\nvertical\n+zigzague\nno eixo\nhorizontal\n(longo)"; -- 19
		"Subir e\ndescer\nno eixo\nvertical\n(curto)"; -- 20
		"Subir e\ndescer\nno eixo\nvertical\n(metade)"; -- 21
		"Subir e\ndescer\nno eixo\nvertical\n(longo)"; -- 22
		"Subir e\ndescer\nno eixo\nvertical\n(curto)\n+zigzague\nno eixo\nhorizontal"; -- 23
		"Subir e\ndescer\nno eixo\nvertical\n(metade)\n+zigzague\nno eixo\nhorizontal"; -- 24
		"Subir e\ndescer\nno eixo\nvertical\n(longo)\n+zigzague\nno eixo\nhorizontal"; -- 25
		"Aceleração\nao descer\npara a\ndireita"; -- 26
		"Aceleração\nao descer\npara a\nesquerda"; -- 27
		"Aceleração\nao subir\npela direita"; -- 28
		"Aceleração\nao subir\npela esquerda"; -- 29
		"Aceleração\nda direita\npara a\nesquerda"; -- 30
		"Aceleração\nda esquerda\npara a\ndireita"; -- 31
		"Aceleração\nda direita\npara a\nesquerda\n+mudança\nno eixo\nvertical"; -- 32
		"Aceleração\nda esquerda\npara a\ndireita\n+mudança\nno eixo\nvertical"; -- 33
		"Desacelerar\nda direita\npara a\nesquerda"; -- 34
		"Desacelerar\nda esquerda\npara a\ndireita"; -- 35
		"Aceleração\nao descer\npara a\nesquerda"; -- 36
		"Aceleração\nao subir\npela\nesquerda"; -- 37
		"Aceleração\nao descer\npara a\ndireita"; -- 38
		"Aceleração\nao subir\npela\nderecha"; -- 39
		"Aceleração\nem descida"; -- 40
		"Aceleração\nna ascensão"; -- 41
		"Aceleração\nem descida\n+mudança\nno eixo\nhorizontal"; -- 42
		"Aceleração\nna ascensão\n+mudança\nno eixo\nhorizontal"; -- 43
		"Desacelerar\nna descida"; -- 44
		"Desacelerar\nao acender"; -- 45
		"Flutuar\nna diagonal\nversão 1"; -- 46
		"Flutuar\nna diagonal\nversão 2"; -- 47
		"Diagonal\ninferior\ndireita"; -- 48
		"Diagonal\ninferior\nesquerda"; -- 49
		"Diagonal\nsuperior\ndireita"; -- 50
		"Diagonal\nsuperior\nesquerda"; -- 51
		"Percorra\no quadro\nno sentido\nhorário"; -- 52
		"Percorra\no quadro\nno sentido\nanti-horário"; -- 53
		"Dando voltas\nem círculos\nno sentido\nhorário\n(curto)"; -- 54
		"Dando voltas\nem círculos\nno sentido\nanti-horário\n(curto)"; -- 55
		"Dando voltas\nem círculos\nno sentido\nhorário\n(metade)"; -- 56
		"Dando voltas\nem círculos\nno sentido\nanti-horário\n(metade)"; -- 57
		"Dando voltas\nem círculos\nno sentido\nhorário\nem tela\ncheia"; -- 58
		"Dando voltas\nem círculos\nno sentido\nanti-horário\nem tela\ncheia"; -- 59
		"Rebater\nna tela"; -- 60
		"Aumentar\no tamanho\n(curto)"; -- 61
		"Aumentar\no tamanho\n(metade)"; -- 62
		"Controle o\nsprite com\no analógico\ndireito"; -- 63
		"Manter a\ntransparencia"; -- 64
		"Alternar\nentre mínimo\ne máximo"; -- 65
		"Alternar\nentre metade\ne o máximo"; -- 66
		"Espelhar\no eixo\nhorizontal\nde acordo\ncom o\nmovimento"; -- 67
		"Espelhar\no eixo\nvertical\nde acordo\ncom o\nmovimento"; -- 68
		"Espelhar\nambos os\neixos\nde acordo\ncom o\nmovimento"; -- 69
		"Espelhar\no eixo\nhorizontal\nmanualmente\ncom o\nanalógico\ndireito"; -- 70
		"Espelhar\no eixo\nvertical\nmanualmente\ncom o\nanalógico\ndireito"; -- 71
		"Espelhar\nambos os\neixos\nmanualmente\ncom o\nanalógico\ndireito"; -- 72
		"Manter o\nreflexo\nno eixo\nhorizontal"; -- 73
		"Manter o\nreflexo\nno eixo\nvertical"; -- 74
		"Manter\nreflexos\nem ambos\nos eixos"; -- 75
		"Digite o\nnúmero de\ncolunas que\ncontêm a\nimagem\n(vertical)"; -- 76
		"Digite o\nnúmero de\nlinhas que\ncontêm a\nimagem\n(horizontal)"; -- 77
	};

	-- Nomes dos estilos de animação para as camadas. -------------------------------
	TEXT_LAY_T = {
		"Camadas fixas"; -- 1
		"Direita\nhorizontal v1"; -- 2
		"Esquerda\nhorizontal v1"; -- 3
		"Direita\nziguezaguear"; -- 4
		"Esquerda\nziguezaguear"; -- 5
		"Direita\nfrontal v1"; -- 6
		"Esquerda\nfrontal v1"; -- 7
		"Ziguezaguear\nhorizontal v1"; -- 8
		"Direita\nhorizontal v2"; -- 9
		"Esquerda\nhorizontal v2"; -- 10
		"Esquerda\nfrontal v2"; -- 11
		"Direita\nfrontal v2"; -- 12
		"Direita\nfrontal v3"; -- 13
		"Esquerda\nfrontal v3"; -- 14
		"Direita\npanorâmico v1"; -- 15
		"Esquerda\npanorâmico v1"; -- 16
		"Direita\npanorâmico v2"; -- 17
		"Esquerda\npanorâmico v2"; -- 18
		"Cruzamento\nhorizontal"; -- 19
		"Ziguezaguear\nhorizontal v2"; -- 20
		"Baixo\nvertical v1"; -- 21
		"Cima\nvertical v1"; -- 22
		"Baixo\nziguezaguear"; -- 23
		"Cima\nziguezaguear"; -- 24
		"Cima\nfrontal v1"; -- 25
		"Baixo\nfrontal v1"; -- 26
		"Ziguezaguear\nvertical v1"; -- 27
		"Baixo\nvertical v2"; -- 28
		"Cima\nvertical v2"; -- 29
		"Cima\nfrontal v2"; -- 30
		"Baixo\nfrontal v2"; -- 31
		"Baixo\nfrontal v3"; -- 32
		"Cima\nfrontal v3"; -- 33
		"Baixo\npanorâmico v1"; -- 34
		"Cima\npanorâmico v1"; -- 35
		"Baixo\npanorâmico v2"; -- 36
		"Cima\npanorâmico v2"; -- 37
		"Cruzamento\nvertical"; -- 38
		"Ziguezaguear\nvertical v2"; -- 39
		"Direita\nredemoinho"; -- 40
		"Esquerda\nredemoinho"; -- 41
		"Zoom 3-4\nPixel zoom"; -- 42
		"Zoom 1-2\nPixel zoom"; -- 43
		"Zoom 2-3\nPixel zoom"; -- 44
		"Zoom 1-4\nPixel zoom"; -- 45
		"Zoom 1-3-4\nPixel zoom"; -- 46
		"Zoom 1-2-3\nPixel zoom"; -- 47
		"Zoom 2-3-4\nPixel zoom"; -- 48
		"Zoom 1-2-4\nPixel zoom"; -- 49
		"Zoom 1-2-3-4\nPixel zoom"; -- 50
		"Zoom 3-4 v2\nPixel zoom"; -- 51
		"Zoom 1-2 v2\nPixel zoom"; -- 52
		"Zoom 2-3 v2\nPixel zoom"; -- 53
		"Zoom 1-4 v2\nPixel zoom"; -- 54
		"Zoom 1-3-4 v2\nPixel zoom"; -- 55
		"Zoom 1-2-3 v2\nPixel zoom"; -- 56
		"Zoom 2-3-4 v2\nPixel zoom"; -- 57
		"Zoom 1-2-4 v2\nPixel zoom"; -- 58
		"Zoom 1-2-3-4 v2\nPixel zoom"; -- 59
		"Direita\nhorizontal v3"; -- 60
		"Esquerda\nhorizontal v3"; -- 61
		"Baixo\nvertical v3"; -- 62
		"Cima\nvertical v3"; -- 63
	};

	-- Menu do editor de estilo. ----------------------------------------------------
	TEXT_M_STI = {
		"Exemplo de nome de jogo.zip"; -- 1
		"Centro / Exemplo de nome de jogo.zip"; -- 2
		"Direita / Exemplo de nome de jogo.zip"; -- 3
		"Esquerda / Exemplo de nome de jogo.zip"; -- 4
		"Nº de jogos"; -- 5
		"Sair"; -- 6
		"Configurar"; -- 7
		"Mudar a arte"; -- 8
		"Tela cheia"; -- 9
		"Executar"; -- 10
		"Atualizar"; -- 11
		"Lista"; -- 12
		"Arte"; -- 13
		"Arte extra"; -- 14
		"Cover flow"; -- 15
		"Logotipo"; -- 16
		"Botão de Cruz"; -- 17
		"Botão Triângulo"; -- 18
		"Botão Quadrado"; -- 19
		"Botão L1"; -- 20
		"Botão R1"; -- 21
		"Botão R3"; -- 22
		"Botão START"; -- 23
		"Botão SELECT"; -- 24
		"Tipo de transição"; -- 25
		"Velocidade"; -- 26
		"Restaurar tudo"; -- 27
		"Salve o estilo"; -- 28
		"Sair do menu de edição"; -- 29
		"Bloquear"; -- 30
		"Guias"; -- 31
		"Posição"; -- 32
		"Tamanho"; -- 33
		"Pixels"; -- 34
		"Restaurar"; -- 35
		"Próximo"; -- 36
		"Anterior"; -- 37
		"Ajuda"; -- 38
		"Elementos"; -- 39
		"Salvar"; -- 40
		"Menu"; -- 41
		"Pixels"; -- 42
		"Ativar elementos"; -- 43
		"Sombra"; -- 44
		"Opções adicionais"; -- 45
		"Reiniciar todos os itens?"; -- 46
		"Salvar alterações?"; -- 47
		"Ao salvar, se existir uma configuração anterior\nserá criada uma cópia de segurança dela\n(substituindo a última cópia existente)."; -- 48
	};

	-- Menu principal. --------------------------------------------------------------
	TEXT_M_PRI = {
		"-Carregando Arte-"; -- 1
		"Sair"; -- 2
		"Configurações"; -- 3
		"Mudar a arte"; -- 4
		"Tela cheia"; -- 5
		"Executar"; -- 6
		"Atualizar"; -- 7
		"Configurar"; -- 8
		"Menu"; -- 9
		"Arte"; -- 10
		"Zoom"; -- 11
		"Jogar"; -- 12
		"Carregando"; -- 13
		"Sem elementos"; -- 14
		"Erro!"; -- 15
		"Jogos ou RetroArch"; -- 16
		"Aplicativo ou ELF"; -- 17
		"POPS ou Binários"; -- 18
		"Neutrino/OPL ou ISO"; -- 19
		"Não encontrado!"; -- 20
		"Nº de jogos"; -- 21
		"Nº de APPS"; -- 22
		"Reiniciar o Prism?"; -- 23
		"Sair do Prism?"; -- 24
		"AVISO!"; -- 25
		"Todas as opções de RetroArch serão reiniciadas"; -- 26
		"-Carregando-"; -- 27
		"Onde você quer criar o executable do jogo?"; -- 28
		"Diretório \"POPS\""; -- 29
		"Diretório \"APPS\""; -- 30
		"Configurar"; -- 31
		"Alternativa"; -- 32
		"Variante"; -- 33
		"Explorador"; -- 34
		"Selecione o dispositivo a ser examinado"; -- 35
		"Ember ou Bios/CUE"; -- 36
	};

	-- Menu de Realocação. ----------------------------------------------------------
	TEXT_M_REL = {
		"AVISO\nEste programa foi projetado para ser executado\na partir da primeira porta (USB) do PS2.\nReconecte o USB à primeira porta e\nreinicie o programa."; -- 1
		"AVISO\nDispositivo de armazenamento USB detectado na\nsegunda porta USB.\ndesconecte o dispositivo USB da segunda porta\ne reinicie o programa."; -- 2
		"O diretório atual não corresponde\nà sua configuração.\nDeseja realocar as configurações\npara este diretório?\nAVISO!\nAs opções de RetroArch serão reiniciadas"; -- 3
		"Realocar"; -- 4
		"Realocando"; -- 5
		"Realocando todas as configurações"; -- 6
	};

-------------------------------------------------------------------------------------
-- English. -------------------------------------------------------------------------
end
