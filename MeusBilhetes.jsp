<%-- 
    Document   : MeusBilhetes
    Created on : Dec 27, 2025, 11:28:16 PM
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
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
    
    // Se não estiver logado, redirecionar para login
    if (idUtilizador == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    // Verificar se o utilizador é sócio
    boolean jaSocio = false;
    String numeroSocio = null;
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    List<Map<String, Object>> bilhetes = new ArrayList<>();
    int totalBilhetes = 0;
    int bilhetesValidados = 0;
    int bilhetesAtivos = 0;
    
    try {
        String dbURL = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
        String dbUser = "root";
        String dbPass = "";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
        
        // Verificar se é sócio
        String sqlSocio = "SELECT numero_socio FROM t_socio WHERE id_utilizador = ?";
        pstmt = conn.prepareStatement(sqlSocio);
        pstmt.setInt(1, idUtilizador);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            jaSocio = true;
            numeroSocio = rs.getString("numero_socio");
        }
        rs.close();
        pstmt.close();
        
        // Buscar bilhetes do utilizador
        String sqlBilhetes = "SELECT b.*, e.nome_evento, e.local_evento, e.data_evento, " +
                           "eq1.nome_equipa as equipa_casa, eq2.nome_equipa as equipa_fora " +
                           "FROM t_bilhetes b " +
                           "LEFT JOIN t_eventos e ON b.id_evento = e.id_evento " +
                           "LEFT JOIN t_equipas eq1 ON e.id_equipa_casa = eq1.id_equipa " +
                           "LEFT JOIN t_equipas eq2 ON e.id_equipa_fora = eq2.id_equipa " +
                           "WHERE b.id_utilizador = ? " +
                           "ORDER BY e.data_evento DESC, b.data_criacao DESC";
        
        pstmt = conn.prepareStatement(sqlBilhetes);
        pstmt.setInt(1, idUtilizador);
        rs = pstmt.executeQuery();
        
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        SimpleDateFormat sdfDate = new SimpleDateFormat("dd/MM/yyyy");
        
        while (rs.next()) {
            Map<String, Object> bilhete = new HashMap<>();
            
            bilhete.put("id_bilhete", rs.getInt("id_bilhete"));
            bilhete.put("codigo_bilhete", rs.getString("codigo_bilhete"));
            bilhete.put("numero_bilhete", rs.getString("numero_bilhete"));
            bilhete.put("nome_titular", rs.getString("nome_titular"));
            bilhete.put("tipo_bilhete", rs.getString("tipo_bilhete"));
            bilhete.put("setor", rs.getString("setor"));
            bilhete.put("fila", rs.getString("fila"));
            bilhete.put("lugar", rs.getString("lugar"));
            bilhete.put("preco_pago", rs.getDouble("preco_pago"));
            bilhete.put("estado_bilhete", rs.getString("estado_bilhete"));
            
            // Informações do evento
            bilhete.put("nome_evento", rs.getString("nome_evento"));
            bilhete.put("local_evento", rs.getString("local_evento"));
            bilhete.put("equipa_casa", rs.getString("equipa_casa"));
            bilhete.put("equipa_fora", rs.getString("equipa_fora"));
            
            Timestamp dataEvento = rs.getTimestamp("data_evento");
            if (dataEvento != null) {
                bilhete.put("data_evento", sdf.format(dataEvento));
                bilhete.put("data_evento_curta", sdfDate.format(dataEvento));
            }
            
            Timestamp dataValidacao = rs.getTimestamp("data_validacao");
            if (dataValidacao != null) {
                bilhete.put("data_validacao", sdf.format(dataValidacao));
            }
            
            bilhetes.add(bilhete);
            totalBilhetes++;
            
            String estado = rs.getString("estado_bilhete");
            if ("validado".equals(estado)) {
                bilhetesValidados++;
            } else if ("vendido".equals(estado) || "reservado".equals(estado)) {
                bilhetesAtivos++;
            }
        }
        
    } catch (Exception e) {
        out.println("<!-- Erro: " + e.getMessage() + " -->");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Meus Bilhetes - SC Rio Tinto</title>
  <link href="css/CssMeusBilhetes.css" rel="stylesheet" type="text/css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
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
              <a href="MeusBilhetes.jsp" class="dropdown-item" style="background: rgba(255, 215, 0, 0.1);">
                <i class="fas fa-ticket-alt"></i>
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
        </li>
      </ul>
    </nav>
  </header>

  <div class="main-content">
    <div class="container">
      <div class="page-header">
        <h1><i class="fas fa-ticket-alt"></i> Meus Bilhetes</h1>
        <p>Consulta todos os teus bilhetes para eventos do SC Rio Tinto</p>
      </div>

      <div class="stats-cards">
        <div class="stat-card">
          <div class="stat-icon">
            <i class="fas fa-ticket-alt"></i>
          </div>
          <div class="stat-number"><%= totalBilhetes %></div>
          <div class="stat-label">Total de Bilhetes</div>
        </div>

        <div class="stat-card">
          <div class="stat-icon">
            <i class="fas fa-check-circle"></i>
          </div>
          <div class="stat-number"><%= bilhetesAtivos %></div>
          <div class="stat-label">Bilhetes Ativos</div>
        </div>

        <div class="stat-card">
          <div class="stat-icon">
            <i class="fas fa-qrcode"></i>
          </div>
          <div class="stat-number"><%= bilhetesValidados %></div>
          <div class="stat-label">Bilhetes Validados</div>
        </div>
      </div>

      <% if (bilhetes.isEmpty()) { %>
        <div class="empty-state">
          <div class="empty-icon">
            <i class="fas fa-ticket-alt"></i>
          </div>
          <h3>Ainda não tens bilhetes</h3>
          <p>Quando comprares bilhetes para eventos do SC Rio Tinto, eles aparecerão aqui.</p>
          <a href="Bilheteria.jsp" class="btn-primary">
            <i class="fas fa-shopping-cart"></i>
            Comprar Bilhetes
          </a>
        </div>
      <% } else { %>
        <div class="bilhetes-grid">
          <% for (Map<String, Object> bilhete : bilhetes) { 
              String estadoBilhete = (String) bilhete.get("estado_bilhete");
              String tipoBilhete = (String) bilhete.get("tipo_bilhete");
              String estadoClass = "";
              
              if ("vendido".equals(estadoBilhete)) {
                  estadoClass = "estado-vendido";
              } else if ("validado".equals(estadoBilhete)) {
                  estadoClass = "estado-validado";
              } else if ("reservado".equals(estadoBilhete)) {
                  estadoClass = "estado-reservado";
              } else if ("cancelado".equals(estadoBilhete)) {
                  estadoClass = "estado-cancelado";
              }
              
              String tipoClass = "";
              if ("socio".equals(tipoBilhete)) {
                  tipoClass = "tipo-socio";
              } else if ("estudante".equals(tipoBilhete)) {
                  tipoClass = "tipo-estudante";
              } else if ("crianca".equals(tipoBilhete)) {
                  tipoClass = "tipo-crianca";
              } else {
                  tipoClass = "tipo-normal";
              }
          %>
          <div class="bilhete-card">
            <div class="bilhete-header">
              <div class="evento-nome">
                <%= bilhete.get("nome_evento") != null ? bilhete.get("nome_evento") : "Evento" %>
              </div>
              <div class="evento-data">
                <i class="fas fa-calendar"></i>
                <%= bilhete.get("data_evento") != null ? bilhete.get("data_evento") : "Data a definir" %>
              </div>
              <div class="evento-local">
                <i class="fas fa-map-marker-alt"></i>
                <%= bilhete.get("local_evento") != null ? bilhete.get("local_evento") : "Local a definir" %>
              </div>
            </div>

            <div class="bilhete-body">
              <div class="bilhete-info-row">
                <span class="info-label">
                  <i class="fas fa-hashtag"></i>
                  Nº Bilhete
                </span>
                <span class="info-value"><%= bilhete.get("numero_bilhete") %></span>
              </div>

              <div class="bilhete-info-row">
                <span class="info-label">
                  <i class="fas fa-user"></i>
                  Titular
                </span>
                <span class="info-value"><%= bilhete.get("nome_titular") %></span>
              </div>

              <div class="bilhete-info-row">
                <span class="info-label">
                  <i class="fas fa-tag"></i>
                  Tipo
                </span>
                <span class="tipo-badge <%= tipoClass %>">
                  <%= tipoBilhete.toUpperCase() %>
                </span>
              </div>

              <div class="bilhete-info-row">
                <span class="info-label">
                  <i class="fas fa-couch"></i>
                  Localização
                </span>
                <span class="info-value">
                  <%= bilhete.get("setor") %>
                  <% if (bilhete.get("fila") != null && bilhete.get("lugar") != null) { %>
                    - Fila <%= bilhete.get("fila") %>, Lugar <%= bilhete.get("lugar") %>
                  <% } %>
                </span>
              </div>

              <div class="bilhete-info-row">
                <span class="info-label">
                  <i class="fas fa-euro-sign"></i>
                  Preço
                </span>
                <span class="info-value destaque">€<%= String.format("%.2f", bilhete.get("preco_pago")) %></span>
              </div>

              <div class="bilhete-info-row">
                <span class="info-label">
                  <i class="fas fa-info-circle"></i>
                  Estado
                </span>
                <span class="estado-badge <%= estadoClass %>">
                  <%= estadoBilhete.toUpperCase() %>
                </span>
              </div>

              <% if ("validado".equals(estadoBilhete) && bilhete.get("data_validacao") != null) { %>
              <div class="bilhete-info-row">
                <span class="info-label">
                  <i class="fas fa-check"></i>
                  Validado em
                </span>
                <span class="info-value" style="font-size: 0.9rem;">
                  <%= bilhete.get("data_validacao") %>
                </span>
              </div>
              <% } %>

              <% if (!"cancelado".equals(estadoBilhete)) { %>
              <div class="codigo-qr">
                <div style="font-size: 0.9rem; color: #666; margin-bottom: 0.5rem; font-weight: 600;">
                  <i class="fas fa-qrcode"></i> CÓDIGO DO BILHETE
                </div>
                <div class="codigo-texto"><%= bilhete.get("codigo_bilhete") %></div>
                <div style="font-size: 0.75rem; color: #999; margin-top: 0.8rem;">
                  Apresenta este código na entrada do evento
                </div>
              </div>
              <% } %>
            </div>
          </div>
          <% } %>
        </div>
      <% } %>
    </div>
  </div>

  <script>
    const header = document.getElementById("header");
    
    window.addEventListener("scroll", () => {
      if (window.scrollY > 50) {
        header.classList.add("scrolled");
      } else {
        header.classList.remove("scrolled");
      }
    });

    console.log('💛 Meus Bilhetes - SC Rio Tinto');
    console.log('Total de bilhetes: <%= totalBilhetes %>');
  </script>
</body>
</html>
