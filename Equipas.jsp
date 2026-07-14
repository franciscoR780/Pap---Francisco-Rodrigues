<%--
    Document   : Equipas
    Created on : 10/12/2025, 10:00:53
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
%>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SC Rio Tinto - Nossas Equipas</title>
    <link href="css/CssEquipas.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>

<body>
    <!-- FLOATING PARTICLES -->
    <div class="particles">
        <div class="particle" style="left: 10%; animation-delay: 0s;"></div>
        <div class="particle" style="left: 20%; animation-delay: 1s;"></div>
        <div class="particle" style="left: 30%; animation-delay: 2s;"></div>
        <div class="particle" style="left: 40%; animation-delay: 3s;"></div>
        <div class="particle" style="left: 50%; animation-delay: 4s;"></div>
        <div class="particle" style="left: 60%; animation-delay: 2.5s;"></div>
        <div class="particle" style="left: 70%; animation-delay: 1.5s;"></div>
        <div class="particle" style="left: 80%; animation-delay: 3.5s;"></div>
        <div class="particle" style="left: 90%; animation-delay: 0.5s;"></div>
    </div>

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
                                    <span class="socio-badge">SÓCIO</span>
                                <% } %>
                                <i class="fas fa-chevron-down" style="font-size: 0.8rem;"></i>
                            </button>
                            <div class="dropdown-menu">
                                <div class="dropdown-header">
                                    <div class="user-name">
                                        <%= primeiroNome %> <%= ultimoNome %>
                                        <% if (jaSocio) { %>
                                            <span class="socio-badge">SÓCIO</span>
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
        <div class="page-header">
            <h1>
                <% if (estaLogado) { %>
                    Bem-vindo, <span class="highlight"><%= primeiroNome %></span>
                <% } else { %>
                    Nossas <span class="highlight">Equipas</span>
                <% } %>
            </h1>
            
            <p class="subtitle">O orgulho e tradição do nosso clube em cada equipa</p>
        </div>

        <%
            int num = 0;
            int totalEquipas = 0;
            Connection conn = null;
            Statement stmt = null;
            Statement stmtCount = null;
            ResultSet rs = null;
            ResultSet rsCount = null;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC", 
                    "root", 
                    ""
                );
                
                stmtCount = conn.createStatement();
                rsCount = stmtCount.executeQuery("SELECT COUNT(*) as total FROM t_equipas");
                if (rsCount.next()) {
                    totalEquipas = rsCount.getInt("total");
                }
        %>

        <div class="stats-bar">
            <div class="stat-item">
                <span class="stat-number"><%= totalEquipas %></span>
                <span class="stat-label">Equipas Ativas</span>
            </div>
            
            <div class="stat-item">
                <span class="stat-number">100%</span>
                <span class="stat-label">Dedicação</span>
            </div>
            
            <div class="stat-item">
                <span class="stat-number">SC</span>
                <span class="stat-label">Rio Tinto</span>
            </div>
        </div>

        <div class="equipas-grid">
            <%
                stmt = conn.createStatement();
                rs = stmt.executeQuery("SELECT * FROM t_equipas ORDER BY categoria, nome_equipa");
                
                while (rs.next()) {
                    num++;
                    int idEquipa = rs.getInt("id_equipa");
                    String nomeEquipa = rs.getString("nome_equipa");
                    String categoria = rs.getString("categoria");
                    String temporada = rs.getString("temporada");
                    java.sql.Date dataCriacao = rs.getDate("data_criacao");
                    
                    String icone = "fa-shield-halved";
                    if (categoria != null) {
                        String catLower = categoria.toLowerCase();
                        if (catLower.contains("seniores") || catLower.contains("senior")) {
                            icone = "fa-trophy";
                        } else if (catLower.contains("juvenis") || catLower.contains("juniores")) {
                            icone = "fa-medal";
                        } else if (catLower.contains("infantis") || catLower.contains("iniciados")) {
                            icone = "fa-futbol";
                        } else if (catLower.contains("benjamins") || catLower.contains("petizes")) {
                            icone = "fa-shield";
                        } else if (catLower.contains("feminino") || catLower.contains("feminina")) {
                            icone = "fa-venus";
                        }
                    }
            %>
            
            <a href="Jogadores.jsp?id_equipa=<%= idEquipa %>" class="equipa-card">
                <div class="equipa-header">
                    <div class="equipa-icon">
                        <i class="fas <%= icone %>"></i>
                    </div>
                    <div class="equipa-nome"><%= nomeEquipa != null ? nomeEquipa : "Nome não definido" %></div>
                    <div class="equipa-categoria"><%= categoria != null ? categoria : "Categoria não definida" %></div>
                </div>
                
                <div class="equipa-body">
                    <div class="equipa-info">
                        <div class="info-row">
                            <div class="info-icon">
                                <i class="fas fa-calendar-alt"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Temporada</div>
                                <div class="info-value"><%= temporada != null ? temporada : "N/A" %></div>
                            </div>
                        </div>
                        
                        <div class="info-row">
                            <div class="info-icon">
                                <i class="fas fa-clock"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Data de Criação</div>
                                <div class="info-value"><%= dataCriacao != null ? dataCriacao.toString() : "N/A" %></div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="equipa-action">
                    VER PLANTEL
                    <i class="fas fa-arrow-right"></i>
                </div>
            </a>
            
            <%
                }
            %>
        </div>

        <%
            } catch (Exception e) { 
        %>
            <div class="error-message">
                <i class="fas fa-exclamation-triangle"></i><br><br>
                Ocorreu um erro ao carregar as equipas:<br>
                <%= e.getMessage() %>
            </div>
        <%
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (rsCount != null) rsCount.close();
                    if (stmt != null) stmt.close();
                    if (stmtCount != null) stmtCount.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    out.println("<div class='error-message'>Erro ao fechar conexão: " + e.getMessage() + "</div>");
                }
            }
        %>
    </div>

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
        const cards = document.querySelectorAll('.equipa-card');
        cards.forEach((card, index) => {
            card.style.animationDelay = `${index * 0.1}s`;
        });

        // Parallax effect for page header
        window.addEventListener('scroll', () => {
            const scrolled = window.pageYOffset;
            const header = document.querySelector('.page-header');
            if (header) {
                header.style.transform = `translateY(${scrolled * 0.4}px)`;
                header.style.opacity = 1 - (scrolled * 0.0015);
            }
        });

        // Counter animation for stats
        const animateCounter = (element, target) => {
            let current = 0;
            const increment = target / 60;
            const timer = setInterval(() => {
                current += increment;
                if (current >= target) {
                    element.textContent = target;
                    clearInterval(timer);
                } else {
                    element.textContent = Math.floor(current);
                }
            }, 20);
        };

        // Intersection Observer for stats animation
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const statNumber = entry.target.querySelector('.stat-number');
                    if (statNumber && !isNaN(statNumber.textContent)) {
                        const target = parseInt(statNumber.textContent);
                        statNumber.textContent = '0';
                        animateCounter(statNumber, target);
                        observer.unobserve(entry.target);
                    }
                }
            });
        }, { threshold: 0.5 });

        document.querySelectorAll('.stat-item').forEach(stat => {
            observer.observe(stat);
        });

        // 3D tilt effect on cards
        cards.forEach(card => {
            card.addEventListener('mousemove', (e) => {
                const rect = card.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;
                
                const centerX = rect.width / 2;
                const centerY = rect.height / 2;
                
                const rotateX = (y - centerY) / 20;
                const rotateY = (centerX - x) / 20;
                
                card.style.transform = `translateY(-20px) scale(1.03) rotateX(${rotateX}deg) rotateY(${rotateY}deg)`;
            });
            
            card.addEventListener('mouseleave', () => {
                card.style.transform = '';
            });
        });

        // Random particle animation delays
        document.querySelectorAll('.particle').forEach(particle => {
            const randomDelay = Math.random() * 8;
            const randomDuration = 6 + Math.random() * 4;
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
            card.style.transform = 'translateY(50px)';
            card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            revealObserver.observe(card);
        });

        console.log('🚀 SC Rio Tinto - Equipas Revolucionadas carregadas com sucesso!');
    </script>
</body>
</html>