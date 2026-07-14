<%--
    Document   : pedidos
    Created on : 06/12/2025, 11:07:51
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
    
    if (idUtilizador == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    if (isAdmin == null) {
        isAdmin = false;
    }
    
    // Verificar se o utilizador é sócio
    boolean jaSocio = false;
    String numeroSocio = null;
    String dataSocio = null;
    
    Connection connSocio = null;
    PreparedStatement pstmtSocio = null;
    ResultSet rsSocio = null;
    
    try {
        String dbURL = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
        String dbUser = "root";
        String dbPass = "";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        connSocio = DriverManager.getConnection(dbURL, dbUser, dbPass);
        
        String sqlSocio = "SELECT numero_socio, data_inscricao FROM t_socio WHERE id_utilizador = ?";
        pstmtSocio = connSocio.prepareStatement(sqlSocio);
        pstmtSocio.setInt(1, idUtilizador);
        rsSocio = pstmtSocio.executeQuery();
        
        if (rsSocio.next()) {
            jaSocio = true;
            numeroSocio = rsSocio.getString("numero_socio");
            dataSocio = rsSocio.getString("data_inscricao");
        }
        
    } catch (Exception e) {
        out.println("<!-- Erro ao verificar sócio: " + e.getMessage() + " -->");
    } finally {
        if (rsSocio != null) try { rsSocio.close(); } catch (SQLException e) {}
        if (pstmtSocio != null) try { pstmtSocio.close(); } catch (SQLException e) {}
        if (connSocio != null) try { connSocio.close(); } catch (SQLException e) {}
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Meus Pedidos - SC Rio Tinto</title>
    <link href="css/CssPedidos.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
</head>
<body>
    <!-- HEADER -->
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
                            <a href="meus-pedidos.jsp" class="dropdown-item" style="background: rgba(255, 215, 0, 0.1);">
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
                </li>
            </ul>
        </nav>
    </header>

    <!-- MAIN CONTENT -->
    <div class="main-container">
        <div class="page-header">
            <h1>MEUS <span class="highlight">PEDIDOS</span></h1>
            <p>Acompanha o estado das tuas encomendas em tempo real</p>
            
            <%
                // Estatísticas rápidas
                Connection connStats = null;
                PreparedStatement pstmtStats = null;
                ResultSet rsStats = null;
                
                int totalEncomendas = 0;
                int encomendasPendentes = 0;
                int encomendasEntregues = 0;
                
                try {
                    String dbURL = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
                    String dbUser = "root";
                    String dbPass = "";
                    
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    connStats = DriverManager.getConnection(dbURL, dbUser, dbPass);
                    
                    String sqlStats = "SELECT " +
                                     "COUNT(*) as total, " +
                                     "SUM(CASE WHEN estado = 'pendente' OR estado = 'processando' THEN 1 ELSE 0 END) as pendentes, " +
                                     "SUM(CASE WHEN estado = 'entregue' THEN 1 ELSE 0 END) as entregues " +
                                     "FROM t_encomendas WHERE id_utilizador = ?";
                    
                    pstmtStats = connStats.prepareStatement(sqlStats);
                    pstmtStats.setInt(1, idUtilizador);
                    rsStats = pstmtStats.executeQuery();
                    
                    if (rsStats.next()) {
                        totalEncomendas = rsStats.getInt("total");
                        encomendasPendentes = rsStats.getInt("pendentes");
                        encomendasEntregues = rsStats.getInt("entregues");
                    }
                } catch (Exception e) {
                } finally {
                    if (rsStats != null) try { rsStats.close(); } catch (SQLException e) {}
                    if (pstmtStats != null) try { pstmtStats.close(); } catch (SQLException e) {}
                    if (connStats != null) try { connStats.close(); } catch (SQLException e) {}
                }
            %>
            
            <div class="stats-bar">
                <div class="stat-item">
                    <div class="stat-number"><%= totalEncomendas %></div>
                    <div class="stat-label">📦 Total Pedidos</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><%= encomendasPendentes %></div>
                    <div class="stat-label">⏳ Em Processamento</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><%= encomendasEntregues %></div>
                    <div class="stat-label">✅ Entregues</div>
                </div>
            </div>
        </div>

        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                String dbURL = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
                String dbUser = "root";
                String dbPass = "";
                
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                
                // Query para buscar encomendas
                String sql = "SELECT " +
                            "e.id_encomenda, " +
                            "e.numero_encomenda, " +
                            "e.data_encomenda, " +
                            "e.data_atualizacao, " +
                            "e.estado, " +
                            "e.valor_total, " +
                            "e.morada_envio, " +
                            "e.metodo_pagamento, " +
                            "e.codigo_rastreio, " +
                            "e.observacoes " +
                            "FROM t_encomendas e " +
                            "WHERE e.id_utilizador = ? " +
                            "ORDER BY e.data_encomenda DESC";
                
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, idUtilizador);
                rs = pstmt.executeQuery();
                
                boolean temEncomendas = false;
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                
                while (rs.next()) {
                    temEncomendas = true;
                    int idEncomenda = rs.getInt("id_encomenda");
                    String numeroEncomenda = rs.getString("numero_encomenda");
                    Timestamp dataEncomenda = rs.getTimestamp("data_encomenda");
                    String estado = rs.getString("estado");
                    double valorTotal = rs.getDouble("valor_total");
                    String codigoRastreio = rs.getString("codigo_rastreio");
                    String moradaEnvio = rs.getString("morada_envio");
                    String metodoPagamento = rs.getString("metodo_pagamento");
                    
                    // Calcular IVA e subtotal
                    double valorSubtotal = valorTotal / 1.23;
                    double valorIva = valorTotal - valorSubtotal;
                    
                    String badgeClass = "badge-" + estado;
        %>
        
        <div class="encomenda-card">
            <div class="encomenda-header">
                <div class="encomenda-info">
                    <div class="info-item">
                        <span class="info-label">Encomenda</span>
                        <span class="info-value">#<%= numeroEncomenda != null ? numeroEncomenda : idEncomenda %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Data</span>
                        <span class="info-value"><%= sdf.format(dataEncomenda) %></span>
                    </div>
                </div>
                <span class="badge <%= badgeClass %>">
                    <%= estado.toUpperCase() %>
                </span>
            </div>

            <!-- TIMELINE DE PROGRESSO -->
            <div class="progress-timeline">
                <div class="timeline-title">📍 Rastreamento do Pedido</div>
                <div class="timeline-container">
                    <div class="timeline-line">
                        <div class="timeline-line-progress" style="width: <%= 
                            estado.equals("pendente") ? "0%" : 
                            estado.equals("comprado") ? "25%" : 
                            estado.equals("processando") ? "50%" : 
                            estado.equals("enviado") ? "75%" : 
                            estado.equals("entregue") ? "100%" : "0%" 
                        %>;"></div>
                    </div>

                    <!-- Pendente -->
                    <div class="timeline-step <%= 
                        estado.equals("pendente") ? "active" : 
                        (!estado.equals("pendente") ? "completed" : "") 
                    %>">
                        <div class="timeline-icon">
                            <%= estado.equals("pendente") ? "📋" : "" %>
                        </div>
                        <div class="timeline-label">
                            Pendente
                            <div class="timeline-date"><%= sdf.format(dataEncomenda) %></div>
                        </div>
                    </div>

                    <!-- Comprado -->
                    <div class="timeline-step <%= 
                        estado.equals("comprado") ? "active" : 
                        (estado.equals("processando") || estado.equals("enviado") || estado.equals("entregue") ? "completed" : "") 
                    %>">
                        <div class="timeline-icon">
                            <%= estado.equals("comprado") ? "💳" : "" %>
                        </div>
                        <div class="timeline-label">
                            Comprado
                            <% if (!estado.equals("pendente")) { %>
                                <div class="timeline-date">Pagamento confirmado</div>
                            <% } %>
                        </div>
                    </div>

                    <!-- Processando -->
                    <div class="timeline-step <%= 
                        estado.equals("processando") ? "active" : 
                        (estado.equals("enviado") || estado.equals("entregue") ? "completed" : "") 
                    %>">
                        <div class="timeline-icon">
                            <%= estado.equals("processando") ? "⚙️" : "" %>
                        </div>
                        <div class="timeline-label">
                            Processando
                            <% if (estado.equals("processando") || estado.equals("enviado") || estado.equals("entregue")) { %>
                                <div class="timeline-date">Em preparação</div>
                            <% } %>
                        </div>
                    </div>

                    <!-- Enviado -->
                    <div class="timeline-step <%= 
                        estado.equals("enviado") ? "active" : 
                        (estado.equals("entregue") ? "completed" : "") 
                    %>">
                        <div class="timeline-icon">
                            <%= estado.equals("enviado") ? "🚚" : "" %>
                        </div>
                        <div class="timeline-label">
                            Enviado
                            <% if (estado.equals("enviado") || estado.equals("entregue")) { %>
                                <div class="timeline-date">A caminho</div>
                            <% } %>
                        </div>
                    </div>

                    <!-- Entregue -->
                    <div class="timeline-step <%= estado.equals("entregue") ? "active completed" : "" %>">
                        <div class="timeline-icon">
                            <%= estado.equals("entregue") ? "🎉" : "" %>
                        </div>
                        <div class="timeline-label">
                            Entregue
                            <% if (estado.equals("entregue")) { %>
                                <div class="timeline-date">Concluído</div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>

            <div class="produtos-lista">
                <%
                    // Buscar produtos desta encomenda
                    PreparedStatement pstmtProdutos = null;
                    ResultSet rsProdutos = null;
                    
                    try {
                        String sqlProdutos = "SELECT " +
                                            "i.quantidade, " +
                                            "i.preco_unitario, " +
                                            "i.preco_total, " +
                                            "p.nome_produto, " +
                                            "p.imagem_principal " +
                                            "FROM t_itens_encomenda i " +
                                            "INNER JOIN t_produtos p ON i.id_produto = p.id_produto " +
                                            "WHERE i.id_encomenda = ?";
                        
                        pstmtProdutos = conn.prepareStatement(sqlProdutos);
                        pstmtProdutos.setInt(1, idEncomenda);
                        rsProdutos = pstmtProdutos.executeQuery();
                        
                        while (rsProdutos.next()) {
                            String nomeProduto = rsProdutos.getString("nome_produto");
                            int quantidade = rsProdutos.getInt("quantidade");
                            double precoUnitario = rsProdutos.getDouble("preco_unitario");
                            double precoTotal = rsProdutos.getDouble("preco_total");
                            String imagemProduto = rsProdutos.getString("imagem_principal");
                %>
                <div class="produto-item">
                    <div class="produto-imagem">
                        <% if (imagemProduto != null && !imagemProduto.isEmpty()) { %>
                            <img src="<%= imagemProduto %>" alt="<%= nomeProduto %>">
                        <% } else { %>
                            <i class="fas fa-tshirt" style="font-size: 2rem; color: var(--amarelo);"></i>
                        <% } %>
                    </div>
                    <div class="produto-detalhes">
                        <div class="produto-nome"><%= nomeProduto %></div>
                        <div class="produto-quantidade">Quantidade: <%= quantidade %> x <%= String.format("%.2f€", precoUnitario) %></div>
                    </div>
                    <div class="produto-preco">
                        <%= String.format("%.2f€", precoTotal) %>
                    </div>
                </div>
                <%
                        }
                    } finally {
                        if (rsProdutos != null) try { rsProdutos.close(); } catch (SQLException e) {}
                        if (pstmtProdutos != null) try { pstmtProdutos.close(); } catch (SQLException e) {}
                    }
                %>
            </div>

            <% if (codigoRastreio != null && !codigoRastreio.isEmpty()) { %>
            <div class="rastreio-info">
                <i class="fas fa-shipping-fast"></i>
                <div>
                    <div style="font-size: 0.9rem; opacity: 0.9;">Código de Rastreio</div>
                    <div class="rastreio-code"><%= codigoRastreio %></div>
                </div>
            </div>
            <% } %>

            <div class="encomenda-footer">
                <div class="total-encomenda">
                    Total: <span><%= String.format("%.2f€", valorTotal) %></span>
                </div>
                <button class="btn-detalhes" onclick="gerarFatura(<%= idEncomenda %>, '<%= numeroEncomenda != null ? numeroEncomenda : String.valueOf(idEncomenda) %>', '<%= sdf.format(dataEncomenda) %>', '<%= moradaEnvio.replace("'", "\\'").replace("\n", " ") %>', '<%= metodoPagamento %>', <%= valorSubtotal %>, <%= valorIva %>, <%= valorTotal %>)">
                    <i class="fas fa-file-pdf"></i>
                    Ver Fatura
                </button>
            </div>
        </div>

        <%
                }
                
                if (!temEncomendas) {
        %>
        <div class="empty-state">
            <i class="fas fa-shopping-bag"></i>
            <h2>Ainda não tens encomendas</h2>
            <p>Começa a explorar os nossos produtos oficiais do SC Rio Tinto!</p>
            <a href="Produtos.jsp" class="btn-primary">
                <i class="fas fa-store"></i>
                Ver Produtos
            </a>
        </div>
        <%
                }
                
            } catch (Exception e) {
                out.println("<div class='empty-state'>");
                out.println("<i class='fas fa-exclamation-triangle' style='color: #ff4444;'></i>");
                out.println("<h2>Erro ao carregar pedidos</h2>");
                out.println("<p>Ocorreu um erro: " + e.getMessage() + "</p>");
                out.println("</div>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        %>
    </div>

    <!-- Logo oculto para usar no PDF -->
    <img id="logo-clube" src="images/Logo SCRT.jpg" style="display: none;" crossorigin="anonymous">

    <script>
        // Scroll reveal animation
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);

        document.querySelectorAll('.encomenda-card').forEach(card => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(20px)';
            card.style.transition = 'all 0.6s ease';
            observer.observe(card);
        });
        
        // Função para gerar fatura em PDF
        function gerarFatura(idEncomenda, numEncomenda, data, morada, metodoPagamento, subtotal, iva, total) {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF();
            
            const amarelo = [255, 215, 0];
            const preto = [10, 10, 10];
            const cinza = [102, 102, 102];
            
            let y = 20;
            
            // TÍTULO
            doc.setFontSize(32);
            doc.setTextColor(...preto);
            doc.setFont('helvetica', 'bold');
            doc.text('FATURA', 20, y);
            
            // ADICIONAR LOGO DO CLUBE
            try {
                const logoImg = document.getElementById('logo-clube');
                if (logoImg && logoImg.complete) {
                    const canvas = document.createElement('canvas');
                    const ctx = canvas.getContext('2d');
                    canvas.width = logoImg.naturalWidth;
                    canvas.height = logoImg.naturalHeight;
                    ctx.drawImage(logoImg, 0, 0);
                    const logoData = canvas.toDataURL('image/jpeg');
                    
                    // Adicionar logo no canto superior direito (ajuste o tamanho conforme necessário)
                    doc.addImage(logoData, 'JPEG', 160, 10, 35, 35);
                }
            } catch (error) {
                console.error('Erro ao adicionar logo:', error);
            }
            
            y = 50;
            
            // DADOS DO CLUBE
            doc.setFontSize(10);
            doc.setFont('helvetica', 'bold');
            doc.setTextColor(...preto);
            doc.text('SC Rio Tinto', 20, y);
            y += 5;
            doc.setFont('helvetica', 'normal');
            doc.setTextColor(...cinza);
            doc.text('Rua do Clube, 123', 20, y);
            y += 5;
            doc.text('4435-123 Rio Tinto', 20, y);
            y += 5;
            doc.text('NIF: 123456789', 20, y);
            
            // DADOS DO CLIENTE
            y = 50;
            doc.setFont('helvetica', 'bold');
            doc.setTextColor(...preto);
            doc.text('COBRAR A:', 110, y);
            y += 5;
            doc.setFont('helvetica', 'normal');
            doc.setTextColor(...cinza);
            doc.text('<%= primeiroNome %> <%= ultimoNome %>', 110, y);
            y += 5;
            doc.text('<%= emailUtilizador %>', 110, y);
            y += 5;
            
            const moradaLinhas = doc.splitTextToSize(morada, 80);
            moradaLinhas.forEach(linha => {
                doc.text(linha, 110, y);
                y += 5;
            });
            
            // DETALHES
            y = 90;
            doc.setDrawColor(...amarelo);
            doc.setLineWidth(0.5);
            doc.line(20, y, 190, y);
            y += 8;
            
            doc.setFont('helvetica', 'bold');
            doc.setTextColor(...preto);
            doc.setFontSize(9);
            doc.text('FATURA #', 20, y);
            doc.text('DATA DA FATURA', 70, y);
            doc.text('MÉTODO PAGAMENTO', 120, y);
            y += 5;
            
            doc.setFont('helvetica', 'normal');
            doc.setTextColor(...cinza);
            doc.text('FT-' + String(idEncomenda).padStart(4, '0'), 20, y);
            doc.text(data, 70, y);
            doc.text(metodoPagamento.toUpperCase(), 120, y);
            
            y += 10;
            doc.setDrawColor(...amarelo);
            doc.line(20, y, 190, y);
            y += 10;
            
            // TABELA
            doc.setFont('helvetica', 'bold');
            doc.setTextColor(...preto);
            doc.text('QTD', 20, y);
            doc.text('DESCRIÇÃO', 40, y);
            doc.text('PREÇO UNIT.', 120, y);
            doc.text('VALOR', 170, y, { align: 'right' });
            
            y += 3;
            doc.setDrawColor(...cinza);
            doc.setLineWidth(0.3);
            doc.line(20, y, 190, y);
            y += 7;
            
            doc.setFont('helvetica', 'normal');
            doc.setTextColor(...cinza);
            doc.text('1', 20, y);
            doc.text('Produtos da encomenda #' + numEncomenda, 40, y);
            doc.text(subtotal.toFixed(2) + '€', 120, y);
            doc.text(subtotal.toFixed(2) + '€', 190, y, { align: 'right' });
            y += 12;
            
            doc.setDrawColor(...cinza);
            doc.line(20, y, 190, y);
            y += 10;
            
            // TOTAIS
            doc.setFont('helvetica', 'normal');
            doc.text('Subtotal', 120, y);
            doc.text(subtotal.toFixed(2) + '€', 190, y, { align: 'right' });
            y += 7;
            
            doc.text('IVA 23.0%', 120, y);
            doc.text(iva.toFixed(2) + '€', 190, y, { align: 'right' });
            y += 10;
            
            doc.setDrawColor(...amarelo);
            doc.setLineWidth(1);
            doc.line(120, y, 190, y);
            y += 8;
            
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(14);
            doc.setTextColor(...preto);
            doc.text('TOTAL', 120, y);
            doc.text(total.toFixed(2) + '€', 190, y, { align: 'right' });
            
            // RODAPÉ
            y = 270;
            doc.setFillColor(...amarelo);
            doc.rect(0, y, 210, 27, 'F');
            
            y += 8;
            doc.setFontSize(10);
            doc.setFont('helvetica', 'bold');
            doc.setTextColor(...preto);
            doc.text('TERMOS E CONDIÇÕES', 20, y);
            y += 6;
            
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(8);
            doc.text('Pagamento deve ser efetuado no prazo de 15 dias.', 20, y);
            y += 4;
            doc.text('NIB: PT50 0000 0000 0000 0000 0000 0', 20, y);
            
            doc.save('Fatura_FT-' + String(idEncomenda).padStart(4, '0') + '_SC_Rio_Tinto.pdf');
        }
    </script>
</body>
</html>