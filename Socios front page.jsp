<%--
    Document   : SociosFrontPage
    Created on : 23/10/2025, 20:14:55
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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
            // Configuração da base de dados - AJUSTAR CONFORME A SUA CONFIGURAÇÃO
            String dbURL = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
            String dbUser = "root";
            String dbPass = "";
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
            
            // Verificar se existe registo na tabela de sócios
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
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SC Rio Tinto - Torna-te Sócio</title>
  <link href="css/CssSocios.css" rel="stylesheet" type="text/css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">
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
                  <a href="admin/dashboard.jsp" class="dropdown-item">
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

  <!-- HERO SECTION -->
  <section class="hero" id="home">
    <div class="hero-content">
      <% if (jaSocio) { %>
        <!-- UTILIZADOR JÁ É SÓCIO -->
        <div class="ja-socio-alert">
          <div class="icon">🎉</div>
          <h2>Parabéns, <%= primeiroNome %>!</h2>
          <p>Já és oficialmente sócio do SC Rio Tinto</p>
          
          <div class="socio-info">
            <div class="socio-info-item">
              <i class="fas fa-id-card"></i>
              <span class="socio-info-label">Número de Sócio:</span>
              <span class="socio-info-value">#<%= numeroSocio %></span>
            </div>
            <div class="socio-info-item">
              <i class="fas fa-calendar-check"></i>
              <span class="socio-info-label">Membro desde:</span>
              <span class="socio-info-value"><%= dataSocio %></span>
            </div>
          </div>

          <p style="font-size: 1.1rem; margin-top: 2rem;">
            Obrigado por fazeres parte da nossa família! 💛🖤<br>
            Continua a apoiar o clube e desfruta de todos os benefícios exclusivos.
          </p>

          <div style="margin-top: 2rem; display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap;">
            <a href="cartao-socio.jsp" class="btn-hero btn-primary">
              <i class="fas fa-id-card"></i>
              Cartão de Sócio Digital
            </a>
            <a href="perfil.jsp" class="btn-hero btn-secondary">
              <i class="fas fa-user"></i>
              Ver Meu Perfil
            </a>
            <a href="#beneficios" class="btn-hero btn-secondary">
              <i class="fas fa-star"></i>
              Ver Benefícios
            </a>
          </div>
        </div>
      <% } else { %>
        <!-- UTILIZADOR AINDA NÃO É SÓCIO -->
        <div class="hero-badge">🤝 Junta-te à família</div>
        <h1>Torna-te <span class="highlight">Sócio</span></h1>
        <% if (estaLogado) { %>
          <p>Bem-vindo de volta, <%= primeiroNome %>! Pronto para fazer parte da maior família desportiva da região? 💛🖤</p>
        <% } else { %>
          <p>Faz parte da maior família desportiva da região. Mais de 75 anos de história, tradição e paixão esperam por ti! 💛🖤</p>
        <% } %>
        
        <div class="hero-stats">
          <div class="stat-item">
            <span class="stat-number">1923</span>
            <span class="stat-label">Fundação</span>
          </div>
          <div class="stat-item">
            <span class="stat-number">2000+</span>
            <span class="stat-label">Sócios</span>
          </div>
          <div class="stat-item">
            <span class="stat-number">100+</span>
            <span class="stat-label">Anos História</span>
          </div>
        </div>
        
        <div class="hero-buttons">
          <% if (estaLogado) { %>
            <a href="formulario_socio.jsp" class="btn-hero btn-primary">
              <i class="fas fa-pen"></i>
              Reserva já o teu Lugar!
            </a>
          <% } else { %>
            <a href="Login.jsp" class="btn-hero btn-primary" onclick="alert('Por favor, inicia sessão para te tornares sócio!'); return true;">
              <i class="fas fa-sign-in-alt"></i>
              Iniciar Sessão para Continuar
            </a>
          <% } %>
          <a href="#beneficios" class="btn-hero btn-secondary">
            <i class="fas fa-star"></i>
            Benefícios
          </a>
        </div>
      <% } %>
    </div>
  </section>

  <!-- BENEFITS SECTION -->
  <section class="benefits-section" id="beneficios">
    <div class="benefits-container">
      <div class="section-title fade-in">
        <h2>Benefícios Exclusivos</h2>
        <p>Ser sócio do SC Rio Tinto é muito mais do que apoiar uma equipa. É fazer parte de uma comunidade única.</p>
      </div>
      
      <div class="benefits-grid">
        <div class="benefit-card slide-up">
          <div class="benefit-icon">
            <i class="fas fa-ticket-alt"></i>
          </div>
          <h3>Acesso aos Jogos</h3>
          <p>Descontos especiais em bilhetes para todos os jogos em casa e acesso prioritário à compra.</p>
        </div>
        
        <div class="benefit-card slide-up">
          <div class="benefit-icon">
            <i class="fas fa-tshirt"></i>
          </div>
          <h3>Descontos na Loja</h3>
          <p>15% de desconto em todos os produtos oficiais do clube, merchandising e equipamentos.</p>
        </div>
        
        <div class="benefit-card slide-up">
          <div class="benefit-icon">
            <i class="fas fa-calendar-check"></i>
          </div>
          <h3>Eventos Exclusivos</h3>
          <p>Convites para apresentações de equipas, jantares de gala e encontros com jogadores e staff técnico.</p>
        </div>
        
        <div class="benefit-card slide-up">
          <div class="benefit-icon">
            <i class="fas fa-newspaper"></i>
          </div>
          <h3>Informação Privilegiada</h3>
          <p>Acesso antecipado a todas as novidades, transferências e informações internas do clube.</p>
        </div>
        
        <div class="benefit-card slide-up">
          <div class="benefit-icon">
            <i class="fas fa-handshake"></i>
          </div>
          <h3>Rede de Contactos</h3>
          <p>Faz parte de uma comunidade ativa com mais de 2500 sócios, criando laços e amizades para toda a vida.</p>
        </div>
        
        <div class="benefit-card slide-up">
          <div class="benefit-icon">
            <i class="fas fa-trophy"></i>
          </div>
          <h3>História e Tradição</h3>
          <p>Contribui para manter viva a tradição e história de mais de 75 anos do nosso querido clube.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- FOOTER -->
  <footer>
    <div class="footer-content">
      <div class="social-links">
        <a href="https://www.instagram.com/sportcluberiotinto/" target="_blank">
          <i class="fab fa-instagram"></i>
        </a>
      </div>
      <p>&copy; 2025 SC Rio Tinto. Todos os direitos reservados.</p>
      <p>Feito com <span style="color: var(--amarelo);">💛</span> para a nossa família</p>
      <p style="margin-top: 1rem; color: #666; font-size: 0.9rem;">
        Desenvolvido com paixão pelo clube
      </p>
    </div>
  </footer>

  <!-- SCRIPTS -->
  <script>
    // HEADER SCROLL EFFECT
    const header = document.getElementById("header");
    window.addEventListener("scroll", () => {
      header.classList.toggle("scrolled", window.scrollY > 50);
    });

    // SMOOTH SCROLL
    function scrollToSection(sectionId) {
      const element = document.getElementById(sectionId);
      if (element) {
        element.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    }

    // SMOOTH SCROLL PARA LINKS
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
          target.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          });
        }
      });
    });

    // FADE IN ANIMATION ON SCROLL
    const observerOptions = {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
        }
      });
    }, observerOptions);

    document.querySelectorAll('.fade-in, .slide-up').forEach(el => {
      observer.observe(el);
    });

    // CONTADOR ANIMADO NAS ESTATÍSTICAS
    function animateCounters() {
      const counters = document.querySelectorAll('.stat-number');
      
      counters.forEach(counter => {
        const target = parseInt(counter.textContent.replace(/\D/g, ''));
        const increment = target / 100;
        let current = 0;
        
        const updateCounter = () => {
          if (current < target) {
            current += increment;
            if (counter.textContent.includes('+')) {
              counter.textContent = Math.floor(current) + '+';
            } else {
              counter.textContent = Math.floor(current);
            }
            requestAnimationFrame(updateCounter);
          } else {
            counter.textContent = counter.textContent.includes('+') ? target + '+' : target;
          }
        };
        
        updateCounter();
      });
    }

    // INICIA CONTADORES QUANDO A SEÇÃO HERO É VISÍVEL
    const heroObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          animateCounters();
          heroObserver.unobserve(entry.target);
        }
      });
    });

    const heroStats = document.querySelector('.hero-stats');
    if (heroStats) {
      heroObserver.observe(heroStats);
    }

    // ANIMAÇÃO DOS ÍCONES DOS BENEFÍCIOS
    document.querySelectorAll('.benefit-card').forEach(card => {
      card.addEventListener('mouseenter', function() {
        const icon = this.querySelector('.benefit-icon');
        if (icon) {
          icon.style.transform = 'scale(1.2) rotate(10deg)';
          icon.style.boxShadow = '0 15px 40px rgba(255, 215, 0, 0.5)';
        }
      });
      
      card.addEventListener('mouseleave', function() {
        const icon = this.querySelector('.benefit-icon');
        if (icon) {
          icon.style.transform = 'scale(1)';
          icon.style.boxShadow = '0 8px 25px rgba(255, 215, 0, 0.3)';
        }
      });
    });

    // PARALLAX EFFECT NO HERO
    window.addEventListener('scroll', () => {
      const scrolled = window.pageYOffset;
      const parallax = document.querySelector('.hero');
      const speed = scrolled * 0.3;
      if (parallax) {
        parallax.style.transform = `translateY(${speed}px)`;
      }
    });

    // SCROLL PROGRESS INDICATOR
    const scrollProgress = document.createElement('div');
    scrollProgress.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      width: 0%;
      height: 4px;
      background: linear-gradient(90deg, var(--amarelo), var(--amarelo-hover));
      z-index: 3000;
      transition: width 0.1s ease;
    `;
    document.body.appendChild(scrollProgress);

    window.addEventListener('scroll', () => {
      const scrolled = (window.scrollY / (document.documentElement.scrollHeight - window.innerHeight)) * 100;
      scrollProgress.style.width = scrolled + '%';
    });

    console.log('🎯 SC Rio Tinto - Página de Sócios carregada com sucesso!');
    console.log('💛 Força Rio Tinto! 💛');
  </script>
</body>
</html>