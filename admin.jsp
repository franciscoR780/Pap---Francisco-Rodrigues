<%-- 
    Document   : admin.jsp
    Created on : 11/12/2025, 14:21:10
    Author     : Aluno
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // VERIFICAÇÃO DE AUTENTICAÇÃO UNIFICADA
    // Primeiro, verificar se o utilizador vem do site principal e já é admin
    Integer idUtilizador = (Integer) session.getAttribute("id_utilizador");
    Boolean isAdmin = (Boolean) session.getAttribute("is_admin");
    String primeiroNome = (String) session.getAttribute("primeiro_nome");
    String ultimoNome = (String) session.getAttribute("ultimo_nome");
    
    // Se o utilizador está logado no site E é admin, criar sessão admin automaticamente
    if (idUtilizador != null && isAdmin != null && isAdmin) {
        // Utilizador autenticado como admin via site - fazer bypass do login
        session.setAttribute("admin_logado", true);
        if (primeiroNome != null && ultimoNome != null) {
            session.setAttribute("admin_username", primeiroNome + " " + ultimoNome);
        } else {
            session.setAttribute("admin_username", "Admin");
        }
    }
    
    // Agora verificar se tem sessão admin ativa (seja do site ou do login admin)
    Boolean adminLogado = (Boolean) session.getAttribute("admin_logado");
    if (adminLogado == null || !adminLogado) {
        // Não está autenticado - redirecionar para login admin
        session.setAttribute("redirect_after_login", "admin.jsp");
        response.sendRedirect("login_admin.jsp");
        return;
    }
    
    // Se chegou aqui, está autenticado como admin
    String adminUsername = (String) session.getAttribute("admin_username");
    if (adminUsername == null) {
        adminUsername = "Admin";
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SC Rio Tinto - Painel Admin</title>
    <link href="css/CssAdmin.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
  
    <%
        // Buscar dados reais da base de dados
        int totalEquipas = 0;
        int totalJogadores = 0;
        int totalTreinadores = 0;
        int totalSocios = 0;
        int totalUtilizadores = 0;
        int totalCategorias = 0;
        int totalProdutos = 0;
        int totalFaturas = 0;
        int totalEncomendas = 0;
        int totalItensEncomenda = 0;
        int totalEventos = 0;
        int totalBilhetes = 0;
        int totalVendasBilhetes = 0;
        int totalNoticias = 0;
        
        String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
        String username = "root";
        String password = "";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, username, password);
            
            // Contar equipas
            Statement stmtEquipas = conn.createStatement();
            ResultSet rsEquipas = stmtEquipas.executeQuery("SELECT COUNT(*) as total FROM t_equipas");
            if (rsEquipas.next()) {
                totalEquipas = rsEquipas.getInt("total");
            }
            rsEquipas.close();
            stmtEquipas.close();
            
            // Contar jogadores
            Statement stmtJogadores = conn.createStatement();
            ResultSet rsJogadores = stmtJogadores.executeQuery("SELECT COUNT(*) as total FROM t_jogadores");
            if (rsJogadores.next()) {
                totalJogadores = rsJogadores.getInt("total");
            }
            rsJogadores.close();
            stmtJogadores.close();
            
            // Contar treinadores
            Statement stmtTreinadores = conn.createStatement();
            ResultSet rsTreinadores = stmtTreinadores.executeQuery("SELECT COUNT(*) as total FROM t_treinadores");
            if (rsTreinadores.next()) {
                totalTreinadores = rsTreinadores.getInt("total");
            }
            rsTreinadores.close();
            stmtTreinadores.close();
            
            // Contar sócios
            Statement stmtSocios = conn.createStatement();
            ResultSet rsSocios = stmtSocios.executeQuery("SELECT COUNT(*) as total FROM t_socio");
            if (rsSocios.next()) {
                totalSocios = rsSocios.getInt("total");
            }
            rsSocios.close();
            stmtSocios.close();
            
            // Contar utilizadores
            Statement stmtUtilizadores = conn.createStatement();
            ResultSet rsUtilizadores = stmtUtilizadores.executeQuery("SELECT COUNT(*) as total FROM t_utilizadores");
            if (rsUtilizadores.next()) {
                totalUtilizadores = rsUtilizadores.getInt("total");
            }
            rsUtilizadores.close();
            stmtUtilizadores.close();
            
            // Contar produtos
            Statement stmtProdutos = conn.createStatement();
            ResultSet rsProdutos = stmtProdutos.executeQuery("SELECT COUNT(*) as total FROM t_produtos");
            if (rsProdutos.next()) {
                totalProdutos = rsProdutos.getInt("total");
            }
            rsProdutos.close();
            stmtProdutos.close();
            
            // Contar categorias
            Statement stmtCategorias = conn.createStatement();
            ResultSet rsCategorias = stmtCategorias.executeQuery("SELECT COUNT(*) as total FROM t_categoria");
            if (rsCategorias.next()) {
                totalCategorias = rsCategorias.getInt("total");
            }
            rsCategorias.close();
            stmtCategorias.close();
            
            // Contar faturas
            Statement stmtFaturas = conn.createStatement();
            ResultSet rsFaturas = stmtFaturas.executeQuery("SELECT COUNT(*) as total FROM t_fatura");
            if (rsFaturas.next()) {
                totalFaturas = rsFaturas.getInt("total");
            }
            rsFaturas.close();
            stmtFaturas.close();
            
            // Contar encomendas
            Statement stmtEncomendas = conn.createStatement();
            ResultSet rsEncomendas = stmtEncomendas.executeQuery("SELECT COUNT(*) as total FROM t_encomendas");
            if (rsEncomendas.next()) {
                totalEncomendas = rsEncomendas.getInt("total");
            }
            rsEncomendas.close();
            stmtEncomendas.close();
            
            // Contar itens de encomenda
            Statement stmtItens = conn.createStatement();
            ResultSet rsItens = stmtItens.executeQuery("SELECT COUNT(*) as total FROM t_itens_encomenda");
            if (rsItens.next()) {
                totalItensEncomenda = rsItens.getInt("total");
            }
            rsItens.close();
            stmtItens.close();
            
            // Contar eventos
            Statement stmtEventos = conn.createStatement();
            ResultSet rsEventos = stmtEventos.executeQuery("SELECT COUNT(*) as total FROM t_eventos");
            if (rsEventos.next()) {
                totalEventos = rsEventos.getInt("total");
            }
            rsEventos.close();
            stmtEventos.close();
            
            // Contar bilhetes
            Statement stmtBilhetes = conn.createStatement();
            ResultSet rsBilhetes = stmtBilhetes.executeQuery("SELECT COUNT(*) as total FROM t_bilhetes");
            if (rsBilhetes.next()) {
                totalBilhetes = rsBilhetes.getInt("total");
            }
            rsBilhetes.close();
            stmtBilhetes.close();
            
            // Contar vendas de bilhetes
            Statement stmtVendas = conn.createStatement();
            ResultSet rsVendas = stmtVendas.executeQuery("SELECT COUNT(*) as total FROM t_vendas_bilhetes");
            if (rsVendas.next()) {
                totalVendasBilhetes = rsVendas.getInt("total");
            }
            rsVendas.close();
            stmtVendas.close();
            
            // Contar notícias
            Statement stmtNoticias = conn.createStatement();
            ResultSet rsNoticias = stmtNoticias.executeQuery("SELECT COUNT(*) as total FROM t_noticias_formacao");
            if (rsNoticias.next()) {
                totalNoticias = rsNoticias.getInt("total");
            }
            rsNoticias.close();
            stmtNoticias.close();
            
            conn.close();
        } catch (Exception e) {
            out.println("<!-- Erro ao carregar dados: " + e.getMessage() + " -->");
        }
    %>
