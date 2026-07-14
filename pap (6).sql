-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 13-Mar-2026 às 00:20
-- Versão do servidor: 10.4.32-MariaDB
-- versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `pap`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_bilhetes`
--

CREATE TABLE `t_bilhetes` (
  `id_bilhete` int(11) NOT NULL,
  `id_evento` int(11) NOT NULL,
  `id_utilizador` int(11) DEFAULT NULL,
  `codigo_bilhete` varchar(50) NOT NULL,
  `numero_bilhete` varchar(20) NOT NULL,
  `nome_titular` varchar(200) NOT NULL,
  `email_titular` varchar(150) DEFAULT NULL,
  `telefone_titular` varchar(20) DEFAULT NULL,
  `tipo_bilhete` enum('normal','socio','estudante','crianca') NOT NULL DEFAULT 'normal',
  `setor` varchar(100) DEFAULT 'Geral',
  `fila` varchar(10) DEFAULT NULL,
  `lugar` varchar(10) DEFAULT NULL,
  `preco_pago` decimal(10,2) NOT NULL,
  `estado_bilhete` enum('reservado','vendido','validado','cancelado') NOT NULL DEFAULT 'reservado',
  `data_reserva` datetime DEFAULT NULL,
  `data_venda` datetime DEFAULT NULL,
  `data_validacao` datetime DEFAULT NULL,
  `metodo_pagamento` enum('multibanco','mbway','cartao','paypal','dinheiro') DEFAULT NULL,
  `referencia_pagamento` varchar(100) DEFAULT NULL,
  `observacoes` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `t_bilhetes`
--

INSERT INTO `t_bilhetes` (`id_bilhete`, `id_evento`, `id_utilizador`, `codigo_bilhete`, `numero_bilhete`, `nome_titular`, `email_titular`, `telefone_titular`, `tipo_bilhete`, `setor`, `fila`, `lugar`, `preco_pago`, `estado_bilhete`, `data_reserva`, `data_venda`, `data_validacao`, `metodo_pagamento`, `referencia_pagamento`, `observacoes`, `data_criacao`, `data_atualizacao`) VALUES
(7, 5, 18, 'SCRT1772444000304-0', 'B54006485', 'Francisco Rodrigues', 'fg654015@gmail.com', '912861704', 'normal', 'Geral', NULL, NULL, 10.00, 'vendido', '2026-03-02 09:33:20', '2026-03-02 09:33:20', NULL, 'cartao', NULL, NULL, '2026-03-02 09:33:20', '2026-03-02 09:33:20');

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_categoria`
--

