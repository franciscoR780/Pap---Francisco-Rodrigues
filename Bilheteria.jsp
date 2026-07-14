<%--
    Document   : Bilheteria
    Created on : 21/10/2025, 16:42:08
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    // Verificar sessão
    Integer idUtilizador = (Integer) session.getAttribute("id_utilizador");
    String primeiroNome = (String) session.getAttribute("primeiro_nome");
    String ultimoNome = (String) session.getAttribute("ultimo_nome");
    String emailUtilizador = (String) session.getAttribute("email");
    Boolean isAdmin = (Boolean) session.getAttribute("is_admin");
    
    if (isAdmin == null) isAdmin = false;
    boolean estaLogado = (idUtilizador != null);
    
    // Verificar se é sócio
    boolean jaSocio = false;
    String numeroSocio = null;
    
    if (estaLogado) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connSocio = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
            PreparedStatement pstmt = connSocio.prepareStatement(
                "SELECT numero_socio FROM t_socio WHERE id_utilizador = ?");
            pstmt.setInt(1, idUtilizador);
            ResultSet rsSocio = pstmt.executeQuery();
            
            if (rsSocio.next()) {
                jaSocio = true;
                numeroSocio = rsSocio.getString("numero_socio");
            }
            
            rsSocio.close();
            pstmt.close();
            connSocio.close();
        } catch (Exception e) {
            out.println("<!-- Erro ao verificar sócio: " + e.getMessage() + " -->");
        }
    }

    // ============================================================
    // ATUALIZAÇÃO AUTOMÁTICA DE ESTADOS COM BASE NAS DATAS
    // ============================================================
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection connUpdate = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");

        // Abrir venda quando chegou a data de abertura (e ainda não passou a data de fecho)
        PreparedStatement pstmtAbrir = connUpdate.prepareStatement(
            "UPDATE t_eventos SET estado_evento = 'venda_aberta' " +
            "WHERE estado_evento = 'agendado' " +
            "AND data_abertura_venda <= NOW() " +
            "AND data_fecho_venda >= NOW()");
        pstmtAbrir.executeUpdate();
        pstmtAbrir.close();

        // Fechar venda quando passou a data de fecho
        PreparedStatement pstmtFechar = connUpdate.prepareStatement(
            "UPDATE t_eventos SET estado_evento = 'concluido' " +
            "WHERE estado_evento = 'venda_aberta' " +
            "AND data_fecho_venda < NOW()");
        pstmtFechar.executeUpdate();
        pstmtFechar.close();

        // Marcar como esgotado se bilhetes_vendidos >= capacidade_total
        PreparedStatement pstmtEsgotar = connUpdate.prepareStatement(
            "UPDATE t_eventos SET estado_evento = 'esgotado' " +
            "WHERE estado_evento = 'venda_aberta' " +
            "AND bilhetes_vendidos >= capacidade_total");
        pstmtEsgotar.executeUpdate();
        pstmtEsgotar.close();

        connUpdate.close();
    } catch (Exception e) {
        out.println("<!-- Erro ao atualizar estados: " + e.getMessage() + " -->");
    }
    // ============================================================
    
    // Filtros
    String filtroCompetição = request.getParameter("competicao");
    String filtroEstado = request.getParameter("estado");
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bilheteira - SC Rio Tinto</title>
    <link href="css/CssBilheteria.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>