</head>
<body>
    <!-- MENU TOGGLE MOBILE -->
    <button class="menu-toggle" onclick="toggleSidebar()">
        <i class="fas fa-bars"></i>
    </button>

    <!-- SIDEBAR -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <div class="sidebar-title">SC Rio Tinto</div>
            <div class="sidebar-subtitle">Painel de Administração</div>
        </div>
        <ul class="sidebar-menu">
            <li>
                <a href="#" class="menu-item active" data-section="dashboard" onclick="showSection('dashboard')">
                    <i class="fas fa-chart-line"></i> Dashboard
                </a>
            </li>
            <li>
                <a href="#" class="menu-item" data-section="categorias" onclick="showSection('categorias')">
                    <i class="fas fa-tags"></i> Categorias
                </a>
            </li>
            <li>
                <a href="#" class="menu-item" data-section="equipas" onclick="showSection('equipas')">
                    <i class="fas fa-users-cog"></i> Equipas
                </a>
            </li>
            <li>
                <a href="#" class="menu-item" data-section="jogadores" onclick="showSection('jogadores')">
                    <i class="fas fa-running"></i> Jogadores
                </a>
            </li>
            <li>
                <a href="#" class="menu-item" data-section="treinadores" onclick="showSection('treinadores')">
                    <i class="fas fa-clipboard-list"></i> Treinadores
                </a>
            </li>
            <li>
                <a href="#" class="menu-item" data-section="socios" onclick="showSection('socios')">
                    <i class="fas fa-id-card"></i> Sócios
                </a>
            </li>
            <li>
                <a href="#" class="menu-item" data-section="utilizadores" onclick="showSection('utilizadores')">
                    <i class="fas fa-user-shield"></i> Utilizadores
                </a>
            </li>
            <li>
                <a href="#" class="menu-item" data-section="produtos" onclick="showSection('produtos')">
                    <i class="fas fa-box"></i> Produtos
                </a>
            </li>
            <li>
                <a href="#" class="menu-item" data-section="encomendas" onclick="showSection('encomendas')">
                    <i class="fas fa-shopping-cart"></i> Encomendas
                </a>
            </li>
            <li>
                <a href="#" class="menu-item" data-section="itens" onclick="showSection('itens')">
                    <i class="fas fa-list-ul"></i> Itens Encomenda
                </a>
            </li>
            <li>
                <a href="#" class="menu-item" data-section="faturas" onclick="showSection('faturas')">
                    <i class="fas fa-file-invoice-dollar"></i> Faturas
                </a>
            </li>
            <li>
                <a href="#" class="menu-item" data-section="eventos" onclick="showSection('eventos')">
                    <i class="fas fa-calendar-alt"></i> Eventos
                </a>
            </li>
            <li>
                <a href="#" class="menu-item" data-section="bilhetes" onclick="showSection('bilhetes')">
                    <i class="fas fa-ticket-alt"></i> Bilhetes
                </a>
            </li>
            <li>
                <a href="#" class="menu-item" data-section="vendas" onclick="showSection('vendas')">
                    <i class="fas fa-cash-register"></i> Vendas Bilhetes
                </a>
            </li>
            <li>
                <a href="#" class="menu-item" data-section="noticias" onclick="showSection('noticias')">
                    <i class="fas fa-newspaper"></i> Notícias
                </a>
            </li>
        </ul>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <div class="header">
            <h1 id="page-title">Dashboard</h1>
            <div class="user-info">
                <span style="font-weight: 600;"><%= adminUsername %></span>
                <div class="user-avatar"><%= adminUsername.substring(0,1).toUpperCase() %></div>
                <button class="btn btn-logout" onclick="logout()">
                    <i class="fas fa-sign-out-alt"></i> Sair
                </button>
            </div>
        </div>

        <!-- DASHBOARD SECTION -->
        <div class="content-section active" id="dashboard-section">
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon">
                            <i class="fas fa-users-cog"></i>
                        </div>
                    </div>
                    <div class="stat-value"><%= totalEquipas %></div>
                    <div class="stat-label">Equipas Registadas</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon">
                            <i class="fas fa-running"></i>
                        </div>
                    </div>
                    <div class="stat-value"><%= totalJogadores %></div>
                    <div class="stat-label">Jogadores Ativos</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon">
                            <i class="fas fa-clipboard-list"></i>
                        </div>
                    </div>
                    <div class="stat-value"><%= totalTreinadores %></div>
                    <div class="stat-label">Treinadores</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon">
                            <i class="fas fa-id-card"></i>
                        </div>
                    </div>
                    <div class="stat-value"><%= totalSocios %></div>
                    <div class="stat-label">Sócios Registados</div>
                </div>
                  
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon">
                            <i class="fas fa-box"></i>
                        </div>
                    </div>
                    <div class="stat-value"><%= totalProdutos %></div>
                    <div class="stat-label">Produtos</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon">
                            <i class="fas fa-shopping-cart"></i>
                        </div>
                    </div>
                    <div class="stat-value"><%= totalEncomendas %></div>
                    <div class="stat-label">Encomendas</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon">
                            <i class="fas fa-calendar-alt"></i>
                        </div>
                    </div>
                    <div class="stat-value"><%= totalEventos %></div>
                    <div class="stat-label">Eventos</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon">
                            <i class="fas fa-ticket-alt"></i>
                        </div>
                    </div>
                    <div class="stat-value"><%= totalBilhetes %></div>
                    <div class="stat-label">Bilhetes</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon">
                            <i class="fas fa-newspaper"></i>
                        </div>
                    </div>
                    <div class="stat-value"><%= totalNoticias %></div>
                    <div class="stat-label">Notícias</div>
                </div>
            </div>

            <div class="info-box">
                <h3>
                    <i class="fas fa-chart-bar"></i> 
                    Visão Geral do Sistema
                </h3>
                <p>
                    Bem-vindo ao painel de administração do SC Rio Tinto. 
                    Utilize o menu lateral para navegar entre as diferentes áreas de gestão do clube.
                </p>
                
                <div class="info-stats">
                    <div class="info-stat-item">
                        <div class="label">Categorias</div>
                        <div class="value"><%= totalCategorias %></div>
                    </div>
                    <div class="info-stat-item">
                        <div class="label">Utilizadores</div>
                        <div class="value"><%= totalUtilizadores %></div>
                    </div>
                    <div class="info-stat-item">
                        <div class="label">Total Membros</div>
                        <div class="value"><%= totalJogadores + totalTreinadores %></div>
                    </div>
                    <div class="info-stat-item">
                        <div class="label">Eventos</div>
                        <div class="value"><%= totalEventos %></div>
                    </div>
                    <div class="info-stat-item">
                        <div class="label">Bilhetes</div>
                        <div class="value"><%= totalBilhetes %></div>
                    </div>
                    <div class="info-stat-item">
                        <div class="label">Vendas Bilhetes</div>
                        <div class="value"><%= totalVendasBilhetes %></div>
                    </div>
                    <div class="info-stat-item">
                        <div class="label">Notícias</div>
                        <div class="value"><%= totalNoticias %></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- CATEGORIAS SECTION -->
        <div class="content-section" id="categorias-section">
            <div class="section-header">
                <h2 class="section-title">Gestão de Categorias</h2>
            </div>
            
            <div class="management-grid">
                <div class="management-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-tags"></i>
                        </div>
                        <div class="card-title">Categorias (<%= totalCategorias %>)</div>
                    </div>
                    <div class="card-body">
                        <div class="card-actions">
                            <a href="InserirCat.jsp" class="btn">
                                <i class="fas fa-plus"></i> Inserir Categoria
                            </a>
                            <a href="ListarCat.jsp" class="btn">
                                <i class="fas fa-list"></i> Listar Categorias
                            </a>
                            <a href="GerirCat.jsp" class="btn">
                                <i class="fas fa-cog"></i> Gerir Categorias
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
            
        <!-- EQUIPAS SECTION -->
        <div class="content-section" id="equipas-section">
            <div class="section-header">
                <h2 class="section-title">Gestão de Equipas</h2>
            </div>

            <div class="management-grid">
                <div class="management-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-users-cog"></i>
                        </div>
                        <div class="card-title">Equipas (<%= totalEquipas %>)</div>
                    </div>
                    <div class="card-body">
                        <div class="card-actions">
                            <a href="InserirEquipas.jsp" class="btn">
                                <i class="fas fa-plus"></i> Inserir Equipa
                            </a>
                            <a href="ListarEquipas.jsp" class="btn">
                                <i class="fas fa-list"></i> Listar Equipas
                            </a>
                            <a href="GerirEquipas.jsp" class="btn">
                                <i class="fas fa-cog"></i> Gerir Equipas
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- JOGADORES SECTION -->
        <div class="content-section" id="jogadores-section">
            <div class="section-header">
                <h2 class="section-title">Gestão de Jogadores</h2>
            </div>
            
            <div class="management-grid">
                <div class="management-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-running"></i>
                        </div>
                        <div class="card-title">Jogadores (<%= totalJogadores %>)</div>
                    </div>
                    <div class="card-body">
                        <div class="card-actions">
                            <a href="InserirJogadores.jsp" class="btn">
                                <i class="fas fa-plus"></i> Inserir Jogador
                            </a>
                            <a href="ListarJogadores.jsp" class="btn">
                                <i class="fas fa-list"></i> Listar Jogadores
                            </a>
                            <a href="GerirJogadores.jsp" class="btn">
                                <i class="fas fa-cog"></i> Gerir Jogadores
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- TREINADORES SECTION -->
        <div class="content-section" id="treinadores-section">
            <div class="section-header">
                <h2 class="section-title">Gestão de Treinadores</h2>
            </div>
            
            <div class="management-grid">
                <div class="management-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-clipboard-list"></i>
                        </div>
                        <div class="card-title">Treinadores (<%= totalTreinadores %>)</div>
                    </div>
                    <div class="card-body">
                        <div class="card-actions">
                            <a href="InserirTreinadores.jsp" class="btn">
                                <i class="fas fa-plus"></i> Inserir Treinador
                            </a>
                            <a href="ListarTreinadores.jsp" class="btn">
                                <i class="fas fa-list"></i> Listar Treinadores
                            </a>
                            <a href="GerirTreinadores.jsp" class="btn">
                                <i class="fas fa-cog"></i> Gerir Treinadores
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- SÓCIOS SECTION -->
        <div class="content-section" id="socios-section">
            <div class="section-header">
                <h2 class="section-title">Gestão de Sócios</h2>
            </div>
            
            <div class="management-grid">
                <div class="management-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-id-card"></i>
                        </div>
                        <div class="card-title">Sócios (<%= totalSocios %>)</div>
                    </div>
                    <div class="card-body">
                        <div class="card-actions">
                            <a href="InserirSocios.jsp" class="btn">
                                <i class="fas fa-plus"></i> Inserir Sócio
                            </a>
                            <a href="ListarSocios.jsp" class="btn">
                                <i class="fas fa-list"></i> Listar Sócios
                            </a>
                            <a href="GerirSocio.jsp" class="btn">
                                <i class="fas fa-cog"></i> Gerir Sócios
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- UTILIZADORES SECTION -->
        <div class="content-section" id="utilizadores-section">
            <div class="section-header">
                <h2 class="section-title">Gestão de Utilizadores</h2>
            </div>
            
            <div class="management-grid">
                <div class="management-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-user-shield"></i>
                        </div>
                        <div class="card-title">Utilizadores (<%= totalUtilizadores %>)</div>
                    </div>
                    <div class="card-body">
                        <div class="card-actions">
                            <a href="InserirUtilizadores.jsp" class="btn">
                                <i class="fas fa-plus"></i> Inserir Utilizador
                            </a>
                            <a href="ListarUtilizadores.jsp" class="btn">
                                <i class="fas fa-list"></i> Listar Utilizadores
                            </a>
                            <a href="GerirUtilizadores.jsp" class="btn">
                                <i class="fas fa-cog"></i> Gerir Utilizadores
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- PRODUTOS SECTION -->
        <div class="content-section" id="produtos-section">
            <div class="section-header">
                <h2 class="section-title">Gestão de Produtos</h2>
            </div>
            
            <div class="management-grid">
                <div class="management-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-box"></i>
                        </div>
                        <div class="card-title">Produtos (<%= totalProdutos %>)</div>
                    </div>
                    <div class="card-body">
                        <div class="card-actions">
                            <a href="InserirProdutos.jsp" class="btn">
                                <i class="fas fa-plus"></i> Inserir Produto
                            </a>
                            <a href="ListarProdutos.jsp" class="btn">
                                <i class="fas fa-list"></i> Listar Produtos
                            </a>
                            <a href="GerirProdutos.jsp" class="btn">
                                <i class="fas fa-cog"></i> Gerir Produtos
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ENCOMENDAS SECTION -->
        <div class="content-section" id="encomendas-section">
            <div class="section-header">
                <h2 class="section-title">Gestão de Encomendas</h2>
            </div>
            
            <div class="management-grid">
                <div class="management-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-shopping-cart"></i>
                        </div>
                        <div class="card-title">Encomendas (<%= totalEncomendas %>)</div>
                    </div>
                    <div class="card-body">
                        <div class="card-actions">
                            <a href="InserirEncomendas.jsp" class="btn">
                                <i class="fas fa-plus"></i> Inserir Encomenda
                            </a>
                            <a href="ListarEncomendas.jsp" class="btn">
                                <i class="fas fa-list"></i> Listar Encomendas
                            </a>
                            <a href="GerirEncomendas.jsp" class="btn">
                                <i class="fas fa-cog"></i> Gerir Encomendas
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ITENS ENCOMENDA SECTION -->
        <div class="content-section" id="itens-section">
            <div class="section-header">
                <h2 class="section-title">Gestão de Itens de Encomenda</h2>
            </div>
            
            <div class="management-grid">
                <div class="management-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-list-ul"></i>
                        </div>
                        <div class="card-title">Itens de Encomenda (<%= totalItensEncomenda %>)</div>
                    </div>
                    <div class="card-body">
                        <div class="card-actions">
                            <a href="InserirItensEncomenda.jsp" class="btn">
                                <i class="fas fa-plus"></i> Inserir Item
                            </a>
                            <a href="ListarItensEncomenda.jsp" class="btn">
                                <i class="fas fa-list"></i> Listar Itens
                            </a>
                            <a href="GerirItensEncomenda.jsp" class="btn">
                                <i class="fas fa-cog"></i> Gerir Itens
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- FATURAS SECTION -->
        <div class="content-section" id="faturas-section">
            <div class="section-header">
                <h2 class="section-title">Gestão de Faturas</h2>
            </div>
            
            <div class="management-grid">
                <div class="management-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-file-invoice-dollar"></i>
                        </div>
                        <div class="card-title">Faturas (<%= totalFaturas %>)</div>
                    </div>
                    <div class="card-body">
                        <div class="card-actions">
                            <a href="InserirFaturas.jsp" class="btn">
                                <i class="fas fa-plus"></i> Inserir Fatura
                            </a>
                            <a href="ListarFaturas.jsp" class="btn">
                                <i class="fas fa-list"></i> Listar Faturas
                            </a>
                            <a href="GerirFaturas.jsp" class="btn">
                                <i class="fas fa-cog"></i> Gerir Faturas
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- EVENTOS SECTION -->
        <div class="content-section" id="eventos-section">
            <div class="section-header">
                <h2 class="section-title">Gestão de Eventos</h2>
            </div>
            
            <div class="management-grid">
                <div class="management-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-calendar-alt"></i>
                        </div>
                        <div class="card-title">Eventos (<%= totalEventos %>)</div>
                    </div>
                    <div class="card-body">
                        <div class="card-actions">
                            <a href="InserirEventos.jsp" class="btn">
                                <i class="fas fa-plus"></i> Inserir Evento
                            </a>
                            <a href="ListarEventos.jsp" class="btn">
                                <i class="fas fa-list"></i> Listar Eventos
                            </a>
                            <a href="GerirEventos.jsp" class="btn">
                                <i class="fas fa-cog"></i> Gerir Eventos
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- BILHETES SECTION -->
        <div class="content-section" id="bilhetes-section">
            <div class="section-header">
                <h2 class="section-title">Gestão de Bilhetes</h2>
            </div>
            
            <div class="management-grid">
                <div class="management-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-ticket-alt"></i>
                        </div>
                        <div class="card-title">Bilhetes (<%= totalBilhetes %>)</div>
                    </div>
                    <div class="card-body">
                        <div class="card-actions">
                            <a href="InserirBilhetes.jsp" class="btn">
                                <i class="fas fa-plus"></i> Inserir Bilhete
                            </a>
                            <a href="ListarBilhetes.jsp" class="btn">
                                <i class="fas fa-list"></i> Listar Bilhetes
                            </a>
                            <a href="GerirBilhetes.jsp" class="btn">
                                <i class="fas fa-cog"></i> Gerir Bilhetes
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- VENDAS BILHETES SECTION -->
        <div class="content-section" id="vendas-section">
            <div class="section-header">
                <h2 class="section-title">Gestão de Vendas de Bilhetes</h2>
            </div>
            
            <div class="management-grid">
                <div class="management-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-cash-register"></i>
                        </div>
                        <div class="card-title">Vendas de Bilhetes (<%= totalVendasBilhetes %>)</div>
                    </div>
                    <div class="card-body">
                        <div class="card-actions">
                            <a href="InserirVendasBilhetes.jsp" class="btn">
                                <i class="fas fa-plus"></i> Inserir Venda
                            </a>
                            <a href="ListarVendasBilhetes.jsp" class="btn">
                                <i class="fas fa-list"></i> Listar Vendas
                            </a>
                            <a href="GerirVendasBilhetes.jsp" class="btn">
                                <i class="fas fa-cog"></i> Gerir Vendas
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- NOTÍCIAS SECTION -->
        <div class="content-section" id="noticias-section">
            <div class="section-header">
                <h2 class="section-title">Gestão de Notícias</h2>
            </div>
            
            <div class="management-grid">
                <div class="management-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-newspaper"></i>
                        </div>
                        <div class="card-title">Notícias (<%= totalNoticias %>)</div>
                    </div>
                    <div class="card-body">
                        <div class="card-actions">
                            <a href="InserirNoticias.jsp" class="btn">
                                <i class="fas fa-plus"></i> Inserir Notícia
                            </a>
                            <a href="ListarNoticias.jsp" class="btn">
                                <i class="fas fa-list"></i> Listar Notícias
                            </a>
                            <a href="GerirNoticias.jsp" class="btn">
                                <i class="fas fa-cog"></i> Gerir Notícias
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function showSection(sectionName) {
            // Esconder todas as seções
            const sections = document.querySelectorAll('.content-section');
            sections.forEach(section => section.classList.remove('active'));
            
            // Mostrar seção selecionada
            document.getElementById(sectionName + '-section').classList.add('active');
            
            // Atualizar menu ativo
            const menuItems = document.querySelectorAll('.menu-item');
            menuItems.forEach(item => item.classList.remove('active'));
            event.target.closest('.menu-item').classList.add('active');
            
            // Atualizar título
            const titles = {
                'dashboard': 'Dashboard',
                'categorias': 'Gestão de Categorias',
                'equipas': 'Gestão de Equipas',
                'jogadores': 'Gestão de Jogadores',
                'treinadores': 'Gestão de Treinadores',
                'socios': 'Gestão de Sócios',
                'utilizadores': 'Gestão de Utilizadores',
                'produtos': 'Gestão de Produtos',
                'encomendas': 'Gestão de Encomendas',
                'itens': 'Gestão de Itens de Encomenda',
                'faturas': 'Gestão de Faturas',
                'eventos': 'Gestão de Eventos',
                'bilhetes': 'Gestão de Bilhetes',
                'vendas': 'Gestão de Vendas de Bilhetes',
                'noticias': 'Gestão de Notícias'
            };
            document.getElementById('page-title').textContent = titles[sectionName];
            
            // Fechar sidebar no mobile
            if (window.innerWidth <= 768) {
                document.getElementById('sidebar').classList.remove('active');
            }
        }
        
        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('active');
        }
        
        function logout() {
            if (confirm('Tem certeza que deseja sair?')) {
                window.location.href = 'logout_admin.jsp';
            }
        }
        
        // Fechar sidebar ao clicar fora (mobile)
        document.addEventListener('click', function(event) {
            const sidebar = document.getElementById('sidebar');
            const toggle = document.querySelector('.menu-toggle');
            
            if (window.innerWidth <= 768 && 
                !sidebar.contains(event.target) && 
                !toggle.contains(event.target) &&
                sidebar.classList.contains('active')) {
                sidebar.classList.remove('active');
            }
        });
    </script>
</body>
</html>