CREATE TABLE `t_categoria` (
  `id_categoria` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `descricao` text DEFAULT NULL,
  `ativo` tinyint(1) DEFAULT 1,
  `imagem` varchar(255) DEFAULT NULL,
  `ordem` int(11) DEFAULT 0,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `t_categoria`
--

INSERT INTO `t_categoria` (`id_categoria`, `nome`, `descricao`, `ativo`, `imagem`, `ordem`, `data_criacao`, `data_atualizacao`) VALUES
(6, 'Camisolas', 'Camisolas oficiais do SC Rio Tinto', 1, 'images/Camisa.png', 1, '2025-12-14 15:44:34', '2025-12-14 15:54:23'),
(7, 'Acessórios', 'Boné Oficial do SC Rio Tinto', 1, 'images/Bone SCRT.png', 2, '2025-12-16 00:26:36', '2025-12-16 00:29:43'),
(8, 'Conjuntos', 'Conjuntos Oficiais do Sc Rio Tinto', 1, 'images/Fato-de-treino.jpg', 3, '2025-12-16 01:54:42', '2025-12-16 01:57:13'),
(9, 'Calcoes', 'Calcoes oficiais do SC Rio Tinto', 1, 'images/calcoes 25 26.png', 4, '2025-12-16 02:01:25', '2025-12-16 02:01:25');

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_encomendas`
--

CREATE TABLE `t_encomendas` (
  `id_encomenda` int(11) NOT NULL,
  `id_utilizador` int(11) NOT NULL,
  `data_encomenda` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `morada_envio` text NOT NULL,
  `metodo_pagamento` enum('multibanco','mbway','cartao','paypal') NOT NULL,
  `estado` enum('pendente','comprado','processando','enviado','entregue','cancelado') DEFAULT 'pendente',
  `valor_total` decimal(10,2) NOT NULL,
  `numero_encomenda` varchar(20) DEFAULT NULL,
  `codigo_rastreio` varchar(50) DEFAULT NULL,
  `observacoes` text DEFAULT NULL,
  `desconto` decimal(10,2) DEFAULT 0.00,
  `taxa_envio` decimal(10,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `t_encomendas`
--

INSERT INTO `t_encomendas` (`id_encomenda`, `id_utilizador`, `data_encomenda`, `data_atualizacao`, `morada_envio`, `metodo_pagamento`, `estado`, `valor_total`, `numero_encomenda`, `codigo_rastreio`, `observacoes`, `desconto`, `taxa_envio`) VALUES
(24, 17, '2026-03-02 09:00:51', '2026-03-02 09:06:23', 'rua dois 2', 'multibanco', 'comprado', 15.67, NULL, NULL, NULL, 0.00, 0.00),
(25, 17, '2026-03-02 09:24:46', '2026-03-02 09:24:54', 'rua pau pau', 'multibanco', 'comprado', 15.67, NULL, NULL, NULL, 0.00, 0.00),
(26, 17, '2026-03-12 23:04:43', '2026-03-12 23:04:50', 'Rua de guifas 123', 'mbway', 'comprado', 20.90, NULL, NULL, NULL, 0.00, 0.00);

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_equipas`
--

CREATE TABLE `t_equipas` (
  `id_equipa` int(11) NOT NULL,
  `nome_equipa` varchar(150) NOT NULL,
  `categoria` varchar(50) DEFAULT NULL,
  `temporada` varchar(20) NOT NULL,
  `data_criacao` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `t_equipas`
--

INSERT INTO `t_equipas` (`id_equipa`, `nome_equipa`, `categoria`, `temporada`, `data_criacao`) VALUES
(2, 'SC RIO TINTO U19', 'Juniores A', '2025/2026', '2025-10-18'),
(3, 'SC RIO TINTO', 'SENIORES A', '2025/2026', '2025-10-05'),
(4, 'SC RIO TINTO FEMININO U19', 'Juniores A', '2025/2026', '2025-08-27');

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_eventos`
--

CREATE TABLE `t_eventos` (
  `id_evento` int(11) NOT NULL,
  `id_equipa_casa` int(11) NOT NULL,
  `id_equipa_fora` int(11) DEFAULT NULL,
  `nome_evento` varchar(200) NOT NULL,
  `descricao` text DEFAULT NULL,
  `local_evento` varchar(200) DEFAULT 'Estádio SC Rio Tinto',
  `data_evento` datetime NOT NULL,
  `data_abertura_venda` datetime NOT NULL,
  `data_fecho_venda` datetime NOT NULL,
  `competicao` varchar(100) DEFAULT NULL,
  `jornada` varchar(50) DEFAULT NULL,
  `capacidade_total` int(11) DEFAULT 5000,
  `bilhetes_vendidos` int(11) DEFAULT 0,
  `preco_normal` decimal(10,2) DEFAULT 10.00,
  `preco_socio` decimal(10,2) DEFAULT 5.00,
  `preco_estudante` decimal(10,2) DEFAULT 7.00,
  `preco_crianca` decimal(10,2) DEFAULT 5.00,
  `estado_evento` enum('agendado','venda_aberta','esgotado','concluido','cancelado') DEFAULT 'agendado',
  `imagem_cartaz` varchar(255) DEFAULT NULL,
  `observacoes` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `t_eventos`
--

INSERT INTO `t_eventos` (`id_evento`, `id_equipa_casa`, `id_equipa_fora`, `nome_evento`, `descricao`, `local_evento`, `data_evento`, `data_abertura_venda`, `data_fecho_venda`, `competicao`, `jornada`, `capacidade_total`, `bilhetes_vendidos`, `preco_normal`, `preco_socio`, `preco_estudante`, `preco_crianca`, `estado_evento`, `imagem_cartaz`, `observacoes`, `data_criacao`, `data_atualizacao`) VALUES
(5, 2, NULL, 'SC Rio Tinto U19 Vs Perafita U19', NULL, 'Estádio SC Rio Tinto - Sintético', '2026-04-25 15:00:00', '2026-03-02 09:37:00', '2026-04-15 23:59:00', '2ª Divisão Campeonato Distrital', '1ª Jornada', 600, 1, 10.00, 5.00, 7.00, 5.00, 'venda_aberta', NULL, NULL, '2026-03-02 09:32:45', '2026-03-02 09:41:06');

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_fatura`
--

CREATE TABLE `t_fatura` (
  `id_fatura` int(11) NOT NULL,
  `id_utilizador` int(11) NOT NULL,
  `id_encomenda` int(11) DEFAULT NULL,
  `data_emissao` date NOT NULL,
  `data_pagamento` date DEFAULT NULL,
  `metodo_pagamento` enum('multibanco','mbway','cartao','paypal') DEFAULT NULL,
  `valor_subtotal` decimal(10,2) NOT NULL,
  `valor_iva` decimal(10,2) DEFAULT 0.00,
  `valor_desconto` decimal(10,2) DEFAULT 0.00,
  `observacoes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `t_fatura`
--

INSERT INTO `t_fatura` (`id_fatura`, `id_utilizador`, `id_encomenda`, `data_emissao`, `data_pagamento`, `metodo_pagamento`, `valor_subtotal`, `valor_iva`, `valor_desconto`, `observacoes`) VALUES
(24, 17, 24, '2026-03-02', NULL, 'multibanco', 12.74, 2.93, 0.00, NULL),
(25, 17, 25, '2026-03-02', NULL, 'multibanco', 12.74, 2.93, 0.00, NULL),
(26, 17, 26, '2026-03-12', NULL, 'mbway', 16.99, 3.91, 0.00, NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_itens_encomenda`
--

CREATE TABLE `t_itens_encomenda` (
  `id_item` int(11) NOT NULL,
  `id_encomenda` int(11) NOT NULL,
  `id_produto` int(11) NOT NULL,
  `quantidade` int(11) NOT NULL,
  `preco_unitario` decimal(10,2) NOT NULL,
  `preco_total` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `t_itens_encomenda`
--

INSERT INTO `t_itens_encomenda` (`id_item`, `id_encomenda`, `id_produto`, `quantidade`, `preco_unitario`, `preco_total`) VALUES
(17, 24, 3, 1, 12.74, 12.74),
(18, 25, 3, 1, 12.74, 12.74),
(19, 26, 2, 1, 16.99, 16.99);

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_jogadores`
--

CREATE TABLE `t_jogadores` (
  `id_jogador` int(11) NOT NULL,
  `id_equipa` int(11) NOT NULL,
  `primeiro_nome` varchar(100) NOT NULL,
  `ultimo_nome` varchar(100) NOT NULL,
  `numero_camisola` int(11) DEFAULT NULL,
  `posicao` varchar(50) DEFAULT NULL,
  `foto_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `t_jogadores`
--

INSERT INTO `t_jogadores` (`id_jogador`, `id_equipa`, `primeiro_nome`, `ultimo_nome`, `numero_camisola`, `posicao`, `foto_url`) VALUES
(3, 2, 'Gabriel', 'Castanheira', 10, 'Médio', 'images/Jogadores SUB19/gabriel.jpg\r\n'),
(4, 2, 'André', 'Ferreira', 1, 'Guarda-Redes', 'images/Jogadores SUB19/andre_ferreira.jpg'),
(5, 2, 'Rogério', 'Magalhães', 12, 'Guarda-Redes', 'images/Jogadores SUB19/rogerio_magalhaes.jpg'),
(6, 2, 'Guilherme', 'Araújo', 31, 'Guarda-Redes', 'images/Jogadores SUB19/guilherme_araujo.jpeg'),
(7, 2, 'Daniel', 'Silva', 2, 'Defesa', 'images/Jogadores SUB19/daniel_silva.jpg'),
(8, 2, 'Manuel', 'Madeira', 3, 'Defesa', 'images/Jogadores SUB19/manuel_madeira.jpeg'),
(9, 2, 'Gonçalo', 'Marques', 4, 'Defesa', 'images/Jogadores SUB19/goncalo_marques.jpg'),
(10, 2, 'Guilherme', 'Rodrigues', 5, 'Defesa', 'images/Jogadores SUB19/guilherme_rodrigues.jpeg'),
(11, 2, 'Dário', 'Oliveira', 6, 'Defesa', 'images/Jogadores SUB19/dario_oliveira.jpeg'),
(12, 2, 'Rafael', 'Pinheiro', 7, 'Defesa', 'images/Jogadores SUB19/rafael_pinheiro.jpg'),
(13, 2, 'Gustavo', 'Botelho', 8, 'Defesa', 'images/Jogadores SUB19/gustavo_botelho.jpg'),
(14, 2, 'Diogo', 'Pedroto', 13, 'Defesa', 'images/Jogadores SUB19/diogo_pedroto.jpg'),
(15, 2, 'Gustavo', 'Figueiredo', 14, 'Defesa', 'images/Jogadores SUB19/gustavo_figueiredo.jpg'),
(16, 2, 'Francisco', 'Viana', 15, 'Defesa', 'images/Jogadores SUB19/francisco_viana.jpg'),
(17, 2, 'Guilherme', 'Silva', 16, 'Defesa', 'images/Jogadores SUB19/guilherme_silva.jpg'),
(18, 2, 'Francisco', 'Lopes', 17, 'Defesa', 'images/Jogadores SUB19/francisco_lopes.jpg'),
(19, 2, 'Martim', 'Miranda', 9, 'Médio', 'images/Jogadores SUB19/martim_miranda.jpg'),
(20, 2, 'Henrique', 'Teixeira', 10, 'Médio', 'images/Jogadores SUB19/henrique_teixeira.jpeg'),
(21, 2, 'Leandro', 'Pinto', 11, 'Médio', 'images/Jogadores SUB19/leandro_pinto.jpg'),
(22, 2, 'Martim', 'Silva', 18, 'Médio', 'images/Jogadores SUB19/martim_silva.jpg'),
(23, 2, 'Daniel', 'Miguel', 19, 'Médio', 'images/Jogadores SUB19/daniel_miguel.jpeg'),
(24, 2, 'Martim', 'Ferreira', 20, 'Médio', 'images/Jogadores SUB19/martim_ferreira.png'),
(25, 2, 'Gonçalo', 'Miguel', 21, 'Médio', 'images/Jogadores SUB19/goncalo_miguel.jpg'),
(26, 2, 'Pedro', 'Lei', 22, 'Médio', 'images/Jogadores SUB19/pedro_lei.jpg'),
(27, 2, 'Gonçalo', 'Viana', 23, 'Avançado', 'images/Jogadores SUB19/careca.png'),
(28, 2, 'Leonardo', 'Silva', 24, 'Avançado', 'images/Jogadores SUB19/leonardo_silva.jpg'),
(29, 2, 'Martim', 'Bateira', 25, 'Avançado', 'images/Jogadores SUB19/martim_bateira.png'),
(30, 2, 'Rafael', 'Costa', 26, 'Avançado', 'images/Jogadores SUB19/rafael_costa.jpg'),
(31, 2, 'Ítalo', 'Zau', 27, 'Avançado', 'images/Jogadores SUB19/italo_zau.jpg'),
(32, 2, 'Toninho', '', 28, 'Avançado', 'images/Jogadores SUB19/toninho.jpg'),
(33, 2, 'Francisco', 'Rodrigues', 29, 'Avançado', 'images/Jogadores SUB19/francisco_rodrigues.jpg'),
(34, 3, 'Monstro', '', 1, 'Guarda-Redes', 'images/Seniores/monstro.jpg'),
(35, 3, 'Brandão', '', 41, 'Guarda-Redes', 'images/Seniores/brandao.jpg'),
(36, 3, 'Rúben', 'Teixeira', 17, 'Defesa', 'images/Seniores/ruben_teixeira.png'),
(37, 3, 'Fábio', '', 4, 'Defesa', 'images/Seniores/fabio.png'),
(38, 3, 'André', 'Pinto', 2, 'Defesa', 'images/Seniores/andre_pinto.png'),
(39, 3, 'Rui', 'da Costa', 30, 'Defesa', 'images/Seniores/rui_costa.jpg'),
(40, 3, 'Riley', 'Horne', 88, 'Defesa', 'images/Seniores/riley_horne.png'),
(41, 3, 'Carlos', 'Freitas', 26, 'Defesa', 'images/Seniores/carlos_freitas.jpg'),
(42, 3, 'João', 'Barge', 82, 'Defesa', 'images/Seniores/joao_barge.png'),
(43, 3, 'Rafael', 'Borges', 33, 'Defesa', 'images/Seniores/rafael_borges.png'),
(44, 3, 'Bruno', 'Moutinho', 27, 'Defesa', 'images/Seniores/bruno_moutinho.jpg'),
(45, 3, 'João', 'Ricardo', 15, 'Médio', 'images/Seniores/joao_ricardo.png'),
(46, 3, 'Lucas', 'Sousa', 22, 'Médio', 'images/Seniores/lucas_sousa.jpg'),
(47, 3, 'Afonso', 'Sá', 40, 'Médio', 'images/Seniores/afonso_sa.png'),
(48, 3, 'Filipe', 'Castro', 19, 'Médio', 'images/Seniores/filipe_castro.jpg'),
(49, 3, 'Gonçalo', 'Gomes', 16, 'Médio', 'images/Seniores/goncalo_gomes.jpg'),
(50, 3, 'Zé', 'Gomes', 28, 'Médio', 'images/Seniores/ze_gomes.jpg'),
(51, 3, 'Gui', '', 10, 'Avançado', 'images/Seniores/gui.png'),
(52, 3, 'Tiago', 'Pinto', 20, 'Avançado', 'images/Seniores/tiago_pinto.png'),
(53, 3, 'Jean', '', 7, 'Avançado', 'images/Seniores/jean.png'),
(54, 3, 'Gustavo', 'Almeida', 77, 'Avançado', 'images/Seniores/gustavo_almeida.jpg'),
(55, 3, 'Tomás', 'Gonçalves', 11, 'Avançado', 'images/Seniores/tomas_goncalves.png'),
(56, 3, 'Rui', 'Bizi', 69, 'Avançado', 'images/Seniores/nelsinho.png'),
(57, 3, 'Jardel', '', 9, 'Avançado', 'images/Seniores/jardel.png'),
(58, 4, 'Kika', '', 1, 'Guarda-Redes', 'images/Jogadoras Sub19/kika.jpg'),
(59, 4, 'Catarina', 'Fonseca', 12, 'Guarda-Redes', 'images/Jogadoras Sub19/catarina_fonseca.jpg'),
(60, 4, 'Carolina', 'Lourenço', 22, 'Guarda-Redes', 'images/Jogadoras Sub19/carolina_lourenco.jpg'),
(61, 4, 'Maria', 'Gomes', 2, 'Defesa', 'images/Jogadoras Sub19/maria_gomes.jpg'),
(62, 4, 'Diana', 'Oliveira', 3, 'Defesa', 'images/Jogadoras Sub19/diana_oliveira.jpg'),
(63, 4, 'Maria', 'Cunha', 4, 'Defesa', 'images/Jogadoras Sub19/maria_cunha.jpg'),
(64, 4, 'Sofia', 'Monteiro', 5, 'Defesa', 'images/Jogadoras Sub19/sofia_monteiro.jpg'),
(65, 4, 'Helena', 'Figueiredo', 6, 'Defesa', 'images/Jogadoras Sub19/helena_figueiredo.jpg'),
(66, 4, 'Cláudia', 'Cardoso', 13, 'Defesa', 'images/Jogadoras Sub19/claudia_cardoso.jpg'),
(67, 4, 'Beatriz', 'Rocha', 7, 'Média', 'images/Jogadoras Sub19/beatriz_rocha.jpg'),
(68, 4, 'Carolina', 'Castro', 8, 'Média', 'images/Jogadoras Sub19/carolina_castro.jpg'),
(69, 4, 'Gabriela', 'Machado', 10, 'Média', 'images/Jogadoras Sub19/gabriela_machado.jpg'),
(70, 4, 'Helena', 'Samões', 14, 'Média', 'images/Jogadoras Sub19/helena_samoes.jpg'),
(71, 4, 'Joana', 'Silva', 15, 'Média', 'images/Jogadoras Sub19/joana_silva.jpg'),
(72, 4, 'Maria', 'Lobo', 16, 'Média', 'images/Jogadoras Sub19/maria_lobo.jpg'),
(73, 4, 'Maria', 'Miranda', 17, 'Média', 'images/Jogadoras Sub19/maria_miranda.jpg'),
(74, 4, 'Leonor', 'Godinho', 9, 'Avançada', 'images/Jogadoras Sub19/leonor_godinho.jpg'),
(75, 4, 'Leonor', 'Granja', 11, 'Avançada', 'images/Jogadoras Sub19/leonor_granja.jpg'),
(76, 4, 'Leonor', 'Pinho', 18, 'Avançada', 'images/Jogadoras Sub19/leonor_pinho.jpg'),
(77, 4, 'Leonor', 'Teixeira', 19, 'Avançada', 'images/Jogadoras Sub19/leonor_teixeira.jpg'),
(78, 4, 'Madalena', 'Leite', 20, 'Avançada', 'images/Jogadoras Sub19/madalena_leite.jpg'),
(79, 4, 'Maria', 'Silva', 21, 'Avançada', 'images/Jogadoras Sub19/maria_silva.jpg'),
(80, 4, 'Mariana', 'Alves', 23, 'Avançada', 'images/Jogadoras Sub19/mariana_alves.jpg'),
(81, 4, 'Mariana', 'Gonçalves', 24, 'Avançada', 'images/Jogadoras Sub19/mariana_goncalves.jpg'),
(82, 4, 'Mariana', 'Henriques', 25, 'Avançada', 'images/Jogadoras Sub19/mariana_henriques.jpg'),
(83, 4, 'Rute', 'Fernandes', 26, 'Avançada', 'images/Jogadoras Sub19/rute_fernandes.jpg'),
(84, 4, 'Sandra', 'Gil', 27, 'Avançada', 'images/Jogadoras Sub19/sandra_gil.jpg'),
(85, 4, 'Sofia', 'Monteiro', 28, 'Avançada', 'images/Jogadoras Sub19/sofia_monteiro.jpg');

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_noticias_formacao`
--

CREATE TABLE `t_noticias_formacao` (
  `id_noticia` int(11) NOT NULL,
  `titulo` varchar(250) NOT NULL,
  `categoria` enum('sub11','sub13','sub15','sub17','sub19','geral') NOT NULL DEFAULT 'geral',
  `resumo` text DEFAULT NULL,
  `conteudo` text NOT NULL,
  `imagem_url` varchar(255) DEFAULT NULL,
  `icone` varchar(50) DEFAULT 'fas fa-newspaper',
  `destaque` tinyint(1) DEFAULT 0,
  `autor` varchar(150) DEFAULT NULL,
  `visualizacoes` int(11) DEFAULT 0,
  `ativo` tinyint(1) DEFAULT 1,
  `data_publicacao` datetime NOT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `t_noticias_formacao`
--

INSERT INTO `t_noticias_formacao` (`id_noticia`, `titulo`, `categoria`, `resumo`, `conteudo`, `imagem_url`, `icone`, `destaque`, `autor`, `visualizacoes`, `ativo`, `data_publicacao`, `data_criacao`, `data_atualizacao`) VALUES
(1, 'Sub-17 conquista título regional com exibição brilhante', 'sub17', 'A equipa de Sub-17 do SC Rio Tinto sagrou-se campeã regional após uma época fantástica, demonstrando todo o trabalho de formação desenvolvido pelo clube.', '<p>A equipa de Sub-17 do SC Rio Tinto sagrou-se campeã regional após uma época verdadeiramente fantástica, demonstrando todo o trabalho de formação desenvolvido pelo clube ao longo dos anos.</p><p>Com uma vitória esmagadora por 4-1 na grande final disputada no Estádio Municipal, os nossos jovens talentos mostraram qualidade técnica impressionante, mentalidade vencedora e um espírito de equipa exemplar que conquistou todos os presentes.</p><p>O treinador da equipa, Ricardo Silva, mostrou-se extremamente orgulhoso: \"Este título é o resultado de muito trabalho, dedicação e paixão pelo clube. Os miúdos mostraram uma evolução incrível ao longo da época e merecem todas as felicitações.\"</p><p>Durante a temporada, a equipa manteve uma média impressionante de 3,2 golos por jogo, com uma defesa sólida que sofreu apenas 12 golos em 26 partidas. Destaque para o avançado Miguel Santos, que terminou como melhor marcador da competição com 28 golos.</p><p>Este sucesso reforça a importância da formação no SC Rio Tinto e promete um futuro brilhante para o clube. Parabéns a todos os envolvidos! 💛🖤</p>', 'images/foto sub17.png', 'fas fa-trophy', 1, 'SC Rio Tinto', 0, 1, '2025-12-20 10:00:00', '2025-12-28 12:00:00', '2025-12-28 01:14:03'),
(2, 'Sub-11 vence torneio de Natal com grande desempenho', 'sub11', 'Os mais jovens do clube mostraram todo o seu talento no torneio de Natal, conquistando o primeiro lugar com jogadas impressionantes e espírito de equipa exemplar.', '<p>Os mais jovens do SC Rio Tinto deram um verdadeiro espetáculo no tradicional Torneio de Natal, conquistando o primeiro lugar com jogadas impressionantes e um espírito de equipa que encheu de orgulho todos os presentes.</p><p>Durante três dias intensos de competição, a equipa Sub-11 enfrentou adversários de todo o distrito, mostrando não apenas qualidade técnica, mas também fair-play e dedicação em cada partida.</p><p>A final foi disputada contra o FC Maia, terminando com uma vitória por 3-2 num jogo emocionante que manteve todos na bancada em suspense até ao último minuto. O golo da vitória foi marcado aos 58 minutos por João Costa, numa jogada ensaiada que demonstrou o excelente trabalho tático da equipa.</p><p>\"Ver estes miúdos a crescer e a desenvolver-se é uma alegria imensa. O torneio de Natal é sempre especial, e este ano conseguimos dar uma excelente prenda aos nossos adeptos\", afirmou o treinador Paulo Mendes.</p><p>Parabéns aos nossos campeões! Este é apenas o começo de uma jornada brilhante nas cores amarelo e preto! 🏆</p>', 'images/foto sub11.png', 'fas fa-futbol', 0, 'SC Rio Tinto', 0, 1, '2025-12-28 09:00:00', '2025-12-28 12:00:00', '2025-12-28 01:16:23'),
(4, 'Sub-15 goleia rival histórico por 5-0 em jogo emocionante', 'sub15', 'Em partida válida pelo campeonato regional, a equipa Sub-15 mostrou superioridade técnica e táctica, goleando o rival por 5-0 num jogo memorável.', '<p>Em partida válida pela 15ª jornada do campeonato regional Sub-15, o SC Rio Tinto apresentou uma exibição de gala ao golear o rival histórico FC Ermesinde por impressionantes 5-0, num jogo que ficará na memória de todos os presentes.</p><p>Desde o apito inicial, os nossos jovens talentos impuseram um ritmo intenso, dominando a posse de bola e criando inúmeras oportunidades de golo. O primeiro golo surgiu logo aos 8 minutos, por intermédio de Rafael Costa, que aproveitou um cruzamento perfeito de Bernardo Silva.</p><p>A equipa não se contentou com a vantagem e continuou a pressionar, marcando mais dois golos antes do intervalo através de Miguel Ferreira (23\') e novamente Rafael Costa (41\'), que bisou neste jogo memorável.</p><p>Na segunda parte, a superioridade manteve-se evidente. Pedro Alves (55\') e Gonçalo Ribeiro (68\') completaram a goleada, selando uma tarde perfeita para o SC Rio Tinto.</p><p>\"Foi uma exibição completa da equipa. Mostrámos organização táctica, qualidade técnica e mentalidade vencedora. Estou muito orgulhoso destes jovens\", declarou o treinador António Pereira no final da partida.</p><p>Com este resultado, a equipa Sub-15 consolida o segundo lugar na tabela classificativa. Força Rio Tinto! 💛🖤</p>', 'images/foto sub15.png', 'fas fa-star', 0, 'SC Rio Tinto', 0, 1, '2025-12-24 16:00:00', '2025-12-28 12:00:00', '2025-12-28 01:17:29'),
(5, 'Jovem promessa da Sub-19 assina pelo plantel sénior', 'sub19', 'O talentoso médio dos Sub-19 impressionou a equipa técnica e assinou contrato profissional, sendo promovido ao plantel principal do clube.', '<p>O SC Rio Tinto tem o orgulho de anunciar a promoção de Gonçalo Viana, jovem médio formado no clube, ao plantel principal. Aos 18 anos, o jogador assina contrato profissional após um percurso marcado por trabalho, resiliência e superação.</p>\r\n\r\n<p>Crescido no bairro, Gonçalo nunca teve o caminho facilitado. Entre treinos, estudos e sacrifícios diários, construiu o seu percurso com humildade e dedicação, tornando-se uma referência dentro e fora de campo na equipa Sub-19. Nesta temporada, destacou-se pelas suas exibições consistentes, liderança natural e compromisso com o jogo coletivo.</p>\r\n\r\n<p>As suas prestações não passaram despercebidas à equipa técnica, que reconheceu no jovem médio não só qualidade técnica e visão de jogo, mas também caráter, maturidade e mentalidade competitiva — valores essenciais para o futebol sénior.</p>\r\n\r\n<p>“O Gonçalo é o exemplo perfeito do que acreditamos no clube. Um miúdo do bairro, trabalhador, com fome de vencer e uma atitude irrepreensível. Ganhou esta oportunidade com mérito próprio”, sublinhou o treinador principal.</p>\r\n\r\n<p>Visivelmente emocionado, Gonçalo Viana reagiu à promoção: “Nada disto foi fácil. Venho de onde muitos duvidam que seja possível chegar aqui. Representar o SC Rio Tinto no plantel principal é um orgulho enorme e a prova de que o trabalho compensa. Isto é só o começo.”</p>\r\n\r\n<p>A subida de Gonçalo reforça o compromisso do SC Rio Tinto com a formação e com a valorização de talentos que crescem com os valores do clube, mostrando que, com esforço e dedicação, é possível transformar sonhos em realidade.</p>\r\n', 'images/foto goncalo10.png', 'fas fa-trophy', 0, 'SC Rio Tinto', 0, 1, '2025-12-22 11:00:00', '2025-12-28 12:00:00', '2025-12-28 18:40:10');

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_produtos`
--

CREATE TABLE `t_produtos` (
  `id_produto` int(11) NOT NULL,
  `id_categoria` int(11) DEFAULT NULL,
  `nome_produto` varchar(200) NOT NULL,
  `descricao` text DEFAULT NULL,
  `preco` decimal(10,2) NOT NULL,
  `stock` int(11) DEFAULT 0,
  `temporada` varchar(20) DEFAULT NULL,
  `imagem_principal` varchar(255) DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `t_produtos`
--

INSERT INTO `t_produtos` (`id_produto`, `id_categoria`, `nome_produto`, `descricao`, `preco`, `stock`, `temporada`, `imagem_principal`, `data_criacao`, `data_atualizacao`) VALUES
(1, 6, 'Camisola Oficial 25/26', 'Camisola do SC Rio Tinto, confortável e leve, ideal para jogos e treinos. Design simples que representa a identidade e o orgulho do clube. Perfeita para atletas e adeptos.', 25.00, -1, '2025/2026', 'images/camisola 25 26.png', '2025-12-14 16:39:06', '2025-12-28 20:58:30'),
(2, 7, 'Boné 25/26', 'Inspirado na tradição e na identidade do Rio Tinto, este chapéu combina estilo e conforto em uma peça versátil para o dia a dia. Confeccionado com material resistente e acabamento de qualidade, ele oferece proteção contra o sol sem abrir mão da elegância. Ideal para uso casual, eventos ao ar livre ou para quem valoriza um visual autêntico, o Chapéu Rio Tinto é perfeito para complementar qualquer look com personalidade e atitude.', 19.99, 6, '2025/2026', 'images/Bone SCRT.png', '2025-12-16 00:30:15', '2026-03-12 23:04:43'),
(3, 7, 'Cachecol 25/26', 'Cachecol oficial do SC Rio Tinto, desenvolvido com materiais de qualidade e acabamento cuidado. Apresenta um tamanho equilibrado — nem muito grande nem muito pequeno — garantindo conforto, praticidade e facilidade de uso. Ideal para apoiar a equipa nos jogos ou para usar no dia a dia, demonstrando o orgulho pelo clube.', 14.99, 6, '2025/2026', 'images/cachecol.png', '2025-12-16 01:33:28', '2026-03-02 09:24:47'),
(4, 8, 'Fato de Treino 25/26', 'O fato de treino oficial do Sport Clube Rio Tinto, desenvolvido para oferecer conforto, desempenho e identidade dentro e fora do campo. Composto por casaco amarelo e calças pretas, este conjunto alia um design moderno à tradição do clube.\r\n\r\nO casaco apresenta um corte atlético, fecho integral e o emblema do Sport Clube Rio Tinto aplicado no peito, acompanhado do logótipo Nike, refletindo uma parceria de excelência. As calças pretas garantem liberdade de movimentos e incluem o símbolo do clube na perna, mantendo um visual elegante e funcional.', 55.00, 10, '2025/2026', 'images/Fato-de-treino.png', '2025-12-16 01:56:05', '2025-12-16 02:04:03'),
(5, 9, 'Calcões Oficiais 25/26', 'Os calções oficiais do Sport Clube Rio Tinto foram desenvolvidos para acompanhar a camisola do clube, garantindo desempenho, conforto e um visual profissional em campo.\r\n\r\nCom um design moderno em preto, estes calções apresentam um corte atlético que proporciona total liberdade de movimentos. O emblema do Sport Clube Rio Tinto surge aplicado numa das pernas, enquanto o logótipo Nike reforça a qualidade e o caráter oficial do equipamento.', 15.99, 10, '2025/2026', 'images/calcoes 25 26.png', '2025-12-16 02:02:08', '2025-12-16 02:03:26');

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_sobre`
--

CREATE TABLE `t_sobre` (
  `id_sobre` int(11) NOT NULL,
  `secao` varchar(50) NOT NULL,
  `tipo` varchar(50) DEFAULT NULL,
  `titulo` varchar(255) DEFAULT NULL,
  `subtitulo` varchar(255) DEFAULT NULL,
  `descricao` text DEFAULT NULL,
  `valor` varchar(100) DEFAULT NULL,
  `icone` varchar(50) DEFAULT NULL,
  `ano` varchar(20) DEFAULT NULL,
  `ordem` int(11) DEFAULT 0,
  `ativo` tinyint(1) DEFAULT 1,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `t_sobre`
--

INSERT INTO `t_sobre` (`id_sobre`, `secao`, `tipo`, `titulo`, `subtitulo`, `descricao`, `valor`, `icone`, `ano`, `ordem`, `ativo`, `data_criacao`) VALUES
(1, 'hero', 'badge', '🏆 Desde 1923', NULL, NULL, NULL, NULL, NULL, 1, 1, '2025-12-28 18:52:57'),
(2, 'hero', 'titulo', 'Sobre o Rio Tinto', NULL, NULL, NULL, NULL, NULL, 2, 1, '2025-12-28 18:52:57'),
(3, 'hero', 'descricao', NULL, NULL, 'Mais de 100 anos de história, tradição e paixão no coração de Gondomar. Descobre a nossa jornada épica! ⚽', NULL, NULL, NULL, 3, 1, '2025-12-28 18:52:57'),
(4, 'timeline', 'evento', 'A Fundação Gloriosa', NULL, 'Em 1 de Julho de 1923, um grupo visionário de Riotintenses, incluindo Serafim Pinto Morgado, João de Sousa Nogueira, Custódio Campos Moura, António Lopes Júnior e António José de Almeida (Finguilo), uniram forças para criar algo extraordinário - o Sport Clube Rio Tinto nascia para eternidade!', NULL, NULL, '1923', 1, 1, '2025-12-28 18:52:57'),
(5, 'timeline', 'evento', 'Os Primeiros Passos', NULL, 'A década de 30 marcou os primeiros grandes momentos do clube, estabelecendo as bases sólidas que sustentariam gerações de triunfos. As cores amarelo e preto começavam a ganhar respeito e admiração em toda a região do Grande Porto.', NULL, NULL, '1930s', 2, 1, '2025-12-28 18:52:57'),
(6, 'timeline', 'evento', 'Era de Crescimento', NULL, 'Os anos 50 trouxeram uma nova dinâmica ao clube, com investimentos na formação e infraestruturas que posicionaram o Rio Tinto como uma referência no futebol distrital, cultivando talentos que levariam o nome do clube muito além das fronteiras de Gondomar.', NULL, NULL, '1950s', 3, 1, '2025-12-28 18:52:57'),
(7, 'timeline', 'evento', 'Modernização', NULL, 'A década de 80 representou um marco na modernização do clube, com a implementação de novas metodologias de treino, melhoria das condições de jogo e uma visão mais profissional que elevou significativamente o nível competitivo da equipa.', NULL, NULL, '1980s', 4, 1, '2025-12-28 18:52:57'),
(8, 'timeline', 'evento', 'Novo Milénio, Novos Sonhos', NULL, 'O século XXI trouxe renovadas ambições e projetos inovadores. O clube expandiu as suas atividades, criou equipas femininas e de formação, estabelecendo-se como um pilar fundamental na comunidade riotintense.', NULL, NULL, '2000s', 5, 1, '2025-12-28 18:52:57'),
(9, 'timeline', 'evento', 'Centenário Glorioso', NULL, 'Celebramos 100 anos de história gloriosa! Um século de emoções, conquistas, lágrimas de alegria e orgulho imenso. O Rio Tinto não é apenas um clube - é uma instituição que moldou gerações e continuará a fazê-lo por muitos séculos.', NULL, NULL, '2023', 6, 1, '2025-12-28 18:52:57'),
(10, 'estatistica', 'numero', 'Anos de História', NULL, NULL, '100+', NULL, NULL, 1, 1, '2025-12-28 18:52:57'),
(11, 'estatistica', 'numero', 'Títulos Conquistados', NULL, NULL, '50+', NULL, NULL, 2, 1, '2025-12-28 18:52:57'),
(12, 'estatistica', 'numero', 'Jogadores Formados', NULL, NULL, '1000+', NULL, NULL, 3, 1, '2025-12-28 18:52:57'),
(13, 'estatistica', 'numero', 'Equipas Ativas', NULL, NULL, '15', NULL, NULL, 4, 1, '2025-12-28 18:52:57'),
(14, 'estatistica', 'numero', 'Sócios Fiéis', NULL, NULL, '5000+', NULL, NULL, 5, 1, '2025-12-28 18:52:57'),
(15, 'estatistica', 'numero', 'Paixão e Orgulho', NULL, NULL, '∞', NULL, NULL, 6, 1, '2025-12-28 18:52:57'),
(16, 'conquista', 'trofeu', 'Campeonatos Distritais', 'Múltiplas Conquistas', NULL, NULL, '🏆', NULL, 1, 1, '2025-12-28 18:52:57'),
(17, 'conquista', 'trofeu', 'Taças Distritais', 'Várias Edições', NULL, NULL, '🥇', NULL, 2, 1, '2025-12-28 18:52:57'),
(18, 'conquista', 'trofeu', 'Campeonatos de Formação', 'Sucessos Continuados', NULL, NULL, '⚽', NULL, 3, 1, '2025-12-28 18:52:57'),
(19, 'conquista', 'trofeu', 'Prémios Fair-Play', 'Reconhecimento Múltiplo', NULL, NULL, '🎖️', NULL, 4, 1, '2025-12-28 18:52:57'),
(20, 'conquista', 'trofeu', 'Troféu Centenário', '2023', NULL, NULL, '🌟', NULL, 5, 1, '2025-12-28 18:52:57'),
(21, 'conquista', 'trofeu', 'Clube do Coração', 'Desde Sempre', NULL, NULL, '👨‍👩‍👧‍👦', NULL, 6, 1, '2025-12-28 18:52:57'),
(22, 'estadio', 'info', 'Nome', NULL, NULL, 'Estádio Cidade de Rio Tinto', NULL, NULL, 1, 1, '2025-12-28 18:52:57'),
(23, 'estadio', 'info', 'Inauguração', NULL, NULL, 'Anos 80', NULL, NULL, 2, 1, '2025-12-28 18:52:57'),
(24, 'estadio', 'info', 'Capacidade', NULL, NULL, '3.000 Lugares', NULL, NULL, 3, 1, '2025-12-28 18:52:57'),
(25, 'estadio', 'info', 'Recorde Assistência', NULL, NULL, 'Casa Sempre Cheia', NULL, NULL, 4, 1, '2025-12-28 18:52:57'),
(26, 'estadio', 'info', 'Alcunha', NULL, NULL, 'A Fortaleza Amarela', NULL, NULL, 5, 1, '2025-12-28 18:52:57'),
(27, 'estadio', 'descricao', 'O Nosso Santuário', NULL, 'O Estádio Cidade de Rio Tinto é muito mais do que um simples recinto desportivo. É o coração pulsante do nosso clube, onde cada jogo se transforma numa festa de emoções puras. As quatro bancadas vibram com os cânticos dos nossos adeptos, criando uma atmosfera única e inigualável que faz deste estádio um dos mais temidos pelos adversários em todo o distrito do Porto.', NULL, NULL, NULL, 1, 1, '2025-12-28 18:52:57'),
(28, 'estadio', 'descricao', 'Momentos Memoráveis', NULL, 'Aqui, cada vitória ecoa pelas arquibancadas como um rugido de leão, cada golo é celebrado como se fosse o primeiro e cada momento vivido fica gravado para sempre na memória de todos os que têm o privilégio de pisar este solo sagrado. O Estádio Cidade de Rio Tinto não é apenas onde jogamos - é onde vivemos os nossos sonhos mais dourados.', NULL, NULL, NULL, 2, 1, '2025-12-28 18:52:57'),
(29, 'estadio', 'melhoria', 'Iluminação LED', NULL, 'Sistema moderno para jogos noturnos espetaculares', NULL, '💡', NULL, 1, 1, '2025-12-28 18:52:57'),
(30, 'estadio', 'melhoria', 'Relvado Premium', NULL, 'Manutenção constante para condições ideais', NULL, '🌱', NULL, 2, 1, '2025-12-28 18:52:57'),
(31, 'estadio', 'melhoria', 'Conectividade', NULL, 'Wi-Fi gratuito para todos os adeptos', NULL, '📶', NULL, 3, 1, '2025-12-28 18:52:57'),
(32, 'cultura', 'intro', 'Mais do que Futebol', NULL, 'O Sport Clube Rio Tinto transcende o desporto. Somos uma família unida por laços que vão muito além do campo de jogo. Aqui, cada vitória é celebrada em conjunto, cada derrota é partilhada com solidariedade, e cada momento é vivido com a intensidade que só o amor verdadeiro pelo clube pode proporcionar.', NULL, NULL, NULL, 1, 1, '2025-12-28 18:52:57'),
(33, 'cultura', 'intro', 'Cores Sagradas', NULL, 'As nossas cores amarelo e preto não são apenas uma combinação cromática - são símbolos de força, determinação e elegância que representam o espírito indomável dos riotintenses. Quando vestimos estas cores, carregamos connosco o peso glorioso de mais de um século de história e tradição.', NULL, NULL, NULL, 2, 1, '2025-12-28 18:52:57'),
(34, 'cultura', 'valor', 'Respeito', NULL, 'Por adversários, árbitros, adeptos e pela história do futebol. O fair-play é uma marca registada do nosso clube.', NULL, NULL, NULL, 1, 1, '2025-12-28 18:52:57'),
(35, 'cultura', 'valor', 'Solidariedade', NULL, 'Apoiamos a nossa comunidade através de iniciativas sociais e programas de inclusão que chegam a todas as famílias de Rio Tinto.', NULL, NULL, NULL, 2, 1, '2025-12-28 18:52:57'),
(36, 'cultura', 'valor', 'Excelência', NULL, 'Procuramos sempre dar o nosso melhor, dentro e fora de campo, formando não apenas atletas, mas cidadãos exemplares.', NULL, NULL, NULL, 3, 1, '2025-12-28 18:52:57'),
(37, 'cultura', 'valor', 'Tradição', NULL, 'Honramos o passado enquanto construímos o futuro, mantendo viva a chama que os fundadores acenderam em 1923.', NULL, NULL, NULL, 4, 1, '2025-12-28 18:52:57'),
(38, 'cultura', 'tradicao', 'Os Fiéis', NULL, 'Cada jogo em casa é uma celebração única. Os nossos adeptos, conhecidos como \"Os Fiéis\", criam uma atmosfera mágica que intimida adversários e inspira a nossa equipa. O hino do clube, cantado com fervor antes de cada partida, ecoa pelos corações de todos os presentes.', NULL, NULL, NULL, 1, 1, '2025-12-28 18:52:57'),
(39, 'cultura', 'tradicao', 'Formação de Jovens', NULL, 'A formação de jovens talentos é uma das nossas maiores orgulhos. Desde os petizes até aos juniores, cada jovem que entra na nossa academia não aprende apenas futebol - aprende os valores da vida, o significado da dedicação e o orgulho de representar uma instituição centenária.', NULL, NULL, NULL, 2, 1, '2025-12-28 18:52:57'),
(40, 'cultura', 'tradicao', 'Espírito Riotintense', NULL, 'Ser riotintense é carregar no peito uma paixão que se transmite de pais para filhos, de avós para netos. É acordar no domingo de jogo com um brilho especial nos olhos, é sentir o coração acelerar quando se ouve o apito inicial, é chorar de alegria com cada golo marcado.', NULL, NULL, NULL, 3, 1, '2025-12-28 18:52:57'),
(41, 'cultura', 'tradicao', 'Coração de Rio Tinto', NULL, 'O nosso clube é o coração pulsante de Rio Tinto, um ponto de encontro onde se criam amizades eternas, onde se celebram os momentos mais felizes da vida e onde se encontra apoio nos momentos mais difíceis. Somos muito mais que um clube - somos uma família de milhares de corações que batem em unissão.', NULL, NULL, NULL, 4, 1, '2025-12-28 18:52:57');

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_socio`
--

CREATE TABLE `t_socio` (
  `id_socio` int(11) NOT NULL,
  `id_utilizador` int(11) DEFAULT NULL,
  `numero_socio` varchar(50) NOT NULL,
  `telemovel` varchar(9) NOT NULL,
  `cartao_de_cidadao` varchar(9) NOT NULL,
  `quota_anual` decimal(10,2) NOT NULL DEFAULT 20.00,
  `data_inscricao` date NOT NULL DEFAULT curdate(),
  `data_nascimento` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `t_socio`
--

INSERT INTO `t_socio` (`id_socio`, `id_utilizador`, `numero_socio`, `telemovel`, `cartao_de_cidadao`, `quota_anual`, `data_inscricao`, `data_nascimento`) VALUES
(19, 17, '2925', '912671891', '123456789', 20.00, '2026-02-25', '2007-11-23');

--
-- Acionadores `t_socio`
--
DELIMITER $$
CREATE TRIGGER `trg_numero_socio` BEFORE INSERT ON `t_socio` FOR EACH ROW BEGIN
    IF NEW.numero_socio IS NULL OR NEW.numero_socio = '' THEN
        SET NEW.numero_socio = LPAD(FLOOR(1 + RAND() * 999999), 6, '0');
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_treinadores`
--

CREATE TABLE `t_treinadores` (
  `id_treinador` int(11) NOT NULL,
  `id_equipa` int(11) DEFAULT NULL,
  `primeiro_nome` varchar(100) NOT NULL,
  `ultimo_nome` varchar(100) NOT NULL,
  `data_nascimento` date DEFAULT NULL,
  `nacionalidade` varchar(50) DEFAULT NULL,
  `nivel_treinador` enum('UEFA C','UEFA B','UEFA A','UEFA Pro','Estagiário','Outro') DEFAULT 'Estagiário',
  `telefone` varchar(20) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `foto_url` varchar(255) DEFAULT NULL,
  `data_contratacao` date DEFAULT NULL,
  `salario` decimal(10,2) DEFAULT NULL,
  `ativo` tinyint(1) DEFAULT 1,
  `observacoes` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `t_treinadores`
--

INSERT INTO `t_treinadores` (`id_treinador`, `id_equipa`, `primeiro_nome`, `ultimo_nome`, `data_nascimento`, `nacionalidade`, `nivel_treinador`, `telefone`, `email`, `foto_url`, `data_contratacao`, `salario`, `ativo`, `observacoes`, `data_criacao`, `data_atualizacao`) VALUES
(1, 2, 'Rodrigo', 'Pereira', '1997-11-13', 'Portugal', 'UEFA B', '912671891', 'rodrigopereira@gmail.com', 'images/Jogadores SUB19/mister.jpg', '2024-09-12', 20.00, 1, '', '2025-12-14 13:36:09', '2025-12-16 00:02:49'),
(2, 3, 'Vasco', 'Oliveira', '1982-07-07', 'Portuguesa', 'UEFA B', '911861172', 'vascooliveira@gmail.com', 'images/Seniores/vasco_oliveira.jpg', '2026-07-07', 300.00, 1, NULL, '2026-03-02 09:45:37', '2026-03-02 09:50:07');

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_utilizadores`
--

CREATE TABLE `t_utilizadores` (
  `id_utilizador` int(11) NOT NULL,
  `primeiro_nome` varchar(100) NOT NULL,
  `ultimo_nome` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `email_verificado` tinyint(1) DEFAULT 0,
  `codigo_verificacao` varchar(255) DEFAULT NULL,
  `data_codigo_verificacao` datetime DEFAULT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `tipo_utilizador` enum('admin','adepto','socio') NOT NULL,
  `palavra_passe` varchar(255) NOT NULL,
  `data_nascimento` date DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizacao` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `codigo_recuperacao` varchar(10) DEFAULT NULL,
  `data_codigo_recuperacao` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Extraindo dados da tabela `t_utilizadores`
--

INSERT INTO `t_utilizadores` (`id_utilizador`, `primeiro_nome`, `ultimo_nome`, `email`, `email_verificado`, `codigo_verificacao`, `data_codigo_verificacao`, `telefone`, `tipo_utilizador`, `palavra_passe`, `data_nascimento`, `data_criacao`, `data_atualizacao`, `codigo_recuperacao`, `data_codigo_recuperacao`) VALUES
(18, 'Francisco', 'Rodrigues', 'fg654015@gmail.com', 1, NULL, NULL, '912861704', 'admin', '$2a$12$XCCfqyQY4utFRIN2ijFd9uSw4Lp.IEZBqkCXwQMKh0Z9jXmH2G5sS', '2007-11-23', '2026-02-25 09:26:04', '2026-02-25 09:29:27', NULL, NULL),
(20, 'Francisco', 'Rodrigues', 'scrxll7765@gmail.com', 1, NULL, NULL, '912378198', 'adepto', '$2a$12$Na8Ewkq1xycJEQ3A0SBNJO1Fma9IbFwiIAzoOaQmsKRthUstvEgb.', '0007-11-23', '2026-03-12 23:13:46', '2026-03-12 23:18:24', NULL, NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `t_vendas_bilhetes`
--

CREATE TABLE `t_vendas_bilhetes` (
  `id_venda` int(11) NOT NULL,
  `id_utilizador` int(11) DEFAULT NULL,
  `numero_venda` varchar(50) NOT NULL,
  `data_venda` datetime NOT NULL,
  `quantidade_bilhetes` int(11) DEFAULT 1,
  `valor_total` decimal(10,2) NOT NULL,
  `metodo_pagamento` enum('multibanco','mbway','cartao','paypal','dinheiro') NOT NULL,
  `estado_pagamento` enum('pendente','pago','falhado','reembolsado') DEFAULT 'pendente',
  `email_envio` varchar(150) DEFAULT NULL,
  `observacoes` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `t_vendas_bilhetes`
--

INSERT INTO `t_vendas_bilhetes` (`id_venda`, `id_utilizador`, `numero_venda`, `data_venda`, `quantidade_bilhetes`, `valor_total`, `metodo_pagamento`, `estado_pagamento`, `email_envio`, `observacoes`, `data_criacao`) VALUES
(7, 18, 'VB1772444000289', '2026-03-02 09:33:20', 1, 10.00, 'cartao', 'pago', 'fg654015@gmail.com', NULL, '2026-03-02 09:33:20');

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `t_bilhetes`
--
ALTER TABLE `t_bilhetes`
  ADD PRIMARY KEY (`id_bilhete`);

--
-- Índices para tabela `t_categoria`
--
ALTER TABLE `t_categoria`
  ADD PRIMARY KEY (`id_categoria`);

--
-- Índices para tabela `t_encomendas`
--
ALTER TABLE `t_encomendas`
  ADD PRIMARY KEY (`id_encomenda`);

--
-- Índices para tabela `t_equipas`
--
ALTER TABLE `t_equipas`
  ADD PRIMARY KEY (`id_equipa`);

--
-- Índices para tabela `t_eventos`
--
ALTER TABLE `t_eventos`
  ADD PRIMARY KEY (`id_evento`);

--
-- Índices para tabela `t_fatura`
--
ALTER TABLE `t_fatura`
  ADD PRIMARY KEY (`id_fatura`);

--
-- Índices para tabela `t_itens_encomenda`
--
ALTER TABLE `t_itens_encomenda`
  ADD PRIMARY KEY (`id_item`);

--
-- Índices para tabela `t_jogadores`
--
ALTER TABLE `t_jogadores`
  ADD PRIMARY KEY (`id_jogador`);

--
-- Índices para tabela `t_noticias_formacao`
--
ALTER TABLE `t_noticias_formacao`
  ADD PRIMARY KEY (`id_noticia`);

--
-- Índices para tabela `t_produtos`
--
ALTER TABLE `t_produtos`
  ADD PRIMARY KEY (`id_produto`);

--
-- Índices para tabela `t_sobre`
--
ALTER TABLE `t_sobre`
  ADD PRIMARY KEY (`id_sobre`);

--
-- Índices para tabela `t_socio`
--
ALTER TABLE `t_socio`
  ADD PRIMARY KEY (`id_socio`);

--
-- Índices para tabela `t_treinadores`
--
ALTER TABLE `t_treinadores`
  ADD PRIMARY KEY (`id_treinador`);

--
-- Índices para tabela `t_utilizadores`
--
ALTER TABLE `t_utilizadores`
  ADD PRIMARY KEY (`id_utilizador`);

--
-- Índices para tabela `t_vendas_bilhetes`
--
ALTER TABLE `t_vendas_bilhetes`
  ADD PRIMARY KEY (`id_venda`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `t_bilhetes`
--
ALTER TABLE `t_bilhetes`
  MODIFY `id_bilhete` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de tabela `t_categoria`
--
ALTER TABLE `t_categoria`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de tabela `t_encomendas`
--
ALTER TABLE `t_encomendas`
  MODIFY `id_encomenda` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT de tabela `t_equipas`
--
ALTER TABLE `t_equipas`
  MODIFY `id_equipa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `t_eventos`
--
ALTER TABLE `t_eventos`
  MODIFY `id_evento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de tabela `t_fatura`
--
ALTER TABLE `t_fatura`
  MODIFY `id_fatura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT de tabela `t_itens_encomenda`
--
ALTER TABLE `t_itens_encomenda`
  MODIFY `id_item` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de tabela `t_jogadores`
--
ALTER TABLE `t_jogadores`
  MODIFY `id_jogador` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=87;

--
-- AUTO_INCREMENT de tabela `t_noticias_formacao`
--
ALTER TABLE `t_noticias_formacao`
  MODIFY `id_noticia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de tabela `t_produtos`
--
ALTER TABLE `t_produtos`
  MODIFY `id_produto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de tabela `t_sobre`
--
ALTER TABLE `t_sobre`
  MODIFY `id_sobre` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT de tabela `t_socio`
--
ALTER TABLE `t_socio`
  MODIFY `id_socio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de tabela `t_treinadores`
--
ALTER TABLE `t_treinadores`
  MODIFY `id_treinador` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `t_utilizadores`
--
ALTER TABLE `t_utilizadores`
  MODIFY `id_utilizador` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de tabela `t_vendas_bilhetes`
--
ALTER TABLE `t_vendas_bilhetes`
  MODIFY `id_venda` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