<body>
    <!-- BACKGROUND LAYER PARA CROSSFADE -->
    <div class="background-layer"></div>

    <!-- FLOATING PARTICLES - MAIS INTENSOS -->
    <div class="particles">
        <div class="particle" style="left: 5%; animation-delay: 0s;"></div>
        <div class="particle" style="left: 15%; animation-delay: 1.2s;"></div>
        <div class="particle" style="left: 25%; animation-delay: 2.4s;"></div>
        <div class="particle" style="left: 35%; animation-delay: 3.6s;"></div>
        <div class="particle" style="left: 45%; animation-delay: 4.8s;"></div>
        <div class="particle" style="left: 55%; animation-delay: 3s;"></div>
        <div class="particle" style="left: 65%; animation-delay: 1.8s;"></div>
        <div class="particle" style="left: 75%; animation-delay: 4.2s;"></div>
        <div class="particle" style="left: 85%; animation-delay: 0.6s;"></div>
        <div class="particle" style="left: 95%; animation-delay: 2.6s;"></div>
    </div>

    <!-- LASER GRID -->
    <div class="laser-grid"></div>

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

    <div class="container">
        <!-- PAGE HERO -->
        <div class="page-hero">
            <h1 class="hero-title">
                <span class="icon"><i class="fas fa-ticket-alt"></i></span>
                <span class="highlight">BILHETEIRA</span> OFICIAL
            </h1>
            <p class="hero-subtitle">Garante o teu lugar e vem apoiar o SC Rio Tinto no estádio!</p>
        </div>

        <!-- FILTROS -->
        <div class="filtros-section">
            <h3>
                <i class="fas fa-filter"></i>
                Filtrar Eventos
            </h3>
            <form method="GET" action="Bilheteria.jsp">
                <div class="filtros-grid">
                    <div class="filtro-item">
                        <label>Competição</label>
                        <select name="competicao">
                            <option value="">Todas as Competições</option>
                            <%
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    Connection connComp = DriverManager.getConnection(
                                        "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                                    Statement stmtComp = connComp.createStatement();
                                    ResultSet rsComp = stmtComp.executeQuery(
                                        "SELECT DISTINCT competicao FROM t_eventos WHERE competicao IS NOT NULL ORDER BY competicao");
                                    
                                    while (rsComp.next()) {
                                        String comp = rsComp.getString("competicao");
                                        String selected = (comp.equals(filtroCompetição)) ? "selected" : "";
                            %>
                                        <option value="<%= comp %>" <%= selected %>><%= comp %></option>
                            <%
                                    }
                                    rsComp.close();
                                    stmtComp.close();
                                    connComp.close();
                                } catch (Exception e) {
                                    out.println("<!-- Erro: " + e.getMessage() + " -->");
                                }
                            %>
                        </select>
                    </div>

                    <div class="filtro-item">
                        <label>Estado</label>
                        <select name="estado">
                            <option value="">Todos os Estados</option>
                            <option value="venda_aberta" <%= "venda_aberta".equals(filtroEstado) ? "selected" : "" %>>Venda Aberta</option>
                            <option value="agendado" <%= "agendado".equals(filtroEstado) ? "selected" : "" %>>Agendado</option>
                            <option value="esgotado" <%= "esgotado".equals(filtroEstado) ? "selected" : "" %>>Esgotado</option>
                        </select>
                    </div>

                    <button type="submit" class="btn-filtrar">
                        <i class="fas fa-search"></i>
                        FILTRAR
                    </button>
                </div>
            </form>
        </div>

        <!-- EVENTOS GRID -->
        <div class="eventos-grid">
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", "root", "");
                    
                    // Construir query com filtros
                    StringBuilder sql = new StringBuilder(
                        "SELECT e.*, " +
                        "ec.nome_equipa AS equipa_casa, " +
                        "ef.nome_equipa AS equipa_fora " +
                        "FROM t_eventos e " +
                        "INNER JOIN t_equipas ec ON e.id_equipa_casa = ec.id_equipa " +
                        "LEFT JOIN t_equipas ef ON e.id_equipa_fora = ef.id_equipa " +
                        "WHERE e.data_evento >= NOW() ");
                    
                    if (filtroCompetição != null && !filtroCompetição.isEmpty()) {
                        sql.append("AND e.competicao = ? ");
                    }
                    if (filtroEstado != null && !filtroEstado.isEmpty()) {
                        sql.append("AND e.estado_evento = ? ");
                    }
                    
                    sql.append("ORDER BY e.data_evento ASC");
                    
                    PreparedStatement pstmt = conn.prepareStatement(sql.toString());
                    
                    int paramIndex = 1;
                    if (filtroCompetição != null && !filtroCompetição.isEmpty()) {
                        pstmt.setString(paramIndex++, filtroCompetição);
                    }
                    if (filtroEstado != null && !filtroEstado.isEmpty()) {
                        pstmt.setString(paramIndex++, filtroEstado);
                    }
                    
                    ResultSet rs = pstmt.executeQuery();
                    
                    SimpleDateFormat sdfData = new SimpleDateFormat("dd/MM/yyyy");
                    SimpleDateFormat sdfHora = new SimpleDateFormat("HH:mm");
                    
                    boolean temEventos = false;
                    
                    while (rs.next()) {
                        temEventos = true;
                        
                        int idEvento = rs.getInt("id_evento");
                        String nomeEvento = rs.getString("nome_evento");
                        String equipaCasa = rs.getString("equipa_casa");
                        String equipaFora = rs.getString("equipa_fora");
                        String localEvento = rs.getString("local_evento");
                        Timestamp dataEvento = rs.getTimestamp("data_evento");
                        String competicao = rs.getString("competicao");
                        String jornada = rs.getString("jornada");
                        int capacidade = rs.getInt("capacidade_total");
                        int vendidos = rs.getInt("bilhetes_vendidos");
                        double precoNormal = rs.getDouble("preco_normal");
                        double precoSocio = rs.getDouble("preco_socio");
                        double precoEstudante = rs.getDouble("preco_estudante");
                        double precoCrianca = rs.getDouble("preco_crianca");
                        String estadoEvento = rs.getString("estado_evento");
                        
                        int disponiveis = capacidade - vendidos;
                        boolean esgotado = disponiveis <= 0 || "esgotado".equals(estadoEvento);
                        boolean vendaAberta = "venda_aberta".equals(estadoEvento);
                        
                        String badgeText = "";
                        if (esgotado) {
                            badgeText = "🚫 ESGOTADO";
                        } else if (vendaAberta) {
                            badgeText = "🎫 VENDA ABERTA";
                        } else {
                            badgeText = "⏳ BREVEMENTE";
                        }
            %>
                        <div class="evento-card">
                            <div class="evento-header">
                                <div class="evento-badge"><%= badgeText %></div>
                                <h3 class="evento-title"><%= nomeEvento %></h3>
                                
                                <div class="evento-info">
                                    <i class="fas fa-calendar-alt"></i>
                                    <%= sdfData.format(dataEvento) %> às <%= sdfHora.format(dataEvento) %>
                                </div>
                                <div class="evento-info">
                                    <i class="fas fa-map-marker-alt"></i>
                                    <%= localEvento %>
                                </div>
                                <% if (competicao != null) { %>
                                <div class="evento-info">
                                    <i class="fas fa-trophy"></i>
                                    <%= competicao %><%= jornada != null ? " - " + jornada : "" %>
                                </div>
                                <% } %>
                            </div>
                            
                            <div class="evento-body">
                                <div class="precos-grid">
                                    <div class="preco-item">
                                        <div class="preco-label">Normal</div>
                                        <div class="preco-valor"><%= String.format("%.2f€", precoNormal) %></div>
                                    </div>
                                    <div class="preco-item">
                                        <div class="preco-label">Sócio</div>
                                        <div class="preco-valor"><%= String.format("%.2f€", precoSocio) %></div>
                                    </div>
                                    <div class="preco-item">
                                        <div class="preco-label">Estudante</div>
                                        <div class="preco-valor"><%= String.format("%.2f€", precoEstudante) %></div>
                                    </div>
                                    <div class="preco-item">
                                        <div class="preco-label">Criança</div>
                                        <div class="preco-valor"><%= String.format("%.2f€", precoCrianca) %></div>
                                    </div>
                                </div>
                                
                                <div class="bilhetes-info">
                                    <strong> Disponibilidade:</strong>
                                    <% if (esgotado) { %>
                                        <span class="bilhetes-esgotado">ESGOTADO</span>
                                    <% } else { %>
                                        <span class="bilhetes-disponivel">
                                             <%= disponiveis %> de <%= capacidade %> bilhetes disponíveis
                                        </span>
                                    <% } %>
                                </div>
                                
                                <% if (vendaAberta && !esgotado) { %>
                                    <button class="btn-comprar" onclick="window.location.href='comprarBilhete.jsp?id_evento=<%= idEvento %>'">
                                        <i class="fas fa-shopping-cart"></i>
                                        COMPRAR BILHETES
                                    </button>
                                <% } else { %>
                                    <button class="btn-comprar" disabled>
                                        <i class="fas fa-lock"></i>
                                        <%= esgotado ? "ESGOTADO" : "VENDA AINDA NÃO ABRIU" %>
                                    </button>
                                <% } %>
                            </div>
                        </div>
            <%
                    }
                    
                    if (!temEventos) {
            %>
                        <div class="sem-eventos">
                            <i class="fas fa-calendar-times"></i>
                            <h3>Nenhum Evento Encontrado</h3>
                            <p>De momento não existem eventos disponíveis com os filtros selecionados.</p>
                        </div>
            <%
                    }
                    
                    rs.close();
                    pstmt.close();
                    conn.close();
                    
                } catch (Exception e) {
                    out.println("<div class='sem-eventos'>");
                    out.println("<i class='fas fa-exclamation-triangle'></i>");
                    out.println("<h3>Erro ao Carregar Eventos</h3>");
                    out.println("<p>Ocorreu um erro: " + e.getMessage() + "</p>");
                    out.println("</div>");
                }
            %>
        </div>
    </div>

    <!-- FOOTER -->
    <footer>
        <div class="footer-content">
            <div class="social-links">
      <a href="https://www.instagram.com/sportcluberiotinto/" title="Instagram"><i class="fab fa-instagram"></i></a>
    </div>
            <p>&copy; 2025 SC Rio Tinto. Todos os direitos reservados.</p>
            <p>Feito com <span style="color: var(--amarelo);">💛</span> para os verdadeiros adeptos</p>
        </div>
    </footer>

    <script>
        // Header scroll effect
        const header = document.getElementById("header");
        let lastScrollY = window.scrollY;
        
        window.addEventListener("scroll", () => {
            const currentScrollY = window.scrollY;
            
            if (currentScrollY > 50) {
                header.classList.add("scrolled");
            } else {
                header.classList.remove("scrolled");
            }
            
            lastScrollY = currentScrollY;
        });

        // Stagger animation for cards
        const cards = document.querySelectorAll('.evento-card');
        cards.forEach((card, index) => {
            card.style.animationDelay = `${index * 0.15}s`;
        });

        // 3D tilt effect on evento cards
        cards.forEach(card => {
            card.addEventListener('mousemove', (e) => {
                const rect = card.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;
                
                const centerX = rect.width / 2;
                const centerY = rect.height / 2;
                
                const rotateX = (y - centerY) / 25;
                const rotateY = (centerX - x) / 25;
                
                card.style.transform = `translateY(-25px) scale(1.04) rotateX(${rotateX}deg) rotateY(${rotateY}deg)`;
            });
            
            card.addEventListener('mouseleave', () => {
                card.style.transform = '';
            });
        });

        // Parallax effect for page hero
        window.addEventListener('scroll', () => {
            const scrolled = window.pageYOffset;
            const hero = document.querySelector('.page-hero');
            if (hero) {
                hero.style.transform = `translateY(${scrolled * 0.5}px)`;
                hero.style.opacity = 1 - (scrolled * 0.002);
            }
        });

        // Random particle animation delays
        document.querySelectorAll('.particle').forEach(particle => {
            const randomDelay = Math.random() * 10;
            const randomDuration = 8 + Math.random() * 4;
            particle.style.animationDelay = `${randomDelay}s`;
            particle.style.animationDuration = `${randomDuration}s`;
        });

        // Smooth reveal on scroll
        const revealObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, { threshold: 0.1 });

        cards.forEach(card => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(60px)';
            card.style.transition = 'opacity 0.8s ease, transform 0.8s ease';
            revealObserver.observe(card);
        });

        // Pulsating effect on "comprar" buttons
        const btnComprar = document.querySelectorAll('.btn-comprar:not(:disabled)');
        btnComprar.forEach(btn => {
            setInterval(() => {
                btn.style.transform = 'scale(1.02)';
                setTimeout(() => {
                    btn.style.transform = 'scale(1)';
                }, 150);
            }, 3000);
        });

        console.log('🎫 Bilheteira SC Rio Tinto - DESIGN ULTRA PREMIUM carregado!');
        console.log('💛 Força Rio Tinto! 💛');
        console.log('🚀 Design Revolucionário Ativado!');
    </script>
</body>
</html>
