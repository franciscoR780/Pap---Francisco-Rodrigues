<%--   
    Document   : Jogadores
    Created on : 10/12/2025, 14:18:38
    Author     : Aluno
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // Verificar se o utilizador está logado
    Integer idUtilizador = (Integer) session.getAttribute("id_utilizador");
    String primeiroNome = (String) session.getAttribute("primeiro_nome");
    String ultimoNome = (String) session.getAttribute("ultimo_nome");
    String emailUtilizador = (String) session.getAttribute("email");
    Boolean isAdmin = (Boolean) session.getAttribute("is_admin");
    
    if (isAdmin == null) {
        isAdmin = false;
    }
    
    boolean estaLogado = (idUtilizador != null);
    
    // Verificar se o utilizador já é sócio
    boolean jaSocio = false;
    String numeroSocio = null;
    String dataSocio = null;
    
    if (estaLogado) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            String dbURL = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String dbUser = "root";
            String dbPass = "";
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
            
            String sql = "SELECT numero_socio, data_inscricao FROM t_socio WHERE id_utilizador = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idUtilizador);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                jaSocio = true;
                numeroSocio = rs.getString("numero_socio");
                dataSocio = rs.getString("data_inscricao");
            }
            
        } catch (Exception e) {
            out.println("<!-- Erro ao verificar sócio: " + e.getMessage() + " -->");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
%>

<%!
    private int getLinha(String posicao) {
        if (posicao == null) return 5;
        String pos = posicao.toLowerCase().trim();
        if (pos.contains("guarda") || pos.equals("gr")) return 1;
        else if (pos.contains("defesa") || pos.equals("dc") || pos.equals("dd") || pos.equals("de") || pos.equals("ld") || pos.equals("le")) return 2;
        else if (pos.contains("médio") || pos.contains("medio") || pos.contains("média") || pos.contains("media") || pos.equals("mc") || pos.equals("mo") || pos.equals("md") || pos.equals("me") || pos.equals("moc")) return 3;
        else if (pos.contains("avançado") || pos.contains("avancado") || pos.contains("avançada") || pos.contains("avancada") || pos.equals("pl") || pos.equals("pe") || pos.equals("pd") || pos.equals("ext") || pos.equals("ed") || pos.equals("ee")) return 4;
        return 5;
    }
    
    private String getAbreviacao(String posicao) {
        if (posicao == null) return "SUB";
        String pos = posicao.toLowerCase().trim();
        if (pos.contains("guarda")) return "GR";
        if (pos.contains("defesa")) return "DEF";
        if (pos.contains("médio") || pos.contains("medio") || pos.contains("média") || pos.contains("media")) return "MED";
        if (pos.contains("avançado") || pos.contains("avancado") || pos.contains("avançada") || pos.contains("avancada")) return "ATA";
        return posicao.length() > 3 ? posicao.substring(0, 3).toUpperCase() : posicao.toUpperCase();
    }

    // FUNÇÃO CORRIGIDA - USA O CAMINHO EXATO DA BASE DE DADOS
    private String encodePath(String path) {
        // Se for null, retorna SVG default
        if (path == null || path.trim().isEmpty() || path.equals("null")) {
            return "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'%3E%3Cdefs%3E%3ClinearGradient id='g' x1='0%25' y1='0%25' x2='100%25' y2='100%25'%3E%3Cstop offset='0%25' style='stop-color:%23FFD700'/%3E%3Cstop offset='50%25' style='stop-color:%23FFA500'/%3E%3Cstop offset='100%25' style='stop-color:%23FFD700'/%3E%3C/linearGradient%3E%3C/defs%3E%3Ccircle cx='100' cy='100' r='100' fill='url(%23g)'/%3E%3Ctext x='100' y='130' text-anchor='middle' fill='%23000' font-size='100' font-weight='900' font-family='Rajdhani, Arial, sans-serif'%3E%3F%3C/text%3E%3C/svg%3E";
        }
        
        // USA O CAMINHO EXATAMENTE COMO VEM DA BASE DE DADOS
        // Apenas converte espaços para %20 para funcionar no URL
        return path.replace(" ", "%20");
    }
%>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SC Rio Tinto - Plantel da Equipa</title>
    <link href="css/CssJogadores.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@300;400;500;600;700;800;900&family=Roboto:wght@300;400;500;700;900&display=swap" rel="stylesheet">
</head>
<body>
    <header id="header">
        <div class="logo-container" onclick="window.location.href='index.htm'">
            <div class="logo-icon">SC</div>
            <span>Rio Tinto</span>
        </div>
        <nav>
            <ul>
                <li><a href="index.htm">Home</a></li>
                <li><a href="noticias-formacao.jsp">Formação</a></li>        
                <li><a href="Produtos.jsp">Produtos</a></li>
                <li><a href="Bilheteria.jsp">Bilheteria</a></li>
                <li><a href="Socios front page.jsp">Sócios</a></li>
                <li><a href="Equipas.jsp">Equipas</a></li>
                <li><a href="Sobre.jsp">Sobre</a></li>
                <li>
                    <% if (estaLogado) { %>
                        <div class="user-dropdown">
                            <button class="btn-header">
                                <i class="fas fa-user-circle"></i>
                                <%= primeiroNome %>
                                <% if (isAdmin) { %>
                                    <span class="admin-badge">ADMIN</span>
                                <% } %>
                                <% if (jaSocio) { %>
                                    <span class="socio-badge">✓ SÓCIO</span>
                                <% } %>
                                <i class="fas fa-chevron-down" style="font-size: 0.8rem;"></i>
                            </button>
                            <div class="dropdown-menu">
                                <div class="dropdown-header">
                                    <div class="user-name">
                                        <%= primeiroNome %> <%= ultimoNome %>
                                        <% if (jaSocio) { %>
                                            <span class="socio-badge">✓ SÓCIO</span>
                                        <% } %>
                                    </div>
                                    <div class="user-email"><%= emailUtilizador %></div>
                                    <% if (jaSocio) { %>
                                        <div style="margin-top: 0.5rem; padding-top: 0.5rem; border-top: 1px solid rgba(255, 215, 0, 0.2);">
                                            <div style="color: var(--amarelo); font-size: 0.75rem; font-weight: 600;">
                                                <i class="fas fa-id-card"></i> Nº <%= numeroSocio %>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                                <a href="perfil.jsp" class="dropdown-item">
                                    <i class="fas fa-user"></i>
                                    Meu Perfil
                                </a>
                                <% if (jaSocio) { %>
                                    <a href="cartao-socio.jsp" class="dropdown-item">
                                        <i class="fas fa-id-card"></i>
                                        Cartão de Sócio
                                    </a>
                                <% } else { %>
                                    <a href="Socios front page.jsp" class="dropdown-item" style="background: rgba(16, 185, 129, 0.1);">
                                        <i class="fas fa-user-plus"></i>
                                        Tornar-me Sócio
                                    </a>
                                <% } %>
                                <a href="pedidos.jsp" class="dropdown-item">
                                    <i class="fas fa-shopping-bag"></i>
                                    Meus Pedidos
                                </a>
                                <a href="MeusBilhetes.jsp" class="dropdown-item">
                                    <i class="fas fa-ticket"></i>
                                    Meus Bilhetes
                                </a>
                                <% if (isAdmin) { %>
                                    <div class="dropdown-divider"></div>
                                    <a href="admin.jsp" class="dropdown-item">
                                        <i class="fas fa-crown"></i>
                                        Painel Admin
                                    </a>
                                <% } %>
                                <div class="dropdown-divider"></div>
                                <a href="logout.jsp" class="dropdown-item logout">
                                    <i class="fas fa-sign-out-alt"></i>
                                    Terminar Sessão
                                </a>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="user-dropdown">
                            <button class="btn-header">
                                <i class="fas fa-user"></i>
                                Conta
                                <i class="fas fa-chevron-down" style="font-size: 0.8rem;"></i>
                            </button>
                            <div class="dropdown-menu">
                                <a href="Login.jsp" class="dropdown-item">
                                    <i class="fas fa-sign-in-alt"></i>
                                    Iniciar Sessão
                                </a>
                                <a href="Registro.jsp" class="dropdown-item">
                                    <i class="fas fa-user-plus"></i>
                                    Criar Conta
                                </a>
                            </div>
                        </div>
                    <% } %>
                </li>
            </ul>
        </nav>
    </header>

    <div class="fifa-container">
        <%
            String idEquipaParam = request.getParameter("id_equipa");
            int idEquipa = 0;
            int totalJogadores = 0;
            int totalTreinadores = 0;
            String nomeEquipa = "";
            String categoria = "";
            String temporada = "";
            
            Connection conn = null;
            List<Map<String, Object>> guardaRedes = new ArrayList<Map<String, Object>>();
            List<Map<String, Object>> defesas = new ArrayList<Map<String, Object>>();
            List<Map<String, Object>> medios = new ArrayList<Map<String, Object>>();
            List<Map<String, Object>> atacantes = new ArrayList<Map<String, Object>>();
            List<Map<String, Object>> treinadores = new ArrayList<Map<String, Object>>();
            
            try {
                if (idEquipaParam != null && !idEquipaParam.isEmpty()) {
                    idEquipa = Integer.parseInt(idEquipaParam);
                    
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                    
                    PreparedStatement pstmtEquipa = conn.prepareStatement("SELECT * FROM t_equipas WHERE id_equipa = ?");
                    pstmtEquipa.setInt(1, idEquipa);
                    ResultSet rsEquipa = pstmtEquipa.executeQuery();
                    
                    if (rsEquipa.next()) {
                        nomeEquipa = rsEquipa.getString("nome_equipa");
                        categoria = rsEquipa.getString("categoria");
                        temporada = rsEquipa.getString("temporada");
                    }
                    rsEquipa.close();
                    pstmtEquipa.close();
                    
                    PreparedStatement pstmtJogadores = conn.prepareStatement(
                        "SELECT * FROM t_jogadores WHERE id_equipa = ? ORDER BY numero_camisola"
                    );
                    pstmtJogadores.setInt(1, idEquipa);
                    ResultSet rsJogadores = pstmtJogadores.executeQuery();
                    
                    while (rsJogadores.next()) {
                        Map<String, Object> jogador = new HashMap<String, Object>();
                        
                        String primeiroNomeJog = rsJogadores.getString("primeiro_nome");
                        String ultimoNomeJog = rsJogadores.getString("ultimo_nome");
                        String nomeCompleto = primeiroNomeJog + " " + ultimoNomeJog;
                        
                        jogador.put("id", rsJogadores.getInt("id_jogador"));
                        jogador.put("nome", nomeCompleto);
                        jogador.put("numero", rsJogadores.getInt("numero_camisola"));
                        
                        String posicao = rsJogadores.getString("posicao");
                        
                        jogador.put("posicao", getAbreviacao(posicao));
                        jogador.put("posicao_completa", posicao);
                        jogador.put("linha", getLinha(posicao));
                        jogador.put("foto", rsJogadores.getString("foto_url"));
                        
                        int numeroCamisola = rsJogadores.getInt("numero_camisola");
                        int overall = 70 + (numeroCamisola % 21);
                        if (overall > 90) overall = 90;
                        jogador.put("overall", overall);
                        
                        // Organizar por tipo de posição
                        int linha = getLinha(posicao);
                        if (linha == 1) {
                            guardaRedes.add(jogador);
                        } else if (linha == 2) {
                            defesas.add(jogador);
                        } else if (linha == 3) {
                            medios.add(jogador);
                        } else if (linha == 4) {
                            atacantes.add(jogador);
                        }
                    }
                    rsJogadores.close();
                    pstmtJogadores.close();
                    
                    totalJogadores = guardaRedes.size() + defesas.size() + medios.size() + atacantes.size();
                    
                    PreparedStatement pstmtTreinadores = conn.prepareStatement(
                        "SELECT * FROM t_treinadores WHERE id_equipa = ?"
                    );
                    pstmtTreinadores.setInt(1, idEquipa);
                    ResultSet rsTreinadores = pstmtTreinadores.executeQuery();
                    
                    while (rsTreinadores.next()) {
                        Map<String, Object> treinador = new HashMap<String, Object>();
                        
                        String primeiroNomeTre = rsTreinadores.getString("primeiro_nome");
                        String ultimoNomeTre = rsTreinadores.getString("ultimo_nome");
                        String nomeCompletoTre = primeiroNomeTre + " " + ultimoNomeTre;
                        
                        treinador.put("nome", nomeCompletoTre);
                        treinador.put("nivel", rsTreinadores.getString("nivel_treinador"));
                        treinador.put("foto", rsTreinadores.getString("foto_url"));
                        treinadores.add(treinador);
                    }
                    rsTreinadores.close();
                    pstmtTreinadores.close();
                    
                    totalTreinadores = treinadores.size();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>

        <a href="Equipas.jsp" class="back-button">
            <i class="fas fa-arrow-left"></i>
            Voltar às Equipas
        </a>

        <% if (totalJogadores > 0) { %>
            <div class="team-header">
                <div class="team-badge-container">
                    <div class="team-badge">SC</div>
                    <div class="team-info-text">
                        <h1><%= nomeEquipa %></h1>
                        <div class="team-rating">
                            <i class="fas fa-star star"></i>
                            <i class="fas fa-star star"></i>
                            <i class="fas fa-star star"></i>
                            <i class="fas fa-star star"></i>
                            <i class="far fa-star star"></i>
                            <span class="chemistry"><i class="fas fa-link"></i> 100</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="team-stats-sidebar">
                <div class="stat-row">
                    <span class="stat-label">Jogadores</span>
                    <span class="stat-value"><%= totalJogadores %></span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">Titulares</span>
                    <span class="stat-value" id="titularesCount">0</span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">Suplentes</span>
                    <span class="stat-value" id="suplentesCount"><%= totalJogadores %></span>
                </div>
                <div class="stat-row">
                    <span class="stat-label">Overall</span>
                    <span class="stat-value">82</span>
                </div>
            </div>

            <% if (!treinadores.isEmpty()) { %>
                <div class="coach-panel">
                    <div class="coach-title">
                        <i class="fas fa-user-tie"></i> Treinador
                    </div>
                    <% for (Map<String, Object> treinador : treinadores) { %>
                        <div class="coach-card-mini">
                            <img src="<%= treinador.get("foto") != null ? treinador.get("foto") : "images/default-coach.png" %>" 
                                 alt="Treinador" class="coach-photo"
                                 onerror="this.src='images/default-coach.png'">
                            <div class="coach-info">
                                <h3><%= treinador.get("nome") %></h3>
                                <p><%= treinador.get("nivel") %></p>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>

            <div class="pitch-scene">
                <div class="pitch-field">
                    <div class="field-lines">
                        <div class="center-line"></div>
                        <div class="center-circle">
                            <div class="center-dot"></div>
                        </div>
                        <div class="penalty-box-top"></div>
                        <div class="penalty-box-bottom"></div>
                    </div>

                    <div class="formation-container">
                        <div class="formation-grid">
                            <!-- Linha de Guarda-Redes -->
                            <div class="formation-line">
                                <div class="empty-position" data-position="GR" data-line="1" onclick="openPlayerSelection(this, 1)">
                                    <div class="empty-card-body">
                                        <i class="fas fa-plus-circle empty-position-icon"></i>
                                        <div class="empty-position-text">Adicionar</div>
                                        <div class="empty-position-label">Guarda-Redes</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Linha de Defesas -->
                            <div class="formation-line">
                                <div class="empty-position" data-position="DEF" data-line="2" onclick="openPlayerSelection(this, 2)">
                                    <div class="empty-card-body">
                                        <i class="fas fa-plus-circle empty-position-icon"></i>
                                        <div class="empty-position-text">Adicionar</div>
                                        <div class="empty-position-label">Defesa</div>
                                    </div>
                                </div>
                                <div class="empty-position" data-position="DEF" data-line="2" onclick="openPlayerSelection(this, 2)">
                                    <div class="empty-card-body">
                                        <i class="fas fa-plus-circle empty-position-icon"></i>
                                        <div class="empty-position-text">Adicionar</div>
                                        <div class="empty-position-label">Defesa</div>
                                    </div>
                                </div>
                                <div class="empty-position" data-position="DEF" data-line="2" onclick="openPlayerSelection(this, 2)">
                                    <div class="empty-card-body">
                                        <i class="fas fa-plus-circle empty-position-icon"></i>
                                        <div class="empty-position-text">Adicionar</div>
                                        <div class="empty-position-label">Defesa</div>
                                    </div>
                                </div>
                                <div class="empty-position" data-position="DEF" data-line="2" onclick="openPlayerSelection(this, 2)">
                                    <div class="empty-card-body">
                                        <i class="fas fa-plus-circle empty-position-icon"></i>
                                        <div class="empty-position-text">Adicionar</div>
                                        <div class="empty-position-label">Defesa</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Linha de Médios -->
                            <div class="formation-line">
                                <div class="empty-position" data-position="MED" data-line="3" onclick="openPlayerSelection(this, 3)">
                                    <div class="empty-card-body">
                                        <i class="fas fa-plus-circle empty-position-icon"></i>
                                        <div class="empty-position-text">Adicionar</div>
                                        <div class="empty-position-label">Médio</div>
                                    </div>
                                </div>
                                <div class="empty-position" data-position="MED" data-line="3" onclick="openPlayerSelection(this, 3)">
                                    <div class="empty-card-body">
                                        <i class="fas fa-plus-circle empty-position-icon"></i>
                                        <div class="empty-position-text">Adicionar</div><div class="empty-position-label">Médio</div>
                                    </div>
                                </div>
                                <div class="empty-position" data-position="MED" data-line="3" onclick="openPlayerSelection(this, 3)">
                                    <div class="empty-card-body">
                                        <i class="fas fa-plus-circle empty-position-icon"></i>
                                        <div class="empty-position-text">Adicionar</div>
                                        <div class="empty-position-label">Médio</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Linha de Atacantes -->
                            <div class="formation-line">
                                <div class="empty-position" data-position="ATA" data-line="4" onclick="openPlayerSelection(this, 4)">
                                    <div class="empty-card-body">
                                        <i class="fas fa-plus-circle empty-position-icon"></i>
                                        <div class="empty-position-text">Adicionar</div>
                                        <div class="empty-position-label">Atacante</div>
                                    </div>
                                </div>
                                <div class="empty-position" data-position="ATA" data-line="4" onclick="openPlayerSelection(this, 4)">
                                    <div class="empty-card-body">
                                        <i class="fas fa-plus-circle empty-position-icon"></i>
                                        <div class="empty-position-text">Adicionar</div>
                                        <div class="empty-position-label">Atacante</div>
                                    </div>
                                </div>
                                <div class="empty-position" data-position="ATA" data-line="4" onclick="openPlayerSelection(this, 4)">
                                    <div class="empty-card-body">
                                        <i class="fas fa-plus-circle empty-position-icon"></i>
                                        <div class="empty-position-text">Adicionar</div>
                                        <div class="empty-position-label">Atacante</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Painel de Suplentes -->
            <div class="substitutes-panel">
                <div class="subs-container">
                    <div class="subs-header">
                        <div class="subs-icon"></div>
                        <h2 class="subs-title">Banco de Suplentes</h2>
                        <span class="subs-count" id="subsCount"><%= totalJogadores %> jogadores</span>
                    </div>
                    <div class="subs-grid" id="substitutesList">
                        <!-- Guarda-Redes -->
                        <% for (Map<String, Object> jogador : guardaRedes) { %>
                            <div class="player-card" 
                                 data-player-id="<%= jogador.get("id") %>"
                                 data-player-name="<%= jogador.get("nome") %>"
                                 data-player-number="<%= jogador.get("numero") %>"
                                 data-player-position="<%= jogador.get("posicao") %>"
                                 data-player-overall="<%= jogador.get("overall") %>"
                                 data-player-photo="<%= jogador.get("foto") %>"
                                 data-player-line="<%= jogador.get("linha") %>">
                                <div class="card-body">
                                    <div class="card-top">
                                        <div class="player-rating-pos">
                                            <div class="player-overall"><%= jogador.get("overall") %></div>
                                            <div class="player-pos"><%= jogador.get("posicao") %></div>
                                        </div>
                                        <div class="player-number-badge"><%= jogador.get("numero") %></div>
                                    </div>
                                    <div class="player-photo-container">
                                        <img src="<%= jogador.get("foto") != null ? encodePath((String)jogador.get("foto")) : "images/default-player.png" %>"
                                             alt="<%= jogador.get("nome") %>" 
                                             class="player-photo"
                                             onerror="this.src='images/default-player.png'">
                                    </div>
                                    <div class="player-name-section">
                                        <div class="player-name"><%= jogador.get("nome") %></div>
                                    </div>
                                </div>
                            </div>
                        <% } %>

                        <!-- Defesas -->
                        <% for (Map<String, Object> jogador : defesas) { %>
                            <div class="player-card" 
                                 data-player-id="<%= jogador.get("id") %>"
                                 data-player-name="<%= jogador.get("nome") %>"
                                 data-player-number="<%= jogador.get("numero") %>"
                                 data-player-position="<%= jogador.get("posicao") %>"
                                 data-player-overall="<%= jogador.get("overall") %>"
                                 data-player-photo="<%= jogador.get("foto") %>"
                                 data-player-line="<%= jogador.get("linha") %>">
                                <div class="card-body">
                                    <div class="card-top">
                                        <div class="player-rating-pos">
                                            <div class="player-overall"><%= jogador.get("overall") %></div>
                                            <div class="player-pos"><%= jogador.get("posicao") %></div>
                                        </div>
                                        <div class="player-number-badge"><%= jogador.get("numero") %></div>
                                    </div>
                                    <div class="player-photo-container">
                                        <img src="<%= jogador.get("foto") != null ? encodePath((String)jogador.get("foto")) : "images/default-player.png" %>"
                                             alt="<%= jogador.get("nome") %>" 
                                             class="player-photo"
                                             onerror="this.src='images/default-player.png'">
                                    </div>
                                    <div class="player-name-section">
                                        <div class="player-name"><%= jogador.get("nome") %></div>
                                    </div>
                                </div>
                            </div>
                        <% } %>

                        <!-- Médios -->
                        <% for (Map<String, Object> jogador : medios) { %>
                            <div class="player-card" 
                                 data-player-id="<%= jogador.get("id") %>"
                                 data-player-name="<%= jogador.get("nome") %>"
                                 data-player-number="<%= jogador.get("numero") %>"
                                 data-player-position="<%= jogador.get("posicao") %>"
                                 data-player-overall="<%= jogador.get("overall") %>"
                                 data-player-photo="<%= jogador.get("foto") %>"
                                 data-player-line="<%= jogador.get("linha") %>">
                                <div class="card-body">
                                    <div class="card-top">
                                        <div class="player-rating-pos">
                                            <div class="player-overall"><%= jogador.get("overall") %></div>
                                            <div class="player-pos"><%= jogador.get("posicao") %></div>
                                        </div>
                                        <div class="player-number-badge"><%= jogador.get("numero") %></div>
                                    </div>
                                    <div class="player-photo-container">
                                        <img src="<%= jogador.get("foto") != null ? encodePath((String)jogador.get("foto")) : "images/default-player.png" %>"
                                             alt="<%= jogador.get("nome") %>" 
                                             class="player-photo"
                                             onerror="this.src='images/default-player.png'">
                                    </div>
                                    <div class="player-name-section">
                                        <div class="player-name"><%= jogador.get("nome") %></div>
                                    </div>
                                </div>
                            </div>
                        <% } %>

                        <!-- Atacantes -->
                        <% for (Map<String, Object> jogador : atacantes) { %>
                            <div class="player-card" 
                                 data-player-id="<%= jogador.get("id") %>"
                                 data-player-name="<%= jogador.get("nome") %>"
                                 data-player-number="<%= jogador.get("numero") %>"
                                 data-player-position="<%= jogador.get("posicao") %>"
                                 data-player-overall="<%= jogador.get("overall") %>"
                                 data-player-photo="<%= jogador.get("foto") %>"
                                 data-player-line="<%= jogador.get("linha") %>">
                                <div class="card-body">
                                    <div class="card-top">
                                        <div class="player-rating-pos">
                                            <div class="player-overall"><%= jogador.get("overall") %></div>
                                            <div class="player-pos"><%= jogador.get("posicao") %></div>
                                        </div>
                                        <div class="player-number-badge"><%= jogador.get("numero") %></div>
                                    </div>
                                    <div class="player-photo-container">
                                        <img src="<%= jogador.get("foto") != null ? encodePath((String)jogador.get("foto")) : "images/default-player.png" %>" 
                                             alt="<%= jogador.get("nome") %>" 
                                             class="player-photo"
                                             onerror="this.src='images/default-player.png'">
                                    </div>
                                    <div class="player-name-section">
                                        <div class="player-name"><%= jogador.get("nome") %></div>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>

        <% } else { %>
            <div class="no-data-message">
                <i class="fas fa-users-slash"></i>
                <h2>Nenhum Jogador Encontrado</h2>
                <p>Esta equipa ainda não possui jogadores cadastrados.</p>
            </div>
        <% } %>

        <% if (conn != null) try { conn.close(); } catch (SQLException e) {} %>
    </div>

    <!-- Modal de Seleção de Jogador -->
    <div class="player-selection-modal" id="playerModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title" id="modalTitle">Selecionar Jogador</h2>
                <button class="modal-close" onclick="closePlayerSelection()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-players-grid" id="modalPlayersList"></div>
        </div>
    </div>

    <script>
        let currentPositionElement = null;

function openPlayerSelection(positionElement, lineNumber) {
    currentPositionElement = positionElement;
    const modal = document.getElementById('playerModal');
    const modalPlayersList = document.getElementById('modalPlayersList');
    const modalTitle = document.getElementById('modalTitle');

    // Definir título baseado na linha
    const positionNames = {
        1: 'Guarda-Redes',
        2: 'Defesa',
        3: 'Médio',
        4: 'Atacante'
    };
    modalTitle.textContent = 'Selecionar ' + positionNames[lineNumber];

    // Limpar lista
    modalPlayersList.innerHTML = '';

    // Pegar todos os jogadores do banco
    const allPlayers = document.querySelectorAll('#substitutesList .player-card');
    const availablePlayers = Array.from(allPlayers).filter(player => {
        return parseInt(player.dataset.playerLine) === lineNumber;
    });

    if (availablePlayers.length === 0) {
        modalPlayersList.innerHTML = `
            <div class="modal-empty-state">
                <i class="fas fa-user-slash"></i>
                <h3>Sem jogadores disponíveis</h3>
                <p>Não há jogadores disponíveis para esta posição.</p>
            </div>
        `;
    } else {
        availablePlayers.forEach(player => {
            const playerCard = player.cloneNode(true);
            playerCard.classList.add('modal-player-card');
            playerCard.onclick = function() {
                selectPlayer(player);
            };
            modalPlayersList.appendChild(playerCard);
        });
    }

    modal.classList.add('active');
}

function closePlayerSelection() {
    const modal = document.getElementById('playerModal');
    modal.classList.remove('active');
    currentPositionElement = null;
}

function selectPlayer(playerElement) {
    if (!currentPositionElement) return;

    console.log('=== DEBUG SELECT PLAYER ===');
    console.log('Player Element:', playerElement);
    console.log('Dataset completo:', playerElement.dataset);

    // Obter TODOS os dados do jogador do dataset
    const playerId = playerElement.dataset.playerId;
    const playerName = playerElement.dataset.playerName;
    const playerNumber = playerElement.dataset.playerNumber;
    const playerPosition = playerElement.dataset.playerPosition;
    const playerOverall = playerElement.dataset.playerOverall;
    const playerLine = playerElement.dataset.playerLine;
    let playerPhoto = playerElement.dataset.playerPhoto;

    console.log('ID:', playerId);
    console.log('Nome:', playerName);
    console.log('Número:', playerNumber);
    console.log('Posição:', playerPosition);
    console.log('Overall:', playerOverall);
    console.log('Linha:', playerLine);
    console.log('Foto ORIGINAL da BD:', playerPhoto);

    // Tratar o caminho da foto
    if (!playerPhoto || playerPhoto === 'null' || playerPhoto === 'undefined' || playerPhoto.trim() === '') {
        console.log('Foto está vazia, usando default');
        playerPhoto = "images/default-player.png";
    } else {
        playerPhoto = playerPhoto.replace(/ /g, '%20');
        console.log('Foto após encoding:', playerPhoto);
    }

    console.log('Foto FINAL que vai ser usada:', playerPhoto);

    // Criar o card do jogador
    const playerCard = document.createElement('div');
    playerCard.className = 'player-card';
    
    playerCard.dataset.playerId = playerId;
    playerCard.dataset.playerName = playerName;
    playerCard.dataset.playerNumber = playerNumber;
    playerCard.dataset.playerPosition = playerPosition;
    playerCard.dataset.playerOverall = playerOverall;
    playerCard.dataset.playerPhoto = playerPhoto;
    playerCard.dataset.playerLine = playerLine;

    // HTML simplificado - SEM SVG inline complexo
    playerCard.innerHTML = 
        '<div class="card-body">' +
            '<div class="card-top">' +
                '<div class="player-rating-pos">' +
                    '<div class="player-overall">' + playerOverall + '</div>' +
                    '<div class="player-pos">' + playerPosition + '</div>' +
                '</div>' +
                '<div class="player-number-badge">' + playerNumber + '</div>' +
            '</div>' +
            '<div class="player-photo-container">' +
                '<img src="' + playerPhoto + '" ' +
                     'alt="' + playerName + '" ' +
                     'class="player-photo" ' +
                     'onerror="this.src=\'images/default-player.png\'">' +
            '</div>' +
            '<div class="player-name-section">' +
                '<div class="player-name">' + playerName + '</div>' +
            '</div>' +
        '</div>' +
        '<button class="remove-player-btn" onclick="removePlayerFromField(this, event)">' +
            '<i class="fas fa-times"></i>' +
        '</button>';

    currentPositionElement.replaceWith(playerCard);
    playerElement.remove();
    closePlayerSelection();
    updateCounters();

    console.log('✅ Jogador adicionado ao campo com sucesso!');
}

function removePlayerFromField(button, event) {
    event.stopPropagation();

    const playerCard = button.closest('.player-card');
    const playerLine = parseInt(playerCard.dataset.playerLine);

    const emptyPosition = document.createElement('div');
    emptyPosition.className = 'empty-position';
    emptyPosition.dataset.line = playerLine;

    const positionLabels = {
        1: 'Guarda-Redes',
        2: 'Defesa',
        3: 'Médio',
        4: 'Atacante'
    };

    const positionCodes = {
        1: 'GR',
        2: 'DEF',
        3: 'MED',
        4: 'ATA'
    };

    emptyPosition.dataset.position = positionCodes[playerLine];
    emptyPosition.onclick = function() {
        openPlayerSelection(this, playerLine);
    };

    emptyPosition.innerHTML = 
        '<div class="empty-card-body">' +
            '<i class="fas fa-plus-circle empty-position-icon"></i>' +
            '<div class="empty-position-text">Adicionar</div>' +
            '<div class="empty-position-label">' + positionLabels[playerLine] + '</div>' +
        '</div>';

    const substituteCard = document.createElement('div');
    substituteCard.className = 'player-card';
    substituteCard.dataset.playerId = playerCard.dataset.playerId;
    substituteCard.dataset.playerName = playerCard.dataset.playerName;
    substituteCard.dataset.playerNumber = playerCard.dataset.playerNumber;
    substituteCard.dataset.playerPosition = playerCard.dataset.playerPosition;
    substituteCard.dataset.playerOverall = playerCard.dataset.playerOverall;
    substituteCard.dataset.playerPhoto = playerCard.dataset.playerPhoto;
    substituteCard.dataset.playerLine = playerCard.dataset.playerLine;

    substituteCard.innerHTML = 
        '<div class="card-body">' +
            '<div class="card-top">' +
                '<div class="player-rating-pos">' +
                    '<div class="player-overall">' + playerCard.dataset.playerOverall + '</div>' +
                    '<div class="player-pos">' + playerCard.dataset.playerPosition + '</div>' +
                '</div>' +
                '<div class="player-number-badge">' + playerCard.dataset.playerNumber + '</div>' +
            '</div>' +
            '<div class="player-photo-container">' +
                '<img src="' + playerCard.dataset.playerPhoto + '" ' +
                     'alt="' + playerCard.dataset.playerName + '" ' +
                     'class="player-photo" ' +
                     'onerror="this.src=\'images/default-player.png\'">' +
            '</div>' +
            '<div class="player-name-section">' +
                '<div class="player-name">' + playerCard.dataset.playerName + '</div>' +
            '</div>' +
        '</div>';

    document.getElementById('substitutesList').appendChild(substituteCard);
    playerCard.replaceWith(emptyPosition);
    updateCounters();
}

function updateCounters() {
    const allFieldPlayers = document.querySelectorAll('.formation-grid .player-card');
    const titularesCount = allFieldPlayers.length;
    
    const allSubPlayers = document.querySelectorAll('#substitutesList .player-card');
    const suplentesCount = allSubPlayers.length;

    document.getElementById('titularesCount').textContent = titularesCount;
    document.getElementById('suplentesCount').textContent = suplentesCount;
    document.getElementById('subsCount').textContent = suplentesCount + ' jogadores';
}

// Scroll header effect
const header = document.getElementById('header');
window.addEventListener('scroll', () => {
    if (window.scrollY > 50) {
        header.classList.add('scrolled');
    } else {
        header.classList.remove('scrolled');
    }
});

// Fechar modal ao clicar fora
document.getElementById('playerModal').addEventListener('click', function(e) {
    if (e.target === this) {
        closePlayerSelection();
    }
});

// Inicializar contadores
updateCounters();
    </script>
</body>
</html>